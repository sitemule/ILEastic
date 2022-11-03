/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*INHERIT) */
/* ------------------------------------------------------------- */
/* Date  . . . . : 14.09.2014                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Base utilies  - Memory manager                */
/*                                                               */
/* debug by:                                                     */
/*                                                               */
/*   QIBM_MALLOC_TYPE=DEBUG                                      */
/*                                                               */
/* See more at:                                                  */
/*   https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_71/rtref/debug_memory_manager.htm  */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     14.09.2014         New program                         */
/* ------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mallocinfo.h>

#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "ostypes.h"
#include "teramem.h"

static INT64 used = 0;
static INT64 allocated = 0;
static INT64 deallocated = 0;
static INT64 balance = 0;
static INT64 limit   = (5.0 * 1000.0 * 1000.0);
static BOOL  debug   = true;

// -------------------------------------------------------------
PVOID memAlloc (UINT64 len)
{
    UINT64 totlen = len + sizeof(MEMHDR);
    UINT64 used;
    _C_mallinfo_t info;
    int           rc;
    PMEMHDR mem =  _C_TS_malloc64(totlen);

    #ifdef MEMDEBUG
    if (debug) {
        rc = _C_TS_malloc_debug(_C_DUMP_TOTALS,
                                _C_NO_CHECKS,
                                &info, sizeof(info));
    }
    #endif

    // Debugging !!!
    if (mem == NULL ) {
       #ifdef MEMDEBUG
          printf("Out of memory, NULL returned from malloc : Usage : %lld \n", balance);
       #endif
       return NULL;
    }

    mem->signature = MEMSIG;
    mem->size      = len;

    allocated  += totlen;
    balance    += totlen;

    // Debugging !!!
    #ifdef MEMDEBUG
       if (balance  > limit ) {
          sleep(10); // Slow down to let us debug
       }
    #endif

    return (PUCHAR) mem + sizeof(MEMHDR);

}
// -------------------------------------------------------------
PVOID memCalloc (UINT64 len) 
{
   PVOID mem= memAlloc (len);
   memset( mem , '\0', len);
   return mem;
}
// -------------------------------------------------------------
void memFree (PVOID * pp)
{
   PUCHAR p;
   PMEMHDR mem;
   UINT64 totlen;

   if (pp == NULL) {
      #ifdef MEMDEBUG
         printf("Free null pointer pointer\n");
      #endif
      return;
   }
   p = (PUCHAR) *pp;
   if (p  == NULL) {
      // printf("Free null pointer\n");
      return;
   }
   mem = (PMEMHDR) (p - sizeof(MEMHDR)) ;
   if (mem->signature != MEMSIG ) {
      #ifdef MEMDEBUG
         printf("Free non valid memory\n");
      #endif
      return;
   }
   mem->signature = 0; // Enusre that we release the signature
   totlen = mem->size + sizeof(MEMHDR);
   deallocated += totlen;
   balance     -= totlen;
   // memFree (mem);
   _C_TS_free(mem);
   *pp = NULL;
}
// -------------------------------------------------------------
PUCHAR memStrDup(PUCHAR s)
{
    PUCHAR p;
    UINT64 len;

    if (s == NULL) return NULL;
    len = strlen(s) + 1;  // Len including the zero term.
    p = memAlloc (len);
    memcpy (p , s , len); // Copy the string including the zerotermination
    return p;
}
// -------------------------------------------------------------
PUCHAR memStrTrimDup(PUCHAR s)
{
    PUCHAR p;
    PUCHAR t;
    UINT64 len = 0;

    if (s == NULL) return NULL;

    for (t=s; *t ; t++) {
       if (*t > ' ') len = (t - s) + 1;
    }
    p = memAlloc (len+1);
    memcpy (p , s , len); // Copy the string including the zerotermination
    *(p+len) = 0;
    return p;
}
// -------------------------------------------------------------
PVOID memRealloc (PVOID * p, UINT64 len)
{
    PUCHAR oldMem = *p;
    if (oldMem)  {
       PMEMHDR mem = (PMEMHDR) (oldMem - sizeof(MEMHDR)) ;
       UINT64 newSize  =  len+ sizeof(MEMHDR);
       // _C_TS_realloc64 does not exists !! reacclo only work up to 2G
       //PMEMHDR newMem =  _C_TS_realloc64(mem , newSize);   // Preserve space for the signature
       PMEMHDR newMem =  _C_TS_realloc(mem , newSize);   // Preserve space for the signature
       balance += newSize - newMem->size;
       newMem->size = newSize;
       *p = (PUCHAR)newMem + sizeof(MEMHDR);      // Return the pointer after the header
    } else {
       *p = memAlloc(len);
    }
    return *p;
}
// -------------------------------------------------------------
UINT64 memSize (PVOID p)
{
   PMEMHDR mem;

   if (p == NULL )  return 0;

   mem = (PMEMHDR) ((PUCHAR) p - sizeof(MEMHDR)) ;
   if (mem->signature != MEMSIG ) {
      #ifdef MEMDEBUG
         printf("Non valid memory\n");
      #endif
      return 0;
   }

   return mem->size;
}
// -------------------------------------------------------------
PVOID memShare (PUCHAR path, UINT64 len)
{
   LONG     fd;
   LONG     result;
   PUCHAR   map;

   fd = open(path  , O_RDWR);

   // Does not exists - creat it
   if (fd == -1) {

      fd = open(path  , O_RDWR | O_CREAT | O_TRUNC, (mode_t)0600);
      if (fd == -1) {
          perror("Error opening file for writing");
          return NULL;
      }

      // Stretch the file size to the size of the (mmapped) array of BYTES
      result = lseek(fd, len-1, SEEK_SET);
      if (result == -1) {
         close(fd);
         perror("Error calling lseek() to 'stretch' the file");
         return NULL;
      }

      /* Something needs to be written at the end of the file to
       * have the file actually have the new size.
       * Just writing an empty string at the current file position will do.
       *
       * Note:
       *  - The current position in the file is at the end of the stretched
       *    file due to the call to lseek().
       *  - An empty string is actually a single '\0' character, so a zero-byte
       *    will be written at the last byte of the file.
       */
      result = write(fd, "", 1);
      if (result != 1) {
         close(fd);
         perror("Error writing last byte of the file");
         return NULL;
      }
   }

   // Now the file is ready to be mmapped.
   map = mmap(0, len , PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
   if (map == MAP_FAILED) {
      close(fd);
      perror("Error mmapping the file");
      return NULL;
   }
   return map;
}
// -------------------------------------------------------------
void memStat (void)
{
   printf("\n");
   printf("Allocated: %-16.16lld " , allocated);
   printf("Deallocated: %-16.16lld " , deallocated);
   printf("Balance: %-16.16lld\n" , balance);
}
// -------------------------------------------------------------
BOOL memLeak (void)
{
   return (balance != 0) ;
}
// -------------------------------------------------------------
UINT64 memUse (void)
{
   return balance;
}
// -------------------------------------------------------------
// Test case:
// -------------------------------------------------------------
/*********************
void main()
{
   PUCHAR p [1000];
   int i ;
   INT64  b1,  b2, b3;
   b1 = memUse();
   for(i=0;i<20  ;i++) {
      p[i] = memAlloc(MEMMAX);
   }
   b2 = memUse();
   for(i=0;i<20  ;i++) {
      memFree (&p[i]);
   }
   b3 = memUse();
}
*/
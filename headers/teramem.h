#define MEMSIG (0x4c6e) // will show <> in the trace
//    define MEMDEBUG 1

PVOID  memAlloc  (UINT64 len);
PVOID  memCalloc (UINT64 len);
void   memFree   (PVOID * p);
PUCHAR memStrDup (PUCHAR s);
PUCHAR memStrTrimDup(PUCHAR s);
PVOID  memRealloc(PVOID * p, UINT64 len);
PVOID  memShare (PUCHAR path, UINT64 len);
UINT64 memSize   (PVOID p);
void   memStat   (void);
BOOL   memLeak   (void);
UINT64 memUse    (void);

#ifndef MEMTYPES_H
#define MEMTYPES_H
typedef _Packed struct _MEMHDR {
      USHORT  signature;    //  2 the "<>" signature
      UCHAR   filler [6];   // 10 Pad up to 16 bytes total
      UINT64  size;         //  4
} MEMHDR, * PMEMHDR;        // 16 -> Total of 16 to let it allign for pointers
#define MEMMAX (2147483424 - sizeof(MEMHDR))
#endif
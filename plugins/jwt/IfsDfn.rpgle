     h/title  IFSDFN - IFS copybook
     f**********************************************************************************************
     f*                                                                                            *
     f*           Source  - IFSDFN                                                                 *
     f*       Description - IFS copybook                                                           *
     f*                     Procedure wrappers over C/Unix File & Directory API's.                 *
     f*                                                                                            *
     f*                                                                                            *
     d/if defined(IFSDFN)
     d/eof
     d/endif
     d/define IFSDFN

      **********************************************************************
      * Some useful CCSID definitions
      **********************************************************************
     D CP_MSDOS        C                   437
     D CP_ISO8859_1    C                   819
     D CP_WINDOWS      C                   1252
     D CP_UTF8         C                   1208
     D CP_UCS2         C                   1200
     D CP_CURJOB       C                   0


      **************************************************************************
      *
      * Global Data Structures
      *
      **************************************************************************
      *
      //---------------------------------------------------------
      // File Information Structure (stat64), Large File Enabled
      //---------------------------------------------------------
     d IFS_Stat        ds                  template qualified
      * File mode
     D  mode                         10U 0
      * File serial number
     D  ino                          10U 0
      * User ID of the owner of file
     D  uid                          10U 0
      * Group ID of the group of file
     D  gid                          10U 0
      * For regular files, the file size in bytes
     D  size                         20I 0
      * Time of last access
     D  atime                        10I 0
      * Time of last data modification
     D  mtime                        10I 0
      * Time of last file status change
     D  ctime                        10I 0
      * ID of device containing file
     D  dev                          10U 0
      * Size of a block of the file
     D  blksize                      10U 0
      * Number of links
     D  nlink                         5U 0
      * Object data codepage
     D  codepage                      5U 0
      * Allocation size of the file
     D  allocsize                    20U 0
      * File serial number generation
     D  ino_gen_id                   10U 0
      * AS/400 object type
     D  objtype                      11A
      * Reserved
     D  reserved2                     5A
      * Device ID (if character special or block special file)
     D  rdev                         10U 0
      * Device ID - 64 bit form
     D  rdev64                       20U 0
      * ID of device containing file 64 bit form.
     D  dev64                        20U 0
      * Number of links-32 bit
     D  nlink32                      10U 0
      * Reserved
     D  reserved1                    26A
      * Object data ccsid
     D  ccsid                         5U 0


      **********************************************************************
      * File Information Structure (stat)
      *   struct stat {
      *     mode_t         st_mode;       /* File mode                       */
      *     ino_t          st_ino;        /* File serial number              */
      *     nlink_t        st_nlink;      /* Number of links                 */
      *     unsigned short st_reserved2;  /* Reserved                    @B4A*/
      *     uid_t          st_uid;        /* User ID of the owner of file    */
      *     gid_t          st_gid;        /* Group ID of the group of file   */
      *     off_t          st_size;       /* For regular files, the file
      *                                      size in bytes                   */
      *     time_t         st_atime;      /* Time of last access             */
      *     time_t         st_mtime;      /* Time of last data modification  */
      *     time_t         st_ctime;      /* Time of last file status change */
      *     dev_t          st_dev;        /* ID of device containing file    */
      *     size_t         st_blksize;    /* Size of a block of the file     */
      *     unsigned long  st_allocsize;  /* Allocation size of the file     */
      *     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
      *     char           st_reserved3;  /* Reserved                    @B4A*/
      *     unsigned short st_codepage;   /* Object data codepage            */
      *     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
      *     dev_t          st_rdev;       /* Device ID (if character special */
      *                                   /* or block special file)      @B4A*/
      *     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5C*/
      *     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
      *     dev64_t        st_dev64;      /* ID of device containing file -  */
      *                                   /* 64 bit form.                @B4A*/
      *     char           st_reserved1[36]; /* Reserved                 @B4A*/
      *     unsigned int   st_ino_gen_id; /* File serial number generation id
      *  };
      *                                                                  @A2A*/
      **********************************************************************
     D statds          DS                  qualified
     D                                     BASED(Template)
     D  st_mode                      10U 0
     D  st_ino                       10U 0
     D  st_nlink                      5U 0
     D  st_reserved2                  5U 0
     D  st_uid                       10U 0
     D  st_gid                       10U 0
     D  st_size                      10I 0
     D  st_atime                     10I 0
     D  st_mtime                     10I 0
     D  st_ctime                     10I 0
     D  st_dev                       10U 0
     D  st_blksize                   10U 0
     D  st_allocsize                 10U 0
     D  st_objtype                   11A
     D  st_reserved3                  1A
     D  st_codepage                   5U 0
     D  st_ccsid                      5U 0
     D  st_rdev                      10U 0
     D  st_nlink32                   10U 0
     D  st_rdev64                    20U 0
     D  st_dev64                     20U 0
     D  st_reserved1                 36A
     D  st_ino_gen_id                10U 0


      **********************************************************************
      * File Information Structure, Large File Enabled (stat64)
      *   struct stat64 {                                                    */
      *     mode_t         st_mode;       /* File mode                       */
      *     ino_t          st_ino;        /* File serial number              */
      *     uid_t          st_uid;        /* User ID of the owner of file    */
      *     gid_t          st_gid;        /* Group ID of the group of fileA2A*/
      *     off64_t        st_size;       /* For regular files, the file     */
      *                                      size in bytes                   */
      *     time_t         st_atime;      /* Time of last access             */
      *     time_t         st_mtime;      /* Time of last data modification2A*/
      *     time_t         st_ctime;      /* Time of last file status changeA*/
      *     dev_t          st_dev;        /* ID of device containing file    */
      *     size_t         st_blksize;    /* Size of a block of the file     */
      *     nlink_t        st_nlink;      /* Number of links                 */
      *     unsigned short st_codepage;   /* Object data codepage            */
      *     unsigned long long st_allocsize; /* Allocation size of the file2A*/
      *     unsigned int   st_ino_gen_id; /* File serial number generationAid*/
      *                                                                      */
      *     qp0l_objtype_t st_objtype;    /* AS/400 object type              */
      *     char           st_reserved2[5]; /* Reserved                  @B4A*/
      *     dev_t          st_rdev;       /* Device ID (if character specialA*/
      *                                   /* or block special file)      @B4A*/
      *     dev64_t        st_rdev64;     /* Device ID - 64 bit form     @B4A*/
      *     dev64_t        st_dev64;      /* ID of device containing file@-2A*/
      *                                   /* 64 bit form.                @B4A*/
      *     nlink32_t      st_nlink32;    /* Number of links-32 bit      @B5A*/
      *     char           st_reserved1[26]; /* Reserved            @B4A @B5C*/
      *     unsigned short st_ccsid;      /* Object data ccsid           @AAA*/
      *  };                                                                  */
      *
      **********************************************************************
     D statds64        DS                  qualified
     D                                     BASED(Template)
     D  st_mode                      10U 0
     D  st_ino                       10U 0
     D  st_uid                       10U 0
     D  st_gid                       10U 0
     D  st_size                      20I 0
     D  st_atime                     10I 0
     D  st_mtime                     10I 0
     D  st_ctime                     10I 0
     D  st_dev                       10U 0
     D  st_blksize                   10U 0
     D  st_nlink                      5U 0
     D  st_codepage                   5U 0
     D  st_allocsize                 20U 0
     D  st_ino_gen_id                10U 0
     D  st_objtype                   11A
     D  st_reserved2                  5A
     D  st_rdev                      10U 0
     D  st_rdev64                    20U 0
     D  st_dev64                     20U 0
     D  st_nlink32                   10U 0
     D  st_reserved1                 26A
     D  st_ccsid                      5U 0

      **********************************************************************
      * ds_statvfs - data structure to receive file system info
      *
      *   f_bsize   = file system block size (in bytes)
      *   f_frsize  = fundamental block size in bytes.
      *                if this is zero, f_blocks, f_bfree and f_bavail
      *                are undefined.
      *   f_blocks  = total number of blocks (in f_frsize)
      *   f_bfree   = total free blocks in filesystem (in f_frsize)
      *   f_bavail  = total blocks available to users (in f_frsize)
      *   f_files   = total number of file serial numbers
      *   f_ffree   = total number of unused file serial numbers
      *   f_favail  = number of available file serial numbers to users
      *   f_fsid    = filesystem ID.  This will be 4294967295 if it's
      *                too large for a 10U 0 field. (see f_fsid64)
      *   f_flag    = file system flags (see below)
      *   f_namemax = max filename length.  May be 4294967295 to
      *                indicate that there is no maximum.
      *   f_pathmax = max pathname legnth.  May be 4294967295 to
      *                indicate that there is no maximum.
      *   f_objlinkmax = maximum number of hard-links for objects
      *                other than directories
      *   f_dirlinkmax = maximum number of hard-links for directories
      *   f_fsid64  = filesystem id (in a 64-bit integer)
      *   f_basetype = null-terminated string containing the file
      *                  system type name.  For example, this might
      *                  be "root" or "Network File System (NFS)"
      *
      *  Since f_basetype is null-terminated, you should read it
      *  in ILE RPG with:
      *       myString = %str(%addr(ds_statvfs.f_basetype))
      **********************************************************************
     D ds_statvfs      DS                  qualified
     D                                     BASED(Template)
     D  f_bsize                      10U 0
     D  f_frsize                     10U 0
     D  f_blocks                     20U 0
     D  f_bfree                      20U 0
     D  f_bavail                     20U 0
     D  f_files                      10U 0
     D  f_ffree                      10U 0
     D  f_favail                     10U 0
     D  f_fsid                       10U 0
     D  f_flag                       10U 0
     D  f_namemax                    10U 0
     D  f_pathmax                    10U 0
     D  f_objlinkmax                 10I 0
     D  f_dirlinkmax                 10I 0
     D  f_reserved1                   4A
     D  f_fsid64                     20U 0
     D  f_basetype                   80A


      **********************************************************************
      * Group Information Structure (group)
      *
      *  struct group {
      *        char    *gr_name;        /* Group name.                      */
      *        gid_t   gr_gid;          /* Group id.                        */
      *        char    **gr_mem;        /* A null-terminated list of pointers
      *                                    to the individual member names.  */
      *  };
      *
      **********************************************************************
     D group           DS                  qualified
     D                                     BASED(Template)
     D   gr_name                       *
     D   gr_gid                      10U 0
     D   gr_mem                        *   DIM(256)


      **********************************************************************
      * User Information Structure (passwd)
      *
      * (Don't let the name fool you, this structure does not contain
      *  any password information.  Its named after the UNIX file that
      *  contains all of the user info.  That file is "passwd")
      *
      *   struct passwd {
      *        char    *pw_name;            /* User name.                   */
      *        uid_t   pw_uid;              /* User ID number.              */
      *        gid_t   pw_gid;              /* Group ID number.             */
      *        char    *pw_dir;             /* Initial working directory.   */
      *        char    *pw_shell;           /* Initial user program.        */
      *   };
      *
      **********************************************************************
     D passwd          DS                  qualified
     D                                     BASED(Template)
     D  pw_name                        *
     D  pw_uid                       10U 0
     D  pw_gid                       10U 0
     D  pw_dir                         *
     D  pw_shell                       *


      **********************************************************************
      * File Time Structure (utimbuf)
      *
      * struct utimbuf {
      *    time_t     actime;           /*  access time       */
      *    time_t     modtime;          /*  modification time */
      * };
      *
      **********************************************************************
     D utimbuf         DS                  qualified
     D                                     BASED(Template)
     D   actime                      10I 0
     D   modtime                     10I 0


      //------------------------------------
      // Directory Entry Structure (dirent)
      //------------------------------------
     d IFS_dirent      ds                  template qualified
      * Reserved
     d  reserv1                      16a
      * Reserved
     d  reserv2                      10u 0
      * The file number of the file
     d  fileno                       10u 0
      * Length of this directory entry in bytes
     d  reclen                       10u 0
      * Reserved
     d  reserv3                      10i 0
      *  Reserved
     d  reserv4                       8a
      * National Language Information about d_name
     d  nlsinfo                      12a
     d   nls_ccsid                   10i 0 Overlay(nlsinfo:1)
     d   nls_cntry                    2a   Overlay(nlsinfo:5)
     d   nls_lang                     3a   Overlay(nlsinfo:7)
     d   nls_reserv                   3a   Overlay(nlsinfo:10)
      * Length of the name, in bytes excluding NULL terminator
     d  namelen                      10u 0
      * Name...null terminated
     d  name                        640a


      *************************************************************************
      *
      * Global Constants
      *
      *************************************************************************
      *
      //-----------------------------------------------
      // Flags for use in IFS_Open()
      // More than one can be used (add them together)
      //-----------------------------------------------
      * Reading Only
     d O_RDONLY        c                   const(1)
      * Writing Only
     d O_WRONLY        c                   const(2)
      * Reading & Writing
     d O_RDWR          c                   const(4)
      * Create File if not exist
     d O_CREAT         c                   const(8)
      * Exclusively create
     d O_EXCL          c                   const(16)
      * Assign a CCSID
     d O_CCSID         c                   const(32)
      * Truncate File to 0 bytes
     d O_TRUNC         c                   const(64)
      * Append to File
     d O_APPEND        c                   const(256)
      * Synchronous write
     d O_SYNC          c                   const(1024)
      * Sync write, data only
     d O_DSYNC         c                   const(2048)
      * Sync read
     d O_RSYNC         c                   const(4096)
      * No controlling terminal
     d O_NOCTTY        c                   const(32768)
      * Share with readers only
     d O_SHARE_RDONLY  c                   const(65536)
      * Share with writers only
     d O_SHARE_WRONLY  c                   const(131072)
      * Share with read & write
     d O_SHARE_RDWR    c                   const(262144)
      * Share with nobody.
     d O_SHARE_NONE    c                   const(524288)
      * Assign a code page
     d O_CODEPAGE      c                   const(8388608)
      * Open in text-mode
     d O_TEXTDATA      c                   const(16777216)
      * Allow text translation on newly created file.
      * Note: O_TEXT_CREAT requires all of the following flags to work:
      *           O_CREAT+O_TEXTDATA+(O_CODEPAGE or O_CCSID)
     d O_TEXT_CREAT    c                   const(33554432)
      * Inherit mode from dir
     d O_INHERITMODE   c                   const(134217728)
      * Large file access (for >2GB files)
     d O_LARGEFILE     c                   const(536870912)

      //----------------------------------------------------------
      * Special MODE shortcuts for open() (instead of those above)
      //----------------------------------------------------------
     d M_RDONLY        C                   const(292)
     d M_RDWR          C                   const(438)
     d M_RWX           C                   const(511)

      **********************************************************************
      * class of users flags for accessx()
      *
      *   ACC_SELF = Check access based on effective uid/gid
      *   ACC_INVOKER = Check access based on real uid/gid
      *                 ( this is equvalent to calling access() )
      *   ACC_OTHERS = Check access of someone not the owner
      *   ACC_ALL = Check access of all users
      **********************************************************************
     D ACC_SELF        C                   0
     D ACC_INVOKER     C                   1
     D ACC_OTHERS      C                   8
     D ACC_ALL         C                   32

      //-------------------------------------------------------------------
      // Mode Flags - user access rights to the file
      //  The mode parm of IFS_Open, IFS_Chmod,... uses
      //  nine least significant bits to determine the file's mode.
      //
      //    user:  owner   group   other
      //  access:  R W X   R W X   R W X
      //     bit:  8 7 6   5 4 3   2 1 0
      //
      //  (This is accomplished by adding the flags below to get the mode)
      //-------------------------------------------------------------------
      * Owner Authority
     d S_IRUSR         c                   const(256)
     d S_IWUSR         c                   const(128)
     d S_IXUSR         c                   const(64)
     d S_IRWXU         c                   const(448)
      * Group Authority
     d S_IRGRP         c                   const(32)
     d S_IWGRP         c                   const(16)
     d S_IXGRP         c                   const(8)
     d S_IRWXG         c                   const(56)
      * Other People
     d S_IROTH         c                   const(4)
     d S_IWOTH         c                   const(2)
     d S_IXOTH         c                   const(1)
     d S_IRWXO         c                   const(7)
      *                                         special modes:
      *                                         restrict rename/unlink
     D S_ISVTX         C                    512
      *                                         Set effective GID
     D S_ISGID         C                   1024
      *                                         Set effective UID
     D S_ISUID         C                   2048


      //----------------------------------
      // Access mode flags for IFS_Access
      //----------------------------------
      * File Exists
     d F_OK            c                   const(0)
      * Read Access
     d R_OK            c                   const(4)
      * Write Access
     d W_OK            c                   const(2)
      * Execute or Search
     d X_OK            c                   const(1)

      //-------------------------------------------
      // "whence" constants for use with IFS_LSeek
      //-------------------------------------------
      /if not defined(SEEK_WHENCE_VALUES)
     d SEEK_SET        c                   CONST(0)
     d SEEK_CUR        c                   CONST(1)
     d SEEK_END        c                   CONST(2)
      /define SEEK_WHENCE_VALUES
      /endif

      **********************************************************************
      * flags specified in the f_flags element of the ds_statvfs
      *   data structure used by the statvfs() API
      **********************************************************************
     D ST_RDONLY...
     D                 C                   CONST(1)
     D ST_NOSUID...
     D                 C                   CONST(2)
     D ST_CASE_SENSITITIVE...
     D                 C                   CONST(4)
     D ST_CHOWN_RESTRICTED...
     D                 C                   CONST(8)
     D ST_THREAD_SAFE...
     D                 C                   CONST(16)
     D ST_DYNAMIC_MOUNT...
     D                 C                   CONST(32)
     D ST_NO_MOUNT_OVER...
     D                 C                   CONST(64)
     D ST_NO_EXPORTS...
     D                 C                   CONST(128)
     D ST_SYNCHRONOUS...
     D                 C                   CONST(256)

      **********************************************************************
      * Constants used by pathconf() API
      **********************************************************************
     D PC_CHOWN_RESTRICTED...
     D                 C                   0
     D PC_LINK_MAX...
     D                 C                   1
     D PC_MAX_CANON...
     D                 C                   2
     D PC_MAX_INPUT...
     D                 C                   3
     D PC_NAME_MAX...
     D                 C                   4
     D PC_NO_TRUNC...
     D                 C                   5
     D PC_PATH_MAX...
     D                 C                   6
     D PC_PIPE_BUF...
     D                 C                   7
     D PC_VDISABLE...
     D                 C                   8
     D PC_THREAD_SAFE...
     D                 C                   9

      **********************************************************************
      * Constants used by sysconf() API
      **********************************************************************
     D SC_CLK_TCK...
     D                 C                   2
     D SC_NGROUPS_MAX...
     D                 C                   3
     D SC_OPEN_MAX...
     D                 C                   4
     D SC_STREAM_MAX...
     D                 C                   5
     D SC_CCSID...
     D                 C                   10
     D SC_PAGE_SIZE...
     D                 C                   11
     D SC_PAGESIZE...
     D                 C                   12
      //-------------------------------------------
      // Misc. constants
      //-------------------------------------------
     d IFS_READ        c                   const('READ')
     d IFS_WRITE       c                   const('WRITE')
     d IFS_ERROR       c                   const(-1)


      *************************************************************************
      *
      * Procedure Prototypes / API wrappers
      *
      *************************************************************************
      *
      *---------------------------------------------------------------------
      * open() -- Open File, Large File Enabled
      *
      * int open(const char *path, int oflag, . . .);
      *
      *     path = path name of file to open
      *    oflag = open flags
      *     mode = file mode, aka permissions.  (Reqd with O_CREAT flag)
      * codepage = code page to assign to file  (Reqd with O_CODEPAGE flag)
      *
      * Returns the file descriptor of the opened file
      *         or -1 if an error occurred
      *---------------------------------------------------------------------
     d IFS_OpenFile    pr            10i 0 extproc('open64')
     d  path                           *   value options(*string)
     d  oflag                        10i 0 value
     d  mode                         10u 0 value options(*nopass)
     d  codepage                     10u 0 value options(*nopass)


      *---------------------------------------------------------------------
      * write() -- Write to stream file
      *
      * int write(int fildes, const void *buf, size_t nbyte);
      *
      *   fildes = file descriptor to write to
      *      buf = pointer to data to be written
      *    nbyte = number of bytes to write
      *
      * Returns the number of bytes written
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
     D IFS_WriteFile   pr            10i 0 extproc('write')
     D  fildes                       10i 0 value
     D  buf                            *   value
     D  nbyte                        10u 0 value


      *---------------------------------------------------------------------
      * read() -- Read from stream file
      *
      * int read(int fildes, void *buf, size_t nbyte);
      *
      *   fildes = file descriptor to read from
      *      buf = pointer to memory to read into
      *    nbyte = maximum number of bytes to read
      *
      * Returns the number of bytes read
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
     d IFS_ReadFile    pr            10i 0 extproc('read')
     d  fildes                       10i 0 value
     d  buf                            *   value
     d  nbyte                        10u 0 value


      *---------------------------------------------------------------------
      * close() -- Close file descriptor
      *
      * int close(int fildes);
      *
      *   fildes = file descriptor to close
      *
      * Returns 0 if successful
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
     d IFS_CloseFile   pr            10i 0 extproc('close')
     d  fildes                       10i 0 value


      **********************************************************************
      * I/O Vector Structure
      *
      *     struct iovec {
      *        void    *iov_base;
      *        size_t  iov_len;
      *     }
      **********************************************************************
      /if not defined(IOVEC_DS_DEFINED)
     D iovec           DS                  qualified
     D                                     BASED(p_iovec)
     D  iov_base                       *
     D  iov_len                      10U 0
      /define IOVEC_DS_DEFINED
      /endif


      *--------------------------------------------------------------------
      * Determine file accessibility
      *
      * int access(const char *path, int amode)
      *--------------------------------------------------------------------
     d IFS_Access      pr            10i 0 ExtProc('access')
     d  Path                           *   Value Options(*string)
     d  amode                        10i 0 Value

      *--------------------------------------------------------------------
      * Determine file accessibility for a class of users
      *
      * int accessx(const char *path, int amode, int who);
      *
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D accessx         PR            10I 0 ExtProc('accessx')
     D   Path                          *   Value Options(*string)
     D   amode                       10I 0 Value
     D   who                         10I 0 value
      /endif

      *--------------------------------------------------------------------
      * Change file permissions
      *
      * int chmod(const char *path, mode_t mode)
      *--------------------------------------------------------------------
     d IFS_Chmod       pr            10i 0 ExtProc('chmod')
     d  path                           *   Value options(*string)
     d  mode                         10u 0 Value


      *--------------------------------------------------------------------
      * Rename a file or directory.
      *
      * int rename(const char *old, const char *new);
      *--------------------------------------------------------------------
     d IFS_Rename      pr            10i 0 ExtProc('Qp0lRenameKeep')
     d  old                            *   Value options(*string)
     d  new                            *   Value options(*string)


      *--------------------------------------------------------------------
      * Remove Link to File.  (deletes 1 reference to a file.  If this
      *   is the last reference, the file itself is deleted.  See
      *   Chapter 3 for more info)
      *
      * int unlink(const char *path)
      *--------------------------------------------------------------------
     d IFS_Unlink      pr            10i 0 ExtProc('unlink')
     d  path                           *   Value options(*string)


      *--------------------------------------------------------------------
      * Set File Access & Modification Times
      *
      * int utime(const char *path, const struct utimbuf *times)
      *--------------------------------------------------------------------
     D utime           PR            10I 0 ExtProc('utime')
     D   path                          *   value options(*string)
     D   times                             likeds(utimbuf) options(*omit)

      *--------------------------------------------------------------------
      * Write to a file
      *
      * ssize_t write(int fildes, const void *buf, size_t bytes)
      *--------------------------------------------------------------------
     D write           PR            10I 0 ExtProc('write')
     D  fildes                       10i 0 value
     D  buf                            *   value
     D  bytes                        10U 0 value

      *--------------------------------------------------------------------
      * Write to a file using (with type A field in prototype)
      *
      * ssize_t write(int fildes, const void *buf, size_t bytes)
      *--------------------------------------------------------------------
     D writeA          PR            10I 0 ExtProc('write')
     D  fildes                       10i 0 value
     D  buf                       65535A   const options(*varsize)
     D  bytes                        10U 0 value

      *--------------------------------------------------------------------
      * Write to descriptor using multiple buffers
      *
      * int writev(int fildes, struct iovec *iovector[], int vector_len);
      *--------------------------------------------------------------------
     D writev          PR            10I 0 ExtProc('writev')
     D  fildes                       10i 0 value
     D  io_vector                          like(iovec)
     D                                     dim(256) options(*varsize)
     D  vector_len                   10I 0 value
      *--------------------------------------------------------------------
      * Get File Information, Large File Enabled
      *
      * int stat(const char *path, struct stat *buf)
      *--------------------------------------------------------------------
     d IFS_FileStat    pr            10i 0 ExtProc('stat64')
     d  path                           *   value options(*string)
     d  buf                                likeds(IFS_Stat)


      *--------------------------------------------------------------------
      * statvfs() -- Get file system status
      *
      *    path = (input) pathname of a link ("file") in the IFS.
      *     buf = (output) data structure containing file system info
      *
      * Returns 0 if successful, -1 upon error.
      * (error information is returned via the "errno" variable)
      *--------------------------------------------------------------------
     D statvfs         PR            10I 0 ExtProc('statvfs64')
     D   path                          *   value options(*string)
     D   buf                               like(ds_statvfs)

      *--------------------------------------------------------------------
      * Make Symbolic Link
      *
      * int symlink(const char *pname, const char *slink)
      *--------------------------------------------------------------------
     D symlink         PR            10I 0 ExtProc('symlink')
     D   pname                         *   value options(*string)
     D   slink                         *   value options(*string)

      *--------------------------------------------------------------------
      * Get system configuration variables
      *
      * long sysconf(int name)
      *--------------------------------------------------------------------
     D sysconf         PR            10I 0 ExtProc('sysconf')
     D   name                        10I 0 Value

      *--------------------------------------------------------------------
      * Set Authorization Mask for Job
      *
      * mode_t umask(mode_t cmask)
      *--------------------------------------------------------------------
     D umask           PR            10U 0 ExtProc('umask')
     D   cmask                       10U 0 Value

      *--------------------------------------------------------------------
      * Get effective group ID
      *
      * gid_t getegid(void)
      *--------------------------------------------------------------------
     D getegid         PR            10U 0 ExtProc('getegid')

      *--------------------------------------------------------------------
      * Get effective user ID
      *
      * uid_t geteuid(void)
      *--------------------------------------------------------------------
     D geteuid         PR            10U 0 ExtProc('geteuid')

      *--------------------------------------------------------------------
      * Get Real Group ID
      *
      * gid_t getgid(void)
      *--------------------------------------------------------------------
     D getgid          PR            10U 0 ExtProc('getgid')

      *--------------------------------------------------------------------
      * Get group information from group ID
      *
      * struct group *getgrgid(gid_t gid)
      *--------------------------------------------------------------------
     D getgrgid        PR              *   ExtProc('getgrgid')
     D   gid                         10U 0 VALUE

      *--------------------------------------------------------------------
      * Get group info using group name
      *
      * struct group  *getgrnam(const char *name)
      *--------------------------------------------------------------------
     D getgrnam        PR              *   ExtProc('getgrnam')
     D   name                          *   VALUE

      *--------------------------------------------------------------------
      * Get group IDs
      *
      * int getgroups(int gidsetsize, gid_t grouplist[])
      *--------------------------------------------------------------------
     D getgroups       PR              *   ExtProc('getgroups')
     D   gidsetsize                  10I 0 value
     D   grouplist                   10U 0 dim(256) options(*varsize)

      *--------------------------------------------------------------------
      * Get user information by user-name
      *
      * (Don't let the name mislead you, this does not return the password,
      *  the user info database on unix systems is called "passwd",
      *  therefore, getting the user info is called "getpw")
      *
      * struct passwd *getpwnam(const char *name)
      *--------------------------------------------------------------------
     D getpwnam        PR              *   ExtProc('getpwnam')
     D   name                          *   Value options(*string)

      *--------------------------------------------------------------------
      * Get user information by user-id number
      *
      * (Don't let the name mislead you, this does not return the password,
      *  the user info database on unix systems is called "passwd",
      *  therefore, getting the user info is called "getpw")
      *
      * struct passwd *getpwuid(uid_t uid)
      *--------------------------------------------------------------------
     D getpwuid        PR              *   extproc('getpwuid')
     D   uid                         10U 0 Value

      *--------------------------------------------------------------------
      * Get Real User-ID
      *
      * uid_t getuid(void)
      *--------------------------------------------------------------------
     D getuid          PR            10U 0 ExtProc('getuid')

      *--------------------------------------------------------------------
      * Perform I/O Control Request
      *
      * int ioctl(int fildes, unsigned long req, ...)
      *--------------------------------------------------------------------
     D ioctl           PR            10I 0 ExtProc('ioctl')
     D   fildes                      10I 0 Value
     D   req                         10U 0 Value
     D   arg                           *   Value

      *--------------------------------------------------------------------
      * Change Owner/Group of symbolic link
      *
      * int lchown(const char *path, uid_t owner, gid_t group)
      *
      * NOTE: for non-symlinks, this behaves identically to chown().
      *       for symlinks, this changes ownership of the link, whereas
      *       chown() changes ownership of the file the link points to.
      *--------------------------------------------------------------------
     D lchown          PR            10I 0 ExtProc('lchown')
     D   path                          *   Value options(*string)
     D   owner                       10U 0 Value
     D   group                       10U 0 Value

      *--------------------------------------------------------------------
      * Create Hard Link to File
      *
      * int link(const char *existing, const char *new)
      *--------------------------------------------------------------------
     D link            PR            10I 0 ExtProc('link')
     D   existing                      *   Value options(*string)
     D   new                           *   Value options(*string)

      *--------------------------------------------------------------------
      * Set File Read/Write Offset
      *
      * off_t lseek(int fildes, off_t offset, int whence)
      *--------------------------------------------------------------------
     D lseek           PR            10I 0 ExtProc('lseek')
     D   fildes                      10I 0 value
     D   offset                      10I 0 value
     D   whence                      10I 0 value

      *--------------------------------------------------------------------
      * Set File Read/Write Offset, Large File Enabled
      *
      * off_t lseek(int fildes, off_t offset, int whence)
      *--------------------------------------------------------------------
     d IFS_LSeek       pr            20i 0 ExtProc('lseek64')
     d  fildes                       10i 0 value
     d  offset                       20i 0 value
     d  whence                       10i 0 value


      *--------------------------------------------------------------------
      * Get File or Link Information
      *
      * int lstat(const char *path, struct stat *buf)
      *
      * NOTE: for non-symlinks, this behaves identically to stat().
      *       for symlinks, this gets information about the link, whereas
      *       stat() gets information about the file the link points to.
      *--------------------------------------------------------------------
     D lstat           PR            10I 0 ExtProc('lstat')
     D   path                          *   Value options(*string)
     D   buf                               likeds(statds)

      *--------------------------------------------------------------------
      * Get File or Link Information, Large File Enabled
      *
      * int lstat64(const char *path, struct stat64 *buf)
      *
      * NOTE: for non-symlinks, this behaves identically to stat().
      *       for symlinks, this gets information about the link, whereas
      *       stat() gets information about the file the link points to.
      *--------------------------------------------------------------------
     D lstat64         PR            10I 0 ExtProc('lstat64')
     D   path                          *   Value options(*string)
     D   buf                               likeds(statds64)

      *--------------------------------------------------------------------
      * Duplicate open file descriptor
      *
      * int dup(int fildes)
      *--------------------------------------------------------------------
     D dup             PR            10I 0 ExtProc('dup')
     D   fildes                      10I 0 Value

      *--------------------------------------------------------------------
      * Duplicate open file descriptor to another descriptor
      *
      * int dup2(int fildes, int fildes2)
      *--------------------------------------------------------------------
     D dup2            PR            10I 0 ExtProc('dup2')
     D   fildes                      10I 0 Value
     D   fildes2                     10I 0 Value

      *--------------------------------------------------------------------
      * Determine file accessibility for a class of users by descriptor
      *
      * int faccessx(int filedes, int amode, int who)
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D faccessx        PR            10I 0 ExtProc('faccessx')
     D   fildes                      10I 0 Value
     D   amode                       10I 0 Value
     D   who                         10I 0 Value
      /endif

      *--------------------------------------------------------------------
      * Change Current Directory by Descriptor
      *
      * int fchdir(int fildes)
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D fchdir          PR            10I 0 ExtProc('fchdir')
     D   fildes                      10I 0 value
      /endif

      *--------------------------------------------------------------------
      * Change file authorizations by descriptor
      *
      * int fchmod(int fildes, mode_t mode)
      *--------------------------------------------------------------------
     D fchmod          PR            10I 0 ExtProc('fchmod')
     D   fildes                      10I 0 Value
     D   mode                        10U 0 Value

      *--------------------------------------------------------------------
      * Change Owner and Group of File by Descriptor
      *
      * int fchown(int fildes, uid_t owner, gid_t group)
      *--------------------------------------------------------------------
     D fchown          PR            10I 0 ExtProc('fchown')
     D   fildes                      10I 0 Value
     D   owner                       10U 0 Value
     D   group                       10U 0 Value

      *--------------------------------------------------------------------
      * Perform File Control
      *
      * int fcntl(int fildes, int cmd, . . .)
      *
      * Note:  Because the same fcntl() API is used for IFS and sockets,
      *        it's conditionally defined here.  If it's defined with
      *        the same conditions in the sockets /copy member, there
      *        will be no conflict.
      *--------------------------------------------------------------------
     D/if not defined(FCNTL_PROTOTYPE)
     D fcntl           PR            10I 0 ExtProc('fcntl')
     D   fildes                      10I 0 Value
     D   cmd                         10I 0 Value
     D   arg                         10I 0 Value options(*nopass)
     D/define FCNTL_PROTOTYPE
     D/endif

      *--------------------------------------------------------------------
      * Get configurable path name variables by descriptor
      *
      * long fpathconf(int fildes, int name)
      *--------------------------------------------------------------------
     D fpathconf       PR            10I 0 ExtProc('fpathconf')
     D   fildes                      10I 0 Value
     D   name                        10I 0 Value

      *--------------------------------------------------------------------
      * Get File Information by Descriptor
      *
      * int fstat(int fildes, struct stat *buf)
      *--------------------------------------------------------------------
     D fstat           PR            10I 0 ExtProc('fstat')
     D   fildes                      10I 0 Value
     D   buf                               likeds(statds)

      *--------------------------------------------------------------------
      * Get File Information from descriptor, large File Enabled
      *
      * int fstat64(int fildes, struct stat *buf)
      *--------------------------------------------------------------------
     d IFS_FStat       pr            10i 0 ExtProc('fstat64')
     d  fildes                       10i 0 value
     d  buf                                likeds(IFS_Stat)


      *--------------------------------------------------------------------
      * Make Directory
      *
      * int mkdir(const char *path, mode_t mode)
      *--------------------------------------------------------------------
     d IFS_MkDir       pr            10i 0 ExtProc('mkdir')
     d  path                           *   Value options(*string)
     d  mode                         10u 0 Value


      *--------------------------------------------------------------------
      * Make FIFO Special File
      *
      * int mkfifo(const char *path, mode_t mode)
      *--------------------------------------------------------------------
      /if defined(*V5R1M0)
     D mkfifo          PR            10I 0 ExtProc('mkfifo')
     D   path                          *   Value options(*string)
     D   mode                        10U 0 Value
      /endif

      *--------------------------------------------------------------------
      * Remove Directory
      *
      * int rmdir(const char *path)
      *--------------------------------------------------------------------
     d IFS_RmDir       pr            10i 0 ExtProc('rmdir')
     d  path                           *   value options(*string)


      *--------------------------------------------------------------------
      * Get File Information
      *
      * int stat(const char *path, struct stat *buf)
      *--------------------------------------------------------------------
     D stat            PR            10I 0 ExtProc('stat')
     D   path                          *   value options(*string)
     D   buf                               likeds(statds)


      *--------------------------------------------------------------------
      * Change Directory
      *
      * int chdir(const char *path)
      *--------------------------------------------------------------------
     d IFS_ChDir       pr            10i 0 ExtProc('chdir')
     d  path                           *   Value Options(*string)


      *--------------------------------------------------------------------
      * Open a Directory
      *
      * DIR *opendir(const char *dirname)
      *--------------------------------------------------------------------
     d IFS_OpenDir     pr              *   ExtProc('opendir')
     d  dirname                        *   Value options(*string)


      *--------------------------------------------------------------------
      * Get configurable path name variables
      *
      * long pathconf(const char *path, int name)
      *--------------------------------------------------------------------
     D pathconf        PR            10I 0 ExtProc('pathconf')
     D   path                          *   Value options(*string)
     D   name                        10I 0 Value

      *--------------------------------------------------------------------
      * Create interprocess channel
      *
      * int pipe(int fildes[2]);
      *--------------------------------------------------------------------
      /if not defined(PIPE_PROTOTYPE)
     D pipe            PR            10I 0 ExtProc('pipe')
     D   fildes                      10I 0 dim(2)
      /define PIPE_PROTOTYPE
      /endif

      *--------------------------------------------------------------------
      * Read from Descriptor with Offset
      *
      * ssize_t pread(int filedes, void *buf, size_t nbyte, off_t offset);
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D pread           PR            10I 0 ExtProc('pread')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D   offset                      10I 0 value
      /endif

      *--------------------------------------------------------------------
      * Read from Descriptor with Offset, Large File Enabled
      *
      * ssize_t pread64(int filedes, void *buf, size_t nbyte,
      *                 size_t nbyte, off64_t offset);
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D pread64         PR            10I 0 ExtProc('pread64')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D   offset                      20I 0 value
      /endif

      *--------------------------------------------------------------------
      * Write to Descriptor with Offset
      *
      * ssize_t pwrite(int filedes, const void *buf,
      *                size_t nbyte, off_t offset);
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D pwrite          PR            10I 0 ExtProc('pwrite')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D   offset                      10I 0 value
      /endif

      *--------------------------------------------------------------------
      * Write to Descriptor with Offset, Large File Enabled
      *
      * ssize_t pwrite64(int filedes, const void *buf,
      *                  size_t nbyte, off64_t offset);
      *--------------------------------------------------------------------
      /if defined(*V5R2M0)
     D pwrite64        PR            10I 0 ExtProc('pwrite64')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value
     D   offset                      20I 0 value
      /endif

      *--------------------------------------------------------------------
      * Perform Miscellaneous file system functions
      *--------------------------------------------------------------------
     D QP0FPTOS        PR                  ExtPgm('QP0FPTOS')
     D   Function                    32A   const
     D   Exten1                       6A   const options(*nopass)
     D   Exten2                       3A   const options(*nopass)

      *--------------------------------------------------------------------
      * Read Directory Entry
      *
      * struct dirent *readdir(DIR *dirp)
      *--------------------------------------------------------------------
     d IFS_ReadDir     pr              *   ExtProc('readdir')
     d  dirp                           *   Value


      *--------------------------------------------------------------------
      * Read Value of Symbolic Link
      *
      * int readlink(const char *path, char *buf, size_t bufsiz)
      *--------------------------------------------------------------------
     D readlink        PR            10I 0 ExtProc('readlink')
     D   path                          *   value options(*string)
     D   buf                           *   value
     D   bufsiz                      10U 0 value

      *--------------------------------------------------------------------
      * Read From Descriptor using Multiple Buffers
      *
      * int readv(int fildes, struct iovec *io_vector[], int vector_len);
      *--------------------------------------------------------------------
     D readv           PR            10I 0 ExtProc('readv')
     D  fildes                       10i 0 value
     D  io_vector                          like(iovec)
     D                                     dim(256) options(*varsize)
     D  vector_len                   10I 0 value

      *--------------------------------------------------------------------
      * Rename File or Directory
      *
      * int rename(const char *old, const char *new)
      *
      *  Note: By defailt, if a file with the new name already exists,
      *        rename will fail with an error.  If you define
      *        RENAMEUNLINK and a file with the new name already exists
      *        it will be unlinked prior to renaming.
      *--------------------------------------------------------------------
      /if defined(RENAMEUNLINK)
     D rename          PR            10I 0 ExtProc('Qp0lRenameUnlink')
     D   old                           *   Value options(*string)
     D   new                           *   Value options(*string)
      /else
     D rename          PR            10I 0 ExtProc('Qp0lRenameKeep')
     D   old                           *   Value options(*string)
     D   new                           *   Value options(*string)
      /endif

      *--------------------------------------------------------------------
      * Reset Directory Stream to Beginning
      *
      * void rewinddir(DIR *dirp)
      *--------------------------------------------------------------------
     D rewinddir       PR                  ExtProc('rewinddir')
     D   dirp                          *   value


      *--------------------------------------------------------------------
      * Change Owner/Group of File
      *
      * int chown(const char *path, uid_t owner, gid_t group)
      *--------------------------------------------------------------------
     D chown           PR            10I 0 ExtProc('chown')
     D   path                          *   Value options(*string)
     D   owner                       10U 0 Value
     D   group                       10U 0 Value

      *--------------------------------------------------------------------
      * Close a file
      *
      * int close(int fildes)
      *
      * Note:  Because the same close() API is used for IFS, sockets,
      *        and pipes, it's conditionally defined here.  If it's
      *        done the same in the sockets & pipe /copy members,
      *        there will be no conflict.
      *--------------------------------------------------------------------
     D/if not defined(CLOSE_PROTOTYPE)
     D close           PR            10I 0 ExtProc('close')
     D  fildes                       10I 0 value
     D/define CLOSE_PROTOTYPE
     D/endif

      *--------------------------------------------------------------------
      * Close a directory
      *
      * int closedir(DIR *dirp)
      *--------------------------------------------------------------------
     d IFS_CloseDir    pr            10I 0 ExtProc('closedir')
     d  dirhandle                      *   Value


      *--------------------------------------------------------------------
      * fstatvfs() -- Get file system status by descriptor
      *
      *  fildes = (input) file descriptor to use to locate file system
      *     buf = (output) data structure containing file system info
      *
      * Returns 0 if successful, -1 upon error.
      * (error information is returned via the "errno" variable)
      *--------------------------------------------------------------------
     D fstatvfs        PR            10I 0 ExtProc('fstatvfs64')
     D   fildes                      10I 0 value
     D   buf                               like(ds_statvfs)

      *--------------------------------------------------------------------
      * Synchronize Changes to file
      *
      * int fsync(int fildes)
      *--------------------------------------------------------------------
     D fsync           PR            10I 0 ExtProc('fsync')
     D   fildes                      10I 0 Value

      *--------------------------------------------------------------------
      * Truncate file
      *
      * int ftruncate(int fildes, off_t length)
      *--------------------------------------------------------------------
     D ftruncate       PR            10I 0 ExtProc('ftruncate')
     D   fildes                      10I 0 Value
     D   length                      10I 0 Value

      *--------------------------------------------------------------------
      * Truncate file, large file enabled
      *
      * int ftruncate64(int fildes, off64_t length)
      *--------------------------------------------------------------------
     D ftruncate64     PR            10I 0 ExtProc('ftruncate64')
     D   fildes                      10I 0 Value
     D   length                      20I 0 Value

      *--------------------------------------------------------------------
      * Get Current Working Directory
      *
      * char *getcwd(char *buf, int size);
      *--------------------------------------------------------------------
     d IFS_GetCwd      pr              *   EXTPROC('getcwd')
     d  buf                            *   VALUE
     d  size                         10i 0 VALUE


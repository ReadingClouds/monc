# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
# 12 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 1



# 1 "/usr/include/stdlib.h" 1 3 4
# 25 "/usr/include/stdlib.h" 3 4
# 1 "/usr/include/bits/libc-header-start.h" 1 3 4
# 33 "/usr/include/bits/libc-header-start.h" 3 4
# 1 "/usr/include/features.h" 1 3 4
# 465 "/usr/include/features.h" 3 4
# 1 "/usr/include/sys/cdefs.h" 1 3 4
# 452 "/usr/include/sys/cdefs.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 453 "/usr/include/sys/cdefs.h" 2 3 4
# 1 "/usr/include/bits/long-double.h" 1 3 4
# 454 "/usr/include/sys/cdefs.h" 2 3 4
# 466 "/usr/include/features.h" 2 3 4
# 489 "/usr/include/features.h" 3 4
# 1 "/usr/include/gnu/stubs.h" 1 3 4
# 10 "/usr/include/gnu/stubs.h" 3 4
# 1 "/usr/include/gnu/stubs-64.h" 1 3 4
# 11 "/usr/include/gnu/stubs.h" 2 3 4
# 490 "/usr/include/features.h" 2 3 4
# 34 "/usr/include/bits/libc-header-start.h" 2 3 4
# 26 "/usr/include/stdlib.h" 2 3 4





# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 216 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 3 4

# 216 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 3 4
typedef long unsigned int size_t;
# 328 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 3 4
typedef int wchar_t;
# 32 "/usr/include/stdlib.h" 2 3 4







# 1 "/usr/include/bits/waitflags.h" 1 3 4
# 40 "/usr/include/stdlib.h" 2 3 4
# 1 "/usr/include/bits/waitstatus.h" 1 3 4
# 41 "/usr/include/stdlib.h" 2 3 4
# 55 "/usr/include/stdlib.h" 3 4
# 1 "/usr/include/bits/floatn.h" 1 3 4
# 119 "/usr/include/bits/floatn.h" 3 4
# 1 "/usr/include/bits/floatn-common.h" 1 3 4
# 24 "/usr/include/bits/floatn-common.h" 3 4
# 1 "/usr/include/bits/long-double.h" 1 3 4
# 25 "/usr/include/bits/floatn-common.h" 2 3 4
# 120 "/usr/include/bits/floatn.h" 2 3 4
# 56 "/usr/include/stdlib.h" 2 3 4


typedef struct
  {
    int quot;
    int rem;
  } div_t;



typedef struct
  {
    long int quot;
    long int rem;
  } ldiv_t;





__extension__ typedef struct
  {
    long long int quot;
    long long int rem;
  } lldiv_t;
# 97 "/usr/include/stdlib.h" 3 4
extern size_t __ctype_get_mb_cur_max (void) __attribute__ ((__nothrow__ , __leaf__)) ;



extern double atof (const char *__nptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1))) ;

extern int atoi (const char *__nptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1))) ;

extern long int atol (const char *__nptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1))) ;



__extension__ extern long long int atoll (const char *__nptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1))) ;



extern double strtod (const char *__restrict __nptr,
        char **__restrict __endptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern float strtof (const char *__restrict __nptr,
       char **__restrict __endptr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));

extern long double strtold (const char *__restrict __nptr,
       char **__restrict __endptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 176 "/usr/include/stdlib.h" 3 4
extern long int strtol (const char *__restrict __nptr,
   char **__restrict __endptr, int __base)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));

extern unsigned long int strtoul (const char *__restrict __nptr,
      char **__restrict __endptr, int __base)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 199 "/usr/include/stdlib.h" 3 4
__extension__
extern long long int strtoll (const char *__restrict __nptr,
         char **__restrict __endptr, int __base)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));

__extension__
extern unsigned long long int strtoull (const char *__restrict __nptr,
     char **__restrict __endptr, int __base)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 385 "/usr/include/stdlib.h" 3 4
extern char *l64a (long int __n) __attribute__ ((__nothrow__ , __leaf__)) ;


extern long int a64l (const char *__s)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1))) ;




# 1 "/usr/include/sys/types.h" 1 3 4
# 27 "/usr/include/sys/types.h" 3 4


# 1 "/usr/include/bits/types.h" 1 3 4
# 27 "/usr/include/bits/types.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 28 "/usr/include/bits/types.h" 2 3 4
# 1 "/usr/include/bits/timesize.h" 1 3 4
# 29 "/usr/include/bits/types.h" 2 3 4


typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;


typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;

typedef signed long int __int64_t;
typedef unsigned long int __uint64_t;






typedef __int8_t __int_least8_t;
typedef __uint8_t __uint_least8_t;
typedef __int16_t __int_least16_t;
typedef __uint16_t __uint_least16_t;
typedef __int32_t __int_least32_t;
typedef __uint32_t __uint_least32_t;
typedef __int64_t __int_least64_t;
typedef __uint64_t __uint_least64_t;



typedef long int __quad_t;
typedef unsigned long int __u_quad_t;







typedef long int __intmax_t;
typedef unsigned long int __uintmax_t;
# 141 "/usr/include/bits/types.h" 3 4
# 1 "/usr/include/bits/typesizes.h" 1 3 4
# 142 "/usr/include/bits/types.h" 2 3 4
# 1 "/usr/include/bits/time64.h" 1 3 4
# 143 "/usr/include/bits/types.h" 2 3 4


typedef unsigned long int __dev_t;
typedef unsigned int __uid_t;
typedef unsigned int __gid_t;
typedef unsigned long int __ino_t;
typedef unsigned long int __ino64_t;
typedef unsigned int __mode_t;
typedef unsigned long int __nlink_t;
typedef long int __off_t;
typedef long int __off64_t;
typedef int __pid_t;
typedef struct { int __val[2]; } __fsid_t;
typedef long int __clock_t;
typedef unsigned long int __rlim_t;
typedef unsigned long int __rlim64_t;
typedef unsigned int __id_t;
typedef long int __time_t;
typedef unsigned int __useconds_t;
typedef long int __suseconds_t;

typedef int __daddr_t;
typedef int __key_t;


typedef int __clockid_t;


typedef void * __timer_t;


typedef long int __blksize_t;




typedef long int __blkcnt_t;
typedef long int __blkcnt64_t;


typedef unsigned long int __fsblkcnt_t;
typedef unsigned long int __fsblkcnt64_t;


typedef unsigned long int __fsfilcnt_t;
typedef unsigned long int __fsfilcnt64_t;


typedef long int __fsword_t;

typedef long int __ssize_t;


typedef long int __syscall_slong_t;

typedef unsigned long int __syscall_ulong_t;



typedef __off64_t __loff_t;
typedef char *__caddr_t;


typedef long int __intptr_t;


typedef unsigned int __socklen_t;




typedef int __sig_atomic_t;
# 30 "/usr/include/sys/types.h" 2 3 4
# 47 "/usr/include/sys/types.h" 3 4
typedef __ino_t ino_t;
# 59 "/usr/include/sys/types.h" 3 4
typedef __dev_t dev_t;




typedef __gid_t gid_t;




typedef __mode_t mode_t;




typedef __nlink_t nlink_t;




typedef __uid_t uid_t;





typedef __off_t off_t;
# 97 "/usr/include/sys/types.h" 3 4
typedef __pid_t pid_t;





typedef __id_t id_t;




typedef __ssize_t ssize_t;
# 121 "/usr/include/sys/types.h" 3 4
typedef __key_t key_t;




# 1 "/usr/include/bits/types/clock_t.h" 1 3 4






typedef __clock_t clock_t;
# 127 "/usr/include/sys/types.h" 2 3 4

# 1 "/usr/include/bits/types/clockid_t.h" 1 3 4






typedef __clockid_t clockid_t;
# 129 "/usr/include/sys/types.h" 2 3 4
# 1 "/usr/include/bits/types/time_t.h" 1 3 4






typedef __time_t time_t;
# 130 "/usr/include/sys/types.h" 2 3 4
# 1 "/usr/include/bits/types/timer_t.h" 1 3 4






typedef __timer_t timer_t;
# 131 "/usr/include/sys/types.h" 2 3 4



typedef __useconds_t useconds_t;



typedef __suseconds_t suseconds_t;





# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 145 "/usr/include/sys/types.h" 2 3 4
# 155 "/usr/include/sys/types.h" 3 4
# 1 "/usr/include/bits/stdint-intn.h" 1 3 4
# 24 "/usr/include/bits/stdint-intn.h" 3 4
typedef __int8_t int8_t;
typedef __int16_t int16_t;
typedef __int32_t int32_t;
typedef __int64_t int64_t;
# 156 "/usr/include/sys/types.h" 2 3 4


typedef __uint8_t u_int8_t;
typedef __uint16_t u_int16_t;
typedef __uint32_t u_int32_t;
typedef __uint64_t u_int64_t;


typedef int register_t __attribute__ ((__mode__ (__word__)));
# 185 "/usr/include/sys/types.h" 3 4
typedef __blksize_t blksize_t;






typedef __blkcnt_t blkcnt_t;



typedef __fsblkcnt_t fsblkcnt_t;



typedef __fsfilcnt_t fsfilcnt_t;
# 227 "/usr/include/sys/types.h" 3 4
# 1 "/usr/include/bits/pthreadtypes.h" 1 3 4
# 23 "/usr/include/bits/pthreadtypes.h" 3 4
# 1 "/usr/include/bits/thread-shared-types.h" 1 3 4
# 44 "/usr/include/bits/thread-shared-types.h" 3 4
# 1 "/usr/include/bits/pthreadtypes-arch.h" 1 3 4
# 21 "/usr/include/bits/pthreadtypes-arch.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 22 "/usr/include/bits/pthreadtypes-arch.h" 2 3 4
# 45 "/usr/include/bits/thread-shared-types.h" 2 3 4




typedef struct __pthread_internal_list
{
  struct __pthread_internal_list *__prev;
  struct __pthread_internal_list *__next;
} __pthread_list_t;

typedef struct __pthread_internal_slist
{
  struct __pthread_internal_slist *__next;
} __pthread_slist_t;
# 74 "/usr/include/bits/thread-shared-types.h" 3 4
# 1 "/usr/include/bits/struct_mutex.h" 1 3 4
# 22 "/usr/include/bits/struct_mutex.h" 3 4
struct __pthread_mutex_s
{
  int __lock;
  unsigned int __count;
  int __owner;

  unsigned int __nusers;



  int __kind;

  short __spins;
  short __elision;
  __pthread_list_t __list;
# 53 "/usr/include/bits/struct_mutex.h" 3 4
};
# 75 "/usr/include/bits/thread-shared-types.h" 2 3 4
# 87 "/usr/include/bits/thread-shared-types.h" 3 4
# 1 "/usr/include/bits/struct_rwlock.h" 1 3 4
# 23 "/usr/include/bits/struct_rwlock.h" 3 4
struct __pthread_rwlock_arch_t
{
  unsigned int __readers;
  unsigned int __writers;
  unsigned int __wrphase_futex;
  unsigned int __writers_futex;
  unsigned int __pad3;
  unsigned int __pad4;

  int __cur_writer;
  int __shared;
  signed char __rwelision;




  unsigned char __pad1[7];


  unsigned long int __pad2;


  unsigned int __flags;
# 55 "/usr/include/bits/struct_rwlock.h" 3 4
};
# 88 "/usr/include/bits/thread-shared-types.h" 2 3 4




struct __pthread_cond_s
{
  __extension__ union
  {
    __extension__ unsigned long long int __wseq;
    struct
    {
      unsigned int __low;
      unsigned int __high;
    } __wseq32;
  };
  __extension__ union
  {
    __extension__ unsigned long long int __g1_start;
    struct
    {
      unsigned int __low;
      unsigned int __high;
    } __g1_start32;
  };
  unsigned int __g_refs[2] ;
  unsigned int __g_size[2];
  unsigned int __g1_orig_size;
  unsigned int __wrefs;
  unsigned int __g_signals[2];
};
# 24 "/usr/include/bits/pthreadtypes.h" 2 3 4



typedef unsigned long int pthread_t;




typedef union
{
  char __size[4];
  int __align;
} pthread_mutexattr_t;




typedef union
{
  char __size[4];
  int __align;
} pthread_condattr_t;



typedef unsigned int pthread_key_t;



typedef int pthread_once_t;


union pthread_attr_t
{
  char __size[56];
  long int __align;
};

typedef union pthread_attr_t pthread_attr_t;




typedef union
{
  struct __pthread_mutex_s __data;
  char __size[40];
  long int __align;
} pthread_mutex_t;


typedef union
{
  struct __pthread_cond_s __data;
  char __size[48];
  __extension__ long long int __align;
} pthread_cond_t;





typedef union
{
  struct __pthread_rwlock_arch_t __data;
  char __size[56];
  long int __align;
} pthread_rwlock_t;

typedef union
{
  char __size[8];
  long int __align;
} pthread_rwlockattr_t;





typedef volatile int pthread_spinlock_t;




typedef union
{
  char __size[32];
  long int __align;
} pthread_barrier_t;

typedef union
{
  char __size[4];
  int __align;
} pthread_barrierattr_t;
# 228 "/usr/include/sys/types.h" 2 3 4



# 395 "/usr/include/stdlib.h" 2 3 4






extern long int random (void) __attribute__ ((__nothrow__ , __leaf__));


extern void srandom (unsigned int __seed) __attribute__ ((__nothrow__ , __leaf__));





extern char *initstate (unsigned int __seed, char *__statebuf,
   size_t __statelen) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));



extern char *setstate (char *__statebuf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 453 "/usr/include/stdlib.h" 3 4
extern int rand (void) __attribute__ ((__nothrow__ , __leaf__));

extern void srand (unsigned int __seed) __attribute__ ((__nothrow__ , __leaf__));



extern int rand_r (unsigned int *__seed) __attribute__ ((__nothrow__ , __leaf__));







extern double drand48 (void) __attribute__ ((__nothrow__ , __leaf__));
extern double erand48 (unsigned short int __xsubi[3]) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern long int lrand48 (void) __attribute__ ((__nothrow__ , __leaf__));
extern long int nrand48 (unsigned short int __xsubi[3])
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern long int mrand48 (void) __attribute__ ((__nothrow__ , __leaf__));
extern long int jrand48 (unsigned short int __xsubi[3])
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern void srand48 (long int __seedval) __attribute__ ((__nothrow__ , __leaf__));
extern unsigned short int *seed48 (unsigned short int __seed16v[3])
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
extern void lcong48 (unsigned short int __param[7]) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 539 "/usr/include/stdlib.h" 3 4
extern void *malloc (size_t __size) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__))
     __attribute__ ((__alloc_size__ (1))) ;

extern void *calloc (size_t __nmemb, size_t __size)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__)) __attribute__ ((__alloc_size__ (1, 2))) ;






extern void *realloc (void *__ptr, size_t __size)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__warn_unused_result__)) __attribute__ ((__alloc_size__ (2)));
# 565 "/usr/include/stdlib.h" 3 4
extern void free (void *__ptr) __attribute__ ((__nothrow__ , __leaf__));
# 580 "/usr/include/stdlib.h" 3 4
extern int posix_memalign (void **__memptr, size_t __alignment, size_t __size)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1))) ;




extern void *aligned_alloc (size_t __alignment, size_t __size)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__)) __attribute__ ((__alloc_size__ (2))) ;



extern void abort (void) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__noreturn__));



extern int atexit (void (*__func) (void)) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));







extern int at_quick_exit (void (*__func) (void)) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 617 "/usr/include/stdlib.h" 3 4
extern void exit (int __status) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__noreturn__));





extern void quick_exit (int __status) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__noreturn__));





extern void _Exit (int __status) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__noreturn__));




extern char *getenv (const char *__name) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1))) ;
# 647 "/usr/include/stdlib.h" 3 4
extern int putenv (char *__string) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));





extern int setenv (const char *__name, const char *__value, int __replace)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));


extern int unsetenv (const char *__name) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 688 "/usr/include/stdlib.h" 3 4
extern int mkstemp (char *__template) __attribute__ ((__nonnull__ (1))) ;
# 731 "/usr/include/stdlib.h" 3 4
extern char *mkdtemp (char *__template) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1))) ;
# 784 "/usr/include/stdlib.h" 3 4
extern int system (const char *__command) ;
# 800 "/usr/include/stdlib.h" 3 4
extern char *realpath (const char *__restrict __name,
         char *__restrict __resolved) __attribute__ ((__nothrow__ , __leaf__)) ;






typedef int (*__compar_fn_t) (const void *, const void *);
# 820 "/usr/include/stdlib.h" 3 4
extern void *bsearch (const void *__key, const void *__base,
        size_t __nmemb, size_t __size, __compar_fn_t __compar)
     __attribute__ ((__nonnull__ (1, 2, 5))) ;







extern void qsort (void *__base, size_t __nmemb, size_t __size,
     __compar_fn_t __compar) __attribute__ ((__nonnull__ (1, 4)));
# 840 "/usr/include/stdlib.h" 3 4
extern int abs (int __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;
extern long int labs (long int __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;


__extension__ extern long long int llabs (long long int __x)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;






extern div_t div (int __numer, int __denom)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;
extern ldiv_t ldiv (long int __numer, long int __denom)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;


__extension__ extern lldiv_t lldiv (long long int __numer,
        long long int __denom)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)) ;
# 922 "/usr/include/stdlib.h" 3 4
extern int mblen (const char *__s, size_t __n) __attribute__ ((__nothrow__ , __leaf__));


extern int mbtowc (wchar_t *__restrict __pwc,
     const char *__restrict __s, size_t __n) __attribute__ ((__nothrow__ , __leaf__));


extern int wctomb (char *__s, wchar_t __wchar) __attribute__ ((__nothrow__ , __leaf__));



extern size_t mbstowcs (wchar_t *__restrict __pwcs,
   const char *__restrict __s, size_t __n) __attribute__ ((__nothrow__ , __leaf__));

extern size_t wcstombs (char *__restrict __s,
   const wchar_t *__restrict __pwcs, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__));
# 957 "/usr/include/stdlib.h" 3 4
extern int getsubopt (char **__restrict __optionp,
        char *const *__restrict __tokens,
        char **__restrict __valuep)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2, 3))) ;







extern int posix_openpt (int __oflag) ;







extern int grantpt (int __fd) __attribute__ ((__nothrow__ , __leaf__));



extern int unlockpt (int __fd) __attribute__ ((__nothrow__ , __leaf__));




extern char *ptsname (int __fd) __attribute__ ((__nothrow__ , __leaf__)) ;
# 1013 "/usr/include/stdlib.h" 3 4
# 1 "/usr/include/bits/stdlib-float.h" 1 3 4
# 1014 "/usr/include/stdlib.h" 2 3 4
# 1023 "/usr/include/stdlib.h" 3 4

# 5 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/usr/include/string.h" 1 3 4
# 26 "/usr/include/string.h" 3 4
# 1 "/usr/include/bits/libc-header-start.h" 1 3 4
# 27 "/usr/include/string.h" 2 3 4






# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 34 "/usr/include/string.h" 2 3 4
# 43 "/usr/include/string.h" 3 4
extern void *memcpy (void *__restrict __dest, const void *__restrict __src,
       size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern void *memmove (void *__dest, const void *__src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));





extern void *memccpy (void *__restrict __dest, const void *__restrict __src,
        int __c, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));




extern void *memset (void *__s, int __c, size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int memcmp (const void *__s1, const void *__s2, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
# 91 "/usr/include/string.h" 3 4
extern void *memchr (const void *__s, int __c, size_t __n)
      __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
# 122 "/usr/include/string.h" 3 4
extern char *strcpy (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));

extern char *strncpy (char *__restrict __dest,
        const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern char *strcat (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));

extern char *strncat (char *__restrict __dest, const char *__restrict __src,
        size_t __n) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int strcmp (const char *__s1, const char *__s2)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));

extern int strncmp (const char *__s1, const char *__s2, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));


extern int strcoll (const char *__s1, const char *__s2)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));

extern size_t strxfrm (char *__restrict __dest,
         const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));



# 1 "/usr/include/bits/types/locale_t.h" 1 3 4
# 22 "/usr/include/bits/types/locale_t.h" 3 4
# 1 "/usr/include/bits/types/__locale_t.h" 1 3 4
# 28 "/usr/include/bits/types/__locale_t.h" 3 4
struct __locale_struct
{

  struct __locale_data *__locales[13];


  const unsigned short int *__ctype_b;
  const int *__ctype_tolower;
  const int *__ctype_toupper;


  const char *__names[13];
};

typedef struct __locale_struct *__locale_t;
# 23 "/usr/include/bits/types/locale_t.h" 2 3 4

typedef __locale_t locale_t;
# 154 "/usr/include/string.h" 2 3 4


extern int strcoll_l (const char *__s1, const char *__s2, locale_t __l)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2, 3)));


extern size_t strxfrm_l (char *__dest, const char *__src, size_t __n,
    locale_t __l) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 4)));





extern char *strdup (const char *__s)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__)) __attribute__ ((__nonnull__ (1)));






extern char *strndup (const char *__string, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__)) __attribute__ ((__nonnull__ (1)));
# 226 "/usr/include/string.h" 3 4
extern char *strchr (const char *__s, int __c)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
# 253 "/usr/include/string.h" 3 4
extern char *strrchr (const char *__s, int __c)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
# 273 "/usr/include/string.h" 3 4
extern size_t strcspn (const char *__s, const char *__reject)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));


extern size_t strspn (const char *__s, const char *__accept)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
# 303 "/usr/include/string.h" 3 4
extern char *strpbrk (const char *__s, const char *__accept)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
# 330 "/usr/include/string.h" 3 4
extern char *strstr (const char *__haystack, const char *__needle)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));




extern char *strtok (char *__restrict __s, const char *__restrict __delim)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));



extern char *__strtok_r (char *__restrict __s,
    const char *__restrict __delim,
    char **__restrict __save_ptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));

extern char *strtok_r (char *__restrict __s, const char *__restrict __delim,
         char **__restrict __save_ptr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));
# 385 "/usr/include/string.h" 3 4
extern size_t strlen (const char *__s)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));




extern size_t strnlen (const char *__string, size_t __maxlen)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));




extern char *strerror (int __errnum) __attribute__ ((__nothrow__ , __leaf__));
# 410 "/usr/include/string.h" 3 4
extern int strerror_r (int __errnum, char *__buf, size_t __buflen) __asm__ ("" "__xpg_strerror_r") __attribute__ ((__nothrow__ , __leaf__))

                        __attribute__ ((__nonnull__ (2)));
# 428 "/usr/include/string.h" 3 4
extern char *strerror_l (int __errnum, locale_t __l) __attribute__ ((__nothrow__ , __leaf__));
# 447 "/usr/include/string.h" 3 4
extern char *strsignal (int __sig) __attribute__ ((__nothrow__ , __leaf__));


extern char *__stpcpy (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *stpcpy (char *__restrict __dest, const char *__restrict __src)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));



extern char *__stpncpy (char *__restrict __dest,
   const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *stpncpy (char *__restrict __dest,
        const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
# 499 "/usr/include/string.h" 3 4

# 6 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/usr/include/time.h" 1 3 4
# 29 "/usr/include/time.h" 3 4
# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 30 "/usr/include/time.h" 2 3 4



# 1 "/usr/include/bits/time.h" 1 3 4
# 34 "/usr/include/time.h" 2 3 4





# 1 "/usr/include/bits/types/struct_tm.h" 1 3 4






struct tm
{
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;





  long int __tm_gmtoff;
  const char *__tm_zone;

};
# 40 "/usr/include/time.h" 2 3 4


# 1 "/usr/include/bits/types/struct_timespec.h" 1 3 4





# 1 "/usr/include/bits/endian.h" 1 3 4
# 35 "/usr/include/bits/endian.h" 3 4
# 1 "/usr/include/bits/endianness.h" 1 3 4
# 36 "/usr/include/bits/endian.h" 2 3 4
# 7 "/usr/include/bits/types/struct_timespec.h" 2 3 4



struct timespec
{
  __time_t tv_sec;



  __syscall_slong_t tv_nsec;
# 26 "/usr/include/bits/types/struct_timespec.h" 3 4
};
# 43 "/usr/include/time.h" 2 3 4





# 1 "/usr/include/bits/types/struct_itimerspec.h" 1 3 4







struct itimerspec
  {
    struct timespec it_interval;
    struct timespec it_value;
  };
# 49 "/usr/include/time.h" 2 3 4
struct sigevent;
# 68 "/usr/include/time.h" 3 4




extern clock_t clock (void) __attribute__ ((__nothrow__ , __leaf__));


extern time_t time (time_t *__timer) __attribute__ ((__nothrow__ , __leaf__));


extern double difftime (time_t __time1, time_t __time0)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));


extern time_t mktime (struct tm *__tp) __attribute__ ((__nothrow__ , __leaf__));





extern size_t strftime (char *__restrict __s, size_t __maxsize,
   const char *__restrict __format,
   const struct tm *__restrict __tp) __attribute__ ((__nothrow__ , __leaf__));




extern char *strptime (const char *__restrict __s,
         const char *__restrict __fmt, struct tm *__tp)
     __attribute__ ((__nothrow__ , __leaf__));






extern size_t strftime_l (char *__restrict __s, size_t __maxsize,
     const char *__restrict __format,
     const struct tm *__restrict __tp,
     locale_t __loc) __attribute__ ((__nothrow__ , __leaf__));
# 119 "/usr/include/time.h" 3 4
extern struct tm *gmtime (const time_t *__timer) __attribute__ ((__nothrow__ , __leaf__));



extern struct tm *localtime (const time_t *__timer) __attribute__ ((__nothrow__ , __leaf__));




extern struct tm *gmtime_r (const time_t *__restrict __timer,
       struct tm *__restrict __tp) __attribute__ ((__nothrow__ , __leaf__));



extern struct tm *localtime_r (const time_t *__restrict __timer,
          struct tm *__restrict __tp) __attribute__ ((__nothrow__ , __leaf__));




extern char *asctime (const struct tm *__tp) __attribute__ ((__nothrow__ , __leaf__));


extern char *ctime (const time_t *__timer) __attribute__ ((__nothrow__ , __leaf__));






extern char *asctime_r (const struct tm *__restrict __tp,
   char *__restrict __buf) __attribute__ ((__nothrow__ , __leaf__));


extern char *ctime_r (const time_t *__restrict __timer,
        char *__restrict __buf) __attribute__ ((__nothrow__ , __leaf__));




extern char *__tzname[2];
extern int __daylight;
extern long int __timezone;




extern char *tzname[2];



extern void tzset (void) __attribute__ ((__nothrow__ , __leaf__));



extern int daylight;
extern long int timezone;
# 205 "/usr/include/time.h" 3 4
extern int nanosleep (const struct timespec *__requested_time,
        struct timespec *__remaining);



extern int clock_getres (clockid_t __clock_id, struct timespec *__res) __attribute__ ((__nothrow__ , __leaf__));


extern int clock_gettime (clockid_t __clock_id, struct timespec *__tp) __attribute__ ((__nothrow__ , __leaf__));


extern int clock_settime (clockid_t __clock_id, const struct timespec *__tp)
     __attribute__ ((__nothrow__ , __leaf__));






extern int clock_nanosleep (clockid_t __clock_id, int __flags,
       const struct timespec *__req,
       struct timespec *__rem);


extern int clock_getcpuclockid (pid_t __pid, clockid_t *__clock_id) __attribute__ ((__nothrow__ , __leaf__));




extern int timer_create (clockid_t __clock_id,
    struct sigevent *__restrict __evp,
    timer_t *__restrict __timerid) __attribute__ ((__nothrow__ , __leaf__));


extern int timer_delete (timer_t __timerid) __attribute__ ((__nothrow__ , __leaf__));


extern int timer_settime (timer_t __timerid, int __flags,
     const struct itimerspec *__restrict __value,
     struct itimerspec *__restrict __ovalue) __attribute__ ((__nothrow__ , __leaf__));


extern int timer_gettime (timer_t __timerid, struct itimerspec *__value)
     __attribute__ ((__nothrow__ , __leaf__));


extern int timer_getoverrun (timer_t __timerid) __attribute__ ((__nothrow__ , __leaf__));





extern int timespec_get (struct timespec *__ts, int __base)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 274 "/usr/include/time.h" 3 4
extern int getdate_err;
# 283 "/usr/include/time.h" 3 4
extern struct tm *getdate (const char *__string);
# 301 "/usr/include/time.h" 3 4

# 7 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/usr/include/signal.h" 1 3 4
# 27 "/usr/include/signal.h" 3 4



# 1 "/usr/include/bits/signum.h" 1 3 4
# 26 "/usr/include/bits/signum.h" 3 4
# 1 "/usr/include/bits/signum-generic.h" 1 3 4
# 27 "/usr/include/bits/signum.h" 2 3 4
# 31 "/usr/include/signal.h" 2 3 4

# 1 "/usr/include/bits/types/sig_atomic_t.h" 1 3 4







typedef __sig_atomic_t sig_atomic_t;
# 33 "/usr/include/signal.h" 2 3 4


# 1 "/usr/include/bits/types/sigset_t.h" 1 3 4



# 1 "/usr/include/bits/types/__sigset_t.h" 1 3 4




typedef struct
{
  unsigned long int __val[(1024 / (8 * sizeof (unsigned long int)))];
} __sigset_t;
# 5 "/usr/include/bits/types/sigset_t.h" 2 3 4


typedef __sigset_t sigset_t;
# 36 "/usr/include/signal.h" 2 3 4
# 57 "/usr/include/signal.h" 3 4
# 1 "/usr/include/bits/types/siginfo_t.h" 1 3 4



# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 5 "/usr/include/bits/types/siginfo_t.h" 2 3 4

# 1 "/usr/include/bits/types/__sigval_t.h" 1 3 4
# 24 "/usr/include/bits/types/__sigval_t.h" 3 4
union sigval
{
  int sival_int;
  void *sival_ptr;
};

typedef union sigval __sigval_t;
# 7 "/usr/include/bits/types/siginfo_t.h" 2 3 4
# 16 "/usr/include/bits/types/siginfo_t.h" 3 4
# 1 "/usr/include/bits/siginfo-arch.h" 1 3 4
# 17 "/usr/include/bits/types/siginfo_t.h" 2 3 4
# 36 "/usr/include/bits/types/siginfo_t.h" 3 4
typedef struct
  {
    int si_signo;

    int si_errno;

    int si_code;





    int __pad0;


    union
      {
 int _pad[((128 / sizeof (int)) - 4)];


 struct
   {
     __pid_t si_pid;
     __uid_t si_uid;
   } _kill;


 struct
   {
     int si_tid;
     int si_overrun;
     __sigval_t si_sigval;
   } _timer;


 struct
   {
     __pid_t si_pid;
     __uid_t si_uid;
     __sigval_t si_sigval;
   } _rt;


 struct
   {
     __pid_t si_pid;
     __uid_t si_uid;
     int si_status;
     __clock_t si_utime;
     __clock_t si_stime;
   } _sigchld;


 struct
   {
     void *si_addr;
    
     short int si_addr_lsb;
     union
       {

  struct
    {
      void *_lower;
      void *_upper;
    } _addr_bnd;

  __uint32_t _pkey;
       } _bounds;
   } _sigfault;


 struct
   {
     long int si_band;
     int si_fd;
   } _sigpoll;



 struct
   {
     void *_call_addr;
     int _syscall;
     unsigned int _arch;
   } _sigsys;

      } _sifields;
  } siginfo_t ;
# 58 "/usr/include/signal.h" 2 3 4
# 1 "/usr/include/bits/siginfo-consts.h" 1 3 4
# 35 "/usr/include/bits/siginfo-consts.h" 3 4
enum
{
  SI_ASYNCNL = -60,
  SI_DETHREAD = -7,

  SI_TKILL,
  SI_SIGIO,

  SI_ASYNCIO,
  SI_MESGQ,
  SI_TIMER,





  SI_QUEUE,
  SI_USER,
  SI_KERNEL = 0x80
# 66 "/usr/include/bits/siginfo-consts.h" 3 4
};




enum
{
  ILL_ILLOPC = 1,

  ILL_ILLOPN,

  ILL_ILLADR,

  ILL_ILLTRP,

  ILL_PRVOPC,

  ILL_PRVREG,

  ILL_COPROC,

  ILL_BADSTK,

  ILL_BADIADDR

};


enum
{
  FPE_INTDIV = 1,

  FPE_INTOVF,

  FPE_FLTDIV,

  FPE_FLTOVF,

  FPE_FLTUND,

  FPE_FLTRES,

  FPE_FLTINV,

  FPE_FLTSUB,

  FPE_FLTUNK = 14,

  FPE_CONDTRAP

};


enum
{
  SEGV_MAPERR = 1,

  SEGV_ACCERR,

  SEGV_BNDERR,

  SEGV_PKUERR,

  SEGV_ACCADI,

  SEGV_ADIDERR,

  SEGV_ADIPERR

};


enum
{
  BUS_ADRALN = 1,

  BUS_ADRERR,

  BUS_OBJERR,

  BUS_MCEERR_AR,

  BUS_MCEERR_AO

};




enum
{
  TRAP_BRKPT = 1,

  TRAP_TRACE,

  TRAP_BRANCH,

  TRAP_HWBKPT,

  TRAP_UNK

};




enum
{
  CLD_EXITED = 1,

  CLD_KILLED,

  CLD_DUMPED,

  CLD_TRAPPED,

  CLD_STOPPED,

  CLD_CONTINUED

};


enum
{
  POLL_IN = 1,

  POLL_OUT,

  POLL_MSG,

  POLL_ERR,

  POLL_PRI,

  POLL_HUP

};
# 59 "/usr/include/signal.h" 2 3 4







# 1 "/usr/include/bits/types/sigevent_t.h" 1 3 4



# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 5 "/usr/include/bits/types/sigevent_t.h" 2 3 4
# 22 "/usr/include/bits/types/sigevent_t.h" 3 4
typedef struct sigevent
  {
    __sigval_t sigev_value;
    int sigev_signo;
    int sigev_notify;

    union
      {
 int _pad[((64 / sizeof (int)) - 4)];



 __pid_t _tid;

 struct
   {
     void (*_function) (__sigval_t);
     pthread_attr_t *_attribute;
   } _sigev_thread;
      } _sigev_un;
  } sigevent_t;
# 67 "/usr/include/signal.h" 2 3 4
# 1 "/usr/include/bits/sigevent-consts.h" 1 3 4
# 27 "/usr/include/bits/sigevent-consts.h" 3 4
enum
{
  SIGEV_SIGNAL = 0,

  SIGEV_NONE,

  SIGEV_THREAD,


  SIGEV_THREAD_ID = 4


};
# 68 "/usr/include/signal.h" 2 3 4




typedef void (*__sighandler_t) (int);




extern __sighandler_t __sysv_signal (int __sig, __sighandler_t __handler)
     __attribute__ ((__nothrow__ , __leaf__));
# 93 "/usr/include/signal.h" 3 4
extern __sighandler_t signal (int __sig, __sighandler_t __handler) __asm__ ("" "__sysv_signal") __attribute__ ((__nothrow__ , __leaf__))

                        ;
# 112 "/usr/include/signal.h" 3 4
extern int kill (__pid_t __pid, int __sig) __attribute__ ((__nothrow__ , __leaf__));






extern int killpg (__pid_t __pgrp, int __sig) __attribute__ ((__nothrow__ , __leaf__));



extern int raise (int __sig) __attribute__ ((__nothrow__ , __leaf__));
# 134 "/usr/include/signal.h" 3 4
extern void psignal (int __sig, const char *__s);


extern void psiginfo (const siginfo_t *__pinfo, const char *__s);
# 151 "/usr/include/signal.h" 3 4
extern int sigpause (int __sig) __asm__ ("__xpg_sigpause");
# 196 "/usr/include/signal.h" 3 4
extern int sigemptyset (sigset_t *__set) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int sigfillset (sigset_t *__set) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int sigaddset (sigset_t *__set, int __signo) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int sigdelset (sigset_t *__set, int __signo) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int sigismember (const sigset_t *__set, int __signo)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 226 "/usr/include/signal.h" 3 4
# 1 "/usr/include/bits/sigaction.h" 1 3 4
# 27 "/usr/include/bits/sigaction.h" 3 4
struct sigaction
  {


    union
      {

 __sighandler_t sa_handler;

 void (*sa_sigaction) (int, siginfo_t *, void *);
      }
    __sigaction_handler;







    __sigset_t sa_mask;


    int sa_flags;


    void (*sa_restorer) (void);
  };
# 227 "/usr/include/signal.h" 2 3 4


extern int sigprocmask (int __how, const sigset_t *__restrict __set,
   sigset_t *__restrict __oset) __attribute__ ((__nothrow__ , __leaf__));






extern int sigsuspend (const sigset_t *__set) __attribute__ ((__nonnull__ (1)));


extern int sigaction (int __sig, const struct sigaction *__restrict __act,
        struct sigaction *__restrict __oact) __attribute__ ((__nothrow__ , __leaf__));


extern int sigpending (sigset_t *__set) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));







extern int sigwait (const sigset_t *__restrict __set, int *__restrict __sig)
     __attribute__ ((__nonnull__ (1, 2)));







extern int sigwaitinfo (const sigset_t *__restrict __set,
   siginfo_t *__restrict __info) __attribute__ ((__nonnull__ (1)));






extern int sigtimedwait (const sigset_t *__restrict __set,
    siginfo_t *__restrict __info,
    const struct timespec *__restrict __timeout)
     __attribute__ ((__nonnull__ (1)));



extern int sigqueue (__pid_t __pid, int __sig, const union sigval __val)
     __attribute__ ((__nothrow__ , __leaf__));
# 301 "/usr/include/signal.h" 3 4
# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 302 "/usr/include/signal.h" 2 3 4

# 1 "/usr/include/bits/types/stack_t.h" 1 3 4
# 23 "/usr/include/bits/types/stack_t.h" 3 4
# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 24 "/usr/include/bits/types/stack_t.h" 2 3 4


typedef struct
  {
    void *ss_sp;
    int ss_flags;
    size_t ss_size;
  } stack_t;
# 304 "/usr/include/signal.h" 2 3 4


# 1 "/usr/include/sys/ucontext.h" 1 3 4
# 37 "/usr/include/sys/ucontext.h" 3 4
__extension__ typedef long long int greg_t;
# 46 "/usr/include/sys/ucontext.h" 3 4
typedef greg_t gregset_t[23];
# 101 "/usr/include/sys/ucontext.h" 3 4
struct _libc_fpxreg
{
  unsigned short int __significand[4];
  unsigned short int __exponent;
  unsigned short int __glibc_reserved1[3];
};

struct _libc_xmmreg
{
  __uint32_t __element[4];
};

struct _libc_fpstate
{

  __uint16_t __cwd;
  __uint16_t __swd;
  __uint16_t __ftw;
  __uint16_t __fop;
  __uint64_t __rip;
  __uint64_t __rdp;
  __uint32_t __mxcsr;
  __uint32_t __mxcr_mask;
  struct _libc_fpxreg _st[8];
  struct _libc_xmmreg _xmm[16];
  __uint32_t __glibc_reserved1[24];
};


typedef struct _libc_fpstate *fpregset_t;


typedef struct
  {
    gregset_t __gregs;

    fpregset_t __fpregs;
    __extension__ unsigned long long __reserved1 [8];
} mcontext_t;


typedef struct ucontext_t
  {
    unsigned long int __uc_flags;
    struct ucontext_t *uc_link;
    stack_t uc_stack;
    mcontext_t uc_mcontext;
    sigset_t uc_sigmask;
    struct _libc_fpstate __fpregs_mem;
    __extension__ unsigned long long int __ssp[4];
  } ucontext_t;
# 307 "/usr/include/signal.h" 2 3 4







extern int siginterrupt (int __sig, int __interrupt) __attribute__ ((__nothrow__ , __leaf__));

# 1 "/usr/include/bits/sigstack.h" 1 3 4
# 317 "/usr/include/signal.h" 2 3 4
# 1 "/usr/include/bits/ss_flags.h" 1 3 4
# 27 "/usr/include/bits/ss_flags.h" 3 4
enum
{
  SS_ONSTACK = 1,

  SS_DISABLE

};
# 318 "/usr/include/signal.h" 2 3 4



extern int sigaltstack (const stack_t *__restrict __ss,
   stack_t *__restrict __oss) __attribute__ ((__nothrow__ , __leaf__));
# 343 "/usr/include/signal.h" 3 4
extern int sighold (int __sig) __attribute__ ((__nothrow__ , __leaf__));


extern int sigrelse (int __sig) __attribute__ ((__nothrow__ , __leaf__));


extern int sigignore (int __sig) __attribute__ ((__nothrow__ , __leaf__));


extern __sighandler_t sigset (int __sig, __sighandler_t __disp) __attribute__ ((__nothrow__ , __leaf__));






# 1 "/usr/include/bits/sigthread.h" 1 3 4
# 31 "/usr/include/bits/sigthread.h" 3 4
extern int pthread_sigmask (int __how,
       const __sigset_t *__restrict __newmask,
       __sigset_t *__restrict __oldmask)__attribute__ ((__nothrow__ , __leaf__));


extern int pthread_kill (pthread_t __threadid, int __signo) __attribute__ ((__nothrow__ , __leaf__));
# 360 "/usr/include/signal.h" 2 3 4






extern int __libc_current_sigrtmin (void) __attribute__ ((__nothrow__ , __leaf__));

extern int __libc_current_sigrtmax (void) __attribute__ ((__nothrow__ , __leaf__));





# 1 "/usr/include/bits/signal_ext.h" 1 3 4
# 375 "/usr/include/signal.h" 2 3 4


# 8 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/usr/include/pthread.h" 1 3 4
# 22 "/usr/include/pthread.h" 3 4
# 1 "/usr/include/sched.h" 1 3 4
# 29 "/usr/include/sched.h" 3 4
# 1 "/usr/lib64/gcc/x86_64-suse-linux/7/include/stddef.h" 1 3 4
# 30 "/usr/include/sched.h" 2 3 4
# 43 "/usr/include/sched.h" 3 4
# 1 "/usr/include/bits/sched.h" 1 3 4
# 76 "/usr/include/bits/sched.h" 3 4
# 1 "/usr/include/bits/types/struct_sched_param.h" 1 3 4
# 23 "/usr/include/bits/types/struct_sched_param.h" 3 4
struct sched_param
{
  int sched_priority;
};
# 77 "/usr/include/bits/sched.h" 2 3 4


# 98 "/usr/include/bits/sched.h" 3 4

# 44 "/usr/include/sched.h" 2 3 4
# 1 "/usr/include/bits/cpu-set.h" 1 3 4
# 32 "/usr/include/bits/cpu-set.h" 3 4
typedef unsigned long int __cpu_mask;






typedef struct
{
  __cpu_mask __bits[1024 / (8 * sizeof (__cpu_mask))];
} cpu_set_t;
# 115 "/usr/include/bits/cpu-set.h" 3 4


extern int __sched_cpucount (size_t __setsize, const cpu_set_t *__setp)
     __attribute__ ((__nothrow__ , __leaf__));
extern cpu_set_t *__sched_cpualloc (size_t __count) __attribute__ ((__nothrow__ , __leaf__)) ;
extern void __sched_cpufree (cpu_set_t *__set) __attribute__ ((__nothrow__ , __leaf__));


# 45 "/usr/include/sched.h" 2 3 4









extern int sched_setparam (__pid_t __pid, const struct sched_param *__param)
     __attribute__ ((__nothrow__ , __leaf__));


extern int sched_getparam (__pid_t __pid, struct sched_param *__param) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_setscheduler (__pid_t __pid, int __policy,
          const struct sched_param *__param) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_getscheduler (__pid_t __pid) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_yield (void) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_get_priority_max (int __algorithm) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_get_priority_min (int __algorithm) __attribute__ ((__nothrow__ , __leaf__));


extern int sched_rr_get_interval (__pid_t __pid, struct timespec *__t) __attribute__ ((__nothrow__ , __leaf__));
# 129 "/usr/include/sched.h" 3 4

# 23 "/usr/include/pthread.h" 2 3 4




# 1 "/usr/include/bits/setjmp.h" 1 3 4
# 26 "/usr/include/bits/setjmp.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 27 "/usr/include/bits/setjmp.h" 2 3 4




typedef long int __jmp_buf[8];
# 28 "/usr/include/pthread.h" 2 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 29 "/usr/include/pthread.h" 2 3 4




enum
{
  PTHREAD_CREATE_JOINABLE,

  PTHREAD_CREATE_DETACHED

};



enum
{
  PTHREAD_MUTEX_TIMED_NP,
  PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_ADAPTIVE_NP

  ,
  PTHREAD_MUTEX_NORMAL = PTHREAD_MUTEX_TIMED_NP,
  PTHREAD_MUTEX_RECURSIVE = PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK = PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL





};




enum
{
  PTHREAD_MUTEX_STALLED,
  PTHREAD_MUTEX_STALLED_NP = PTHREAD_MUTEX_STALLED,
  PTHREAD_MUTEX_ROBUST,
  PTHREAD_MUTEX_ROBUST_NP = PTHREAD_MUTEX_ROBUST
};





enum
{
  PTHREAD_PRIO_NONE,
  PTHREAD_PRIO_INHERIT,
  PTHREAD_PRIO_PROTECT
};
# 100 "/usr/include/pthread.h" 3 4
enum
{
  PTHREAD_RWLOCK_PREFER_READER_NP,
  PTHREAD_RWLOCK_PREFER_WRITER_NP,
  PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP,
  PTHREAD_RWLOCK_DEFAULT_NP = PTHREAD_RWLOCK_PREFER_READER_NP
};
# 120 "/usr/include/pthread.h" 3 4
enum
{
  PTHREAD_INHERIT_SCHED,

  PTHREAD_EXPLICIT_SCHED

};



enum
{
  PTHREAD_SCOPE_SYSTEM,

  PTHREAD_SCOPE_PROCESS

};



enum
{
  PTHREAD_PROCESS_PRIVATE,

  PTHREAD_PROCESS_SHARED

};
# 155 "/usr/include/pthread.h" 3 4
struct _pthread_cleanup_buffer
{
  void (*__routine) (void *);
  void *__arg;
  int __canceltype;
  struct _pthread_cleanup_buffer *__prev;
};


enum
{
  PTHREAD_CANCEL_ENABLE,

  PTHREAD_CANCEL_DISABLE

};
enum
{
  PTHREAD_CANCEL_DEFERRED,

  PTHREAD_CANCEL_ASYNCHRONOUS

};
# 193 "/usr/include/pthread.h" 3 4





extern int pthread_create (pthread_t *__restrict __newthread,
      const pthread_attr_t *__restrict __attr,
      void *(*__start_routine) (void *),
      void *__restrict __arg) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 3)));





extern void pthread_exit (void *__retval) __attribute__ ((__noreturn__));







extern int pthread_join (pthread_t __th, void **__thread_return);
# 247 "/usr/include/pthread.h" 3 4
extern int pthread_detach (pthread_t __th) __attribute__ ((__nothrow__ , __leaf__));



extern pthread_t pthread_self (void) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));


extern int pthread_equal (pthread_t __thread1, pthread_t __thread2)
  __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));







extern int pthread_attr_init (pthread_attr_t *__attr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_attr_destroy (pthread_attr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_attr_getdetachstate (const pthread_attr_t *__attr,
     int *__detachstate)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setdetachstate (pthread_attr_t *__attr,
     int __detachstate)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_attr_getguardsize (const pthread_attr_t *__attr,
          size_t *__guardsize)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setguardsize (pthread_attr_t *__attr,
          size_t __guardsize)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_attr_getschedparam (const pthread_attr_t *__restrict __attr,
           struct sched_param *__restrict __param)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setschedparam (pthread_attr_t *__restrict __attr,
           const struct sched_param *__restrict
           __param) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_getschedpolicy (const pthread_attr_t *__restrict
     __attr, int *__restrict __policy)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setschedpolicy (pthread_attr_t *__attr, int __policy)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_attr_getinheritsched (const pthread_attr_t *__restrict
      __attr, int *__restrict __inherit)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setinheritsched (pthread_attr_t *__attr,
      int __inherit)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_attr_getscope (const pthread_attr_t *__restrict __attr,
      int *__restrict __scope)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_attr_setscope (pthread_attr_t *__attr, int __scope)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_attr_getstackaddr (const pthread_attr_t *__restrict
          __attr, void **__restrict __stackaddr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2))) __attribute__ ((__deprecated__));





extern int pthread_attr_setstackaddr (pthread_attr_t *__attr,
          void *__stackaddr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1))) __attribute__ ((__deprecated__));


extern int pthread_attr_getstacksize (const pthread_attr_t *__restrict
          __attr, size_t *__restrict __stacksize)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));




extern int pthread_attr_setstacksize (pthread_attr_t *__attr,
          size_t __stacksize)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_attr_getstack (const pthread_attr_t *__restrict __attr,
      void **__restrict __stackaddr,
      size_t *__restrict __stacksize)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2, 3)));




extern int pthread_attr_setstack (pthread_attr_t *__attr, void *__stackaddr,
      size_t __stacksize) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 405 "/usr/include/pthread.h" 3 4
extern int pthread_setschedparam (pthread_t __target_thread, int __policy,
      const struct sched_param *__param)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (3)));


extern int pthread_getschedparam (pthread_t __target_thread,
      int *__restrict __policy,
      struct sched_param *__restrict __param)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));


extern int pthread_setschedprio (pthread_t __target_thread, int __prio)
     __attribute__ ((__nothrow__ , __leaf__));
# 434 "/usr/include/pthread.h" 3 4
extern int pthread_getconcurrency (void) __attribute__ ((__nothrow__ , __leaf__));


extern int pthread_setconcurrency (int __level) __attribute__ ((__nothrow__ , __leaf__));
# 470 "/usr/include/pthread.h" 3 4
extern int pthread_once (pthread_once_t *__once_control,
    void (*__init_routine) (void)) __attribute__ ((__nonnull__ (1, 2)));
# 482 "/usr/include/pthread.h" 3 4
extern int pthread_setcancelstate (int __state, int *__oldstate);



extern int pthread_setcanceltype (int __type, int *__oldtype);


extern int pthread_cancel (pthread_t __th);




extern void pthread_testcancel (void);




typedef struct
{
  struct
  {
    __jmp_buf __cancel_jmp_buf;
    int __mask_was_saved;
  } __cancel_jmp_buf[1];
  void *__pad[4];
} __pthread_unwind_buf_t __attribute__ ((__aligned__));
# 516 "/usr/include/pthread.h" 3 4
struct __pthread_cleanup_frame
{
  void (*__cancel_routine) (void *);
  void *__cancel_arg;
  int __do_it;
  int __cancel_type;
};
# 656 "/usr/include/pthread.h" 3 4
extern void __pthread_register_cancel (__pthread_unwind_buf_t *__buf)
     ;
# 668 "/usr/include/pthread.h" 3 4
extern void __pthread_unregister_cancel (__pthread_unwind_buf_t *__buf)
  ;
# 709 "/usr/include/pthread.h" 3 4
extern void __pthread_unwind_next (__pthread_unwind_buf_t *__buf)
     __attribute__ ((__noreturn__))

     __attribute__ ((__weak__))

     ;



struct __jmp_buf_tag;
extern int __sigsetjmp (struct __jmp_buf_tag *__env, int __savemask) __attribute__ ((__nothrow__));





extern int pthread_mutex_init (pthread_mutex_t *__mutex,
          const pthread_mutexattr_t *__mutexattr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutex_destroy (pthread_mutex_t *__mutex)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutex_trylock (pthread_mutex_t *__mutex)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutex_lock (pthread_mutex_t *__mutex)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_mutex_timedlock (pthread_mutex_t *__restrict __mutex,
        const struct timespec *__restrict
        __abstime) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
# 756 "/usr/include/pthread.h" 3 4
extern int pthread_mutex_unlock (pthread_mutex_t *__mutex)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_mutex_getprioceiling (const pthread_mutex_t *
      __restrict __mutex,
      int *__restrict __prioceiling)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));



extern int pthread_mutex_setprioceiling (pthread_mutex_t *__restrict __mutex,
      int __prioceiling,
      int *__restrict __old_ceiling)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 3)));




extern int pthread_mutex_consistent (pthread_mutex_t *__mutex)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 789 "/usr/include/pthread.h" 3 4
extern int pthread_mutexattr_init (pthread_mutexattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutexattr_destroy (pthread_mutexattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutexattr_getpshared (const pthread_mutexattr_t *
      __restrict __attr,
      int *__restrict __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_mutexattr_setpshared (pthread_mutexattr_t *__attr,
      int __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_mutexattr_gettype (const pthread_mutexattr_t *__restrict
          __attr, int *__restrict __kind)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));




extern int pthread_mutexattr_settype (pthread_mutexattr_t *__attr, int __kind)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_mutexattr_getprotocol (const pthread_mutexattr_t *
       __restrict __attr,
       int *__restrict __protocol)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));



extern int pthread_mutexattr_setprotocol (pthread_mutexattr_t *__attr,
       int __protocol)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_mutexattr_getprioceiling (const pthread_mutexattr_t *
          __restrict __attr,
          int *__restrict __prioceiling)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_mutexattr_setprioceiling (pthread_mutexattr_t *__attr,
          int __prioceiling)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_mutexattr_getrobust (const pthread_mutexattr_t *__attr,
     int *__robustness)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));







extern int pthread_mutexattr_setrobust (pthread_mutexattr_t *__attr,
     int __robustness)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 871 "/usr/include/pthread.h" 3 4
extern int pthread_rwlock_init (pthread_rwlock_t *__restrict __rwlock,
    const pthread_rwlockattr_t *__restrict
    __attr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlock_destroy (pthread_rwlock_t *__rwlock)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlock_rdlock (pthread_rwlock_t *__rwlock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlock_tryrdlock (pthread_rwlock_t *__rwlock)
  __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_rwlock_timedrdlock (pthread_rwlock_t *__restrict __rwlock,
           const struct timespec *__restrict
           __abstime) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
# 902 "/usr/include/pthread.h" 3 4
extern int pthread_rwlock_wrlock (pthread_rwlock_t *__rwlock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlock_trywrlock (pthread_rwlock_t *__rwlock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_rwlock_timedwrlock (pthread_rwlock_t *__restrict __rwlock,
           const struct timespec *__restrict
           __abstime) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
# 924 "/usr/include/pthread.h" 3 4
extern int pthread_rwlock_unlock (pthread_rwlock_t *__rwlock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));





extern int pthread_rwlockattr_init (pthread_rwlockattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlockattr_destroy (pthread_rwlockattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlockattr_getpshared (const pthread_rwlockattr_t *
       __restrict __attr,
       int *__restrict __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_rwlockattr_setpshared (pthread_rwlockattr_t *__attr,
       int __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_rwlockattr_getkind_np (const pthread_rwlockattr_t *
       __restrict __attr,
       int *__restrict __pref)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_rwlockattr_setkind_np (pthread_rwlockattr_t *__attr,
       int __pref) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));







extern int pthread_cond_init (pthread_cond_t *__restrict __cond,
         const pthread_condattr_t *__restrict __cond_attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_cond_destroy (pthread_cond_t *__cond)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_cond_signal (pthread_cond_t *__cond)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_cond_broadcast (pthread_cond_t *__cond)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));






extern int pthread_cond_wait (pthread_cond_t *__restrict __cond,
         pthread_mutex_t *__restrict __mutex)
     __attribute__ ((__nonnull__ (1, 2)));
# 997 "/usr/include/pthread.h" 3 4
extern int pthread_cond_timedwait (pthread_cond_t *__restrict __cond,
       pthread_mutex_t *__restrict __mutex,
       const struct timespec *__restrict __abstime)
     __attribute__ ((__nonnull__ (1, 2, 3)));
# 1020 "/usr/include/pthread.h" 3 4
extern int pthread_condattr_init (pthread_condattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_condattr_destroy (pthread_condattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_condattr_getpshared (const pthread_condattr_t *
     __restrict __attr,
     int *__restrict __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_condattr_setpshared (pthread_condattr_t *__attr,
     int __pshared) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_condattr_getclock (const pthread_condattr_t *
          __restrict __attr,
          __clockid_t *__restrict __clock_id)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_condattr_setclock (pthread_condattr_t *__attr,
          __clockid_t __clock_id)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 1056 "/usr/include/pthread.h" 3 4
extern int pthread_spin_init (pthread_spinlock_t *__lock, int __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_spin_destroy (pthread_spinlock_t *__lock)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_spin_lock (pthread_spinlock_t *__lock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_spin_trylock (pthread_spinlock_t *__lock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_spin_unlock (pthread_spinlock_t *__lock)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));






extern int pthread_barrier_init (pthread_barrier_t *__restrict __barrier,
     const pthread_barrierattr_t *__restrict
     __attr, unsigned int __count)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_barrier_destroy (pthread_barrier_t *__barrier)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_barrier_wait (pthread_barrier_t *__barrier)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));



extern int pthread_barrierattr_init (pthread_barrierattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_barrierattr_destroy (pthread_barrierattr_t *__attr)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_barrierattr_getpshared (const pthread_barrierattr_t *
        __restrict __attr,
        int *__restrict __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));


extern int pthread_barrierattr_setpshared (pthread_barrierattr_t *__attr,
        int __pshared)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 1123 "/usr/include/pthread.h" 3 4
extern int pthread_key_create (pthread_key_t *__key,
          void (*__destr_function) (void *))
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));


extern int pthread_key_delete (pthread_key_t __key) __attribute__ ((__nothrow__ , __leaf__));


extern void *pthread_getspecific (pthread_key_t __key) __attribute__ ((__nothrow__ , __leaf__));


extern int pthread_setspecific (pthread_key_t __key,
    const void *__pointer) __attribute__ ((__nothrow__ , __leaf__)) ;




extern int pthread_getcpuclockid (pthread_t __thread_id,
      __clockid_t *__clock_id)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
# 1157 "/usr/include/pthread.h" 3 4
extern int pthread_atfork (void (*__prepare) (void),
      void (*__parent) (void),
      void (*__child) (void)) __attribute__ ((__nothrow__ , __leaf__));
# 1171 "/usr/include/pthread.h" 3 4

# 9 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2

# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_consts.h" 1
# 11 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h" 1






# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_consts.h" 1
# 8 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h" 2



# 10 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
typedef int clockid_t;





typedef struct array_tag {
  void **data;
  int size;
  int after;
  pthread_mutex_t mutex;
} array_t;




typedef struct varray_tag {
  volatile void **data;
  int size;
  int after;
  pthread_mutex_t mutex;
} varray_t;





extern int is_initialized;




extern array_t *threads;
# 51 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
extern array_t *thread_attrs;




extern array_t *thread_keys;




extern array_t *mutexes;
# 70 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
extern array_t *mutex_attrs;




extern array_t *once_ctrls;





extern array_t *conds;
# 90 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
extern array_t *cond_attrs ;





extern array_t *barriers;
# 105 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
extern array_t *barrier_attrs;





extern varray_t *spinlocks;





extern array_t *rwlocks;
# 126 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_data.h"
extern array_t *rwlock_attrs;

void thread_init_internal(int *);
void thread_destroy_internal(int *);



void array_init(array_t **array,int size);

void varray_init(varray_t **array,int size);

void array_resize(array_t **array,int size);

void varray_resize(varray_t **array,int size);

void array_delete(array_t *array);

void varray_delete(varray_t *array);


int is_valid(array_t *arr, int id);


int vis_valid(varray_t *arr, int id);
# 12 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2
# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_attr.h" 1
# 22 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_attr.h"
# 1 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_consts.h" 1
# 23 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_attr.h" 2






void thread_attr_destroy(int *attr, int *info);

void thread_attr_init(int *attr, int *info);

void thread_attr_getdetachstate(int *attr, int *detachstate, int *info);

void thread_attr_setdetachstate(int *attr, int *detachstate, int *info);

void thread_attr_getguardsize(int *attr, size_t *guardsize, int *info);

void thread_attr_setguardsize(int *attr, size_t *guardsize, int *info);

void thread_attr_getinheritsched(int *attr, int *inheritsched, int *info);

void thread_attr_setinheritsched(int *attr, int *inheritsched, int *info);

void thread_attr_getschedparam(int *attr, struct sched_param *param, int *info);

void thread_attr_setschedparam(int *attr, struct sched_param *param, int *info);

void thread_attr_getschedpolicy(int *attr, int *policy, int *info);

void thread_attr_setschedpolicy(int *attr, int *policy, int *info);

void thread_attr_getscope(int *attr, int *scope, int *info);

void thread_attr_setscope(int *attr, int *scope, int *info);

void thread_attr_getstacksize(int *attr, size_t *stacksize, int *info);

void thread_attr_setstacksize(int *attr, size_t *stacksize, int *info);





void thread_mutexattr_destroy(int *attr,int *info);

void thread_mutexattr_init(int *attr,int *info);

void thread_mutexattr_getpshared(int *attr, int *pshared, int *info);

void thread_mutexattr_setpshared(int *attr, int *pshared, int *info);

void thread_mutexattr_getprioceiling(int *attr, int *prioceiling, int *info);

void thread_mutexattr_setprioceiling(int *attr, int *prioceiling, int *info);

void thread_mutexattr_getprotocol(int *attr, int *protocol, int *info);

void thread_mutexattr_setprotocol(int *attr, int *protocol, int *info);

void thread_mutexattr_gettype(int *attr, int *type, int *info);

void thread_mutexattr_settype(int *attr, int *type, int *info);







void thread_condattr_destroy(int *attr,int *info);


void thread_condattr_init(int *attr,int *info);

void thread_condattr_getpshared(int *attr, int *pshared, int *info);

void thread_condattr_setpshared(int *attr, int *pshared, int *info);
# 126 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_attr.h"
void thread_rwlockattr_destroy(int *attr,int *info);

void thread_rwlockattr_init(int *attr,int *info);

void thread_rwlockattr_getpshared(int *attr, int *pshared, int *info);

void thread_rwlockattr_setpshared(int *attr, int *pshared, int *info);
# 13 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h" 2

void thread_init(int *info);

void thread_destroy(int* info);




void thread_alloc(int *thread_id, int *info);

void thread_create(int *thread_id, int *attr_id,
                      void *(**start_routine)(void *),
                      void *arg, int* info);

void thread_detach(int *thread_id, int *info);

void thread_equal(int *t1, int *t2, int *info);


void thread_exit(void *value_ptr);


void thread_join(int *thread_id, void **value_ptr, int *info);

void thread_cancel(int *thread_id, int *info);

void thread_kill(int *thread_id, int *sig, int *info);

void thread_once_init(int *once_ctrl, int *info);

void thread_once(int *once_ctrl_id, void (**routine)(void), int *info);

void thread_self(int *thread_id, int *info);


void thread_atfork(void (**prepare)(void),
                      void (**parent)(void),
                      void (**child)(void), int *info);




void thread_cleanup_pop(int *execute,
                           int *info);




void thread_cleanup_push(void *(*routine)(void *),
                            void *arg, int* info);

void thread_getconcurrency(int *currlevel, int *info);

void thread_setconcurrency(int *newlevel, int *info);






void thread_getschedparam(int *thread, int *policy, struct sched_param *param, int *info);
void thread_setschedparam(int *thread, int *policy, struct sched_param *param, int *info);




void thread_setcancelstate(int *state, int *oldstate, int *info);
void thread_setcanceltype(int *type, int *oldtype, int *info);






void thread_key_delete(int *key_id, int *info);

void thread_key_create(int *key_id,void (*destructor)(void *),int *info);

void thread_getspecific(int *key, void **value, int *info);

void thread_setspecific(int *key, void **value, int *info);





void thread_mutex_destroy(int *mutex_id, int *info);

void thread_mutex_init(int *mutex_id, int *attr_id, int *info);

void thread_mutex_lock(int *mutex_id, int *info);

void thread_mutex_trylock(int *mutex_id, int *info);

void thread_mutex_unlock(int *mutex_id, int *info);

void thread_mutex_getprioceiling(int *mutex, int *prioceiling, int *info);

void thread_mutex_setprioceiling(int *mutex, int *prioceiling, int *old_ceiling, int *info);
# 122 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h"
void thread_cond_destroy(int *cond_id, int *info);

void thread_cond_init(int *cond_id, int *attr_id, int *info);

void thread_cond_timedwait(int *cond_id, int *mutex_id, struct timespec *abstime, int *info);

void thread_cond_wait(int *cond_id, int *mutex_id, int *info);

void thread_cond_broadcast(int *cond_id, int *info);

void thread_cond_signal(int *cond_id, int *info);
# 173 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.h"
void thread_rwlock_destroy(int *rwlock_id, int *info);

void thread_rwlock_init(int *rwlock_id, int *attr_id, int *info);

void thread_rwlock_rdlock(int *lock_id, int *info);

void thread_rwlock_tryrdlock(int *lock_id, int *info);

void thread_rwlock_wrlock(int *lock_id, int *info);

void thread_rwlock_trywrlock(int *lock_id, int *info);

void thread_rwlock_unlock(int *lock_id, int *info);
# 13 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 2




void thread_init(int *info) {
  thread_init_internal(info);
}




void thread_destroy(int* info) {
  thread_destroy_internal(info);
  }
# 36 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
void thread_alloc(int *thread_id, int *info) {

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(threads->mutex));
  if (threads->after == threads->size) {

    array_resize(&threads,threads->size*2);
  }
  threads->data[threads->after] = (pthread_t*) malloc(sizeof(pthread_t));

  *thread_id = threads->after;
  threads->after++;

  pthread_mutex_unlock(&(threads->mutex));

}

void thread_create(int *thread_id, int *attr_id,
    void *(**start_routine)(void *), void *arg, int* info) {
  int i = 0;
  pthread_attr_t *attr;
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(threads,*thread_id)) {
    *info = -2;
    return;
  }

  pthread_mutex_lock(&(threads->mutex));

  if (*attr_id == -1) {



    attr = (pthread_attr_t*) malloc(sizeof(pthread_attr_t));
    pthread_attr_init(attr);
    pthread_attr_setdetachstate(attr, 
# 81 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                                     PTHREAD_CREATE_JOINABLE
# 81 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                                                            );
  } else {
    if (!is_valid(thread_attrs,*attr_id)) {
      pthread_mutex_unlock(&(threads->mutex));
      *info = -2;
      return;
    }
    attr = thread_attrs->data[*attr_id];
  }

  *info = pthread_create(threads->data[*thread_id], attr, (*start_routine), arg);


  if (*attr_id == -1)
    free(attr);

  if (*info) {
    pthread_mutex_unlock(&(threads->mutex));
    return;
  }

  pthread_mutex_unlock(&(threads->mutex));

}

void thread_detach(int *thread_id, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(threads,*thread_id)) {
    *info = -2;
    return;
  }

  *info = pthread_detach(*((pthread_t*)(threads->data[*thread_id])));
}

void thread_equal(int *t1, int *t2, int *info) {
  *info = 0;

  if (!is_initialized)
    *info = -1;
  else if (!is_valid(threads,*t1))
    *info = -2;
  else if (!is_valid(threads,*t2))
    *info = -2;
  else
    *info = pthread_equal(*((pthread_t*)(threads->data[*t1])),
        *((pthread_t*)(threads->data[*t2])));

}

void thread_exit(void *value_ptr) {

  pthread_exit(value_ptr);

}

void thread_join(int *thread_id, void **value_ptr, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(threads->mutex));
  if (!is_valid(threads,*thread_id)) {
    *info = -2;
    return;
  }

  *info = pthread_join(*((pthread_t*)(threads->data[*thread_id])),value_ptr);

  if (*info) {
    pthread_mutex_unlock(&(threads->mutex));
    return;
  }

  free(threads->data[*thread_id]);
  threads->data[*thread_id] = 
# 166 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                             ((void *)0)
# 166 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                                 ;

  pthread_mutex_unlock(&(threads->mutex));
}

void thread_cancel(int *thread_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(threads,*thread_id)) {
    *info = -2;
    return;
  }

  *info = pthread_cancel(*((pthread_t*)(threads->data[*thread_id])));

}

void thread_testcancel(int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }


  pthread_testcancel();

}


void thread_kill(int *thread_id, int *sig, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(threads,*thread_id)) {
    *info = -2;
    return;
  }

  *info = pthread_kill(*((pthread_t*)(threads->data[*thread_id])),*sig);

}

void thread_once_init(int *once_ctrl, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(once_ctrls->mutex));
  if (once_ctrls->after == once_ctrls->size) {

    array_resize(&once_ctrls,once_ctrls->size*2);
  }
  once_ctrls->data[once_ctrls->after] = (pthread_once_t*) malloc(sizeof(pthread_once_t));


  pthread_once((pthread_once_t*)once_ctrls->data[once_ctrls->after],
# 236 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                                                                   ((void *)0)
# 236 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                                                                       );




  *once_ctrl = once_ctrls->after;
  once_ctrls->after++;

  pthread_mutex_unlock(&(once_ctrls->mutex));
}

void thread_once(int *once_ctrl_id, void (**routine)(void), int *info) {
  *info = 0;

  if (!is_initialized)
    *info = -1;
  else if (!is_valid(once_ctrls,*once_ctrl_id))
    *info = -2;
  else
    *info = pthread_once(once_ctrls->data[*once_ctrl_id],*routine);

}

void thread_self(int *thread_id, int *info) {
  pthread_t tid;
  int i = 0;
  *info = 0;
  *thread_id = -1;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  tid = pthread_self();
  for (i = 0; i < threads->after; i++) {
    if (threads->data[i] == 
# 272 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                           ((void *)0)
# 272 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                               )
      continue;
    if (pthread_equal(tid,*((pthread_t*)(threads->data[i])))) {
      *thread_id = i;
      return;
    }
  }
  *info = -2;
}


void thread_atfork(void (**prepare)(void),
    void (**parent)(void), void (**child)(void), int *info) {

  *info = pthread_atfork(*prepare,*parent,*child);

}







void thread_cleanup_pop(int *execute, int *info) {
  *info = -2;


}







void thread_cleanup_push(void *(*routine)(void *), void *arg, int* info) {
  *info = -2;

}

void thread_getconcurrency(int *currlevel, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  *currlevel = pthread_getconcurrency();

}


void thread_setconcurrency(int *new_level, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  *info = pthread_setconcurrency(*new_level);

}
# 368 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
void thread_getschedparam(int *thread, int *policy, struct sched_param *param, int *info) {
  *info = 0;
  ;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(threads->mutex));
  if (!is_valid(threads,*thread)) {
    pthread_mutex_unlock(&(threads->mutex));
    *info = -2;
    return;
  }

  *info = pthread_getschedparam(*((pthread_t*)(threads->data[*thread])),policy,param);

  pthread_mutex_unlock(&(threads->mutex));

}

void thread_setschedparam(int *thread, int *policy, struct sched_param *param, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(threads->mutex));
  if (!is_valid(threads,*thread)) {
    pthread_mutex_unlock(&(threads->mutex));
    *info = -2;
    return;
  }

  *info = pthread_setschedparam(*((pthread_t*)(threads->data[*thread])),*policy,param);

  pthread_mutex_unlock(&(threads->mutex));

}
# 433 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
void thread_setcancelstate(int *state, int *oldstate, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  *info = pthread_setcancelstate(*state,oldstate);

}

void thread_setcanceltype(int *type, int *oldtype, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  *info = pthread_setcanceltype(*type,oldtype);

}






void thread_key_delete(int *key_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(thread_keys->mutex));

  if (!is_valid(thread_keys,*key_id)) {
    pthread_mutex_unlock(&(thread_keys->mutex));
    *info = -2;
    return;
  }

  *info = pthread_key_delete(*((pthread_key_t*)(thread_keys->data[*key_id])));

  pthread_mutex_unlock(&(thread_keys->mutex));
}

void thread_key_create(int *key_id,void (*destructor)(void *),int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(thread_keys->mutex));
  if (thread_keys->after == thread_keys->size) {

    array_resize(&thread_keys,thread_keys->size*2);
  }
  thread_keys->data[thread_keys->after] = (pthread_key_t*) malloc(sizeof(pthread_key_t));

  *info = pthread_key_create((pthread_key_t*)(thread_keys->data[thread_keys->after]),destructor);

  if (*info) {
    pthread_mutex_unlock(&(thread_keys->mutex));
    return;
  }

  *key_id = thread_keys->after;
  thread_keys->after++;

  pthread_mutex_unlock(&(thread_keys->mutex));

}





void thread_getspecific(int *key, void **value, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(thread_keys->mutex));

  if (!is_valid(thread_keys,*key)) {
    pthread_mutex_unlock(&(thread_keys->mutex));
    *info = -2;
    return;
  }

  *value = pthread_getspecific(*((pthread_key_t*)(thread_keys->data[*key])));

  pthread_mutex_unlock(&(thread_keys->mutex));
}





void thread_setspecific(int *key, void **value, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(thread_keys->mutex));

  if (!is_valid(thread_keys,*key)) {
    pthread_mutex_unlock(&(thread_keys->mutex));
    *info = -2;
    return;
  }

  *info = pthread_setspecific(*((pthread_key_t*)(thread_keys->data[*key])),
                              *value);

  pthread_mutex_unlock(&(thread_keys->mutex));
}






void thread_mutex_destroy(int *mutex_id, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(mutexes->mutex));

  if (!is_valid(mutexes,*mutex_id)) {
    pthread_mutex_unlock(&(mutexes->mutex));
    *info = -2;
    return;
  }

  *info = pthread_mutex_destroy(((pthread_mutex_t*)(mutexes->data[*mutex_id])));

  if (*info) {
    pthread_mutex_unlock(&(mutexes->mutex));
    return;
  }

  free(mutexes->data[*mutex_id]);
  mutexes->data[*mutex_id] = 
# 595 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                            ((void *)0)
# 595 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                                ;


  pthread_mutex_unlock(&(mutexes->mutex));

}


void thread_mutex_init(int *mutex_id, int *attr_id, int *info) {
  int i = 0;
  *info = 0;

  pthread_mutexattr_t *attr;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(mutexes->mutex));
  if (mutexes->after == mutexes->size) {

    array_resize(&mutexes,mutexes->size*2);
  }
  mutexes->data[mutexes->after] = (pthread_mutex_t*) malloc(sizeof(pthread_mutex_t));

  if (*attr_id == -1) {
    attr = 
# 622 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
          ((void *)0)
# 622 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
              ;
  } else {
    attr = mutex_attrs->data[*attr_id];
  }

  *info = pthread_mutex_init((pthread_mutex_t*)(
        mutexes->data[mutexes->after]), attr);

  if (*info) {
    pthread_mutex_unlock(&(mutexes->mutex));
    return;
  }

  *mutex_id = mutexes->after;
  mutexes->after++;

  pthread_mutex_unlock(&(mutexes->mutex));


}

void thread_mutex_lock(int *mutex_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(mutexes,*mutex_id)) {
    *info = -2;
    return;
  }

  *info = pthread_mutex_lock((pthread_mutex_t*)(mutexes->data[*mutex_id]));

}

void thread_mutex_trylock(int *mutex_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(mutexes,*mutex_id)) {
    *info = -2;
    return;
  }

  *info = pthread_mutex_trylock((pthread_mutex_t*)(mutexes->data[*mutex_id]));


}

void thread_mutex_unlock(int *mutex_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(mutexes,*mutex_id)) {
    *info = -2;
    return;
  }

  *info = pthread_mutex_unlock((pthread_mutex_t*)(mutexes->data[*mutex_id]));

}

void thread_mutex_getprioceiling(int *mutex, int *prioceiling, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(mutexes->mutex));
  if (!is_valid(mutexes,*mutex)) {
    pthread_mutex_unlock(&(mutexes->mutex));
    *info = -2;
    return;
  }

  *info = pthread_mutex_getprioceiling(
                 (pthread_mutex_t*)(mutexes->data[*mutex]),
                 prioceiling);

  pthread_mutex_unlock(&(mutexes->mutex));

}

void thread_mutex_setprioceiling(int *mutex, int *prioceiling, int *old_ceiling, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(mutexes->mutex));
  if (!is_valid(mutexes,*mutex)) {
    pthread_mutex_unlock(&(mutexes->mutex));
    *info = -2;
    return;
  }

  *info = pthread_mutex_setprioceiling(
                 (pthread_mutex_t*)(mutexes->data[*mutex]),
                 *prioceiling,old_ceiling);

  pthread_mutex_unlock(&(mutexes->mutex));

}
# 772 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
void thread_cond_destroy(int *cond_id, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(conds->mutex));

  if (!is_valid(conds,*cond_id)) {
    pthread_mutex_unlock(&(conds->mutex));
    *info = -2;
    return;
  }

  *info = pthread_cond_destroy(((pthread_cond_t*)(conds->data[*cond_id])));

  if (*info) {
    pthread_mutex_unlock(&(conds->mutex));
    return;
  }

  free(conds->data[*cond_id]);
  conds->data[*cond_id] = 
# 797 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                         ((void *)0)
# 797 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                             ;

  pthread_mutex_unlock(&(conds->mutex));

}


void thread_cond_init(int *cond_id, int *attr_id, int *info) {
  int i = 0;
  *info = 0;
  pthread_condattr_t *attr;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(conds->mutex));
  if (conds->after == conds->size) {

    array_resize(&conds,conds->size*2);
  }
  conds->data[conds->after] = (pthread_cond_t*) malloc(sizeof(pthread_cond_t));

  if (*attr_id == -1) {
    attr = 
# 822 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
          ((void *)0)
# 822 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
              ;
  } else {
    attr = cond_attrs->data[*attr_id];
  }

  *info = pthread_cond_init((pthread_cond_t*)(conds->data[conds->after]), attr);

  if (*info) {
    pthread_mutex_unlock(&(conds->mutex));
    return;
  }

  *cond_id = conds->after;
  conds->after++;

  pthread_mutex_unlock(&(conds->mutex));

}

void thread_cond_timedwait(int *cond_id, int *mutex_id, struct timespec *abstime, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if ((!is_valid(mutexes,*mutex_id)) || (!is_valid(conds,*cond_id))) {
    *info = -2;
    return;
  }

  *info = pthread_cond_timedwait((pthread_cond_t*)(conds->data[*cond_id]),
                                 (pthread_mutex_t*)(mutexes->data[*mutex_id]),
                                 abstime);

}


void thread_cond_wait(int *cond_id, int *mutex_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if ((!is_valid(mutexes,*mutex_id)) || (!is_valid(conds,*cond_id))) {
    *info = -2;
    return;
  }

  *info = pthread_cond_wait((pthread_cond_t*)(conds->data[*cond_id]),
                            (pthread_mutex_t*)(mutexes->data[*mutex_id]));

}


void thread_cond_broadcast(int *cond_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(conds,*cond_id)) {
    *info = -2;
    return;
  }

  *info = pthread_cond_broadcast((pthread_cond_t*)(conds->data[*cond_id]));

}


void thread_cond_signal(int *cond_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(conds,*cond_id)) {
    *info = -2;
    return;
  }

  *info = pthread_cond_signal((pthread_cond_t*)(conds->data[*cond_id]));

}
# 1147 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
void thread_rwlock_destroy(int *rwlock_id, int *info) {

  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(rwlocks->mutex));

  if (!is_valid(rwlocks,*rwlock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_destroy(((pthread_rwlock_t*)(rwlocks->data[*rwlock_id])));

  if (*info) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    return;
  }

  free(rwlocks->data[*rwlock_id]);
  rwlocks->data[*rwlock_id] = 
# 1172 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
                             ((void *)0)
# 1172 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
                                 ;

  pthread_mutex_unlock(&(rwlocks->mutex));

}


void thread_rwlock_init(int *rwlock_id, int *attr_id, int *info) {
  int i = 0;
  *info = 0;
  pthread_rwlockattr_t *attr;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  pthread_mutex_lock(&(rwlocks->mutex));
  if (rwlocks->after == rwlocks->size) {

    array_resize(&rwlocks,rwlocks->size*2);
  }
  rwlocks->data[rwlocks->after] = (pthread_rwlock_t*) malloc(sizeof(pthread_rwlock_t));

  if (*attr_id == -1) {
    attr = 
# 1197 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c" 3 4
          ((void *)0)
# 1197 "/lustre/ehz2col/collaboration/projects/parachute/peter.clark.mon/MONC/vn1.0.0_Circle-A-v2/extract/monc/io/src/forthread/ft_wrapper.c"
              ;
  } else {
    attr = rwlock_attrs->data[*attr_id];
  }

  *info = pthread_rwlock_init((pthread_rwlock_t*)(rwlocks->data[rwlocks->after])
                               ,attr);

  if (*info) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    return;
  }

  *rwlock_id = rwlocks->after;
  rwlocks->after++;

  pthread_mutex_unlock(&(rwlocks->mutex));

}


void thread_rwlock_rdlock(int *lock_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(rwlocks,*lock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_rdlock((pthread_rwlock_t*)(rwlocks->data[*lock_id]));

}

void thread_rwlock_tryrdlock(int *lock_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(rwlocks,*lock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_tryrdlock((pthread_rwlock_t*)(rwlocks->data[*lock_id]));

}


void thread_rwlock_wrlock(int *lock_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(rwlocks,*lock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_wrlock((pthread_rwlock_t*)(rwlocks->data[*lock_id]));

}

void thread_rwlock_trywrlock(int *lock_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(rwlocks,*lock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_trywrlock((pthread_rwlock_t*)(rwlocks->data[*lock_id]));

}

void thread_rwlock_unlock(int *lock_id, int *info) {
  *info = 0;

  if (!is_initialized) {
    *info = -1;
    return;
  }

  if (!is_valid(rwlocks,*lock_id)) {
    pthread_mutex_unlock(&(rwlocks->mutex));
    *info = -2;
    return;
  }

  *info = pthread_rwlock_unlock((pthread_rwlock_t*)(rwlocks->data[*lock_id]));

}

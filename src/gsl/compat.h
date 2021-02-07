/* @(#) $Source: /cvs/wlv/src/linker/source/compat.h,v $ $Revision: 1.6 $ $Date: 2011/04/06 18:41:44 $ */
/*****************************************************************
Version identification:
compat.h	1.45 3/22/96

Copyright (c) 1990-1996 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

						PT_COPYRIGHT_VERSION_2
						COPYRIGHTENDKEY
*/

#ifndef COMPAT_H_INCLUDED
#define COMPAT_H_INCLUDED
// Copyright Keysight Technologies 2001 - 2017  

#include "Platforms.h"

#ifdef __cplusplus
extern "C" {
#endif

/***************************************************************************/
/* Define #defines for each Ptolemy architecture. (Alphabetical, please) */

#if defined(_AIX)
/* IBM rs6000 and powerpc running AIX */
#define PTAIX
#endif

#if defined(_AIX) && ! defined(__GNUC__)
/* AIX with IBM xlc and xlC */
#define PTAIX_XLC
#endif

#if defined(__alpha)
/* DEC Alpha */
#define PTALPHA
#endif
  
#if defined(freebsd)
/* FreeBSD */
#define PTFREEBSD
#endif

#if defined(hpux) || defined(__hpux)
/* HP PA */
#define PTHPPA
#endif

#if defined(PTHPPA) && ! defined(__GNUC__) && __cplusplus < 199707L
/* HP PA, compiled with cfront */
#define PTHPPA_CFRONT
#endif

#if defined(PTHPPA) && defined(HPUX_10)
/* HP PA 10.x */
#define PTHPPA10
#endif

#if defined(PTHPPA) && defined(HPUX_11)
/* HP PA 11.x */
#define PTHPPA11
#endif

#if defined(__sgi) && defined(IRIX5)
/* SGI running IRIX5.x */
#define PTIRIX5
#endif

#if defined(__sgi) && ! defined(__GNUC__)
/* SGI running IRIX5.x with native SGI CC*/
#define PTIRIX5_CFRONT
#endif

#if defined(__sgi) && ! defined(__GNUC__) && defined(IRIX6) && defined (_ABIO32)
/* SGI running IRIX6.x , native SGI CC in 32 bits mode */
#define PTIRIX5			/* SGI says it is 100% compatible with IRIX5 */
#define PTIRIX6
#define PTIRIX6_32_CFRONT
#endif

#if defined(__sgi) && ! defined(__GNUC__) && defined(IRIX6) && defined (_ABI64)
/* SGI running IRIX6.x , native SGI CC in 64 bit mode */
#define PTIRIX6
#define PTIRIX6_64_CFRONT
#endif

#if defined(linux)
#define PTLINUX
#endif

#if defined(PTLINUX) && defined(__ELF__)
/* Shorthand for Linux and ELF */
#define PTLINUX_ELF
#endif

#if defined(netbsd_i386)
#define PTNBSD_386
#endif

#if defined(sparc) && (defined(__svr4__) || defined(__SVR4))
/* Sun SPARC running Solaris2.x, SunC++ or g++ */
#ifndef SOL2
#define SOL2
#endif

#define PTSOL2
#endif

#if defined(sparc) && (defined(__svr4__) || defined(__SVR4)) && !defined(__GNUC__)
/* Sun SPARC running Solaris2.x, with something other than gcc/g++ */
#define PTSOL2_CFRONT
#endif

#if defined(sparc) && !(defined(__svr4__) || defined(PTSOL2_CFRONT))
/* Really, we mean sun4 running SunOs4.1.x, Sun C++ or g++ */
#define SUN4
#define PTSUN4
#endif

#if defined(sparc) && !defined(__svr4__) && !defined(__GNUC__)
/* Really, we mean sun4 running SunOs4.1.x with something other than gcc/g++ */
#define SUN4
#define PTSUN4_CFRONT
#endif

/* Unixware1.1
*#define PTSVR4
*/

#if defined(ultrix)
/* DEC MIPS running Ultrix4.x */
#define PTULTRIX
#define PTMIPS
#endif

#if defined(WIN32)
/* Windows */
#define PTWIN32
#endif

/* Definition of common 64-bit preprocessor symbols */
#if defined(PTALPHA) || defined(PTIRIX6)
#define PT64BIT
#endif

/***************************************************************************/
/* Used to keep function paramters straight.  Note that SunOS4.1.3 cc
 *  is non ANSI, so we can't use function parameters everywhere.
 */
#ifndef ARGS
#if defined(__STDC__) || defined(__cplusplus)
#define ARGS(args)	args
#else
#define ARGS(args)	()
#endif
#endif

/* Volatile produces warnings under some cfront versions, and under
 * non-ansi cc compilers, such as SunOS4.1 cc
 */
#if !defined(VOLATILE)
#if defined(PTHPPA_CFRONT) || defined(PTSUN4_CFRONT) || !(defined(__STDC__) || defined(__cplusplus))
#define VOLATILE
#else
#define VOLATILE volatile
#endif /* PTSUN4_CFRONT or PTHPPA_CFRONT or non-ansi cc*/
#endif /* ! VOLATILE */

/* This is really lame, so lets just not use it.
 */
#if 0
#if !defined(PTLINUX) && !defined(PTNBSD_386) && !defined(PTFREEBSD)
#if defined(USG) && ! defined(PTHPPA) && ! defined(PTAIX) && !defined(PTSVR4) && !defined(PTSOL2)
extern int sprintf();
#else
#ifndef PTIRIX5
#ifndef PTSOL2
#ifndef PTULTRIX
#ifndef PTHPPA
#ifndef PTAIX
#ifndef PTALPHA
#ifndef PTSVR4
#if !(defined(sun) && defined (__GNUC__)) && !defined(hppa) && !defined(__hppa__)
#if defined(sun) && !defined(__GNUC__) && defined(__cplusplus) && !defined(SOL2)
/* SunOS4.1.3 Sun Cfront */	
#else
extern char *sprintf();
#endif
#endif /*sun && __GNUC__*/
#endif /* PTSVR4 */
#endif /* PTALPHA */
#endif /* PTAIX */
#endif /* PTHPPA */
#endif /* PTULTRIX */
#endif /* PTSOL2 */
#endif /* PTIRIX5 */
#endif
#endif /* PTLINUX */
#endif /* 0 */

#ifdef __cplusplus
} //End of extern "C"
#endif

#if defined(__GNUC__) && !defined(PTNBSD_386) && !defined(PTFREEBSD)
#include "gui_stdio.h"          /* Get the decl for FILE.  sigh.
                                 * Also get sprintf() for linux. */
#include "gui_types.h"          /* Need for bind(). */
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__GNUC__) && !defined(PTNBSD_386) && !defined(PTFREEBSD)

#ifndef SYS_SOCKET_H
#define SYS_SOCKET_H		/* mips Ultrix4.3A requires this
				   otherwise we get conflicts with
				   thor/kernel/rpc.c and ptkNet.c */
#include <sys/socket.h>
#endif

#ifdef PTSUN4
#include <sys/time.h>			/* For select() */
/* Place all SunOS4.1.3 specific declarations here. (In alphabetical order). */

extern int accept(int, struct sockaddr *, int *);
extern void bzero(char *, int); 	/* vem/rpc/server.c */

extern int fgetc(FILE *);
extern int fputs(const char *, FILE *);

/* pxgraph/xgraph.c, octtools/Xpackages/rpc/{appOct.c,rpc.c} all call fread()*/
extern long unsigned int 
fread(void *, long unsigned int, long unsigned int, FILE *);
extern long unsigned int 
fwrite(const void *, long unsigned int, long unsigned int, FILE *);

extern int getdtablesize();		/* vem/rpc/server.c */

extern int gethostname(char *, int);	/* vem/rcp/serverNet.c (among others)*/

/* Don't define getsockname for SOL2.  thor/kernel/rpc.c calls getsockname().*/
extern int getsockname(int, struct sockaddr *, int *);

/* octtools/Xpackages/iv/ivGetLine.c calls ioctl */
extern int ioctl(int, int request, caddr_t);

/* octtools/Xpackages/rpc/{appNet.c,serverNet.c} thor/analyzer/X11/event.c
   all call select */
extern select(int, fd_set *, fd_set *, fd_set *, struct timeval *);

/* Under SunOS4.1.3, strcasecmp is in strings.h, not string.h */
/* octtools/Packages/tap/quantize.c uses strcasecmp */
extern int strcasecmp(const char *, const char *);

extern int system(const char *);

/* Under SunOS4.1.3, tolower() and toupper are not in ctype.h */
/* vem/strings/str.c (and other files ) use tolower() and toupper(). */
extern int tolower(int c);
extern int toupper(int c);

extern int ungetc(int, FILE *);
extern int vfork();
extern int vfprintf(FILE *, const char *, char *);

#endif /* SUN4 */

/* IBM RS6000 running AIX */
#ifdef PTAIX
#include <sys/select.h>
#endif


/* Here we define common missing function prototypes */
/* Alphabetical, please */

#if !defined(PTIRIX5) && !defined(PTHPPA) && ! defined(PTALPHA) && !defined(PTLINUX)
				/* thor/kernel/rpc.c use bind2(), listen(). */
#if defined(PTFREEBSD)
/* Under linux and libc-5.2.18, bind() takes a const second arg */
extern int bind(int, const struct sockaddr *, int);
#else /* PTFREEBSD */
extern int bind(int, struct sockaddr *, int);
#endif  /* PTFREEBSD */
#endif /* ! PTIRIX5 && ! PTHPPA && ! PTALPHA && ! PTLINUX*/

extern void endpwent();		/* octtools/Packages/fc/fc.c and
				   octtools/Packages/utility/texpand.c */

#ifndef linux 
extern int fclose (FILE *);
extern int fflush (FILE *);
extern int fprintf (FILE *, const char *, ...);
extern int fscanf (FILE *, const char *, ...);
#endif

#ifdef PTSOL2
extern double hypot(double, double); /* kernel/ComplexSubset.h */
#endif

#ifndef PTLINUX
extern int listen(int, int);
#endif

#if defined(PTNBSD_386) || defined(PTFREEBSD)
extern off_t lseek();		/* octtools/vem/serverVem.c uses lseek(). */
#elif !defined(_HP10_target) && !defined(PTLINUX)
extern long lseek();
#endif /* PTNBSD_386 || PTFREEBSD */

#ifndef linux 
extern int pclose(FILE *);
extern void perror (const char *);
extern int printf (const char *, ...);
#endif

#if !defined(PTHPPA) && !defined(PTLINUX) && !defined(PTALPHA) && !(defined(PTSOL2) && !defined(PTSOL2_3)) && !defined(PTSOL2_4)
extern int putenv (char *);
#endif /* ! PTHPPA && ! PTLINUX && ! PTALPHA */

#ifndef linux 
extern int puts (const char *);
#endif

#if defined(PTSUN4) || defined(PTULTRIX)
/* This should have been defined in sys/time.h.  kernel/SimControl.cc
   uses it.
 */
extern int setitimer( int, struct itimerval *, struct itimerval *);
#endif /* PTSUN4 || PTULTRIX */

#if defined(PTLINUX)
#include <sys/time.h>		/* for select() */
#endif

#if !defined(PTALPHA)
extern void setpwent();		/* octtools/Packages/fc/fc.c and
				   octtools/Packages/utility/texpand.c */
#endif

#ifndef linux 
extern int sscanf (const char *, const char *, ...);
extern int socket(int, int, int); /* thor/kernel/rpc.c uses socket() */
#endif

#if ! defined(PTAIX) && ! defined(PTLINUX)
extern int symlink(const char *, const char *);	/* CGCTarget.cc */
#endif

#if ! defined(PTLINUX)
extern int unlink(const char *);
#endif

/* End of common missing function prototypes */
#else  /* !__GNUC__ */
#ifdef PTIRIX5_CFRONT           /* dpwe addns */
#include "gui_unistd.h"             /* for select() */
#include "gui_stdio.h"              /* for sprintf() */
#endif /* PTIRIX5_CFRONT */
#endif /* __GNUC__ */


#ifdef NEED_SYS_ERRLIST
#if defined(PTLINUX)
#include <errno.h>
#else
#if defined(PTWIN32)
#define sys_errlist _sys_errlist
#define sys_nerr _sys_nerr
#else
#if defined(PTNBSD_386) || defined(PTFREEBSD)
/* See also kernel/State.h */
extern const char *const sys_errlist[];
#else
extern char *sys_errlist[];
#endif /* PTNBSD_386 */
extern int sys_nerr;
extern int errno;
#endif
#endif
#endif /* NEED_SYS_ERRLIST */


#if defined(PTAIX) || defined(SUN_57)
/* AIX defines putenv as putenv(char *) so we wrapper it.  The declaration
   is in compat/ptolemy/compat.h */
#include <stdlib.h>
#define putenv ptolemyputenv
int ptolemyputenv(const char *);
#endif

/* Here we define common types that differ by platform */

/* thor/analyzerX11/event.c, octtools/vem/rpc/serverNet.c,
 octtools/Xpackages/rpc/appNet.c use FDS_TYPE */
#ifdef PTHPPA

#ifndef FDS_TYPE
#define FDS_TYPE (int *)
#endif

#else /* PTHPPA */

#ifndef FDS_TYPE
#define FDS_TYPE (fd_set *)
#endif

#endif /* PTHPPA */


#ifdef PTSVR4
#define FDS_TYPE (fd_set *)
#define SYSV
#endif /* PTSVR4 */

/* Fix up casts for kernel/TimeVal.cc */

#ifdef PTHPPA
#define TV_SEC_TYPE	unsigned long
#endif /* PTHPPA */

#ifndef TV_USEC_TYPE
#define TV_USEC_TYPE	long int
#endif

#ifndef TV_SEC_TYPE
#define TV_SEC_TYPE	long int
#endif

/* End of common types that differ by platform */

/* Start of octtools specific defines */
/* Decide whether to include dirent.h or sys/dir.h.
 * octtools/Packages/fc.h uses this
 */
#if defined(aiws) || defined(_IBMR2) || defined(SYSV) || defined(PTALPHA)
#define USE_DIRENT_H
#endif

/* Does wait() take an int* arg or a union wait * arg
 * DEC Ultrix wait() takes union wait *
 * See octtools/Packages/utility/csystem.c
 */
#if defined(_IBMR2) || defined(SYSV) || defined(PTALPHA) || defined(PTHPPA) ||defined(PTSUN4) || defined(PTSOL2) || defined(PTIRIX5)
#define WAIT_TAKES_INT_STAR
#endif

/* Use wait3 or waitPid()?
 * Used in octtools/Packages/utils/pipefork.c, vov/lib.c
 */
#if defined(SYSV) || defined(PTALPHA)
#define USE_WAITPID
#endif

/* Use SystemV curses?  See octtools/attache/io.c
 */
#if defined(PTHPPA) || defined(SYSV) || defined(PTLINUX) || defined(PTALPHA) || defined(PTFREEBSD)
#define USE_SYSV_CURSES
#endif

/* Do we need to defined stricmp()?  See octtools/installColors/installColors.c
 */
#if defined(PT_ULTRIX) || defined(PTHPPA) || defined(PTIRIX5) || defined(PTSOL2) || defined(PTLINUX) || defined(PTALPHA) || defined(PTNBSD_386) || defined(PTAIX) || defined(PTFREEBSD)
#ifndef NEED_STRICMP
#define NEED_STRICMP
#endif
#endif

/* Do we have termios.h?  See octtools/Xpackages/iv/ivGetLine.c */
#if defined(PTHPPA) || defined(SYSV) || defined(PTIRIX5) || defined(PTLINUX) || defined(PTFREEBSD)
#define HAS_TERMIOS
#endif

/* Is sys_siglist[] present?  See octtools/vem/rpc/vemRPC.c */
#if defined(PTHPPA) || defined(SYSV) || defined(PTLINUX) || defined(PTFREEBSD)
#define NO_SYS_SIGLIST
#endif 

/* Should we use getrlimit()?  See octtools/vem/rpc/{server.c, serverNet.c} */
#if defined(PTHPPA) || defined(SYSV)
#define USE_GETRLIMIT
#endif

/* Is char* environ defined? See octtools/Packages/vov/lib.c */
#if defined(PTHPPA) || defined(PTLINUX)
/* Under PTHPPA and PTLINUX, don't need environ declaration. */
#else
#define NEED_ENVIRON_DECL
#endif

/* End of octtools specific defines */

#ifdef __cplusplus
} //End of extern "C"
#endif

#endif   /* COMPAT_H_INCLUDED */

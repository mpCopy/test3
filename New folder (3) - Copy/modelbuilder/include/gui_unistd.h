/* @(#) $Source: /cvs/wlv/src/gsl/source/gui_unistd.h,v $ $Revision: 100.23 $ $Date: 2011/08/23 21:38:59 $  */
/* SCCS @(#) /wlv/src/gsl700/source gui_unistd.h 700.7 date: 09/25/95 */
/******************************************************************************/
/******************************************************************************/
/****************************                    ******************************/
/******************                                        ********************/
/***                             GUI_UNISTD.H                               ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
/******************************************************************************/

#ifndef GUI_UNISTD_H_INCLUDED
#define GUI_UNISTD_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "gslexpt.h"            // Needed for the GSL_API definition.

#include <sys/types.h>

#if defined (_WIN32)                /* Win32 platforms */
#include <io.h>                     /* for read(), write(), close(), unlink(), etc. */
#include <direct.h>                 /* for chdir(), getcwd() and rmdir() */
#include <process.h>                /* for execxx() and _exit() */
#else
#include <unistd.h>                 /* Unix platforms */ 
#endif

#if defined (_WIN32)                /* Win32 platforms */
#define  chdir      _chdir          /* POSIX/XPG3 function */
#define  access     _access         /* POSIX/XPG3 function */
#ifndef R_OK
#define R_OK                    4   /* for access function */
#endif
#ifndef W_OK
#define W_OK                    2   /* for access function */
#endif
// X_OK does not make sence on windows

#if defined(__cplusplus)
#undef   close                      /* C++ conflict with fstreams.h */
#undef   read                       /* C++ conflict with fstreams.h */
#undef   write                      /* C++ conflict with fstreams.h */
#else
#define  close      _close
#define  read       _read
#define  write      _write
#endif
#define  dup        _dup
#define  dup2       _dup2
#define  execl      _execl
#define  execle     _execle
#define  execlp     _execlp
#define  execv      _execv
#define  execve     _execve
#define  execvp     _execvp
#define  getcwd     _getcwd
#define  getpid     _getpid
#define  isatty     _isatty
#define  lseek      _lseek
#define  pipe       _pipe
#define  rmdir      _rmdir
#define  unlink     _unlink

#ifdef sleep
#   undef  sleep
#endif
#define    sleep    gsl_sleep     /* See gui_unistd.c for remapped sleep() */

#endif /* if defined (_WIN32) */


/* Suffix for temporary lock file - gsl_flock() */
#define LOCK_FILE_SUFFIX "_flock"


#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

GSL_API unsigned int gsl_sleep (unsigned int seconds); 
GSL_API char *gsl_getlogin();

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#endif /* GUI_UNISTD_H_INCLUDED */

/******************************************************************************/
/*************************  end of GUI_UNISTD.H  ******************************/
/******************************************************************************/

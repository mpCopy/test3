/* @(#) $Source: /cvs/wlv/src/gsl/source/gui_stdio.h,v $ $Revision: 100.16 $ $Date: 2011/08/23 21:38:59 $  */
/* SCCS @(#) /wlv/src/gsl700/source gui_stdio.h 700.7 date: 06/10/96 */
/* SCCS @(#) /wlv/src/gsl600/source gui_stdio.h 600.6 date: 11/17/94 */
/* SCCS @(#) gui500/gui/ansi_include gui_stdio.h 1.1 date: 07/20/93 */
/* SCCS @(#) gui400/gui/ansi_include gui_stdio.h 1.3 date: 05/04/92 */
/******************************************************************************/
/******************************************************************************/
/****************************                    ******************************/
/******************                                        ********************/
/***                             GUI_STDIO.H                                ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
/******************************************************************************/

#ifndef GUI_STDIO_H_INCLUDED
#define GUI_STDIO_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "gsl_stdio.h"

#if defined (_WIN32)                     /* WIN32 platforms */
#include <io.h>

#define  fileno     _fileno
#define  getw       _getw               /* XPG3 functions */
#define  pclose     _pclose
#define  popen      _popen
#define  putw       _putw
#define  tempnam    _tempnam

#ifdef L_tmpnam
#   undef  L_tmpnam
#endif
#define    L_tmpnam 256        /* need longer path than default 14 chars */

#ifdef tmpnam
#   undef  tmpnam
#endif
#define    tmpnam   gsl_tmpnam	/* See gui_stdio.c for remapped tmpnam() */

#endif   /* _WIN32 */

#endif /* GUI_STDIO_H_INCLUDED */

/*************************  end of GUI_STDIO.H  *******************************/
/******************************************************************************/

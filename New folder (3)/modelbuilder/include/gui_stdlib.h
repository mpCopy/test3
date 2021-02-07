/* @(#) $Source: /cvs/wlv/src/gsl/source/gui_stdlib.h,v $ $Revision: 100.19 $ $Date: 2011/08/23 21:38:59 $  */
/* SCCS @(#) /wlv/src/gsl700/source gui_stdlib.h 700.6 date: 04/24/96 */
/* SCCS @(#) /wlv/src/gsl600/source gui_stdlib.h 600.5 date: 11/17/94 */
/* SCCS @(#) gui500/gui/ansi_include gui_stdlib.h 1.1 date: 07/20/93 */
/* SCCS @(#) gui400/gui/ansi_include gui_stdlib.h 1.3 date: 05/04/92 */
/******************************************************************************/
/******************************************************************************/
/****************************                    ******************************/
/******************                                        ********************/
/***                             GUI_STDLIB.H                               ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
/******************************************************************************/

#ifndef GUI_STDLIB_H_INCLUDED
#define GUI_STDLIB_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "gsl_stdlib.h"

#if defined(__cplusplus) || defined(c_plusplus)
extern "C++" {
#include <cstdlib>
}
#endif

#if defined (_WIN32)    /* WIN32 - remap the following functions */

#ifdef getenv
#   undef  getenv
#endif
#define    getenv    gsl_getenv     /* See gsl_stdlib.c for remapped getenv() */

#include <malloc.h>

#ifdef malloc
#undef malloc
#endif

#ifdef calloc
#undef calloc
#endif

#ifdef realloc
#undef realloc
#endif
#endif // ifdef _WIN32

#endif /* GUI_STDLIB_H_INCLUDED */

/******************************************************************************/
/*************************  end of GUI_STDLIB.H  ******************************/
/******************************************************************************/

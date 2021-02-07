/* @(#) $Source: /cvs/wlv/src/gsl/source/gui_string.h,v $ $Revision: 100.20 $ $Date: 2011/08/23 21:38:59 $  */
/* SCCS @(#) /wlv/src/gsl700/source gui_string.h 700.9 date: 07/31/96 */
/* SCCS @(#) /wlv/src/gsl600/source gui_string.h 600.7 date: 02/17/95 */
/* SCCS @(#) gui500/gui/ansi_include gui_string.h 1.2 date: 05/23/94 */
/* SCCS @(#) gui400/gui/ansi_include gui_string.h 1.3 date: 05/04/92 */
/******************************************************************************/
/******************************************************************************/
/****************************                    ******************************/
/******************                                        ********************/
/***                             GUI_STRING.H                               ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
/******************************************************************************/

#ifndef GUI_STRING_H_INCLUDED
#define GUI_STRING_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "gslexpt.h"            // Needed for the GSL_API definition.

#include <string.h>
#if defined(__cplusplus) || defined(c_plusplus)
/* 
 When used with a c++ compiler include cstring before remapping 
 commands. This allows STLport to remap command to namespace while
 still allowing the gsl remap.
*/
#include <cstring>
#endif


/* Remaped string functions */
#ifdef strcmp
#   undef  strcmp
#endif
#define    strcmp gsl_strcmp    /* See gui_string.c for remapped strcmp() */

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif
GSL_API int gsl_strcmp (const char *s1, const char *s2);
GSL_API char *gsl_strcasestr (const char *s1, const char *s2);
GSL_API char *strrstr(const char *, const char *);

#ifdef  _WIN32	/* WIN32 platforms */
GSL_API int strcasecmp( const char* const string1, const char* const string2 );
GSL_API int strncasecmp( const char* const string1, const char* const string2, int n);
#endif /* _WIN32 */

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#endif /* GUI_STRING_H_INCLUDED */

/******************************************************************************/
/*************************  end of GUI_STRING.H  ******************************/
/******************************************************************************/

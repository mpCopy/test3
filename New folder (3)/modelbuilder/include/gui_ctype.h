/* @(#) $Source: /cvs/wlv/src/gsl/source/gui_ctype.h,v $ $Revision: 100.10 $ $Date: 2012/02/05 18:57:51 $  */
/* SCCS @(#) /wlv/src/gsl700/source gui_ctype.h 700.1 date: 05/18/95 */
/* SCCS @(#) /wlv/src/gsl600/source gui_ctype.h 600.5 date: 11/17/94 */
/* SCCS @(#) gui500/gui/ansi_include gui_ctype.h 1.1 date: 07/20/93 */
/* SCCS @(#) gui400/gui/ansi_include gui_ctype.h 1.3 date: 05/04/92 */
/******************************************************************************/
/******************************************************************************/
/****************************                    ******************************/
/******************                                        ********************/
/***                             GUI_CTYPE.H                                ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
/******************************************************************************/
/******************************************************************************/

#ifndef GUI_CTYPE_H_INCLUDED
#define GUI_CTYPE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "MosaicCore/utf8/ctype_intl.h"

//Helpful inline functions
// Not available in C because we want them inline.

//TODO: Eliminate this file once the Mosaic Core project is in universal usage.

#if defined(__cplusplus) || defined(c_plusplus)

inline int gsl_islower_not_intl(int c)
{
    return Mosaic::islower_not_intl(c);
}

inline int gsl_isupper_not_intl(int c)
{
    return Mosaic::isupper_not_intl(c);
}

inline int gsl_isalpha_not_intl(int c)
{
    return Mosaic::isalpha_not_intl(c);
}

inline int gsl_isalnum_not_intl(int c)
{
    return Mosaic::isalnum_not_intl(c);
}

inline int gsl_isdigit_not_intl(int c)
{
    return Mosaic::isdigit_not_intl(c);
}

inline int gsl_isxdigit_not_intl(int c)
{
    return Mosaic::isxdigit_not_intl(c);
}

inline int gsl_ascii_not_intl(int c)
{
    return Mosaic::isascii_not_intl(c);
}

inline int gsl_isspace_not_intl(int c)
{
    return Mosaic::isspace_not_intl(c);
}

inline int gsl_isprint_or_intl(int c)
{
    return Mosaic::isprint_or_intl(c);
}

inline int gsl_ispunct_or_intl(int c)
{
    return Mosaic::ispunct_or_intl(c);
}

inline int gsl_isgraph_or_intl(int c)
{
    return Mosaic::isgraph_or_intl(c);
}
#endif

#endif /* GUI_CTYPE_H_INCLUDED */

/******************************************************************************/
/**************************  end of GUI_CTYPE.H  ******************************/
/******************************************************************************/

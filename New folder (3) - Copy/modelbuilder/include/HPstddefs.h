/* @(#) $Source: /cvs/wlv/src/gsl/source/HPstddefs.h,v $ $Revision: 100.20 $ $Date: 2011/08/23 21:38:59 $  */
/****************************                    ******************************/
/******************                                        ********************/
/***                    HP EESOF Standard Definitions                       ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
 
#ifndef HPSTDDEFS_H_INCLUDED
#define HPSTDDEFS_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2017  
 
  /* boolean constants */
#ifdef FALSE
#undef FALSE
#endif
#define FALSE    0

#ifdef TRUE
#undef TRUE
#endif
#define TRUE     1

#include "c_bool.h"

#ifdef _DEBUG

// Checking debug mode
#ifndef DEBUG
#error "_DEBUG is defined, but DEBUG is not defined. Define both DEBUG and _DEBUG in the compiler options in debug mode."
#endif

#ifdef NDEBUG
#error "_DEBUG and NDEBUG are both defined. Do not define both DEBUG/_DEBUG and NDEBUG in the same build."
#endif

#ifdef OPT_BUILD
#error "_DEBUG and OPT_BUILD are both defined. Do not define both DEBUG/_DEBUG and OPT_BUILD in the same build."
#endif

#else

// Checking opt mode
#ifdef DEBUG
#error "DEBUG is defined, but _DEBUG is not defined. Define both DEBUG and _DEBUG in the compiler options for debug mode."
#endif

#ifndef NDEBUG
#error "_DEBUG and NDEBUG are both undefined. Define either (DEBUG and _DEBUG) or (NDEBUG and OPT_BUILD) in the compiler options."
#endif

#ifndef OPT_BUILD
#error "_DEBUG and OPT_BUILD are both undefined. Define either (DEBUG and _DEBUG) or (NDEBUG and OPT_BUILD) in the compiler options."
#endif

#endif

/* taken from Berkeley math.h kb */
#define EEDBL_MAX 3.4e+38 
// most platforms have already defined INFINITY in <math.h>, and it causes compiler warnings to leave it here.
// it is now only here for reference.
// #define INFINITY        EEDBL_MAX
#define MINUS_INFINITY -EEDBL_MAX

#define EEDBL_MIN 2.2e-308

  /* standard definitions */
#define PI       3.14159265358979311599796
#define PID2     1.57079632679489655799898
#define TWOPI    6.28318530717958623199593
#define EXP1     2.718281828
#define LOG_10   2.302585093
#define MU0      12.56637062e-7
#define EPS0     8.854185331e-12
#define ETA0     376.7303664
#define VAIR     2.9979250e8
#define RHOAU    2.439e-8
#define RHOCU    1.724e-8
#define DBPERNEP 8.685889638
#define NEPPERDB 0.115129255
#define RADPERDEG 0.017453292519943290
#define DEGPERRAD 57.29577951308232000

/* Hard coded float min/max values used in gparsmod */
#define EEMAXFLOAT   1.701411e38
#define EEMINFLOAT  -1.701411e38

  /* string defines */
#define NULLCHAR     '\0'
#define NULLSTRG     ""
#define NULLPOINTER  0L
#define NULLDEVICE   -1

#ifndef NULL
#define NULL         0
#endif

#define MAXSTRSZE    1024
#define LINSZE       1024


#if defined(_WIN32)             /* Win32 NT */

    /* file/directory/environment for PC */
#   define DRIVE_SEPARATOR             ':'
#   define HOME_SEPARATOR              '\\'
#   define DIRECTORY_SEPARATOR         '\\'
#   define DIRECTORY_SEPARATOR_STRG    "\\"
#   define EXTENSION_SEPARATOR         '.'
#   define CURRENT_WORKING_DIRECTORY   ".\\"
#   define EESOF_DEFAULT_DIR           "\\hpeesof"
#   define HPEESOF_DEFAULT_DIR         "\\hpeesof"
#   define NON_CONFORMING_SEPARATOR     '/'

#else

    /* file/directory/environment for Unix */
#   define DRIVE_SEPARATOR             '/'
#   define HOME_SEPARATOR              '~'
#   define DIRECTORY_SEPARATOR         '/'
#   define DIRECTORY_SEPARATOR_STRG    "/"
#   define EXTENSION_SEPARATOR         '.'
#   define CURRENT_WORKING_DIRECTORY   "./"
#   define EESOF_DEFAULT_DIR           "/hpeesof"
#   define HPEESOF_DEFAULT_DIR         "/hpeesof"
#   define NON_CONFORMING_SEPARATOR    '\\'
#endif

/* HP EEsof directory */
#define HPEESOF_DIRECTORY              "hpeesof"


/* Basic data type bit sizes */
#ifndef BYTESIZE
#define BYTESIZE        8
#endif

#ifndef BITSPERBYTE
#define BITSPERBYTE     8
#endif

#ifndef BITS
#define BITS(type)      (BITSPERBYTE * (int)sizeof(type))
#endif

#endif /* HPSTDDEFS_H_INCLUDED */
 
/******************************************************************************/
/***************************  end of HPstddefs  *******************************/
/******************************************************************************/

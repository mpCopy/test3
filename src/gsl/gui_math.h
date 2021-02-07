
#ifndef GUI_MATH_H_INCLUDED
#define GUI_MATH_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

// Steps for using gsl_math.h in place of gui_math.h
// 1.  Change the include from gui_math.h to gsl_math.h

#include "gslexpt.h"            // Needed for the GSL_API definition.
#include "gsl_math.h"           // Function headers for GSL math functions
#include "Platforms.h"
// This is here because the code below for the math functions under SOLARIS in
// C++ have to do something special to the prototypes.  This depends on having
// Platforms.h available. Although it is expected that files including any
// gui_xxx header should be including eetype.h, which includes Platforms.h, some
// projects were found to  not follow this assumption. Therefore, this ensures 
// Platforms.h is available.


#ifdef _WIN32
#pragma warning(disable:4514)/* unreferenced inline function has been removed */
#endif

#if defined (_WIN32)               
#if !defined(M_PI)
#define M_PI	    3.14159265358979323846264338
#endif
#if !defined(M_PI_2)
#define M_PI_2	    1.57079632679489661923132169
#endif
#if !defined(M_PI_4)
#define M_PI_4	    0.78539816339744830961566085
#endif
#if !defined(MAXFLOAT)
#define  MAXFLOAT   ((float)3.40282346638528860e+38)
#endif
#endif

#endif /* GUI_MATH_H_INCLUDED */


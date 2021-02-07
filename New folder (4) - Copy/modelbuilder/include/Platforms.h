/* @(#) $Source: /cvs/wlv/src/gsl/source/Platforms.h,v $ $Revision: 100.19 $ $Date: 2011/08/23 21:38:59 $  */
/****************************                    *****************************/
/******************                                        *******************/
/***                    HP EESOF Platform Definitions                      ***/
/***                                                                       ***/
/******************                                        *******************/
/****************************                    *****************************/
 
#ifndef PLATFORMS_H_INCLUDED
#define PLATFORMS_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2017  

#ifndef GUI_LIMITS_H_INCLUDED
# include "gui_limits.h"
#endif


/* Target machine codes */
#define	 INTEL_WIN32	10
#define	 INTEL_LINUX	11

typedef long long ee_long64;

#ifdef __WIN32
# define EE_LONG64_MAX		(9223372036854775807i64)
#else	/* ! __WIN32 */
# define EE_LONG64_MAX		(9223372036854775807LL)
#endif	/* ! __WIN32 */
#define EE_LONG64_MIN		((-EE_LONG64_MIN) - 1)



#if defined(_WIN32)             /* Win32 NT */
#   define _WIN32_target
#   define PLATFORM_TARGET  INTEL_WIN32
#else
#   undef  _WIN32_target
#endif

#if defined(linux)
#   define _linux_target
#   define _LINUX_target
#   define PLATFORM_TARGET  INTEL_LINUX
#else
#   undef _linux_target
#endif



#if defined(linux)
#undef NULL
#define NULL (0)
#endif


/* linux */
#if defined(linux)
#ifdef __GNUG__  // g++ only 
static_assert(sizeof(void *) == 8, "Only 64 bit is supported");
#endif
/* 64-bit linux */
typedef long				EE_INTEGRAL_PTR;
#  define EE_INTEGRAL_PTR_MAX		LONG_MAX
#  define EE_INTEGRAL_PTR_MIN		LONG_MIN
#  define EE_INTEGRAL_PTR_PRINT_STR	"0x%016p"
/*****************************************************************************/
/* Windows */
#elif defined(WIN32)
static_assert(sizeof(void *) == 8, "Only 64 bit is supported");
/* 64-bit windows */
typedef long long			EE_INTEGRAL_PTR;
#  if defined(_I64_MIN) && defined(_I64_MAX)
#   define EE_INTEGRAL_PTR_MAX		_I64_MAX
#   define EE_INTEGRAL_PTR_MIN		_I64_MIN
#  else	/* !_I64_MIN */
#   define EE_INTEGRAL_PTR_MAX		9223372036854775807i64
#   define EE_INTEGRAL_PTR_MIN		(-9223372036854775807i64 - 1)
#  endif	/* !_I64_MIN */
#  define EE_INTEGRAL_PTR_PRINT_STR	"0x%016p"
/*****************************************************************************/
/* Unsupported platform -- generate an error */
#else	/* Unknown platform */
UNSUPPORTED PLATFORM
(Perhaps the platform #defines have changed?)
#endif	/* Unknown platform */

/******************************************************************************
 *****************************************************************************/

#endif /* PLATFORMS_H_INCLUDED */
 

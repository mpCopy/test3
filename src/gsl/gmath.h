
#ifndef GMATH_H_INCLUDED
#define GMATH_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

// Steps needed to use gsl_math.h directly instead of gmath.h
// 1.  
#include "gslexpt.h"            // Needed for the GSL_API definition.
#include "gui_math.h"           // Includes all necessary math function headers.

// Single Precision Complex math operators
#define cnoadd          gmath_csnoadd    
#define cnosub          gmath_csnosub
#define cnomlt          gmath_csnomlt
#define cnodiv          gmath_csnodiv
#define cnoexp          gmath_csnoexp
#define cnolog          gmath_csnolog
#define cnolog10        gmath_csnolog10
#define cnopwr          gmath_csnopwr
#define cno10x          gmath_csno10x
#define cnosqr          gmath_csnosqr
#define cnosqrt         gmath_csnosqrt
#define cnosin          gmath_csnosin
#define cnocos          gmath_csnocos
#define cnotan          gmath_csnotan
#define cnosinh         gmath_csnosinh
#define cnocosh         gmath_csnocosh
#define cnotanh         gmath_csnotanh
#define cnoasin         gmath_csnoasin
#define cnoacos         gmath_csnoacos
#define cnoatan         gmath_csnoatan
#define cnoasinh        gmath_csnoasinh
#define cnoacosh        gmath_csnoacosh
#define cnoatanh        gmath_csnoatanh

#define gmathM_dnosqr        ((x) * (x))
#define gmathM_eedabs(x)     fabs(x)
#define gmathM_dnosqrt(x)    sqrt(x)
#define gmathM_dnopwr(x,y)   pow(x, y)
#define gmathM_dnosin(x)     sin(x)
#define gmathM_dnocos(x)     cos(x)
#define gmathM_dnotan(x)     tan(x)
#define gmathM_dnosinh(x)    sinh(x)
#define gmathM_dnocosh(x)    cosh(x)
#define gmathM_dnotanh(x)    tanh(x)
#define gmathM_dnoasin(x)    asin(x)
#define gmathM_dnoacos(x)    acos(x)
#define gmathM_dnoatan(x)    atan(x)
#define gmathM_dno10x(x)     gmathM_dnopwr(10.0, x)
#define gmathM_dnoexp(x)     exp(x)
#define gmathM_dnolog(x)     log(x)
#define gmathM_dnolog10(x)   log10(x)
#define gmathM_dmagxy(x, y)  hypot(x, y)

#endif  // GMATH_H_INCLUDED

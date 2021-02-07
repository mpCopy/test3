
#ifndef GSL_MATH_H_INCLUDED
#define GSL_MATH_H_INCLUDED
// Copyright Keysight Technologies 2008 - 2017  

#include "gslexpt.h"            // Needed for the GSL_API definition.
#include "c_bool.h"             // Needed for ee_bool
#include <math.h>

#if defined(_WIN32)
#undef complex
#endif
#include <float.h> // for hypot(), isnan(), jx(), yx(), etc.


#if defined(__cplusplus) || defined(c_plusplus)
# include <cmath>

// Define 2's complement positive/negative int, long, limits
#define EEMAXPOSSHORT    32767
#define EEMAXNEGSHORT   -32768
#define EEMAXPOSINT      2147483647
#define EEMAXNEGINT     -2147483647
#define EEMAXPOSLONG     2147483647
#define EEMAXNEGLONG    -2147483647

// Define math constants. 
// Note, these will not serve for quad-precision data. When the time comes, we will define
// new math constants that support 113 bit precision, which is about 34 decimal digits
const double GSL_PI = 3.14159265358979323846;
const double GSL_PI_2 = 1.57079632679489661923;
const double GSL_TWOPI = 6.28318530717958647692;
const double GSL_E = 2.71828182845904523536;
const double GSL_LN10 = 2.30258509299404568401;
const double GSL_MU0 = 12.56637061435917295385e-7;
const double GSL_EPS0 = 8.8541879239442e-12;
const double GSL_ETA0 = 376.7303111199824;
const double GSL_DB_PER_NEP = 8.68588963806503655302;
const double GSL_NEP_PER_DB = 0.11512925464970228420;
const double GSL_RAD_PER_DEG = 0.01745329251994329576;
const double GSL_DEG_PER_RAD = 57.29577951308232087679;

inline double square(double x)
{
    return((x) * (x));
}

#if defined(_WIN32)
// Inline functions instead of #define statements.  These are necessary to allow 
// the Windows functions to be used the same as the Unix functions.
inline double finite(double _in)
{
    return(_finite(_in));
}

inline int isnan(double _X)
{
    return(_isnan(_X));
}

#if !defined(_WIN32)
//TODO: Do we need the rest of these? The Microsoft headers have these wrappers already!
inline   double hypot(double _X, double _Y)
{
    return(_hypot(_X, _Y));
}
#endif

inline double j0(double _X)
{
    return(_j0(_X));
}

inline double j1(double _X)
{
    return(_j1(_X));
}

inline double jn(int _X, double _Y)
{
    return(_jn(_X, _Y));
}

inline double  y0(double _X)
{
    return(_y0(_X));
}

inline double  y1(double _X)
{
    return(_y1(_X));
}

inline double yn(int _X, double _Y)
{
    return(_yn(_X, _Y));
}
# endif
#else
#if defined(_WIN32)
//Regular C, can't use inline functions.
//These functions are simple wrappers that call the library versions (with underscores).
GSL_API  double finite(double _in);
#ifndef isnan
GSL_API  int isnan(double _X);
#endif
# endif
GSL_API  double square(double _x);
#endif

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif
GSL_API  double gmath_quiet_nan(void);
GSL_API  void gmath_set_usererr(ee_bool *add);
GSL_API  void gmath_clr_ematherr(void);
GSL_API  ee_bool gmath_ematherr(void);
GSL_API  int gmath_eetrunc(double x);
GSL_API  long gmath_eedtrunc(double x);
GSL_API  int gmath_eeround(double x);
GSL_API  double gmath_eedround(double x);
GSL_API  int gmath_eeiabs(int i);
GSL_API  float gmath_eefloat(int i);
GSL_API  float gmath_eefabs(float x);
GSL_API  float gmath_snosqr(float x);
GSL_API  float gmath_snosqrt(float x);
GSL_API  float gmath_snopwr(float x, float y);
GSL_API  float gmath_snosin(float x);
GSL_API  float gmath_snocos(float x);
GSL_API  float gmath_snotan(float);
GSL_API  float gmath_snosinh(float x);
GSL_API  float gmath_snocosh(float x);
GSL_API  float gmath_snotanh(float x);
GSL_API  float gmath_snoasin(float x);
GSL_API  float gmath_snoacos(float);
GSL_API  float gmath_snoatan(float);
GSL_API  float gmath_sno10x(float x);
GSL_API  float gmath_snoexp(float x);
GSL_API  float gmath_snolog(float x);
GSL_API  float gmath_snolog10(float x);
GSL_API  float gmath_snoatan2(float y, float x);
GSL_API  float gmath_snoasinh(float x);
GSL_API  float gmath_snoacosh(float x);
GSL_API  float gmath_snoatanh(float x);
GSL_API  float gmath_magxy(float x, float y);
GSL_API  void gmath_csnoadd(float xin1, float yin1, float xin2, float yin2,
                          float *xout, float *yout);
GSL_API  void gmath_csnosub(float xin1, float yin1, float xin2, float yin2,
                          float *xout, float *yout);
GSL_API  void gmath_csnomlt(float xin1, float yin1, float xin2, float yin2,
                          float *xout, float *yout);
GSL_API  void gmath_csnodiv(float xin1, float yin1, float xin2, float yin2,
                          float *xout, float *yout);
GSL_API  void gmath_csnoexp(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnolog(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnolog10(float xint, float yin, float *xout, float *yout);
GSL_API  void gmath_csnopwr(float xin1, float yin1, float xin2, float yin2,
                          float *xout, float *yout);
GSL_API  void gmath_csno10x(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnosqr(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnosqrt(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnosin(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnocos(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnotan(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnosinh(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnocosh(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnotanh(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoasin(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoacos(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoatan(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoasinh(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoacosh(float xin, float yin, float *xout, float *yout);
GSL_API  void gmath_csnoatanh(float xin, float yin, float *xout, float *yout);

GSL_API  double gmath_dnoatan2(double y, double x);
GSL_API  double gmath_dnoerf(double x);
GSL_API  double gmath_dnoerfc(double x);
GSL_API  long   gmath_eelround(double x);

GSL_API  void gmath_cdnoadd(double xin1, double yin1, double xin2, double yin2,
                          double *xout, double *yout);
GSL_API  void gmath_cdnosub(double xin1, double yin1, double xin2, double yin2,
                          double *xout, double *yout);
GSL_API  void gmath_cdnomlt(double xin1, double yin1, double xin2, double yin2,
                          double *xout, double *yout);
GSL_API  void gmath_cdnodiv(double xin1, double yin1, double xin2, double yin2,
                          double *xout, double *yout);

GSL_API  void gmath_cdnoexp(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnolog(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnolog10(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnopwr(double xin1, double yin1, double xin2, double yin2,
                          double *xout, double *yout);
GSL_API  void gmath_cdno10x(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnosqr(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnosqrt(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnosin(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnocos(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnotan(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnosinh(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnocosh(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnotanh(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoasin(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoacos(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoatan(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoasinh(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoacosh(double xin, double yin, double *xout, double *yout);
GSL_API  void gmath_cdnoatanh(double xin, double yin, double *xout, double *yout);

// Windows does not have built in functions for asinh, acosh, or atanh.  These 
// functions take the place of the unix functions.  For non-windows platforms, the functions 
// call the windows equivalent functions.
GSL_API  double gmath_dnoasinh(double x);
GSL_API  double gmath_dnoacosh(double x);
GSL_API  double gmath_dnoatanh(double x);

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#endif // GSL_MATH_H_INCLUDED

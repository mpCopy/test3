/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/compat/win32/pwd.h,v $ $Revision: 1.6 $ $Date: 2011/08/25 01:47:10 $ */
/* Provided for compatibity with other C++ compilers ONLY! */

#ifndef PWD_H_INCLUDED
#define PWD_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2014  

struct passwd {int pw_dir;} _vxyz;

#define getuid() &_vxyz
#define getpwuid( p ) p
#define getpwnam( p ) &_vxyz

#endif   /* PWD_H_INCLUDED */

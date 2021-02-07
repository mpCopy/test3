/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFPcwzLinear.pl,v $ $Revision: 1.24 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFPcwzLinear_h
#define _SDFPcwzLinear_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFPcwzLinear.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "ComplexArrayState.h"
#include "sdfstarsDll.h"

class SDFPcwzLinear:public SDFStar
{
public:
	SDFPcwzLinear();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	/* virtual */ ~SDFPcwzLinear();
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	ComplexArrayState Breakpoints;
#line 52 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFPcwzLinear.pl"
int size;   // used to store the Breakpoints array size
		double *x_array;
// x_array is used to store a copy of the x values of the Breakpoints array
// (these values are used a lot in the go method so having a copy increases speed)

};
#endif

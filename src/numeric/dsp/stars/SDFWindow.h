/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFWindow.pl,v $ $Revision: 100.29 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFWindow_h
#define _SDFWindow_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFWindow.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "StringState.h"
#include "FloatArrayState.h"
#include "sdfdspstarsDll.h"

class SDFWindow:public SDFStar
{
public:
	SDFWindow();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	/* virtual */ ~SDFWindow();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	StringState Name;
	IntState Length;
	IntState Period;
	FloatArrayState WindowParameters;
#line 56 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFWindow.pl"
int realLen;
		int realPeriod;
		double* windowTaps;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFRectCxDoppler.pl,v $ $Revision: 1.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRectCxDoppler_h
#define _SDFRectCxDoppler_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRectCxDoppler.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFRectCx.h"
#include "gui_math.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFRectCxDoppler:public SDFRectCx
{
public:
	SDFRectCxDoppler();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Bandwidth;
	FloatState Te;
	FloatState Fe;
	FloatState Fsimu;
	FloatState Vn;
	FloatState Tp;
	IntState Np;
	FloatState Fpor;
	FloatState C;
	FloatState SNRn;
	FloatState SqrPthn;
	FloatState Sdelay;
	IntState Dopplercount;
#line 129 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRectCxDoppler.pl"
double arg1;
		double arg2;
		double doparg0;
		double amp;
		int dopplerChanged;

};
#endif

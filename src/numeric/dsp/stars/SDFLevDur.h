/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFLevDur.pl,v $ $Revision: 100.22 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFLevDur_h
#define _SDFLevDur_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLevDur.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFLevDur:public SDFStar
{
public:
	SDFLevDur();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFLevDur();
	InSDFPort autocor;
	OutSDFPort lp;
	OutSDFPort refl;
	OutSDFPort errPower;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Order;
#line 50 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLevDur.pl"
double *aOrig, *aPrime, *r;
		int ORD;

};
#endif

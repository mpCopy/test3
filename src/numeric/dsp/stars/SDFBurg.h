/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFBurg.pl,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFBurg_h
#define _SDFBurg_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBurg.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFBurg:public SDFStar
{
public:
	SDFBurg();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFBurg();
	InSDFPort input;
	OutSDFPort lp;
	OutSDFPort refl;
	OutSDFPort errPower;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Order;
	IntState NumInputs;
#line 57 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBurg.pl"
double *f, *b, *aOrig, *aPrime;
		int N, M;

};
#endif

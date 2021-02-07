/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFAutocor.pl,v $ $Revision: 100.28 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFAutocor_h
#define _SDFAutocor_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFAutocor.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "EnumState.h"
#include "sdfdspstarsDll.h"

class SDFAutocor:public SDFStar
{
public:
	SDFAutocor();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	OutSDFPort output;

protected:
	enum UnbiasedE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	IntState NoInputsToAvg;
	IntState NoLags;
	EnumState Unbiased;
#line 51 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFAutocor.pl"
int lags, N;

};
#endif

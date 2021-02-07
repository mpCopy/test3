/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFGainFix.pl,v $ $Revision: 1.27 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFGainFix_h
#define _SDFGainFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFGainFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "FixState.h"
#include "PrecisionState.h"
#include "EnumState.h"
#include "fixbaseDll.h"

class SDFGainFix:public SDFFix
{
public:
	SDFGainFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	enum UseArrivingPrecisionE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	FixState Gain;
	EnumState UseArrivingPrecision;
	PrecisionState InputPrecision;
	PrecisionState OutputPrecision;
#line 65 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFGainFix.pl"
Fix fixIn, out;

};
#endif

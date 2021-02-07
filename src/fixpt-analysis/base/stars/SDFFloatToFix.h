/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFFloatToFix.pl,v $ $Revision: 1.24 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFFloatToFix_h
#define _SDFFloatToFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFFloatToFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "PrecisionState.h"
#include "fixbaseDll.h"

class SDFFloatToFix:public SDFFix
{
public:
	SDFFloatToFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	PrecisionState OutputPrecision;
#line 29 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFFloatToFix.pl"
Fix out;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFRampFix.pl,v $ $Revision: 1.27 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFRampFix_h
#define _SDFRampFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFRampFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "FixState.h"
#include "PrecisionState.h"
#include "fixbaseDll.h"

class SDFRampFix:public SDFFix
{
public:
	SDFRampFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	PrecisionState OutputPrecision;
	FixState Step;
	FixState Value;
#line 60 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFRampFix.pl"
Fix t;
		bool firstFiringDone;

};
#endif

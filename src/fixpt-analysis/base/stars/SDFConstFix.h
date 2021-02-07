/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFConstFix.pl,v $ $Revision: 1.28 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFConstFix_h
#define _SDFConstFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFConstFix.pl by ptlang

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

class SDFConstFix:public SDFFix
{
public:
	SDFConstFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FixState Level;
	PrecisionState OutputPrecision;
#line 39 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFConstFix.pl"
Fix out;

};
#endif

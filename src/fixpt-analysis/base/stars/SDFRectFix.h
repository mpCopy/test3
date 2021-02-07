/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFRectFix.pl,v $ $Revision: 1.27 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFRectFix_h
#define _SDFRectFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFRectFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "IntState.h"
#include "FixState.h"
#include "PrecisionState.h"
#include "fixbaseDll.h"

class SDFRectFix:public SDFFix
{
public:
	SDFRectFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FixState Height;
	IntState Width;
	IntState Period;
	IntState Count;
	PrecisionState OutputPrecision;
#line 65 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFRectFix.pl"
Fix out;

};
#endif

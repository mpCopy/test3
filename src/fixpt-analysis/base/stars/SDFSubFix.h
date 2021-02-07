/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFSubFix.pl,v $ $Revision: 1.26 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFSubFix_h
#define _SDFSubFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFSubFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "PrecisionState.h"
#include "EnumState.h"
#include "fixbaseDll.h"

class SDFSubFix:public SDFFix
{
public:
	SDFSubFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort pos;
	MultiInSDFPort neg;
	OutSDFPort output;

protected:
	enum UseArrivingPrecisionE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	EnumState UseArrivingPrecision;
	PrecisionState InputPrecision;
	PrecisionState OutputPrecision;
#line 47 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFSubFix.pl"
Fix fixIn, diff;

};
#endif

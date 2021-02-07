/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFAddFix.pl,v $ $Revision: 1.28 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFAddFix_h
#define _SDFAddFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFAddFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "StringState.h"
#include "PrecisionState.h"
#include "EnumState.h"
#include "fixbaseDll.h"

class SDFAddFix:public SDFFix
{
public:
	SDFAddFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	MultiInSDFPort input;
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
	StringState _symbolName;
#line 49 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFAddFix.pl"
Fix fixIn, sum;

};
#endif

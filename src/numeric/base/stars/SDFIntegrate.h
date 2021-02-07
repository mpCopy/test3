/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFIntegrate.pl,v $ $Revision: 100.13 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFIntegrate_h
#define _SDFIntegrate_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIntegrate.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "EnumState.h"
#include "sdfstarsDll.h"

class SDFIntegrate:public SDFStar
{
public:
	SDFIntegrate();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort data;
	InSDFPort reset;
	OutSDFPort output;

protected:
	enum SaturateE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FeedbackGain;
	FloatState Top;
	FloatState Bottom;
	EnumState Saturate;
	FloatState State;
#line 83 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIntegrate.pl"
double spread;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFSineGen.pl,v $ $Revision: 100.36 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFSineGen_h
#define _SDFSineGen_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFSineGen.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFSineGen:public SDFStar
{
public:
	SDFSineGen();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState RadiansPerSample;
	FloatState InitialRadians;
#line 35 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFSineGen.pl"
double t;
	  double dt;

};
#endif

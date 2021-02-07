/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFImpulseFloat.pl,v $ $Revision: 100.17 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFImpulseFloat_h
#define _SDFImpulseFloat_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFImpulseFloat.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFImpulseFloat:public SDFStar
{
public:
	SDFImpulseFloat();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Level;
	IntState Period;
	IntState Delay;
	IntState Count;

};
#endif

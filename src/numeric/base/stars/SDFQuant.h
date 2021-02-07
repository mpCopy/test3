/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFQuant.pl,v $ $Revision: 1.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFQuant_h
#define _SDFQuant_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFQuant.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatArrayState.h"
#include "sdfstarsDll.h"

class SDFQuant:public SDFStar
{
public:
	SDFQuant();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatArrayState Thresholds;
	FloatArrayState Levels;
	IntState QuantizationLevel;

};
#endif

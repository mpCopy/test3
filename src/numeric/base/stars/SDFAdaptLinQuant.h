/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFAdaptLinQuant.pl,v $ $Revision: 1.22 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFAdaptLinQuant_h
#define _SDFAdaptLinQuant_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFAdaptLinQuant.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFAdaptLinQuant:public SDFStar
{
public:
	SDFAdaptLinQuant();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	InSDFPort inStep;
	OutSDFPort amplitude;
	OutSDFPort outStep;
	OutSDFPort stepLevel;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Bits;

};
#endif

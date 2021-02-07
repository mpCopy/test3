/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFLinQuantIdx.pl,v $ $Revision: 1.20 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFLinQuantIdx_h
#define _SDFLinQuantIdx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLinQuantIdx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFLinQuantIdx:public SDFStar
{
public:
	SDFLinQuantIdx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort amplitude;
	OutSDFPort stepNumber;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Levels;
	FloatState Low;
	FloatState High;
	FloatState Height;

};
#endif

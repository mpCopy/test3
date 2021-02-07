/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFRampFloat.pl,v $ $Revision: 100.16 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRampFloat_h
#define _SDFRampFloat_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRampFloat.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFRampFloat:public SDFStar
{
public:
	SDFRampFloat();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState Step;
	FloatState Value;

};
#endif

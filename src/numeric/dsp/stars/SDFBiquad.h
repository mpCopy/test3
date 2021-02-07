/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFBiquad.pl,v $ $Revision: 100.20 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFBiquad_h
#define _SDFBiquad_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBiquad.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfdspstarsDll.h"

class SDFBiquad:public SDFStar
{
public:
	SDFBiquad();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState D1;
	FloatState D2;
	FloatState N0;
	FloatState N1;
	FloatState N2;
	FloatState State1;
	FloatState State2;

};
#endif

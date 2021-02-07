/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFMuLaw.pl,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFMuLaw_h
#define _SDFMuLaw_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFMuLaw.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfdspstarsDll.h"

class SDFMuLaw:public SDFStar
{
public:
	SDFMuLaw();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Compress;
	IntState Mu;
	FloatState Denom;

};
#endif

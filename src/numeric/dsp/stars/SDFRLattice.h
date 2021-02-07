/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFRLattice.pl,v $ $Revision: 100.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRLattice_h
#define _SDFRLattice_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFRLattice.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatArrayState.h"
#include "sdfdspstarsDll.h"

class SDFRLattice:public SDFStar
{
public:
	SDFRLattice();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFRLattice();
	InSDFPort signalIn;
	OutSDFPort signalOut;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatArrayState ReflectionCoefs;
#line 33 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFRLattice.pl"
double *w;
		double *y;
		int M;

};
#endif

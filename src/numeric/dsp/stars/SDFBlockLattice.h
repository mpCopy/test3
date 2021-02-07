/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFBlockLattice.pl,v $ $Revision: 100.21 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFBlockLattice_h
#define _SDFBlockLattice_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockLattice.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFBlockLattice:public SDFStar
{
public:
	SDFBlockLattice();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFBlockLattice();
	InSDFPort signalIn;
	InSDFPort coefs;
	OutSDFPort signalOut;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState BlockSize;
	IntState Order;
#line 49 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockLattice.pl"
double *b;
		double *f;
		double *reflectionCoefs;
		int lastM;

};
#endif

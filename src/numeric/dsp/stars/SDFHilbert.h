/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFHilbert.pl,v $ $Revision: 100.25 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFHilbert_h
#define _SDFHilbert_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFHilbert.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFFIR.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFHilbert:public SDFFIR
{
public:
	SDFHilbert();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	/* virtual */ void setup();
	IntState N;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFUnwrap.pl,v $ $Revision: 100.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFUnwrap_h
#define _SDFUnwrap_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFUnwrap.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfdspstarsDll.h"

class SDFUnwrap:public SDFStar
{
public:
	SDFUnwrap();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState OutPhase;
	FloatState PrevPhase;

};
#endif

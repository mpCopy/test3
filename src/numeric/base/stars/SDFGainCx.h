/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFGainCx.pl,v $ $Revision: 1.21 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFGainCx_h
#define _SDFGainCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFGainCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "ComplexState.h"
#include "sdfstarsDll.h"

class SDFGainCx:public SDFStar
{
public:
	SDFGainCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	ComplexState Gain;

};
#endif

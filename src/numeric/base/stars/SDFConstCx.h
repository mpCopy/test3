/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFConstCx.pl,v $ $Revision: 1.24 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFConstCx_h
#define _SDFConstCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFConstCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFConstCx:public SDFStar
{
public:
	SDFConstCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState Real;
	FloatState Imag;

};
#endif

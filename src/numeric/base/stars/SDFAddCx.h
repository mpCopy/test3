/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFAddCx.pl,v $ $Revision: 1.19 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFAddCx_h
#define _SDFAddCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFAddCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFAddCx:public SDFStar
{
public:
	SDFAddCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	MultiInSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

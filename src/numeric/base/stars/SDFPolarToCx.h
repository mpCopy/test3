/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFPolarToCx.pl,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFPolarToCx_h
#define _SDFPolarToCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFPolarToCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFPolarToCx:public SDFStar
{
public:
	SDFPolarToCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort magnitude;
	InSDFPort phase;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

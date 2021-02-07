/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFPolarToRect.pl,v $ $Revision: 1.18 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFPolarToRect_h
#define _SDFPolarToRect_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFPolarToRect.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFPolarToRect:public SDFStar
{
public:
	SDFPolarToRect();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort magnitude;
	InSDFPort phase;
	OutSDFPort x;
	OutSDFPort y;

protected:
	/* virtual */ void go();
};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFMpyCx.pl,v $ $Revision: 1.17 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFMpyCx_h
#define _SDFMpyCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFMpyCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFMpyCx:public SDFStar
{
public:
	SDFMpyCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	MultiInSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

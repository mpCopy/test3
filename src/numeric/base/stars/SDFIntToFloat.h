/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFIntToFloat.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFIntToFloat_h
#define _SDFIntToFloat_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIntToFloat.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFIntToFloat:public SDFStar
{
public:
	SDFIntToFloat();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

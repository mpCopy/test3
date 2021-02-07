/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFFixToFloat.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:58:50 $ */
#ifndef _SDFFixToFloat_h
#define _SDFFixToFloat_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFFixToFloat.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1996 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "fixbaseDll.h"

class SDFFixToFloat:public SDFStar
{
public:
	SDFFixToFloat();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFSub.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFSub_h
#define _SDFSub_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFSub.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFSub:public SDFStar
{
public:
	SDFSub();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort pos;
	MultiInSDFPort neg;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

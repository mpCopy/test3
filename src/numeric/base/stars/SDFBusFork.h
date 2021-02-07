/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFBusFork.pl,v $ $Revision: 1.18 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFBusFork_h
#define _SDFBusFork_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFBusFork.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFBusFork:public SDFStar
{
public:
	SDFBusFork();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	MultiInSDFPort input;
	MultiOutSDFPort outputA;
	MultiOutSDFPort outputB;

protected:
	/* virtual */ void go();
};
#endif

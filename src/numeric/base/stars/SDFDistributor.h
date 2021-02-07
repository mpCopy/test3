/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFDistributor.pl,v $ $Revision: 1.20 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFDistributor_h
#define _SDFDistributor_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDistributor.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFDistributor:public SDFStar
{
public:
	SDFDistributor();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	MultiOutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState BlockSize;

};
#endif

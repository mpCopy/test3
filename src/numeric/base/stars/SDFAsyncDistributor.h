/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFAsyncDistributor.pl,v $ $Revision: 100.4 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFAsyncDistributor_h
#define _SDFAsyncDistributor_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFAsyncDistributor.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2001 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntArrayState.h"
#include "sdfstarsDll.h"

class SDFAsyncDistributor:public SDFStar
{
public:
	SDFAsyncDistributor();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	MultiOutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntArrayState BlockSizes;

private:
#line 44 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFAsyncDistributor.pl"
int in_block_size;

};
#endif

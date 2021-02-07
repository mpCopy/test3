/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFReciprocal.pl,v $ $Revision: 1.21 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFReciprocal_h
#define _SDFReciprocal_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFReciprocal.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFReciprocal:public SDFStar
{
public:
	SDFReciprocal();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState MagLimit;

};
#endif

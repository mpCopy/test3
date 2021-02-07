/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFOrderTwoInt.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFOrderTwoInt_h
#define _SDFOrderTwoInt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFOrderTwoInt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFOrderTwoInt:public SDFStar
{
public:
	SDFOrderTwoInt();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort upper;
	InSDFPort lower;
	OutSDFPort greater;
	OutSDFPort lesser;

protected:
	/* virtual */ void go();
};
#endif

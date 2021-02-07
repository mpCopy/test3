/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFSubInt.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFSubInt_h
#define _SDFSubInt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFSubInt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFSubInt:public SDFStar
{
public:
	SDFSubInt();
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

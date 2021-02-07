/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFDivByInt.pl,v $ $Revision: 1.19 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFDivByInt_h
#define _SDFDivByInt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDivByInt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFDivByInt:public SDFStar
{
public:
	SDFDivByInt();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Divisor;

};
#endif

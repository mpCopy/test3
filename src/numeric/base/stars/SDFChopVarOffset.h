/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFChopVarOffset.pl,v $ $Revision: 1.21 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFChopVarOffset_h
#define _SDFChopVarOffset_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFChopVarOffset.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFChop.h"
#include "sdfstarsDll.h"

class SDFChopVarOffset:public SDFChop
{
public:
	SDFChopVarOffset();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort offsetCntrl;

protected:
	/* virtual */ void go();
};
#endif

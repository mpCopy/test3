/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFQuantIdx.pl,v $ $Revision: 1.17 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFQuantIdx_h
#define _SDFQuantIdx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFQuantIdx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFQuant.h"
#include "sdfstarsDll.h"

class SDFQuantIdx:public SDFQuant
{
public:
	SDFQuantIdx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort stepNumber;

protected:
	/* virtual */ void go();
};
#endif

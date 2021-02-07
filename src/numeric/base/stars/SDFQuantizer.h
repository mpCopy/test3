/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFQuantizer.pl,v $ $Revision: 1.20 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFQuantizer_h
#define _SDFQuantizer_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFQuantizer.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatArrayState.h"
#include "sdfstarsDll.h"

class SDFQuantizer:public SDFStar
{
public:
	SDFQuantizer();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;
	OutSDFPort outIndex;

protected:
	/* virtual */ void go();
	FloatArrayState FloatCodebook;

};
#endif

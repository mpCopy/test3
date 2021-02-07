/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFTableCx.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFTableCx_h
#define _SDFTableCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFTableCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "ComplexArrayState.h"
#include "sdfstarsDll.h"

class SDFTableCx:public SDFStar
{
public:
	SDFTableCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	ComplexArrayState Values;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFDeMux.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFDeMux_h
#define _SDFDeMux_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDeMux.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "PtMatrixHelper.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFDeMux:public SDFStar
{
public:
	SDFDeMux();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	InSDFPort control;
	MultiOutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState BlockSize;

private:
#line 24 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDeMux.pl"
PtMatrixHelper inputMxHelper;

};
#endif

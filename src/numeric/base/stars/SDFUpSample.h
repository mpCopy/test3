/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFUpSample.pl,v $ $Revision: 1.22 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFUpSample_h
#define _SDFUpSample_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFUpSample.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "PtMatrixHelper.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFUpSample:public SDFStar
{
public:
	SDFUpSample();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Factor;
	IntState Phase;
	FloatState Fill;

private:
#line 52 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFUpSample.pl"
PtMatrixHelper inputMxHelper;

};
#endif

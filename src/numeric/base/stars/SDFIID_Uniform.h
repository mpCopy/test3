/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFIID_Uniform.pl,v $ $Revision: 100.20 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFIID_Uniform_h
#define _SDFIID_Uniform_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIID_Uniform.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "PtRng.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFIID_Uniform:public SDFStar
{
public:
	SDFIID_Uniform();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFIID_Uniform();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Lower;
	FloatState Upper;
#line 42 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIID_Uniform.pl"
PtUniform *random;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFIID_Gaussian.pl,v $ $Revision: 100.20 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFIID_Gaussian_h
#define _SDFIID_Gaussian_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIID_Gaussian.pl by ptlang

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

class SDFIID_Gaussian:public SDFStar
{
public:
	SDFIID_Gaussian();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFIID_Gaussian();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Mean;
	FloatState Variance;
#line 44 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFIID_Gaussian.pl"
PtNormal *random;

};
#endif

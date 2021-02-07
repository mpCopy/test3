/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFFFT_Cx.pl,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFFFT_Cx_h
#define _SDFFFT_Cx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFFT_Cx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "EnumState.h"
#include "sdfdspstarsDll.h"

class SDFFFT_Cx:public SDFStar
{
public:
	SDFFFT_Cx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFFFT_Cx();
	InSDFPort input;
	OutSDFPort output;

protected:
	enum DirectionE
	{
		Inverse,
		Forward
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	IntState Order;
	IntState Size;
	EnumState Direction;
#line 51 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFFT_Cx.pl"
double* data;
                int fftSize;

};
#endif

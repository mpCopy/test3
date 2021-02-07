/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFIIR_Fix.pl,v $ $Revision: 100.29 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFIIR_Fix_h
#define _SDFIIR_Fix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFIIR_Fix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "FloatState.h"
#include "FloatArrayState.h"
#include "PrecisionState.h"
#include "EnumState.h"
#include "fixbaseDll.h"

class SDFIIR_Fix:public SDFFix
{
public:
	SDFIIR_Fix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFIIR_Fix();
	InSDFPort signalIn;
	OutSDFPort signalOut;

protected:
	enum UseArrivingPrecisionE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Gain;
	FloatArrayState Numerator;
	FloatArrayState Denominator;
	PrecisionState CoefPrecision;
	EnumState UseArrivingPrecision;
	PrecisionState InputPrecision;
	PrecisionState AccumPrecision;
	PrecisionState StatePrecision;
	PrecisionState OutputPrecision;
#line 94 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFIIR_Fix.pl"
int numState;
		Fix *fdbckCoefs, *fwdCoefs, *state;
		Fix fixIn, fdbckAccum, fwdAccum, out;

};
#endif

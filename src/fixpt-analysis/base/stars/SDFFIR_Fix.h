/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/fixpt-analysis/base/stars/SDFFIR_Fix.pl,v $ $Revision: 100.31 $ $Date: 2012/09/13 21:46:24 $ */
#ifndef _SDFFIR_Fix_h
#define _SDFFIR_Fix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFFIR_Fix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFFix.h"
#include "IntState.h"
#include "FixArrayState.h"
#include "PrecisionState.h"
#include "EnumState.h"
#include "fixbaseDll.h"

class SDFFIR_Fix:public SDFFix
{
public:
	SDFFIR_Fix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
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
	FixArrayState Taps;
	IntState Decimation;
	IntState DecimationPhase;
	IntState Interpolation;
	EnumState UseArrivingPrecision;
	PrecisionState InputPrecision;
	PrecisionState TapPrecision;
	PrecisionState AccumulationPrecision;
	PrecisionState OutputPrecision;
#line 93 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/fixpt-analysis/base/stars/SDFFIR_Fix.pl"
Fix Accum, fixIn, out, tap;
                int phaseLength;

};
#endif

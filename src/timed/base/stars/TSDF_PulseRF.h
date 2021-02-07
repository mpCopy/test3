/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_PulseRF.pl,v $ $Revision: 100.52 $ $Date: 2011/08/25 01:09:32 $ */
#ifndef _TSDF_PulseRF_h
#define _TSDF_PulseRF_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_PulseRF.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDF_PulseRF:public TSDFbasesource
{
public:
	TSDF_PulseRF();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (Complex *pVout);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FCarrier;
	FloatState PeakPower;
	FloatState Phase;
	FloatState PulsePeriod;
	FloatState PulseWidth;
	FloatState Delay;
	FloatState OnOffRatio;
	FloatState RiseTime;
	FloatState FallTime;
#line 113 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_PulseRF.pl"
double LeadingEdgeTime, TrailingEdgeTime, PlateauTime;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_Sinusoid.pl,v $ $Revision: 100.53 $ $Date: 2011/08/25 01:09:32 $ */
#ifndef _TSDF_Sinusoid_h
#define _TSDF_Sinusoid_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Sinusoid.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDF_Sinusoid:public TSDFbasesource
{
public:
	TSDF_Sinusoid();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (double *fVout);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState VPeak;
	FloatState Frequency;
	FloatState Phase;
	FloatState DecayRatio;
	FloatState Delay;
	FloatState DurationTime;
	FloatState RepetitionInterval;
#line 86 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Sinusoid.pl"
double DecayConstant;

};
#endif

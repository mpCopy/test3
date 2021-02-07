/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_Ramp.pl,v $ $Revision: 100.44 $ $Date: 2011/08/25 01:09:32 $ */
#ifndef _TSDF_Ramp_h
#define _TSDF_Ramp_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Ramp.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "EnumState.h"
#include "tsdfstarsDll.h"

class TSDF_Ramp:public TSDFbasesource
{
public:
	TSDF_Ramp();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (double *fVout);

protected:
	enum TypeE
	{
		Linear_Ramp,
		Power_Ramp,
		Exponential_Ramp
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FCarrier;
	FloatState VStart;
	FloatState VFinal;
	FloatState VOff;
	EnumState Type;
	FloatState RampConstant;
	FloatState Delay;
	FloatState DurationTime;
	FloatState RepetitionInterval;

};
#endif

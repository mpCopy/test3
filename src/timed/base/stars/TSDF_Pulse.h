/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_Pulse.pl,v $ $Revision: 100.47 $ $Date: 2011/08/25 01:09:31 $ */
#ifndef _TSDF_Pulse_h
#define _TSDF_Pulse_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Pulse.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDF_Pulse:public TSDFbasesource
{
public:
	TSDF_Pulse();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (double *fVout);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FCarrier;
	FloatState VStart;
	FloatState VPlateau;
	FloatState VStop;
	FloatState Delay;
	FloatState LeadingEdgeTime;
	FloatState PlateauTime;
	FloatState TrailingEdgeTime;
	FloatState RepetitionInterval;

};
#endif

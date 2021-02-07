/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_Clock.pl,v $ $Revision: 100.45 $ $Date: 2011/08/25 01:09:31 $ */
#ifndef _TSDF_Clock_h
#define _TSDF_Clock_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Clock.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "Block.h"
#include "StringList.h"
#include "ConstIters.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDF_Clock:public TSDFbasesource
{
public:
	TSDF_Clock();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (double *fVout);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Period;
	FloatState Delay;
	FloatState DutyCycle;
#line 58 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_Clock.pl"
unsigned long numFirings;

};
#endif

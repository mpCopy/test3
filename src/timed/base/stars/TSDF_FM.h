/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_FM.pl,v $ $Revision: 100.37 $ $Date: 2011/08/25 01:09:31 $ */
#ifndef _TSDF_FM_h
#define _TSDF_FM_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_FM.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "Block.h"
#include "StringList.h"
#include "ConstIters.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDF_FM:public TSDFbasesource
{
public:
	TSDF_FM();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (Complex *pVout);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FCarrier;
	FloatState Power;
	FloatState Phase;
	FloatState Sensitivity;
	FloatState FSignal;
	FloatState VPeak;
#line 85 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_FM.pl"
float theta0, phase;

};
#endif

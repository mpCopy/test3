/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFLMS_OscDet.pl,v $ $Revision: 100.19 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFLMS_OscDet_h
#define _SDFLMS_OscDet_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLMS_OscDet.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFLMS.h"
#include "FloatState.h"
#include "sdfdspstarsDll.h"

class SDFLMS_OscDet:public SDFLMS
{
public:
	SDFLMS_OscDet();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort cosOmega;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState InitialOmega;

};
#endif

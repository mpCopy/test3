/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFLMS_Cx.pl,v $ $Revision: 100.30 $ $Date: 2012/04/13 06:30:16 $ */
#ifndef _SDFLMS_Cx_h
#define _SDFLMS_Cx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLMS_Cx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFFIR_Cx.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "sdfdspstarsDll.h"

class SDFLMS_Cx:public SDFFIR_Cx
{
public:
	SDFLMS_Cx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	InSDFPort error;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState StepSize;
	IntState ErrorDelay;
	StringState SaveTapsFile;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFLMS.pl,v $ $Revision: 100.25 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFLMS_h
#define _SDFLMS_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLMS.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFFIR.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "sdfdspstarsDll.h"

class SDFLMS:public SDFFIR
{
public:
	SDFLMS();
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

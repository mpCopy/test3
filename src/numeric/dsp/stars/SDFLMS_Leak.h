/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFLMS_Leak.pl,v $ $Revision: 100.17 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFLMS_Leak_h
#define _SDFLMS_Leak_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFLMS_Leak.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFLMS.h"
#include "FloatState.h"
#include "sdfdspstarsDll.h"

class SDFLMS_Leak:public SDFLMS
{
public:
	SDFLMS_Leak();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort step;

protected:
	/* virtual */ void go();
	FloatState Mu;

};
#endif

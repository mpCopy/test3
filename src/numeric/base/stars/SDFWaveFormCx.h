/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFWaveFormCx.pl,v $ $Revision: 1.37 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFWaveFormCx_h
#define _SDFWaveFormCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFWaveFormCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "TargetTask.h"
#include "IntState.h"
#include "ComplexArrayState.h"
#include "CommonEnums.h"
#include "sdfstarsDll.h"

class SDFWaveFormCx:public SDFStar
{
public:
	SDFWaveFormCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutSDFPort output;

protected:
	/* virtual */ void go();
	ComplexArrayState Value;
	QueryState ControlSimulation;
	QueryState Periodic;
	IntState Period;
#line 57 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFWaveFormCx.pl"
int pos;
		SourceControl task;

};
#endif

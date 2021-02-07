/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFWaveForm.pl,v $ $Revision: 1.33 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFWaveForm_h
#define _SDFWaveForm_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFWaveForm.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "TargetTask.h"
#include "IntState.h"
#include "FloatArrayState.h"
#include "CommonEnums.h"
#include "sdfstarsDll.h"

class SDFWaveForm:public SDFStar
{
public:
	SDFWaveForm();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatArrayState Value;
	QueryState ControlSimulation;
	QueryState Periodic;
	IntState Period;
#line 73 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFWaveForm.pl"
int pos;
		SourceControl task;

};
#endif

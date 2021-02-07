/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/TSDFInputArgumentTimed.pl,v $ $Revision: 1.24 $ $Date: 2011/08/28 15:51:57 $ */
#ifndef _TSDFInputArgumentTimed_h
#define _TSDFInputArgumentTimed_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFInputArgumentTimed.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2001 - 2014 Keysight Technologies, Inc
 */
#include "TSDFArgumentTimed.h"
#include "TargetTask.h"
#include "FloatState.h"
#include "CommonEnums.h"
#include "dfapistarsDll.h"

class TSDFInputArgumentTimed:public TSDFArgumentTimed
{
public:
	TSDFInputArgumentTimed();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	const char* type ();
	void setBuffer (int sz, Pointer dBuff, double* tBuff);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
#line 20 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFInputArgumentTimed.pl"
SourceControl control;
	FloatState TStep;
	QueryState ControlSimulation;

};
#endif

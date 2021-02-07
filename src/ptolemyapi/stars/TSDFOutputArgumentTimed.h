/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/TSDFOutputArgumentTimed.pl,v $ $Revision: 1.18 $ $Date: 2011/08/28 15:51:57 $ */
#ifndef _TSDFOutputArgumentTimed_h
#define _TSDFOutputArgumentTimed_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFOutputArgumentTimed.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2001 - 2014 Keysight Technologies, Inc
 */
#include "TSDFArgumentTimed.h"
#include "TargetTask.h"
#include "dfapistarsDll.h"

class TSDFOutputArgumentTimed:public TSDFArgumentTimed
{
public:
	TSDFOutputArgumentTimed();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	const char* type ();
	void setBuffer (int sz, void* dBuff, double* tBuff);

protected:
	/* virtual */ void go();
#line 18 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFOutputArgumentTimed.pl"
SinkControl control;

};
#endif

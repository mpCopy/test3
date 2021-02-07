/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFConstTimed.pl,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:09:31 $ */
#ifndef _TSDFConstTimed_h
#define _TSDFConstTimed_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFConstTimed.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "ComplexState.h"
#include "tsdfstarsDll.h"

class TSDFConstTimed:public TSDFbasesource
{
public:
	TSDFConstTimed();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState FCarrier;
	ComplexState Value;

};
#endif

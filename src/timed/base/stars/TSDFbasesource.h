/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbasesource.pl,v $ $Revision: 1.25 $ $Date: 2011/08/25 01:09:32 $ */
#ifndef _TSDFbasesource_h
#define _TSDFbasesource_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbasesource.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "TSDFStar.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"
#line 19 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbasesource.pl"
#define DF_ZERO_OHMS 1.0e-12

class TSDFbasesource:public TSDFStar
{
public:
	TSDFbasesource();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutTSDFPort output;

protected:
	/* virtual */ void setup();
#line 23 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbasesource.pl"
double ctime; 
int allowZeroROut;
	FloatState ROut;
	FloatState RTemp;
	FloatState TStep;

};
#endif

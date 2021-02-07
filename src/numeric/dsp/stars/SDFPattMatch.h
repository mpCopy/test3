/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFPattMatch.pl,v $ $Revision: 100.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFPattMatch_h
#define _SDFPattMatch_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFPattMatch.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFPattMatch:public SDFStar
{
public:
	SDFPattMatch();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort templ;
	InSDFPort window;
	OutSDFPort index;
	OutSDFPort values;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState TempSize;
	IntState WinSize;
#line 61 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFPattMatch.pl"
int N;

};
#endif

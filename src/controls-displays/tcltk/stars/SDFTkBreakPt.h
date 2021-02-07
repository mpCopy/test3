/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkBreakPt.pl,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkBreakPt_h
#define _SDFTkBreakPt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkBreakPt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTclScript.h"
#include "StringState.h"
#include "sdftclstarsDll.h"

class SDFTkBreakPt:public SDFTclScript
{
public:
	SDFTkBreakPt();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	StringState Condition;
	StringState OptionalAlternateScript;

};
#endif

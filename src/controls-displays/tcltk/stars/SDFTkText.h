/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkText.pl,v $ $Revision: 100.22 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkText_h
#define _SDFTkText_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkText.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTkShowValues.h"
#include "IntState.h"
#include "sdftclstarsDll.h"

class SDFTkText:public SDFTkShowValues
{
public:
	SDFTkText();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
protected:
	/* virtual */ void setup();
	IntState NumberOfPastValues;

};
#endif

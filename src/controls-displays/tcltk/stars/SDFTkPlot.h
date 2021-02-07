/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkPlot.pl,v $ $Revision: 100.26 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkPlot_h
#define _SDFTkPlot_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkPlot.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTkXYPlot.h"
#include "EnumState.h"
#include "sdftclstarsDll.h"

class SDFTkPlot:public SDFTkXYPlot
{
public:
	SDFTkPlot();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	enum RepeatBorderPointsE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	EnumState RepeatBorderPoints;
#line 38 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkPlot.pl"
int sampleCount;

};
#endif

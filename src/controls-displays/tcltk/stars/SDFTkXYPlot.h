/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkXYPlot.pl,v $ $Revision: 100.34 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkXYPlot_h
#define _SDFTkXYPlot_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkXYPlot.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "XYPlot.h"
#include "TargetTask.h"
#include "IntState.h"
#include "StringState.h"
#include "FloatArrayState.h"
#include "EnumState.h"
#include "sdftclstarsDll.h"

class SDFTkXYPlot:public SDFStar
{
public:
	SDFTkXYPlot();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	/* virtual */ ~SDFTkXYPlot();
	MultiInSDFPort X;
	MultiInSDFPort Y;

protected:
	enum StyleE
	{
		dot,
		connect
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	StringState Label;
	StringState Geometry;
	StringState xTitle;
	StringState yTitle;
	FloatArrayState xRange;
	FloatArrayState yRange;
	IntState Persistence;
	EnumState Style;
	IntState UpdateSize;
#line 92 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkXYPlot.pl"
XYPlot xyplot;
	  char *labCopy;
	  char *geoCopy;
	  char *xtCopy;
	  char *ytCopy;
	  VisualTargetTask control;

private:
	int validRange (FloatArrayState& range);
	char* saveAndStripSpaces (const char* string);
	char* formatLabel (const char* string );

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkBarGraph.pl,v $ $Revision: 100.29 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkBarGraph_h
#define _SDFTkBarGraph_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkBarGraph.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "miscFuncs.h"
#include "ptk.h"
#include "BarGraph.h"
#include "Target.h"
#include "TargetTask.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "sdftclstarsDll.h"

class SDFTkBarGraph:public SDFStar
{
public:
	SDFTkBarGraph();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	/* virtual */ ~SDFTkBarGraph();
	MultiInSDFPort input;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	StringState Label;
	FloatState Top;
	FloatState Bottom;
	IntState NumberOfBars;
	FloatState BarGraphHeight;
	FloatState BarGraphWidth;
	StringState Position;
	IntState UpdateSize;
#line 75 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkBarGraph.pl"
BarGraph bar;
		int count, batchCount;
		char *labCopy;
		char *posCopy;
		VisualTargetTask control;

};
#endif

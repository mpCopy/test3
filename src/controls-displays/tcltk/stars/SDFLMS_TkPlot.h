/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFLMS_TkPlot.pl,v $ $Revision: 100.26 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFLMS_TkPlot_h
#define _SDFLMS_TkPlot_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFLMS_TkPlot.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFLMS.h"
#include "BarGraph.h"
#include "TargetTask.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "sdftclstarsDll.h"

class SDFLMS_TkPlot:public SDFLMS
{
public:
	SDFLMS_TkPlot();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	/* virtual */ ~SDFLMS_TkPlot();
	void resetTaps ();
	void redrawTaps ();
	void setStepSize (const char *newValue);

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState StepSizeLow;
	FloatState StepSizeHigh;
	FloatState FullScale;
	StringState Geometry;
	FloatState Width;
	FloatState Height;
	StringState Identifier;
	IntState UpdateInterval;

private:
#line 72 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFLMS_TkPlot.pl"
VisualTargetTask control;
	    // Count iterations
	    int invCount;

	    // To create unique Tcl command names, we generate unique symbols
	    static int instCount;
	    int myInst;

	    // Bar graph object
	    BarGraph bg;

	    InfString butName;
	    InfString sliderName;

	    // initial position of slider
	    int position;
	    int resetFlag;

};
#endif

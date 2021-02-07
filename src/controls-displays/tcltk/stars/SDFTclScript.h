/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTclScript.pl,v $ $Revision: 100.26 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTclScript_h
#define _SDFTclScript_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTclScript.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "TclStarIfc.h"
#include "TargetTask.h"
#include "FileNameState.h"
#include "sdftclstarsDll.h"

class SDFTclScript:public SDFStar
{
public:
	SDFTclScript();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
	MultiOutSDFPort output;
	MultiInSDFPort input;

protected:
	/* virtual */ void go();
	FileNameState TclFile;
#line 35 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTclScript.pl"
// Standardized interface to Tcl
		TclStarIfc tcl;
		VisualTargetTask control;

};
#endif

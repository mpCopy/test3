/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkButtons.pl,v $ $Revision: 100.27 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkButtons_h
#define _SDFTkButtons_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkButtons.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTclScript.h"
#include "FloatState.h"
#include "StringState.h"
#include "StringArrayState.h"
#include "EnumState.h"
#include "sdftclstarsDll.h"

class SDFTkButtons:public SDFTclScript
{
public:
	SDFTkButtons();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
protected:
	enum SimultaneousEventsE
	{
		do_not_allow,
		allow
	};

	enum ButtonControlE
	{
		Not_synchronous,
		Synchronous
	};

	enum PutInControlPanelE
	{
		NO,
		YES
	};

	enum OutputTypeE
	{
		Impulse,
		Level
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	StringState Label;
	StringArrayState Identifiers;
	FloatState Value;
	EnumState SimultaneousEvents;
	EnumState ButtonControl;
	EnumState PutInControlPanel;
	EnumState OutputType;

};
#endif

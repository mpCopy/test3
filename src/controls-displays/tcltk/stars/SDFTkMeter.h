/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkMeter.pl,v $ $Revision: 100.27 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkMeter_h
#define _SDFTkMeter_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkMeter.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTclScript.h"
#include "StringState.h"
#include "EnumState.h"
#include "sdftclstarsDll.h"

class SDFTkMeter:public SDFTclScript
{
public:
	SDFTkMeter();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
protected:
	enum PutInControlPanelE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	StringState Label;
	StringState Low;
	StringState High;
	EnumState PutInControlPanel;

};
#endif

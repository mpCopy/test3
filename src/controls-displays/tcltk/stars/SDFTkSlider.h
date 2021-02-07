/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/SDFTkSlider.pl,v $ $Revision: 100.26 $ $Date: 2011/08/25 01:59:12 $ */
#ifndef _SDFTkSlider_h
#define _SDFTkSlider_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkSlider.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFTclScript.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "EnumState.h"
#include "sdftclstarsDll.h"

class SDFTkSlider:public SDFTclScript
{
public:
	SDFTkSlider();
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
	FloatState Low;
	FloatState High;
	FloatState Value;
	StringState Identifier;
	EnumState PutInControlPanel;
	IntState Granularity;

};
#endif

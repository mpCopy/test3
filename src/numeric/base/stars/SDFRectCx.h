/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFRectCx.pl,v $ $Revision: 1.26 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRectCx_h
#define _SDFRectCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRectCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "gui_math.h"
#include "IntState.h"
#include "ComplexState.h"
#include "sdfstarsDll.h"

class SDFRectCx:public SDFStar
{
public:
	SDFRectCx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	ComplexState Height;
	IntState Width;
	IntState Period;
	IntState Count;

};
#endif

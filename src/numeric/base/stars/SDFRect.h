/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFRect.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRect_h
#define _SDFRect_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRect.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFRect:public SDFStar
{
public:
	SDFRect();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Height;
	IntState Width;
	IntState Period;
	IntState Count;

};
#endif

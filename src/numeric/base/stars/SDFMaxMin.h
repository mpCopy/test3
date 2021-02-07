/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFMaxMin.pl,v $ $Revision: 1.27 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFMaxMin_h
#define _SDFMaxMin_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFMaxMin.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "EnumState.h"
#include "sdfstarsDll.h"

class SDFMaxMin:public SDFStar
{
public:
	SDFMaxMin();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;
	OutSDFPort index;

protected:
	enum MaxOrMinE
	{
		min,
		max
	};

	enum CompareE
	{
		valueIn,
		magnitudeIn
	};

	enum OutputTypeE
	{
		valueOut,
		magnitudeOut
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	IntState N;
	EnumState MaxOrMin;
	EnumState Compare;
	EnumState OutputType;

};
#endif

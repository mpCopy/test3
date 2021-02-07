/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFLimit.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFLimit_h
#define _SDFLimit_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLimit.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "EnumState.h"
#include "sdfstarsDll.h"

class SDFLimit:public SDFStar
{
public:
	SDFLimit();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	OutSDFPort output;

protected:
	enum TypeE
	{
		linear,
		atan
	};

	/* virtual */ void go();
	FloatState K;
	FloatState Bottom;
	FloatState Top;
	EnumState Type;
#line 60 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLimit.pl"
double scale, offset;

};
#endif

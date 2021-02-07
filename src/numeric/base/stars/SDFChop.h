/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFChop.pl,v $ $Revision: 1.22 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFChop_h
#define _SDFChop_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFChop.pl by ptlang

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

class SDFChop:public SDFStar
{
public:
	SDFChop();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	enum UsePastInputsE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	IntState nRead;
	IntState nWrite;
	IntState Offset;
	EnumState UsePastInputs;
#line 137 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFChop.pl"
int hiLim, inidx, loLim;
	void computeRange ();

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFTest.pl,v $ $Revision: 1.31 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFTest_h
#define _SDFTest_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFTest.pl by ptlang

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
#line 69 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFTest.pl"
#define EQID 0
#define NEID 1
#define GTID 2
#define GEID 3
#define LTID 4
#define LEID 5

class SDFTest:public SDFStar
{
public:
	SDFTest();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort Signal;
	InSDFPort Test;
	OutSDFPort output;
	void setTest ( int val );
	void setPrevResult ( int val );

protected:
	enum ConditionE
	{
		EQ,
		NE,
		GT,
		GE,
		LT,
		LE
	};

	enum CrossingsOnlyE
	{
		False,
		True
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	EnumState Condition;
	FloatState Tolerance;
	EnumState CrossingsOnly;

private:
#line 77 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFTest.pl"
int prevResult;
                int test;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFLogic.pl,v $ $Revision: 1.24 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFLogic_h
#define _SDFLogic_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLogic.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "EnumState.h"
#include "sdfstarsDll.h"
#line 55 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLogic.pl"
#define NOTID 0
#define ANDID 1
#define NANDID 2
#define ORID 3
#define NORID 4
#define XORID 5
#define XNORID 6

class SDFLogic:public SDFStar
{
public:
	SDFLogic();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	MultiInSDFPort input;
	OutSDFPort output;
#line 65 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLogic.pl"
int test;

protected:
	enum LogicE
	{
		NOT,
		AND,
		NAND,
		OR,
		NOR,
		XOR,
		XNOR
	};

	/* virtual */ void go();
	EnumState Logic;

};
#endif

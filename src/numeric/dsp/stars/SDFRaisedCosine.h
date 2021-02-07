/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFRaisedCosine.pl,v $ $Revision: 100.29 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRaisedCosine_h
#define _SDFRaisedCosine_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFRaisedCosine.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFFIR.h"
#include "IntState.h"
#include "FloatState.h"
#include "EnumState.h"
#include "sdfdspstarsDll.h"

class SDFRaisedCosine:public SDFFIR
{
public:
	SDFRaisedCosine();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	enum SquareRootE
	{
		NO,
		YES
	};

	/* virtual */ void setup();
	IntState Length;
	IntState SymbolInterval;
	FloatState ExcessBW;
	EnumState SquareRoot;

};
#endif

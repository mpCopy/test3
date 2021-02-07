/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFDB.pl,v $ $Revision: 1.21 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFDB_h
#define _SDFDB_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDB.pl by ptlang

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

class SDFDB:public SDFStar
{
public:
	SDFDB();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	enum TypeE
	{
		Power_as_10_log_input_,
		Amplitude_as_20_log_input_
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Min;
	EnumState Type;

private:
#line 49 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFDB.pl"
double gain;

};
#endif

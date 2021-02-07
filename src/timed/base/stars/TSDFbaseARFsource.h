/* @(#) $Header: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbaseARFsource.pl,v 100.17 2011/08/25 01:57:51 build Exp $ */
#ifndef _TSDFbaseARFsource_h
#define _TSDFbaseARFsource_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbaseARFsource.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2003 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbaseARFsourceWTB.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "EnumState.h"
#include "CommonEnums.h"
#include "tsdfstarsDll.h"

class TSDFbaseARFsource:public TSDFbaseARFsourceWTB
{
public:
	TSDFbaseARFsource();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutTSDFPort RF;
	OutTSDFPort Minus;

protected:
	enum NoiseE
	{
		NO,
		YES
	};

	IntState Num;
	FloatState ROut;
	FloatState RTemp;
	EnumState Noise;
	StringState TStep;
	FloatState Power;
	QueryState MirrorSpectrum;

};
#endif

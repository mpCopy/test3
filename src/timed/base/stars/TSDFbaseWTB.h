/* @(#) $Header: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbaseWTB.pl,v 100.5 2011/08/25 01:57:51 build Exp $ */
#ifndef _TSDFbaseWTB_h
#define _TSDFbaseWTB_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbaseWTB.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2004 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbaseARFsourceWTB.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "CommonEnums.h"
#include "tsdfstarsDll.h"

class TSDFbaseWTB:public TSDFbaseARFsourceWTB
{
public:
	TSDFbaseWTB();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutTSDFPort RF_Out;
	InTSDFPort Meas_In;

protected:
	StringState RequiredParameters;
	FloatState CE_TimeStep;
	StringState WTB_TimeStep;
	StringState BasicParameters;
	FloatState SourceR;
	FloatState SourceTemp;
	FloatState MeasR;
	QueryState MirrorSourceSpectrum;
	QueryState MirrorMeasSpectrum;
	IntState TestBenchSeed;
	StringState SignalParameters;

};
#endif

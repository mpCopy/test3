/* @(#) $Header: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbaseWTB_TX.pl,v 100.5 2011/08/25 01:57:51 build Exp $ */
#ifndef _TSDFbaseWTB_TX_h
#define _TSDFbaseWTB_TX_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbaseWTB_TX.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2004 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbaseWTB.h"
#include "FloatState.h"
#include "StringState.h"
#include "CommonEnums.h"
#include "tsdfstarsDll.h"

class TSDFbaseWTB_TX:public TSDFbaseWTB
{
public:
	TSDFbaseWTB_TX();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	FloatState SourcePower;
	StringState MeasurementInfo;
	QueryState EnableSourceNoise;
	QueryState RF_MirrorFreq;
	QueryState MeasMirrorFreq;

};
#endif

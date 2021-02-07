/* @(#) $Header: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbaseARFsourceWTB.pl,v 100.4 2011/08/25 01:57:51 build Exp $ */
#ifndef _TSDFbaseARFsourceWTB_h
#define _TSDFbaseARFsourceWTB_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbaseARFsourceWTB.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2004 - 2017 Keysight Technologies, Inc
 */
#include "TSDFWVS.h"
#include "FloatState.h"
#include "tsdfstarsDll.h"

class TSDFbaseARFsourceWTB:public TSDFWVS
{
public:
	TSDFbaseARFsourceWTB();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	FloatState GainImbalance;
	FloatState PhaseImbalance;
	FloatState I_OriginOffset;
	FloatState Q_OriginOffset;
	FloatState IQ_Rotation;

};
#endif

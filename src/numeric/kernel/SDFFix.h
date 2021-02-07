/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/kernel/SDFFix.pl,v $ $Revision: 1.53 $ $Date: 2011/08/25 01:58:03 $ */
#ifndef _SDFFix_h
#define _SDFFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/kernel/SDFFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "StringList.h"
#include "gui_stdio.h"
#include "gui_string.h"
#include "gui_stdlib.h"
#include "EnumState.h"
#include "sdfDll.h"

class SDFFix:public SDFStar
{
public:
	SDFFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ ~SDFFix();
	virtual StringList blockSynth ();
	virtual StringList portSynth (PortHole& port);
	virtual StringList emitStateSynth (PortHole& port);
	int portNumber (const char* portName);

protected:
	enum OverflowHandlerE
	{
		wrapped,
		saturate,
		zero_saturate,
		warning
	};

	enum ReportOverflowE
	{
		DONT_REPORT,
		REPORT
	};

	enum RoundFixE
	{
		TRUNCATE,
		ROUND
	};

	/* virtual */ void setup();
	EnumState OverflowHandler;
	EnumState ReportOverflow;
	EnumState RoundFix;
#line 47 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/kernel/SDFFix.pl"
int overflows, totalChecks;
	int checkOverflow (Fix& fix);
	virtual StringList stateSynth (State& state);
	virtual StringList portConnectSynth (PortHole& port);
#line 237 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/kernel/SDFFix.pl"
Block*  myClone;

};
#endif

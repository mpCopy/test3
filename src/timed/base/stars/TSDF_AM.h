/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDF_AM.pl,v $ $Revision: 100.37 $ $Date: 2011/08/25 01:09:31 $ */
#ifndef _TSDF_AM_h
#define _TSDF_AM_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDF_AM.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbasesource.h"
#include "FloatState.h"
#include "EnumState.h"
#include "tsdfstarsDll.h"

class TSDF_AM:public TSDFbasesource
{
public:
	TSDF_AM();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	void getOutputAtCurrentTime (Complex *pVout);

protected:
	enum TypeE
	{
		Conventional_Am,
		DSB_SC_Am
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	EnumState Type;
	FloatState FCarrier;
	FloatState Power;
	FloatState Phase;
	FloatState VRef;
	FloatState FSignal;
	FloatState VPeak;

};
#endif

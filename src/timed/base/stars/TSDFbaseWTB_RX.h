/* @(#) $Header: /cvs/wlv/src/hptolemyaddons/src/timed/base/stars/TSDFbaseWTB_RX.pl,v 100.6 2011/08/25 01:57:51 build Exp $ */
#ifndef _TSDFbaseWTB_RX_h
#define _TSDFbaseWTB_RX_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFbaseWTB_RX.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2004 - 2017 Keysight Technologies, Inc
 */
#include "TSDFbaseWTB.h"
#include "tsdfstarsDll.h"

class TSDFbaseWTB_RX:public TSDFbaseWTB
{
public:
	TSDFbaseWTB_RX();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
};
#endif

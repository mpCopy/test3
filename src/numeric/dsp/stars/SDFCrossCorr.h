/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFCrossCorr.pl,v $ $Revision: 1.14 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFCrossCorr_h
#define _SDFCrossCorr_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFCrossCorr.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFAutocor.h"
#include "sdfdspstarsDll.h"

class SDFCrossCorr:public SDFAutocor
{
public:
	SDFCrossCorr();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input2;
	OutSDFPort delay;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
};
#endif

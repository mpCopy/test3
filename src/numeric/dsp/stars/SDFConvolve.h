/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFConvolve.pl,v $ $Revision: 100.22 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFConvolve_h
#define _SDFConvolve_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFConvolve.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFConvolve:public SDFStar
{
public:
	SDFConvolve();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort inA;
	InSDFPort inB;
	OutSDFPort out;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState TruncationDepth;
	IntState IterationCount;

};
#endif

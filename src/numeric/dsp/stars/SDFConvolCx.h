/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFConvolCx.pl,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFConvolCx_h
#define _SDFConvolCx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFConvolCx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFConvolCx:public SDFStar
{
public:
	SDFConvolCx();
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

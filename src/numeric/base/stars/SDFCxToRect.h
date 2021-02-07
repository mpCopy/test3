/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFCxToRect.pl,v $ $Revision: 1.17 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFCxToRect_h
#define _SDFCxToRect_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFCxToRect.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFCxToRect:public SDFStar
{
public:
	SDFCxToRect();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort real;
	OutSDFPort imag;

protected:
	/* virtual */ void go();
};
#endif

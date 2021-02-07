/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFRectToPolar.pl,v $ $Revision: 1.16 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFRectToPolar_h
#define _SDFRectToPolar_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFRectToPolar.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFRectToPolar:public SDFStar
{
public:
	SDFRectToPolar();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort x;
	InSDFPort y;
	OutSDFPort magnitude;
	OutSDFPort phase;

protected:
	/* virtual */ void go();
};
#endif

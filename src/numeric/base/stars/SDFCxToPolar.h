/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFCxToPolar.pl,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFCxToPolar_h
#define _SDFCxToPolar_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFCxToPolar.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFCxToPolar:public SDFStar
{
public:
	SDFCxToPolar();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort magnitude;
	OutSDFPort phase;

protected:
	/* virtual */ void go();
};
#endif

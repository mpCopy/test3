/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFLn.pl,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFLn_h
#define _SDFLn_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFLn.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFLn:public SDFStar
{
public:
	SDFLn();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFConst.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFConst_h
#define _SDFConst_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFConst.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFConst:public SDFStar
{
public:
	SDFConst();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatState Level;

};
#endif

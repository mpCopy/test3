/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFConstInt.pl,v $ $Revision: 1.23 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFConstInt_h
#define _SDFConstInt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFConstInt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFConstInt:public SDFStar
{
public:
	SDFConstInt();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	IntState Level;

};
#endif

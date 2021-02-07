/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFTable.pl,v $ $Revision: 1.22 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFTable_h
#define _SDFTable_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFTable.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatArrayState.h"
#include "sdfstarsDll.h"

class SDFTable:public SDFStar
{
public:
	SDFTable();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
	FloatArrayState Values;

};
#endif

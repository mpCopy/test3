/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFInterleaveDeinterleave.pl,v $ $Revision: 100.4 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFInterleaveDeinterleave_h
#define _SDFInterleaveDeinterleave_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFInterleaveDeinterleave.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2001 - 2017 Keysight Technologies, Inc
 */
#include "SDFTranspose.h"
#include "IntState.h"
#include "sdfstarsDll.h"

class SDFInterleaveDeinterleave:public SDFTranspose
{
public:
	SDFInterleaveDeinterleave();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	/* virtual */ void setup();
	IntState Rows;
	IntState Columns;

};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/base/stars/SDFAdd_M.pl,v $ $Revision: 100.26 $ $Date: 2011/08/28 15:49:22 $ */
#ifndef _SDFAdd_M_h
#define _SDFAdd_M_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFAdd_M.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFMatrixBase.h"
#include "sdfmatrixDll.h"

class SDFAdd_M:public SDFMatrixBase
{
public:
	SDFAdd_M();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	MultiInSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/base/stars/SDFAbs_M.pl,v $ $Revision: 100.23 $ $Date: 2011/08/28 15:49:22 $ */
#ifndef _SDFAbs_M_h
#define _SDFAbs_M_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFAbs_M.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFMatrixBase.h"
#include "sdfmatrixDll.h"

class SDFAbs_M:public SDFMatrixBase
{
public:
	SDFAbs_M();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void go();
};
#endif

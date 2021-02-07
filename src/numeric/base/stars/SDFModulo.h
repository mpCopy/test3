/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/base/stars/SDFModulo.pl,v $ $Revision: 1.26 $ $Date: 2011/08/25 01:09:09 $ */
#ifndef _SDFModulo_h
#define _SDFModulo_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFModulo.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1996 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "sdfstarsDll.h"

class SDFModulo:public SDFStar
{
public:
	SDFModulo();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Modulo;

};
#endif

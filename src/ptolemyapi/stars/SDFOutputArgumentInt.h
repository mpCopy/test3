/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/SDFOutputArgumentInt.pl,v $ $Revision: 1.5 $ $Date: 2011/08/25 01:59:19 $ */
#ifndef _SDFOutputArgumentInt_h
#define _SDFOutputArgumentInt_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFOutputArgumentInt.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2000 - 2014 Keysight Technologies, Inc
 */
#include "SDFArgument.h"
#include "dfapistarsDll.h"

class SDFOutputArgumentInt:public SDFArgument
{
public:
	SDFOutputArgumentInt();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	const char* type ();

protected:
	/* virtual */ void go();
};
#endif

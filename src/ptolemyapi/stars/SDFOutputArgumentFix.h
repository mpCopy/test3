/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/SDFOutputArgumentFix.pl,v $ $Revision: 1.7 $ $Date: 2011/08/25 01:59:19 $ */
#ifndef _SDFOutputArgumentFix_h
#define _SDFOutputArgumentFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFOutputArgumentFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2001 - 2014 Keysight Technologies, Inc
 */
#include "SDFArgument.h"
#include "dfapistarsDll.h"

class SDFOutputArgumentFix:public SDFArgument
{
public:
	SDFOutputArgumentFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	const char* type ();

protected:
	/* virtual */ void go();
};
#endif

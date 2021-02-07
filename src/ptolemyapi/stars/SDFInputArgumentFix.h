/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/SDFInputArgumentFix.pl,v $ $Revision: 1.6 $ $Date: 2011/08/25 01:59:19 $ */
#ifndef _SDFInputArgumentFix_h
#define _SDFInputArgumentFix_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFInputArgumentFix.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2001 - 2014 Keysight Technologies, Inc
 */
#include "SDFArgument.h"
#include "StringState.h"
#include "dfapistarsDll.h"

class SDFInputArgumentFix:public SDFArgument
{
public:
	SDFInputArgumentFix();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	const char* type ();

protected:
	/* virtual */ void go();
	StringState Precision;

};
#endif

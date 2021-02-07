/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/SDFArgument.pl,v $ $Revision: 1.13 $ $Date: 2011/08/25 01:59:19 $ */
#ifndef _SDFArgument_h
#define _SDFArgument_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFArgument.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2000 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "TargetTask.h"
#include "SimControl.h"
#include "StringState.h"
#include "EnumState.h"
#include "dfapistarsDll.h"

class SDFArgument:public SDFStar
{
public:
	SDFArgument();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
	InSDFPort input;
	OutSDFPort output;
	const char* argName ();
	void setBuffer (int sz, Pointer buf);
	void fixToString (char * bitArray, Fix fix);
	void stringToFix (const char * bitArray, Fix& fix);
	virtual const char* type ();

protected:
	enum BufferEndE
	{
		Wrap,
		Halt
	};

	/* virtual */ void go();
	StringState ArgName;
	EnumState BufferEnd;
#line 40 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFArgument.pl"
Pointer buffer;
    int size;
	int nextToken () {
#line 60 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFArgument.pl"
idx++;
      if (idx >= size) {
	if (BufferEnd == Halt)
	  Error::abortRun(*this,"End of buffer reached");
	idx=0;
      }
      return idx;
	}
	enum arith_type precisionSign (StringList& p);
	StringList precisionVal (StringList& p);

private:
#line 44 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/SDFArgument.pl"
int idx;
    SinkControl control;

};
#endif

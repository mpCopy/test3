/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/stars/TSDFArgumentTimed.pl,v $ $Revision: 1.40 $ $Date: 2011/08/28 15:51:57 $ */
#ifndef _TSDFArgumentTimed_h
#define _TSDFArgumentTimed_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFArgumentTimed.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2001 - 2014 Keysight Technologies, Inc
 */
#include "TSDFStar.h"
#include "SimControl.h"
#include "StringState.h"
#include "EnumState.h"
#include "dfapistarsDll.h"

class TSDFArgumentTimed:public TSDFStar
{
public:
	TSDFArgumentTimed();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
	InTSDFPort input;
	OutTSDFPort output;
	const char* argName ();
	void setTStep (double t);
	void setupInputTStep (double TStep);
	virtual void setBuffer (int sz, Pointer buf, double* index);
	virtual const char* type ();
	int interpData (double time, double* buffer);
	void appendCache (double time, double data);
	void printCache ();
	void deleteCache ();
	void printArg (int index, double time, StringList data, int flag=0);

protected:
	enum InterpolationE
	{
		Linear,
		Lagrange
	};

	/* virtual */ void setup();
	/* virtual */ void go();
	StringState ArgName;
	EnumState Interpolation;
#line 40 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFArgumentTimed.pl"
int size;
    double * timeArray;
    double * dataArray;
    typedef struct{ 
      double time;
      double data;
    } cacheT;
    cacheT *cache;
    int cacheIdx;
    double cacheLastRequest;
    int cacheSize;
    int cacheBuffSize;
    double tStep;
    double ctime;
    int idx;
    int shiftFactor;

private:
#line 58 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptolemyapi/stars/TSDFArgumentTimed.pl"
double delta;
	int searchCache (int l, int h, double time);
	void shiftCache ();

};
#endif

#ifndef _SDFTkHistogram_h
#define _SDFTkHistogram_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkHistogram.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2000 - 2014 Keysight Technologies, Inc
 */
#include "SDFTkBarGraph.h"
#include "BarGraph.h"
#include "IntState.h"
#include "sdftclstarsDll.h"

class SDFTkHistogram:public SDFTkBarGraph
{
public:
	SDFTkHistogram();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
	/* virtual */ ~SDFTkHistogram();
protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState DataPoints;
#line 20 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/controls-displays/tcltk/stars/SDFTkHistogram.pl"
int **histogram;
    double bucketSize, top, bottom;

private:
	void freeData ();

};
#endif

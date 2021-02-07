#ifndef _SDFWVS_h
#define _SDFWVS_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/base/stars/SDFWVS.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2005 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "sdfstarsDll.h"

class SDFWVS:public SDFStar
{
public:
	SDFWVS();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	int copyStates (const char * str);
	int reorderStates (StringList& sL);
	int removeStates (StringList& sL);
	int hideStates (StringList& sL);
	int unhideStates (StringList& sL);
	int removeAllStates ();
	int makeSettable (StringList& sL);
	int setDefaultValue (const char *stateName, const char* ivalue);
	int setDefaultDesc (const char *stateName, const char* ivalue);

};
#endif

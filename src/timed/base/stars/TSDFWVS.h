#ifndef _TSDFWVS_h
#define _TSDFWVS_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/timed/base/stars/TSDFWVS.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2003 - 2017 Keysight Technologies, Inc
 */
#include "TSDFStar.h"
#include "tsdfstarsDll.h"

class TSDFWVS:public TSDFStar
{
public:
	TSDFWVS();
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

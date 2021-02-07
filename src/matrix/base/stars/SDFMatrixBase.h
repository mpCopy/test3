/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/base/stars/SDFMatrixBase.pl,v $ $Revision: 100.5 $ $Date: 2011/08/28 15:49:22 $ */
#ifndef _SDFMatrixBase_h
#define _SDFMatrixBase_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFMatrixBase.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1999 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "HPtolemyMatrix.h"
#include "sdfmatrixDll.h"

    //! An abstract base class for matrix components

    /*! Prior to ADS 2006A, this class implemented the licensing
        for all of its derived classes by pulling the mdl_matrix 
        keyword. 
 
        Currently, this class serves no additional purpose other 
        than including the HptolemyMatrix.h include file. This class
        is being left in place simply because removing it would entail
        making changes to tens of components.
    */
class SDFMatrixBase:public SDFStar
{
public:
	SDFMatrixBase();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
};
#endif

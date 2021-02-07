/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/base/stars/SDFSVD_M.pl,v $ $Revision: 100.27 $ $Date: 2011/08/28 15:49:22 $ */
#ifndef _SDFSVD_M_h
#define _SDFSVD_M_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFSVD_M.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFMatrixBase.h"
#include <math.h>
#include "IntState.h"
#include "FloatState.h"
#include "EnumState.h"
#include "sdfmatrixDll.h"

class SDFSVD_M:public SDFMatrixBase
{
public:
	SDFSVD_M();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort input;
	OutSDFPort svals;
	OutSDFPort rsvec;
	OutSDFPort lsvec;

protected:
	enum GenerateLeftE
	{
		Do_not_Generate_Left_Singular_Vectors,
		Generate_Left_Singular_Vectors
	};

	enum GenerateRightE
	{
		Do_not_Generate_Right_Singular_Vectors,
		Generate_Right_Singular_Vectors
	};

	/* virtual */ void go();
	FloatState Threshold;
	IntState MaxIterations;
	EnumState GenerateLeft;
	EnumState GenerateRight;
#line 65 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFSVD_M.pl"
int nrows,ncols;
        FloatMatrix *U, *W, *V;
	double hypot (double a, double b);
	void svd (const FloatMatrix& A,FloatMatrix& U,FloatMatrix& V,FloatMatrix& W,double threshhold, int withU, int withV);

};
#endif

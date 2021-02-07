/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/base/stars/SDFKalman_M.pl,v $ $Revision: 100.33 $ $Date: 2011/08/28 15:49:22 $ */
#ifndef _SDFKalman_M_h
#define _SDFKalman_M_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFKalman_M.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 1997 - 2014 Keysight Technologies, Inc
 */
#include "SDFMatrixBase.h"
#include <math.h>
#include "IntState.h"
#include "FloatArrayState.h"
#include "sdfmatrixDll.h"

class SDFKalman_M:public SDFMatrixBase
{
public:
	SDFKalman_M();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFKalman_M();
	InSDFPort input;
	InSDFPort StateTransitionMatrixAtTimeN;
	InSDFPort MeasurementMatrixAtTimeN;
	InSDFPort ProcessNoiseCorrMatrixAtTimeN;
	InSDFPort MeasurementNoiseCorrMatrixAtTimeN;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState StateDimension;
	IntState InputDimension;
	FloatArrayState InitialState;
	FloatArrayState InitialCorrMatrix;
	FloatArrayState InitialStateTransitionMatrix;
	FloatArrayState InitialProcessNoiseCorrMatrix;
#line 76 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/matrix/base/stars/SDFKalman_M.pl"
int stateDim;
    int inputDim;

    // intermediate variables, part of the state
    FloatMatrix *stateVector;                        // x(n|y(n));
    FloatMatrix *gainMatrix;                         // G(n)
    FloatMatrix *innovationsVector;                  // alpha(n)
    FloatMatrix *innovationsCorrMatrix;              // sigma(n)
    FloatMatrix *predStateVector;                    // x(n+1|y(n));
    FloatMatrix *predStateErrCorrMatrix;             // K(n+1,n)
    FloatMatrix *presentErrCorrMatrix;               // K(n)

};
#endif

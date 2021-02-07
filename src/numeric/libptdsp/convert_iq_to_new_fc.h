#ifndef CONVERT_IQ_TO_NEW_FC_H_INCLUDED
#define CONVERT_IQ_TO_NEW_FC_H_INCLUDED
// Copyright  2001 - 2017 Keysight Technologies, Inc  


#ifdef __cplusplus
extern "C" {
#endif



#define MAX_BW_OVER_TSTEP 5

/****************************************************************************

This function was copied from numeric/omnisys/kernel/func_math.cc (original
function name jmath_convert_iq_to_new_fc) and was slightly modified.

If a star needs to use this function in its go method, it needs to check
in the begin method that the simulation time step is smaller than 
1 / ( Delta_f * MAX_BW_OVER_TSTEP ), where Delta_f = fabs( newfc - oldfc ).

If this condition is not satisfied a warning message should be output
letting the user know that the simulation time step is not small enough
and that loss of information may occur. The recommended simulation time
step should be 1 / ( Delta_f * MAX_BW_OVER_TSTEP ).

The arguments of this function are:
newfc: the frequency at which we want to characterize the I and Q envelopes
oldfc: the frequency at which the I and Q envelopes are characterized
t    : simulation time
*iv  : value of the I envelope
*qv  : value of the Q envelope

****************************************************************************/

void convert_iq_to_new_fc( double newfc, double oldfc, double t, double *iv, double *qv );



#ifdef __cplusplus
}
#endif


#endif   /* CONVERT_IQ_TO_NEW_FC_H_INCLUDED */

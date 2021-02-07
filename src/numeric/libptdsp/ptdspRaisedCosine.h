/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/libptdsp/ptdspRaisedCosine.h,v $ $Revision: 100.9 $ $Date: 2011/08/25 01:47:32 $ */


#ifndef PTDSPRAISEDCOSINE_H_INCLUDED
#define PTDSPRAISEDCOSINE_H_INCLUDED
// Copyright  1997 - 2017 Keysight Technologies, Inc  


/*
Copyright (c) 1990-1996 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

					PT_COPYRIGHT_VERSION_2
					COPYRIGHTENDKEY

Programmer: Joseph Buck and Brian Evans
Version: @(#)ptdspRaisedCosine.h	1.3	7/23/96
*/

#ifdef __cplusplus
extern "C" {
#endif

extern double Ptdsp_RaisedCosine(int t, int T, double excess);
extern double Ptdsp_SqrtRaisedCosine(int t, int T, double excess);

/* The code is used by TSDF_LPF_RaisedCosineTimed.pl.  t and T might not be integers */
extern double Ptdsp_RaisedCosineD(double t, double T, double excess);
extern double Ptdsp_SqrtRaisedCosineD(double t, double T, double excess);

#ifdef __cplusplus
}
#endif

#endif   /* PTDSPRAISEDCOSINE_H_INCLUDED */

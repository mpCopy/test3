/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/compat/cfront/NegExp.h,v $ $Revision: 100.7 $ $Date: 2011/08/25 01:47:10 $ */
/*
Copyright (c) 1990-1995 The Regents of the University of California.
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
*/

#ifndef NEGEXP_H_INCLUDED
#define NEGEXP_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#include "Random.h"
#include "gui_math.h"



// This version substitutes for libg++ random-number classes.
// Return an exponentially distributed r.v. with mean "arg".

class ACG;

class NegativeExpntl : public Random {
private:
	double mean;
public:
	NegativeExpntl(double arg,ACG*) : mean(arg) {}
	double operator()() {
		return -log(unif01()) * mean;
	}
};

#endif   /* NEGEXP_H_INCLUDED */

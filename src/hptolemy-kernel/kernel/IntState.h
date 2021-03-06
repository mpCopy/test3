/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ScalarState.hP,v $ $Revision: 100.10 $ $Date: 2004/03/25 20:34:07 $ */
#ifndef _IntState_h
#define _IntState_h 1

#ifdef __GNUG__
#pragma interface
#endif

// This file was originally auto-generated, but that magic is gone.  Just edit it directly if you need to change it.

#include "State.h"

/**************************************************************************
Version identification:
ScalarState.hP	2.10	12/3/94

Copyright (c) 1990-1994 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the above
copyright notice and the following two paragraphs appear in all copies
of this software.

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
                                                        COPYRIGHTENDKEY


 Programmer:  I. Kuroda and J. T. Buck
 Date of creation: 6/15/89

 IMPORTANT!!!!  If the name of this file is not ScalarState.hP, DO NOT
 EDIT IT!  The files IntState.h and FloatState.h are both generated from
 a template file by means of the "genclass" program.

**************************************************************************/

/** A state with int type.

  @author I. Kuroda and J. T. Buck*/
class IntState : public State
{
public:
        /// Constructor
        IntState();

        /// Parse the initial value string to set the current value
        void initialize();

        /// Return the string "INT"
	const char* type() const;

        /// Return the current value of the state as a string
	StringList currentValue() const;

        /// Assign the current value from a given int
        int operator=(int rvalue) { return val = rvalue;}

	/// Assign the current value from another IntState
        IntState& operator=(const IntState&  rhs)
        { this->val=rhs.val; return *this;}

        /// Return the current value when cast to a int
        operator int() const { return val;}

	/// Set the initial value string from a int
	void setInitValue(int);

	/// Set the initial value string from a const char*
	//We must redeclare this because of the {\em c++ hiding rule}
	void setInitValue(const char* s) { State::setInitValue(s);}

	/// Return TRUE when the argument is a ``IntState''
	int isA(const char*) const;

	/// Return ``IntState''
	const char* className() const {return "IntState";}
	
	/// Return a new IntState
	State* clone () const;

protected:
	/// Storage location for the current value
	int val;
};	

MULTISTATE(IntState,IntMultiState)
#endif

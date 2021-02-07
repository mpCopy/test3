/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ComplexArrayState.h,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef COMPLEXARRAYSTATE_H_INCLUDED
#define COMPLEXARRAYSTATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "State.h"
#include <complex>

/**************************************************************************
Version identification:
@(#)ComplexArrayState.h	2.12	3/2/95

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

 Programmer:  I. Kuroda and J. T. Buck
 Date of creation: 6/8/90

**************************************************************************/

/** Array state with complex type.
 
  The expression parser for {\tt ComplexArrayState} accepts a series 
  of {\em subarray
  expressions}, which are concatenated together to get the current value
  when {\tt initialize()} is called.  Subarray expressions may specify
  a single element, some number of copies of a single element, or a
  galaxy array state of the same type (another {\tt ComplexArrayState}).  A
  single element specifier may either be a Complex, or a
  Complex galaxy state name, or a general Complex
  expression enclosed in parentheses.  A number of copies of this
  single element can be specified by appending an integer expression
  enclosed in square brackets.
  */
class ComplexArrayState : public State
{
public:
	/// Construct an empty array
	ComplexArrayState () {nElements = 0; val = 0; 	m_pComplexArray = 0; }

	/// Construct an array with a specified size
	ComplexArrayState (int size);

	/// Construct an array with a specified fill value
	ComplexArrayState (int size, const Complex& fill_value) ;

	/// Destruct the array
	~ComplexArrayState ();

	/// Return the size of the array
	int size() const;

	/// Return the n{\em th} element
	Complex & operator [] (int n) {
		return val[n];
	}

	/// Return the string ``COMPLEXARRAY''
	const char* type() const; // { return "ComplexArray";}

	/// Return TRUE when the argument is a ComplexArrayState
	int isA(const char*) const;


	/// Return the string ``ComplexArrayState''
	const char* className() const;

	/// Return TRUE
	int isArray() const;

	/// Return the current value of the state as a string
        StringList currentValue() const;

	/// Parse the initial value string to set the current value
	void initialize();

	/// Extend or truncate the array to a specified size
	void resize(int);

	/// Parse an element of the array
	ParseToken evalExpression(Tokenizer&);

	/// Return a new ComplexArrayState
	virtual State* clone() const;

	operator std::complex<double>*()
	{
		delete [] m_pComplexArray;
		m_pComplexArray = 0;
		if ( size()>0)
		{
			int i;
			m_pComplexArray = new std::complex<double>[size()];
			for ( i = 0 ; i < size() ; i++)
			{
				m_pComplexArray[i] = std::complex<double>(val[i].real(),val[i].imag());
			}
		}
		return m_pComplexArray;
	}

protected:
	
	/// The number of elements in the array
	int	nElements;

	/// The current value array 
	Complex	*val;

	std::complex<double> *m_pComplexArray;
};
MULTISTATE(ComplexArrayState,ComplexArrayMultiState)
#endif   /* COMPLEXARRAYSTATE_H_INCLUDED */

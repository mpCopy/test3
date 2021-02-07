// Copyright  2009 - 2017 Keysight Technologies, Inc  
#pragma once

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//-----------------------------------------------------------------------------------


#include "commonbase.h"


namespace SystemVueModelBuilder
{

	//Forward declaration
	class FixedPoint;


	// ----------------------------------------------------------------------------
	//  CLASS : FixedPointBitRef
	//
	//  Proxy class for bit-selection in class FixedPoint, behaves like a bit.
	//	Provides reference to individual bits in a FixedPoint data type
	//
	//	An object of class FixedPointBitRef must not be created explicitly.
	//	The [] operator of a FixedPoint class returns an object of the 
	//	FixedPointBitRef and that should be the only way to obtain an object 
	//	of this class.
	// ----------------------------------------------------------------------------

	class MODELBUILDER_API FixedPointBitRef
	{
		friend class FixedPoint;

	public:

		/// Copy Constructor
		inline FixedPointBitRef( const FixedPointBitRef& a )
			: m_num( a.m_num ), m_idx( a.m_idx )
		{}


		/// Assignment operator when RHS is another FixedPointBitRef
		inline FixedPointBitRef& operator = ( const FixedPointBitRef& a )
		{
			if( &a != this )
			{
				set( a.get() );
			}
			return *this;
		}


		/// Assignment operator when RHS is a bool
		inline FixedPointBitRef& operator = ( bool a )
		{
			set( a );
			return *this;
		}

		/// Unary AND (&) operator when RHS is a FixedPointBitRef
		inline 	FixedPointBitRef&	operator &= ( const FixedPointBitRef& b )
		{
			set( get() && b.get() );
			return *this;
		}

		/// Unary AND (&) operator when RHS is a bool
		inline FixedPointBitRef& operator &= ( bool b )
		{
			set( get() && b );
			return *this;
		}

		/// Unary OR (|) operator when RHS is a FixedPointBitRef
		inline FixedPointBitRef& operator |= ( const FixedPointBitRef& b )
		{
			set( get() || b.get() );
			return *this;
		}


		/// Unary OR (|) operator when RHS is a bool
		inline FixedPointBitRef& operator |= ( bool b )
		{
			set( get() || b );
			return *this;
		}


		/// Unary XOR (^) operator when RHS is a FixedPointBitRef
		inline FixedPointBitRef& operator ^= ( const FixedPointBitRef& b )
		{
			set( get() != b.get() );
			return *this;
		}

		/// Unary XOR (^) operator when RHS is a bool
		inline FixedPointBitRef& operator ^= ( bool b )
		{
			set( get() != b );
			return *this;
		}

		/// Implicit conversion to bool
		operator bool() const
		{
			return get();
		}


	private:

		FixedPoint& m_num;
		int  m_idx;
			private:
		bool get() const;
		void set( bool );

		// constructor

		inline FixedPointBitRef( FixedPoint& num_, int idx_ )
			: m_num( num_ ), m_idx( idx_ )
		{}
		// disabled
		FixedPointBitRef();


	};

} // namespace SystemVueModelBuilder 

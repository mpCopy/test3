// Copyright  2009 - 2017 Keysight Technologies, Inc  
#pragma once

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//-----------------------------------------------------------------------------------

namespace SystemVueModelBuilder
{


	namespace FixedPointEnums
	{
		// ----------------------------------------------------------------------------
		//  ENUM : FixedPointEnums::NumRep
		//
		//  Enumeration of number representations for character string conversion.
		// ----------------------------------------------------------------------------

		enum NumRep
		{
			NOBASE = 0,
			BINARY    = 2,
			OCTAL    = 8,
			DECIMAL    = 10,
			HEX    = 16,
			BINARY_UNSIGNED,
			BINARY_SIGN_MAGNITUDE,
			OCTAL_UNSIGNED,
			OCTAL_SIGN_MAGNITUDE,
			HEX_UNSIGNED,
			HEX_SIGN_MAGNITUDE,
			CSD
		};

		// ----------------------------------------------------------------------------
		//  ENUM : FixedPointEnums::StringFormat
		//
		//  Enumeration of formats for character string conversion.
		// ----------------------------------------------------------------------------

		enum StringFormat
		{
			FIXED_FORMAT,	// fixed
			SCIENTIFIC_FORMAT	// scientific
		};

		// ----------------------------------------------------------------------------
		//  ENUM : FixedPointEnums::QuantizationMode
		//
		//  Enumeration of quantization modes.
		// ----------------------------------------------------------------------------

		enum QuantizationMode
		{
			ROUND,		// rounding to plus infinity
			ROUND_ZERO,	// rounding to zero
			ROUND_MINUS_INFINITY,	// rounding to minus infinity
			ROUND_INFINITY,		// rounding to infinity
			ROUND_CONVERGENT,	// convergent rounding
			TRUNCATE,		// truncation
			TRUNCATE_ZERO		// truncation to zero
		};


		// ----------------------------------------------------------------------------
		//  ENUM : FixedPointEnums::OverflowMode
		//
		//  Enumeration of overflow modes.
		// ----------------------------------------------------------------------------

		enum OverflowMode
		{
			SATURATE,		// saturation
			SATURATE_ZERO,	// saturation to zero
			SATURATE_SYMMETRICAL,		// symmetrical saturation
			WRAP,		// wrap-around (*)
			WRAP_SIGN_MAGNITUDE		// sign magnitude wrap-around (*)
		};

		// ----------------------------------------------------------------------------
		//  ENUM : FixedPointEnums::Sign
		//
		//  Enumeration of sign encodings.
		// ----------------------------------------------------------------------------

		enum Sign
		{
			UNSIGNED,	// unsigned
			TWOS_COMPLEMENT	// two's complement
		};

		
		// ----------------------------------------------------------------------------
		//  Built-in & default fixed-point type parameter values.
		// ----------------------------------------------------------------------------

		const int       DEFAULT_WL_     = 32;
		const int       DEFAULT_IWL_    = 32;
		const QuantizationMode DEFAULT_QUANTIZATION_MODE_ = TRUNCATE;
		const OverflowMode DEFAULT_OVERFLOW_MODE_ = FixedPointEnums::WRAP;
		const int       DEFAULT_N_BITS_ = 0;


		
	} // namespace FixedPointEnums

} // namespace SystemVueModelBuilder

#ifndef _DFEnumerations_h
#define _DFEnumerations_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//	DFEnumerations.h
//		Predefined  enumerations. 
//-----------------------------------------------------------------------------------



namespace SystemVueModelBuilder
{

	//-----------------------------------------------------------------------------------
	//	QueryEnum is a predefined Dataflow  enumeration. An instance of QueryEnum
	//	can be added as parameter using ADD_MODEL_PARAM macro without needing to
	//	use ADD_MODEL_ENUM_PARAM
	//
	//	If used with ADD_MODEL_PARAM then there is no need to use AddEnumeration
	//	method of DFParam class to add individual enumerations
	//
	//	However, if added using ADD_MODEL_ENUM_PARAM then individal enumerations
	//	must be added using AddEnumeration method of DFParam class.
	//-----------------------------------------------------------------------------------		
	enum QueryEnum 
	{ 
		QUERY_NO = 0,  
		QUERY_YES = 1
	};

	//-----------------------------------------------------------------------------------
	//	SwitchEnum is a predefined Dataflow  enumeration. An instance of SwitchEnum
	//	can be added as parameter using ADD_MODEL_PARAM macro without needing to
	//	use ADD_MODEL_ENUM_PARAM
	//
	//	If used with ADD_MODEL_PARAM then there is no need to use AddEnumeration
	//	method of DFParam class to add individual enumerations
	//
	//	However, if added using ADD_MODEL_ENUM_PARAM then individal enumerations
	//	must be added using AddEnumeration method of DFParam class.
	//-----------------------------------------------------------------------------------	
	enum SwitchEnum 
	{ 
		SWITCH_OFF = 0,  
		SWITCH_ON = 1
	};

	//-----------------------------------------------------------------------------------
	//	BooleanEnum is a predefined Dataflow  enumeration. An instance of BooleanEnum
	//	can be added as parameter using ADD_MODEL_PARAM macro without needing to
	//	use ADD_MODEL_ENUM_PARAM
	//
	//	If used with ADD_MODEL_PARAM then there is no need to use AddEnumeration
	//	method of DFParam class to add individual enumerations
	//
	//	However, if added using ADD_MODEL_ENUM_PARAM then individal enumerations
	//	must be added using AddEnumeration method of DFParam class.
	//-----------------------------------------------------------------------------------	
	enum BooleanEnum 
	{ 
		BOOLEAN_FALSE = 0, 
		BOOLEAN_TRUE = 1
	};

	//-----------------------------------------------------------------------------------
	// Following can be used as input to SetEnumeration method of 
	// a DFParam object. This converts an integer parameter
	// to a corresponding predefined enumerations 
	//
	// There is no need to use AddEnumeration after using SetEnumeration
	//-----------------------------------------------------------------------------------
	extern MODELBUILDER_API  const char * QUERY_ENUM  ; // Corresponding enumeration is QueryEnum
	extern MODELBUILDER_API  const char * SWITCH_ENUM  ; // Corresponding enumeration is SwitchEnum
	extern MODELBUILDER_API  const char * BOOLEAN_ENUM  ; // Corresponding enumeration is BooleanEnum


	// Namespace to hold Parmeter units
	namespace Units
	{

		//-----------------------------------------------------------------------------------
		// UnitType is an input of SetUnit method of a DFParam object. The Units field of the 
		// parameter in SystemVue will be set accordingly. The default value is SetUnit
		// is not called in SystemVueModelBuilder::Units::UNITLESS
		//-----------------------------------------------------------------------------------
		enum UnitType
		{
			NONE,		// No unit, Units field will be set to () 
			ANGLE,      // Angle unit, Units field can be set to either deg, or rad 
			LENGTH,     // Length Unit, Units field can be set to mm, mil, in, M, cm , or uM
			TIME,       // Time Unit, Units field can be set to ps, ns, us, ms, or s
			FREQUENCY,  // Frequency Unit, Units field can be set to Hz, KHz, MHz, GHz, or THz
			VOLTAGE,    // Voltage Unit, Units field can be set to  V, KV, mV, uV, nV, pV, dBV, dBmV, or dBuV
			POWER,      // Power Unit, Units field can be set to W, dBm, uW, mW, KW, MW, or dbW
			RESISTANCE, // Resistance Unit, Units field can be set to one of Ohm, KOhm, or MOhm
			TEMPERATURE // Temperature Unit, Units field can be set to C, F, K
		};
	}
}  

#endif

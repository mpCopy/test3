// Copyright  2009 - 2017 Keysight Technologies, Inc  
//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	DFParam.h
//		DFParam class
//-----------------------------------------------------------------------------------
#ifndef _DFaram_h
#define _DFaram_h

#ifdef __GNUG__
#pragma interface
#endif

#include "CommonBase.h"
#include "DFEnumerations.h"

namespace SystemVueModelBuilder
{
	class CDFParamImplementation; 


	//------------------------------------------------------------------------------
	//	An object based on DFParam class is returned by ADD_MODEL_PARAM and 
	//	ADD_MODEL_ARRAY_PARAM in mendatory DEFINE_MODEL_INTERFACE macro, in 
	//	C++ Data Flow model. The object can be used to modify certain recently 
	//	added parameter properties using mutator methods included in this class.
	//------------------------------------------------------------------------------
	class MODELBUILDER_API DFParam
	{
	private:
		 CDFParamImplementation *m_cParamImplementation;
	
	public:

		//---------------------------------------------------------------------------
		// This constructor must not be used by any C++ Data Flow model. Please use
		// objects of type DFParam returned by ADD_MODEL_PARAM or ADD_MODEL_ARRAY_PARAM
		// in DEFINE_MODEL_INTERFACE to modify any parameter properties.
		//---------------------------------------------------------------------------
		DFParam(CDFParamImplementation *cParamImplementation);


		//---------------------------------------------------------------------------
		// This function changes the default name of a parameter to pcName. By default 
		// the name of the parmeter is same as the variable name that is added by using
		// ADD_MODEL_PARAM or ADD_MODEL_ARRAY_PARAM
		//---------------------------------------------------------------------------
		void SetName(const char * pcName);
		
		
		//---------------------------------------------------------------------------
		// This functions adds a more detailed description of a parmater to 
		// pcDescription. By default the description of the parmeter is same as the 
		// variable name that is added by using ADD_MODEL_PARAM or ADD_MODEL_ARRAY_PARAM
		//---------------------------------------------------------------------------
		void SetDescription(const char *pcDescription);


		//---------------------------------------------------------------------------
		// This function sets the default value of a parameter. The default value must
		// be added as a string using the exact format that is used to enter actual
		// parameter value for the parameter type in GUI. 
		// When a model is placed on the design schematic, this default parameter value
		// will be assigned to the parameter by default. There is no deault value 
		// set for the parameter if this function is not used. 
		//---------------------------------------------------------------------------
		void SetDefaultValue(const char *pcValue); 



		/// <summary>
		/// This function sets the unit of a parameter. By default the unit of the 
		/// parameter is SystemVueModelBuilder::Units::NONE.
		///
		/// <param name="eUnit"> UnitType for the parameter </param>
		/// Possible values are
		/// <list type="bullet">
		/// <item>
		/// <description>SystemVueModelBuilder::Units::NONE</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::ANGLE</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::LENGTH</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::TIME</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::FREQUENCY</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::VOLTAGE</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::POWER</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::RESISTANCE</description>
		/// </item>
		/// <item>
		/// <description>SystemVueModelBuilder::Units::TEMPERATURE</description>
		/// </item>
		/// </list>
		/// </summary>
		void SetUnit(Units::UnitType eUnitType); 



		//---------------------------------------------------------------------------
		// This function is only valid for a string type parameter. It adds a browse
		// button for file browsing if the originally added parameter was of string 
		// type.
		//---------------------------------------------------------------------------
		void SetParamAsFile();


		//---------------------------------------------------------------------------
		// This function in only valid for enum or integer type parameter. In case of
		// integer parameter it converts the ineger parameter to enum parameter and adds
		// enumeration value to be displayed in Part properties dialogie. I
		// In case of enumeration it adds enumeration value to be displayed in Part 
		// properties dialogue.
		//---------------------------------------------------------------------------
		void AddEnumeration(const char *pcEnumName, int iEnumValue);


		//---------------------------------------------------------------------------
		// This function in only valid for integer type parameter. In case of
		// integer parameter it converts the ineger parameter to a predefined enum 
		// parameter and adds corresponding enumeration value to be displayed in 
		// Part properties dialogie. 
		// 
		// The function can take only one of the following possible values as parameter
		// * SystemVueModelBuilder::QUERY_ENUM   ( The possible values are QUERY_NO=0, and  QUERY_YES=1 )
		// * SystemVueModelBuilder::SWITCH_ENUM  ( The possible values are SWITCH_OFF=0, and  SWITCH_ON=1 )
		// * SystemVueModelBuilder::BOOLEAN_ENUM ( The possible values are BOOLEAN_FALSE=0, and BOOLEAN_TRUE=1 )
		//---------------------------------------------------------------------------
		void SetEnumeration(const char * EnumerationName);

		//---------------------------------------------------------------------------
		// This method should be called if you want to support code generation for 
		// your model and your model includes parameters that are managed by other classes.
		//
		// Prepends a path to the code generation named, used to enable having classes
		// that are included as data members that define parameters. A null
		// pointer argument is ignored.  The path should include '.' or '->' to 
		// define the access to the data members.
		//---------------------------------------------------------------------------
		void PrependCodeGenName(const char * pcCodeGenPath);


		//---------------------------------------------------------------------------
		// This method should be called if you want to hide a parameter from GUI based
		// on the values of another parameter in the same model.
		//
		// pcHideCondition must be a valid MathLang conditional statement using relational 
		// operators returning true or false. The statment must use one of the parameter "names"
		// other than the one for which the hide condition is being set. The parameter name used
		// must be the same as set using SetName method of a DFParam object
		//
		// e.g myParam.SetHideCondition("ShowAdvancedParams ~= 1");
		//
		// Any parameter used in hide condition must have a name that could be used as 
		// a valid MathLang variable. Also enumeration cannot be used as is in the condition
		// e.g myParam.SetHideCondition("ShowAdvancedParams ~= YES"); is incorrect, use 
		// myParam.SetHideCondition("ShowAdvancedParams ~= 1"); instead, if YES is equal to 1
		// in your enumeration list. 
		//
		//---------------------------------------------------------------------------
		void SetHideCondition(const char * pcHideCondition);


		// This method turns on and off schematic visibility of a parameter
		void SetSchematicDisplay( bool bDisplay);

		// This method turns on and off run-time tuning of a parameter, by default it is off
		void SetDynamicUpdate( bool bDynamicUpdateSupported);

		//------------------------------------------------------------------------------
		// For internal use only. A C++ Data Flow model must not use this at all
		//------------------------------------------------------------------------------
		 CDFParamImplementation *  GetImplementation() ;


	};
} // end namespcae SystemVueModelBuilder

#endif

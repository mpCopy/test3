#ifndef _DFPort_h
#define _DFPort_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	DFPort.h
//		DFPort Class
//-----------------------------------------------------------------------------------

#include "CommonBase.h"

namespace SystemVueModelBuilder
{
	class CDFPortImplementation;

	//------------------------------------------------------------------------------
	//	An object of DFPort class is returned by ADD_MODEL_INPUT and 
	//	ADD_MODEL_OUTPUT in mendatory DEFINE_MODEL_INTERFACE macro, in 
	//	C++ Data Flow model. The object can be used to modify certain recently 
	//	added port properties using mutator methods included in this class.
	//------------------------------------------------------------------------------
	class MODELBUILDER_API DFPort
	{
	private:
		CDFPortImplementation *m_cPortImplementation;
	public:
		//---------------------------------------------------------------------------
		// This constructor must not be used by any C++ Data Flow model. Please use
		// objects of type DFPort returned by ADD_MODEL_INPUT or ADD_MODEL_OUTPUT
		// in DEFINE_MODEL_INTERFACE to modify any port properties.
		//---------------------------------------------------------------------------
		DFPort(CDFPortImplementation *cPortImplementation);
		

		//---------------------------------------------------------------------------
		// This function changes the default name of a port to pcName. By default 
		// the name of the port is same as the variable name that is added by using
		// ADD_MODEL_INPUT or ADD_MODEL_OUTPUT
		//---------------------------------------------------------------------------
		void SetName(const char * pcName);
		

		//---------------------------------------------------------------------------
		// This function declares that a port supports optional connections. By default 
		// all ports require connections.
		//---------------------------------------------------------------------------
		void SetOptional(bool bIsOptional = true);


		//---------------------------------------------------------------------------
		// This functions adds a more detailed description of a port to 
		// pcDescription. By default the description of the port is same as the 
		// variable name that is added by using ADD_MODEL_INPUT or ADD_MODEL_OUTPUT
		//---------------------------------------------------------------------------
		void SetDescription(const char *pcDescription);
		

		//---------------------------------------------------------------------------
		// This function can be used to add a rate variable to the port. The value of
		// this rate variable can be set only in setup method of the C++ Data Flow 
		// model. The variable value must not be modifed in any method other than "setup". 
		// If a rate variable is not added to a multi-rate port then default rate
		// of "1" is used. 
		// The memory for the pointer to the data variable of the port is assigned 
		// according to the value of this rate variable set in setup method. 
		//---------------------------------------------------------------------------
		void AddRateVariable( unsigned &iRate);		


		//---------------------------------------------------------------------------
		// This function can be used to add a rate variable to a Bus port. The values of
		// this pointer rate variable can be set only in setup method of the C++ Data Flow 
		// model. The variable value must not be modifed in any method other than "setup". 
		// If a rate variable is not added to a multi-rate port then default rate
		// of "1" is used. 
		//
		// iRate[i] will be assigned to ith port in the Bus
		//
		// The memory for the pointer to the data variable of the port is assigned 
		// according to the value of this rate variable set in setup method. 
		//---------------------------------------------------------------------------
		void AddRateVariable( unsigned *&iRate);		

		

		//---------------------------------------------------------------------------
		// This method should be called if you want to support code generation for 
		// your model and your model includes ports that are managed by other classes.
		//
		// Prepends a path to the code generation named, used to enable having classes
		// that are included as data members that define ports. A null
		// pointer argument is ignored.  The path should include '.' or '->' to 
		// define the access to the data members.
		//---------------------------------------------------------------------------
		void PrependCodeGenName(const char * pcCodeGenPath);


	};
} // end namespcae SystemVueModelBuilder

#endif

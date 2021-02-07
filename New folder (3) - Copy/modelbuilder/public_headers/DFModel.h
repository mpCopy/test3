#ifndef _DFModel_h
#define _DFModel_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	DFModel.h
//		Definition of DFModel class - the base class for C++ Data Flow models
//-----------------------------------------------------------------------------------
#define DFInterfaceVersion 4

namespace SystemVueModelBuilder
{
	class DFInterface;

	//-----------------------------------------------------------------------------------
	//	DFModel
	//		Data Flow Compiled Model class
	//		All C++ Data Flow models must be derived from this class
	//		Each derived model must use the DECLARE_MODEL_INTERFACE macro in the header and 
	//		DEFINE_MODEL_INTERFACE macro in the C++ implementation file
	//-----------------------------------------------------------------------------------
	class DFModel
	{
	public:
		//------------------------------------------------------------------------------
		// Virtual function to define ports, parameter and error/warning/message strings.
		// This function must be overridden by each C++ Data Flow model.
		// The overridden function must be used to add all ports, parmaters and 
		// error/warning/message strings this function.
		//------------------------------------------------------------------------------
		virtual bool		DefineInterface(DFInterface &model) = 0;

		//------------------------------------------------------------------------------
		// Virtual function to set port-rates and fixed point prcession for output ports.
		// This virtual function can optionally be overridden by a C++ Data Flow model.
		// The overridden function should only be used to setup rates for a multi-rate 
		// port and to set the output precission of Fix point type output ports. 
		// All parameter values are available to be examined in this funtion.
		// There should not be any other functionality added in this function.
		//------------------------------------------------------------------------------
		virtual bool			Setup()			{ return true; }

		//------------------------------------------------------------------------------
		// Virtual function to add any functionality before the start of the simulation.
		// This virtual function can optionally be overridden by a C++ Data Flow model.
		// This function can be used to add any functionality before the start of the 
		// simulation except changing port rates and output precissions of fix point 
		// type output ports. 
		// All parameter values are available to be examined in this funtion.
		//------------------------------------------------------------------------------
		virtual bool			Initialize()	{ return true; }  

		//------------------------------------------------------------------------------
		// Virtual function to add any functionality during the simulation. 
		// This virtual function can optionally be overridden by a C++ Data Flow model.
		// This function is called by the simulator once for every invokation of the model 
		// instance during the simulation. All input port values and parameter values
		// are available in this function. All output port values should be set in this 
		// function.
		//------------------------------------------------------------------------------
		virtual bool			Run()			{ return true; }  

		//------------------------------------------------------------------------------
		// Virtual function to add any functionality after the end of simulation. 
		// This virtual function can optionally be overridden by a C++ Data Flow model.
		// This function is called by the simulator once for every model instance after
		// the simulation ends. 
		//------------------------------------------------------------------------------
		virtual bool			Finalize()		{ return true; }  
		
		//-------- Construction / Destruction ---------
		DFModel()					{ }
		virtual ~DFModel()		{ }

		//------------------------------------------------------------------------------
		// The following data member is for internal use only please do not use
		// it in any part of C++ Data Flow model implementation. 
		//------------------------------------------------------------------------------
		DFInterface * pcInterface;

	};

	//------------------------------------------------------------------------------
	// For internal use only. A C++ Data Flow model must not use this at all
	//------------------------------------------------------------------------------
	typedef DFModel* (*pfnDFModelCreate) (const char** pccClassName);		// pointer to CDFModel create function

}	// namespace SystemVueModelBuilder

#endif

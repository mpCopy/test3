// Copyright  2009 - 2017 Keysight Technologies, Inc  
//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	DFErrorHandler.h
//		ErrorHandler Class
//-----------------------------------------------------------------------------------
#ifndef _ErrorHandler_h
#define _ErrorHandler_h

#include "CommonBase.h"

namespace SystemVueModelBuilder
{
	class DFModel;

	//-----------------------------------------------------------------------------------
	// This class provides static methods which can be called inside
	// a DFModel to post Error/Warning/Info messages
	//-----------------------------------------------------------------------------------
	class MODELBUILDER_API DFErrorHandler
	{
	public:
		//---------------------------------------------------
		// Posts Error message and aborts the simulation
		//---------------------------------------------------
		static void PostError (DFModel *, const char* pcError);

		//---------------------------------------------------
		// Posts Warning message
		//---------------------------------------------------
		static void PostWarning (DFModel *, const char* pcWarning);

		//---------------------------------------------------
		// Posts Info message
		//---------------------------------------------------
		static void PostMessage (DFModel *, const char* pcMessage);
	};
	
}

#endif

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2009.  All rights reserved.
//	LibraryProperties.h
//		This header provides the functionality to override the default behavior
//		of a library loaded into SystemVue. 
//-----------------------------------------------------------------------------------

#ifndef _LibraryProperties_h
#define _LibraryProperties_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

#include "CommonBase.h"

namespace SystemVueModelBuilder
{
	class LibraryPropertiesImplementation;

	/// The <c>LibraryProperties</c> enables you to control different properties of a DLL as it is loaded into SystemVue.
	/// You can optionally define the <c>DefineLibraryProperties</c> function in your DLL to use this class.  
	/// Upon loading of the DLL, SystemVue will check if this function is define and if so, SystemVue will pass you an instance of this class.
	class MODELBUILDER_API LibraryProperties
	{
	public:
		LibraryProperties();
		~LibraryProperties();

		/// By default, the libraries contained in a DLL will use the DLL name as to define the library names used in SystemVue.
		/// To override this behavior, call the <c>SetLibraryName</c> method.
		/// <param name="strName">Base name to use for libraries added to SystemVue.</param>
		void SetLibraryName( const wchar_t* strName );
		void SetLibraryName( const char* strName );		// narrow-char overload

		/// By default, the parts in a library encode a path to model library. For example, if you have a model named AddCx in your library, the part will point to "AddCx@DLL Name Models".  By removing this path, you can use the Library Manager search path to change the model used in simulation.
		void SetExcludeLibrarySuffixFromPartModels();

		/// The <c>AddLibrary</c> method allows you to load additional libraries into SystemVue that have linked into your DLL as resources.
		/// <param name="uidResource">The resource id.</param>
		/// <param name="bMerge">If true, merge the library into the default library of the same type that is auto-created for the DLL. (Default = true)</param>
		/// <param name="strResourceType">The resource type. (Default = "XML")</param>
		void AddLibrary( unsigned int uidResource, const wchar_t* strResourceType, bool bMerge = true );
		void AddLibrary( unsigned int uidResource, const char* strResourceType = "XML", bool bMerge = true );			// narrow-char overload

		/// For EEsof use only.
		LibraryPropertiesImplementation* m_pImplementation;
	};
}


#ifdef _USRDLL
/*
To override the default library properties, you can optionally define the
DefineLibraryProperties function.  Below is an example:

#include "Stdafx.h"
#include "LibraryProperties.h"

void DefineLibraryProperties(SystemVueModelBuilder::LibraryProperties* pLibraryProperties)
{
	pLibraryProperties->SetLibraryName("C++ Model Builder");
	pLibraryProperties->SetExcludeLibraryPath();
}
*/
extern "C" __declspec(dllexport) bool DefineLibraryProperties(SystemVueModelBuilder::LibraryProperties* pLibraryProperties);
#endif

#endif

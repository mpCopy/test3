//-----------------------------------------------------------------------------------
//	Copyright (c) Keysight Technologies 2008.  All rights reserved.
//  For internal use only
//-----------------------------------------------------------------------------------

// this is a basic include for windows stuff
#pragma once

#if defined(WIN32)

#ifndef _USRDLL // Prevent warnings in modelbuiler - user may include <windows.h>

#ifndef ADS_BUILD
// Modify the following defines if you have to target a platform prior to the ones specified below.
// Refer to MSDN for the latest info on corresponding values for different platforms.
#define WINVER 0x500
#define _WIN32_WINNT 0x0501		// Change this to the appropriate value to target Windows XP or later.
#define _WIN32_WINDOWS 0x0500 // Change this to the appropriate value to target Windows Me or later.

#define _WIN32_IE 0x0501	// Change this to the appropriate value to target IE 5.0 or later.
#endif

#endif // ifndef _USRDLL

#ifdef NOMODELBUILDER

#define MODELBUILDER_API

#else // ifndef NOMODELBUILDER

#ifdef ADS_BUILD
#define MODELBUILDER_EXPORT
#endif

#ifndef _USRDLL
#define MODELBUILDER_EXPORT
#endif

#ifdef MODELBUILDER_EXPORT
#define MODELBUILDER_API __declspec(dllexport)
#else
#define MODELBUILDER_API __declspec(dllimport)
#endif

#endif

#else /*NOT WIN32*/
#define MODELBUILDER_API
#endif

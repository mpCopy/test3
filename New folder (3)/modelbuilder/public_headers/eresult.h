//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	EResult.h
//		Declaration and definition of ERESULT error return codes
//		Note: This is compatible with Windows HRESULT
//-----------------------------------------------------------------------------------
#ifndef _EResult_h
#define _EResult_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

typedef int	ERESULT;

inline bool		Success( ERESULT hr ) { return (hr >= 0); }
inline bool		Failure( ERESULT hr ) { return (hr < 0); }

#define NOERROR_				0
#define E_UNEXPECTED_		0x8000FFFFL
#define E_NOTIMPL_			0x80004001L
#define E_OUTOFMEMORY_		0x8007000EL
#define E_INVALIDARG_		0x80070057L
#define E_FAIL_				0x80004005L
#define E_ACCESSDENIED_		0x80070005L

// ERROR_BAD_FORMAT passes Success() test.  We usually use it to flag a loss of precision
#define E_ERROR_BAD_FORMAT_	11L

#endif

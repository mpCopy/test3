#ifndef C_BOOL_H_INCLUDED
#define C_BOOL_H_INCLUDED
// Copyright Keysight Technologies 2007 - 2017  

// This file exists to define bool for C, using a type that is
// compatible with the C++ type on the same platform.


// First, define gsl_bool_equivalent in both C and C++.
#ifdef _WIN32
typedef unsigned char gsl_bool_equivalent;
#elif defined(linux)
typedef unsigned char gsl_bool_equivalent;
#else
/* Unsupported platform -- generate an error */
UNSUPPORTED PLATFORM
(Perhaps the platform #defines have changed?)
#endif

#if !defined(__cplusplus) && !defined(c_plusplus)

// C-Code: Define bool, true, and false.
typedef gsl_bool_equivalent bool;

#ifdef false
#undef false
#endif
#define false    0

#ifdef true
#undef true
#endif
#define true     1 


#else


namespace 
{
    template<bool> struct CompileTimeError; // by default will generate an error
    template<> struct CompileTimeError<true> {};

    inline void bool_test()
    {
        (CompileTimeError<sizeof(bool) == sizeof(gsl_bool_equivalent)>());
    }
}

#endif /* __cplusplus */


// Finally, define the old ee_bool for C and C++.
typedef int ee_bool;


#endif  /* C_BOOL_H_INCLUDED */
 

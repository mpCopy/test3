/*
   This file is generated by the make system to enable win32 shared
   libraries.  It must be the last included file.
*/

#undef DllImport

#if defined(WIN32)
    #if !defined(tsdfstars_DLL_BUILD)
        #define DllImport  __declspec(dllimport)
    #else 
        #define DllImport
    #endif
#else
    #define DllImport
#endif

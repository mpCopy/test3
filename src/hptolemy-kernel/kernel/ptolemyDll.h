#pragma once

#if defined(WIN32)
    #if !defined(ptolemy_DLL_BUILD)
        #define HPTOLEMY_KERNEL_API  __declspec(dllimport)
    #else 
        #define HPTOLEMY_KERNEL_API
    #endif
#else
    #define HPTOLEMY_KERNEL_API
#endif

#pragma once
// Copyright Keysight Technologies 2008 - 2017  
#include <stdlib.h>
#include "gslexpt.h"            // Needed for the GSL_API definition.

extern "C" {

GSL_API char *gsl_getenv (const char *envname);          // getenv()
GSL_API char* ads_version_str(const char* programName);
GSL_API  void gsl_qsort( char *aa, size_t n, size_t es, int (*cmp)() );

}

class QString;
GSL_API bool getenv_and_registry_qt(const char *envname, QString *returnValue);


#pragma once
// Copyright Keysight Technologies 1996 - 2017  


#include "gslexpt.h"            // Needed for the GSL_API definition.

#ifndef GSL_STDIO_H_INCLUDED
#define GSL_STDIO_H_INCLUDED
// Copyright Keysight Technologies 2008 - 2017  

#include "gslexpt.h"            // Needed for the GSL_API definition.

#if defined(__cplusplus) || defined(c_plusplus)
#include <cstdio>
#endif

#include <stdio.h>
#define LINUX_HAS_GSL_TMPNAM 1

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif
// OS sensitive filename functions
GSL_API  FILE   *gsl_fopen (const char *filename, const char *mode);
GSL_API  int     gsl_fclose (FILE *stream);
GSL_API  char   *gsl_fgets (char *string, int maxchar, FILE *stream);


#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#include "gsl_misc_utf8.h"

#endif // GSL_STDIO_H_INCLUDED

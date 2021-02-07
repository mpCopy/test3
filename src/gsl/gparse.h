#ifndef GPARSE_H_INCLUDED
#define GPARSE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

// This file is deprecated because it includes gui_string.h and defines macros
// Use gsl_gparse.h to avoid the macros.
#include "gslexpt.h"            // Needed for the GSL_API definition.
#include "gui_string.h"         /* provided for backward compatibility only */
#include "c_bool.h"
#include "gsl_gparse.h"


#define MAX_STRG_LEN    1024
#define MAXBUFSZE       MAX_STRG_LEN

#define MAX_CHAR        32      /* being used in gparse_cnvt_xxx functions */
                                /* maximum lenght of the characters to be  */
                                /* converted                               */
#define MAX_EXP         1.0e-99 /* exponent limit - also being used in the */
                                /* gparse_cnvt_xxx functions               */

#endif

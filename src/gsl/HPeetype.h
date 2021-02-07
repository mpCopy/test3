/* @(#) $Source: /cvs/wlv/src/gsl/source/HPeetype.h,v $ $Revision: 100.13 $ $Date: 2011/08/23 21:38:59 $  */
/****************************                    ******************************/
/******************                                        ********************/
/***                       HP EESOF GSL Definitions                         ***/
/***                                                                        ***/
/******************                                        ********************/
/****************************                    ******************************/
 
#ifndef HPEETYPE_H_INCLUDED
#define HPEETYPE_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2017  

#include "gslexpt.h"
#include "c_bool.h"

/* HP-EEsof server names: check with daealias.c. sshk 7/2/97 */
# define GRAPHICS_SERVER  "eegraph"
# define STATUS_SERVER    "hpeesofsess"
# define HARDCOPY_SERVER  "hpeesofhcopy"
# define HELP_SERVER      "hpeesofhelp"
# define DATASET_SERVER   "hpeesofdss"
# define DISPLAY_SERVER   "hpeesofdds"
# define INSTRUMENT_SERVER "hpeesofinstrio"
# define DATA_FILE_TOOL   "eesofdftool"

  /*define the comment char */
#define  COMMENT   '!'
 
/*-------------------------------------------------------------------------------*/
/*                           GLISTMOD types                                      */
/*-------------------------------------------------------------------------------*/
 
typedef void *LHANDLE;              /* (fake) handle type if returned */
 
#endif /* HPEETYPE_H_INCLUDED */
 
/******************************************************************************/
/*****************************  end of HPeetype  ******************************/
/******************************************************************************/

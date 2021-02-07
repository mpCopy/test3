/* Copyright Keysight Technologies 1998 - 2011 */ 
LOCAL const char sccs_cui_circuit_template[]="@(#) $Source: /cvs/sr/src/geminiui/modelbuilder/U2PA.c,v $ $Revision: 1.5 $ $Date: 2011/08/27 00:17:20 $";

/******************************************************************************
    
   This template file can be modified by the user, it will never be modified
   by the Analog Model Development interface.  The structure of the files
   is (assuming user's model is called XYZ):

   XYZ_h.c         This file is auto-generated each time during the compile
                   process. It includes:

                   userdefs.h    the header file (copied to the local
                                 project's network directory only once).
                                 The file includes the <math.h> system
                                 header file.
                                 
                   XYZ.c         this file

   XYZ.dsn	   This is the symbol file.

   XYZ.ael	   This file contains the AEL code necessary to describe
                   the component and its parameters to the ADS design
                   environment (note that an .atf version of this file
                   is automatically generated by ADS when the component
                   is loaded).


   Each of the function calls below can be modified by the user.  Note
   that all functions are not necessarily used, this depends on the
   settings in the Code Options...  dialog box (the XYZ_h.c file
   redirects unused functions to NULL).

   Several other files will be installed in the networks directory:

   userindx.c	   This file is for backwards compatibility with the 
		   Series IV Senior interface. Once copied, it is never
		   modified by the Analog Model Development interface.

   cui_indx.c      This file is auto-generated each time a compile/link
		   is performed. It contains the list of calls from the
		   simulator to link in the boot_modules in the user's
		   code.

   hpeesof*.mak    This is the makefile that will be used to compile/link 
		   (* = debug or opt).  It will #include two other files:

		   modelbuilder.mak   This file is auto-generated each
				      time and contains the files to
				      complile/link based on the dialog
				      box settings.

                   user.mak	      This file is copied only once and
				      never modified by the Analog Model
				      Development interface. It can be
				      modified by the user.

*******************************************************************************/

#define EPS 1e-99
#define ZO 50
#define STDTEMP 27.0

/******************************************************************************/
/*
 * Simple grounded pi-section resistive attenuator element
 * ELEMENT U2PA Id n1 n2 R1=# R2=# R3=#
 *          n1 o---+---R2----+---o n2
 *                 |         |
 *                 R1        R3
 *                 |         |
 *                 =         =
 */

/* senior model data structure */
typedef struct _SeniorType SeniorType;
struct _SeniorType{
  int cnt;                /* loop counter */
  double old;             /* previous iteration value */
};

/* Add Y-parameter function calls here for LINEAR models only (the
   linear portion of a nonlinear model is added in the analyze_lin
   procedure).                                                                */
static boolean compute_y (
  UserInstDef *userInst,
  double omega,
  COMPLEX *yPar)
{
 
  double R1, R2, R3;
  double YA1, YA2;
  double ZA1, ZA2, ZB1, ZB2;
  double Z1, Z2;
  COMPLEX S[4];
  UserParamData *pData = userInst->pData;
  boolean status = TRUE;

  R1 = R1_P;
  R2 = R2_P;
  R3 = R3_P;

  if (R1 < EPS)
    R1 = EPS;
  if (R2 < EPS)
    R2 = EPS;
  if (R3 < EPS)
    R3 = EPS;

  S[3].imag = S[2].imag = S[1].imag = S[0].imag = 0.0; /* imag part */

  YA1 = 1.0 / R3 + 1.0 / ZO;
  ZA1 = 1.0 / YA1;
  ZB1 = R2 + ZA1;
  Z1 = (R1 * ZB1) / (R1 + ZB1);
  S[0].real = (Z1 - ZO) / (Z1 + ZO); /* S11 real */

  YA2 = 1.0 / R1 + 1.0 / ZO;
  ZA2 = 1.0 / YA2;
  ZB2 = R2 + ZA2;
  Z2 = (R3 * ZB2) / (R3 + ZB2);
  S[3].real = (Z2 - ZO) / (Z2 + ZO); /* S22 */
  S[2].real = S[1].real = (2.0/ZO) /
                          (1.0/ZA1 + 1.0/ZA2 + R2/(ZA1 * ZA2));
  /* convert S[2x2] -> yPar[2x2] */
  return s_y_convert(S, yPar, 1, ZO, 2);

  return status;
}


/* Add pre-analysis routines here.                                            */
static boolean pre_analysis (
  UserInstDef *userInst)
{
  boolean status = TRUE;
  
  return status;
}


/* Add post-analysis routines here.                                           */
static boolean post_analysis (
  UserInstDef *userInst)
{
  boolean status = TRUE;
  
  return status;
}


/* Add modify_param routines here. This function is called when any device
   parameter values change
*/
static boolean modify_param (
  UserInstDef *userInst)
{
  boolean status = TRUE;

  return status;
}


/* Add LINEAR noise contribution here.                                        */
static boolean compute_n (
  UserInstDef *userInst,
  double omega,
  COMPLEX *yPar,
  COMPLEX *nCorr)
{
  UserElemDef *userDef = userInst->userDef;

  return passive_noise(yPar, STDTEMP, userDef->numExtNodes, nCorr);
}


/* Add Linear contribution for NONLINEAR models here (use compute_y to
   add linear model y-parameters).                                            */
static boolean analyze_lin (
  UserInstDef *userInst,
  double omega)
{
  boolean status = TRUE;

  return status;
}


/* Add Nonlinear contribution for NONLINEAR models here.                      */
static boolean analyze_nl (
  UserInstDef *userInst,
  double *vPin)
{
  boolean status = TRUE;
  
  return status;
}


/* Add small-signal AC model (linear + linearized) Y-parameters.              */
static boolean analyze_ac (
  UserInstDef *userInst,
  double *vPin,
  double omega)
{
  boolean status = TRUE;
  
  return status;
}


/* Add bias-dependent small-signal noise parameters here.                     */
static boolean analyze_ac_n (
  UserInstDef *userInst,
  double *vPin,
  double omega)
{
  boolean status = TRUE;
  
  return status;
}


/* Add transient response here.                                               */
static boolean analyze_tr(
  UserInstDef *userInst,
  double      *vPin)
{
  boolean status = TRUE;
  UserParamData *pData = userInst->pData;

  status = add_tr_resistor(userInst, 0, GND, R1_P) &&
           add_tr_resistor(userInst, 0, 1,   R2_P) &&
           add_tr_resistor(userInst, 1, GND, R3_P);
  return status;
}

/* Add setup ideal transmission line calls here                               */
static boolean fix_tr(
  UserInstDef *userInst)
{
  boolean status = TRUE;
  
  return status;
}


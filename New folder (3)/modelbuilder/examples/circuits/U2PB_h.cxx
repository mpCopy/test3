// Copyright Keysight Technologies 2010 - 2011  
/* NOTE: The user should not edit this file.
This file is generated when <OK> is chosen in the
Code Options dialog box or when a compile is done. */


#include "userdefs.h"


#define NUM_EXT_NODES           2
#define ANALYZE_NL_DEF_PTR      NULL
#define ANALYZE_NL_FCN_PTR      NULL
#define ANALYZE_LIN_FCN_PTR     NULL
#define ANALYZE_AC_FCN_PTR      NULL
#define COMPUTE_Y_FCN_PTR       compute_y
#define NUM_NONLINEAR_INT_NODES NULL
#define PRE_ANALYSIS_FCN_PTR    pre_analysis
#define POST_ANALYSIS_FCN_PTR   NULL
#define MODIFY_PARAM            modify_param
#define COMPUTE_N_FCN_PTR       NULL
#define ANALYZE_AC_N_FCN_PTR    NULL
#define ANALYZE_TR_FCN_PTR      analyze_tr
#define ANALYZE_TR_DEF_PTR      analyze_tr_def_ptr
#define NUM_TRANSIENT_CAPS      0
#define NUM_TRANSIENT_INDS      0
#define NUM_TRANSIENT_TLS       1
#define NUM_TRANSIENT_INT_NODES 0
#define FIX_TR                  fix_tr
#define U2PB_PARMS           U2PB_parms
#define U2PB_ELEMENTS        U2PB_elements


static boolean compute_y(UserInstDef *userInst, double omega, COMPLEX *yPar);
static boolean compute_n(UserInstDef *userInst, double omega, COMPLEX *yPar, COMPLEX *nCorr);
static boolean analyze_lin(UserInstDef *userInst, double omega);
static boolean analyze_nl(UserInstDef *userInst, double *vPin);
static boolean pre_analysis(UserInstDef *userInst);
static boolean post_analysis(UserInstDef *userInst);
static boolean analyze_ac(UserInstDef *userInst, double *vPin, double omega);
static boolean analyze_ac_n(UserInstDef *userInst, double *vPin, double omega);
static boolean analyze_tr(UserInstDef *userInst, double *vPin);
static boolean fix_tr(UserInstDef *userInst);


static boolean modify_param(UserInstDef *userInst);


#define A_P  userInst->pData[0].value.dVal
#define B_P  userInst->pData[1].value.dVal
#define L_P  userInst->pData[2].value.dVal
#define K_P  userInst->pData[3].value.dVal



#define _P__0  0
#define _P__1  1



static UserParamType
U2PB_parms[] =
{
    {"A", REAL_data},   {"B", REAL_data},   {"L", REAL_data}, 
    {"K", REAL_data}
};



static UserTranDef
ANALYZE_TR_DEF_PTR =
{
  NUM_TRANSIENT_INT_NODES,   /* numIntNodes */
  NUM_TRANSIENT_CAPS,        /* numCaps */
  NUM_TRANSIENT_INDS,        /* numInds */
  NUM_TRANSIENT_TLS,         /* numTlines */
  FALSE,                     /* useConvolution-- obsoleted in ADS 2004A */
  ANALYZE_TR_FCN_PTR,        /* analyze_tr */
  FIX_TR,                    /* fix_tr */
};


static UserElemDef U2PB_ELEMENTS[] =
{
  "U2PB",   /* modelName */
  NUM_EXT_NODES,          /* # of external nodes */
  siz(U2PB_PARMS),   /* # of parameters */
  U2PB_PARMS,   /* # of parameter structure */
  PRE_ANALYSIS_FCN_PTR,   /* pre-analysis fcn ptr */
  COMPUTE_Y_FCN_PTR,      /* Linear model fcn ptr */
  COMPUTE_N_FCN_PTR,      /* Linear noise model fcn ptr */
  POST_ANALYSIS_FCN_PTR,  /* post-analysis fcn ptr */
  NULL,                   /* nonlinear structure ptr */
  NULL,                   /* User-defined arb. data structure */
  &ANALYZE_TR_DEF_PTR,    /* transient fcn ptr */
  2,                      /* version number */
  MODIFY_PARAM            /* modify_param fcn ptr */
};


#include "U2PB.c"


boolean boot_senior_U2PB (void)
{
  return load_elements2(U2PB_ELEMENTS, siz(U2PB_ELEMENTS));
}

/* Copyright Keysight Technologies 2002 - 2011 */ 
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
#define PRE_ANALYSIS_FCN_PTR    NULL
#define POST_ANALYSIS_FCN_PTR   NULL
#define COMPUTE_N_FCN_PTR       NULL
#define ANALYZE_AC_N_FCN_PTR    NULL
#define ANALYZE_TR_FCN_PTR      analyze_tr
#define ANALYZE_TR_DEF_PTR      analyze_tr_def_ptr
#define NUM_TRANSIENT_CAPS      0
#define NUM_TRANSIENT_INDS      0
#define NUM_TRANSIENT_TLS       1
#define NUM_TRANSIENT_INT_NODES 0
#define USE_CONVOLUTION         FALSE
#define FIX_TR                  fix_tr
#define U2PC_PARMS                 U2PC_parms
#define U2PC_ELEMENTS              U2PC_elements


static boolean compute_y(UserInstDef *userInst, double omega, COMPLEX *yPar);
static boolean compute_n(UserInstDef *userInst, double omega, COMPLEX *yPar, COMPLEX *nCorr);
static boolean analyze_lin(UserInstDef *userInst, double omega);
static boolean analyze_nl(UserInstDef *userInst, double *vPin);
static boolean pre_analysis(UserInstDef *userInst);
static boolean post_analysis(UserInstDef *userInst);
static boolean analyze_ac(UserInstDef *userInst, double *vPin, double omega);
static boolean analyze_ac_n(UserInstDef *userInst, double *vPin, double omega);
static boolean analyze_tr(UserInstDef *userInst, double *vPin);
static boolean fix_tr(UserInstDef *pInst);


#define Z0_P  userInst->pData[0].value.dVal
#define L_P  userInst->pData[1].value.dVal
#define Er_P  userInst->pData[2].value.dVal
#define att_P  userInst->pData[3].value.dVal



#define _Pin_1  0
#define _Pin_2  1



static UserParamType
U2PC_parms[] =
{
  {"Z0", REAL_data},  {"L", REAL_data},  {"Er", REAL_data},
  {"att", REAL_data}
};



static UserTranDef
ANALYZE_TR_DEF_PTR =
{
  NUM_TRANSIENT_INT_NODES,   /* numIntNodes */
  NUM_TRANSIENT_CAPS,        /* numCaps */
  NUM_TRANSIENT_INDS,        /* numInds */
  NUM_TRANSIENT_TLS,         /* numTlines */
  USE_CONVOLUTION,           /* useConvolution */
  ANALYZE_TR_FCN_PTR,        /* analyze_tr */
  FIX_TR,                    /* fix_tr */
};


static UserElemDef U2PC_ELEMENTS[] =
{
  "U2PC",   /* modelName */
  NUM_EXT_NODES,          /* # of external nodes */
  siz(U2PC_PARMS),   /* # of parameters */
  U2PC_PARMS,   /* # of parameter structure */
  PRE_ANALYSIS_FCN_PTR,   /* pre-analysis fcn ptr */
  COMPUTE_Y_FCN_PTR,      /* Linear model fcn ptr */
  COMPUTE_N_FCN_PTR,      /* Linear noise model fcn ptr */
  POST_ANALYSIS_FCN_PTR,  /* post-analysis fcn ptr */
  NULL,                /* nonlinear structure ptr */
  NULL,                   /* User-defined arb. data structure */
  &ANALYZE_TR_DEF_PTR,    /* transient fcn ptr */
};


#include "U2PC.c"


boolean boot_senior_U2PC (void)
{
  return load_elements(U2PC_ELEMENTS, siz(U2PC_ELEMENTS));
}

/* Copyright Keysight Technologies 1998 - 2011 */ 
/* NOTE: The user should not edit this file.
This file is generated when <OK> is chosen in the
Code Options dialog box or when a compile is done. */


#include "userdefs.h"


#define NUM_EXT_NODES           2
#define ANALYZE_NL_DEF_PTR      analyze_nl_def_ptr
#define ANALYZE_NL_FCN_PTR      analyze_nl
#define ANALYZE_LIN_FCN_PTR     analyze_lin
#define COMPUTE_Y_FCN_PTR       NULL
#define NUM_NONLINEAR_INT_NODES 1
#define PRE_ANALYSIS_FCN_PTR    NULL
#define POST_ANALYSIS_FCN_PTR   NULL
#define ANALYZE_AC_FCN_PTR      analyze_ac
#define COMPUTE_N_FCN_PTR       NULL
#define ANALYZE_AC_N_FCN_PTR    analyze_ac_n
#define ANALYZE_TR_FCN_PTR      analyze_tr
#define ANALYZE_TR_DEF_PTR      analyze_tr_def_ptr
#define NUM_TRANSIENT_CAPS      0
#define NUM_TRANSIENT_INDS      0
#define NUM_TRANSIENT_TLS       0
#define NUM_TRANSIENT_INT_NODES 1
#define USE_CONVOLUTION         FALSE
#define FIX_TR                  NULL
#define PNDIODE_PARMS                 PNDIODE_parms
#define PNDIODE_ELEMENTS              PNDIODE_elements


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


#define AREA_P  userInst->pData[0].value.dVal
#define IS_P  userInst->pData[1].value.dVal
#define RS_P  userInst->pData[2].value.dVal
#define N_P  userInst->pData[3].value.dVal
#define TT_P  userInst->pData[4].value.dVal
#define CJO_P  userInst->pData[5].value.dVal
#define VJ_P  userInst->pData[6].value.dVal
#define M_P  userInst->pData[7].value.dVal
#define EG_P  userInst->pData[8].value.dVal
#define XTI_P  userInst->pData[9].value.dVal
#define KF_P  userInst->pData[10].value.dVal
#define AF_P  userInst->pData[11].value.dVal
#define FC_P  userInst->pData[12].value.dVal
#define BV_P  userInst->pData[13].value.dVal
#define IBV_P  userInst->pData[14].value.dVal
#define FFE_P  userInst->pData[15].value.dVal



#define _Pin_1  0
#define _N  1



static UserParamType
PNDIODE_parms[] =
{
  {"AREA", REAL_data},  {"IS", REAL_data},  {"RS", REAL_data},
  {"N", REAL_data},  {"TT", REAL_data},
  {"CJO", REAL_data},  {"VJ", REAL_data},
  {"M", REAL_data},  {"EG", REAL_data},
  {"XTI", REAL_data},  {"KF", REAL_data},
  {"AF", REAL_data},  {"FC", REAL_data},
  {"BV", REAL_data},  {"IBV", REAL_data},
  {"FFE", REAL_data}
};



static UserNonLinDef
ANALYZE_NL_DEF_PTR =
{
  NUM_NONLINEAR_INT_NODES,   /* numIntNodes */
  ANALYZE_LIN_FCN_PTR,       /* analyze_lin() */
  ANALYZE_NL_FCN_PTR,        /* analyze_nl() */
  ANALYZE_AC_FCN_PTR,        /* analyze_ac() */
  NULL,                      /* Nonlin modelDef (user can change) */
  ANALYZE_AC_N_FCN_PTR,      /* analyze_ac_n() */
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


static UserElemDef PNDIODE_ELEMENTS[] =
{
  "PNDIODE",   /* modelName */
  NUM_EXT_NODES,          /* # of external nodes */
  siz(PNDIODE_PARMS),   /* # of parameters */
  PNDIODE_PARMS,   /* # of parameter structure */
  PRE_ANALYSIS_FCN_PTR,   /* pre-analysis fcn ptr */
  COMPUTE_Y_FCN_PTR,      /* Linear model fcn ptr */
  COMPUTE_N_FCN_PTR,      /* Linear noise model fcn ptr */
  POST_ANALYSIS_FCN_PTR,  /* post-analysis fcn ptr */
  &ANALYZE_NL_DEF_PTR,    /* nonlinear structure ptr */
  NULL,                   /* User-defined arb. data structure */
  &ANALYZE_TR_DEF_PTR,    /* transient fcn ptr */
};


#include "PNDIODE.c"


boolean boot_senior_PNDIODE (void)
{
  return load_elements(PNDIODE_ELEMENTS, siz(PNDIODE_ELEMENTS));
}

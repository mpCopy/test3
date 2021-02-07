/*@(#) $Source: /cvs/sr/src/geminiui/modelbuilder/userdefs.h,v $ $Revision: 1.22 $ $Date: 2011/08/27 00:17:21 $ */

#ifndef USERDEFS_H_INCLUDED
#define LOCAL static 
LOCAL const char sccs_userdefs_h[]="@(#) $Source: /cvs/sr/src/geminiui/modelbuilder/userdefs.h,v $ $Revision: 1.22 $ $Date: 2011/08/27 00:17:21 $";
#define USERDEFS_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2011  

#include <math.h>
#include <stdio.h>

#define BOOLEAN int
#define boolean int
#define RealNumber double 
#define ComplexNumber COMPLEX
#define TRUE 1
#define FALSE 0

/* -*-C-*-
*******************************************************************************
*
* File:         libra.h
* RCS:          $Header: /cvs/sr/src/geminiui/modelbuilder/userdefs.h,v 1.22 2011/08/27 00:17:21 build Exp $
* Description:  
* Author:       Marek Mierzwinski
* Created:      Tue Apr 23 10:45:20 1996
* Modified:     Thu May 29 12:13:40 1997 (Darryl Okahata) darrylo@sr.hp.com
* Language:     C
* Package:      N/A
* Status:       Experimental (Do Not Distribute)
*
* (C) Copyright 1996, Hewlett-Packard, all rights reserved.
*
*******************************************************************************
*/

/*
 * Header file for inclusion in a Gemini Senior module:
 * EEsof's typedefs, macros, Senior user-typedefs, macros are defined here.
 * Also included are Senior user-needed interface function declarations.
 * Warning: Do not modify any existing definition/declaration here.
 * 
 * This file provides the definitions for the Libra-Senior user defined
 * models. 
 */


#ifndef LIBRA_H_INCLUDED
#define LIBRA_H_INCLUDED

#if !defined(PRODUCTION_BITS)
# ifdef OPT_BUILD
/*
 * Enable PRODUCTION_BITS for optimized builds
 */
#  define PRODUCTION_BITS	1
# endif
#endif

#undef COMPLEX


#ifndef EETYPE_H_INCLUDED /* must match HP EEsof's eetype.h */
#define  TWOPI     6.28318530717958623199593
#endif /* EETYPE_H_INCLUDED */

#ifndef XTYPEDEF_H_INCLUDED /* must match HP EEsof's xtypedef.h */
/*
 * define some physical constants     MEM: remove?
 */

/* if the user want to keep consistent with Libra, please use this value
#define  BOLTZ           1.3806226e-23
#define  CHARGE          1.6021918e-19
*/

/* use NIST Codata-86 value */
#define   BOLTZ   1.380658e-23
#define   CHARGE  1.60217733e-19



#define  CTOK            273.15
#define  NOISE_REF_TEMP  290.0   /* standard noise reference temperature, in Kelvin */
#define  FOUR_K_TO       (4.0*BOLTZ*NOISE_REF_TEMP)   /* noise normalization 4kToB, B=1 Hz */

#define SENIOR_TEMPORARY_MIN_VALUE  	1e-30
#define siz(thing) (sizeof(thing)/sizeof(*thing))

/* Complex type for (linear) Y-, Noise Correlation parameters */
typedef struct
{
  double real;
  double imag;
} COMPLEX;

/* Element parameter type */
typedef enum
{
  NO_data = -1,
  REAL_data = 0,
  INT_data  = 1,
  MTRL_data = 2, /* for parameter referring to an instance */
  STRG_data = 3,
  CMPLX_data = 4,
  INT_VECTOR_data,
  REAL_VECTOR_data,
  CMPLX_VECTOR_data,
  REPEAT_param
} DataTypeE;

#endif /* XTYPEDEF_H_INCLUDED */


/* Element parameter definition */
typedef struct
{
  char *keyword;
  DataTypeE dataType;
} UserParamType;




/* SENIOR_DATA is comparable to USER_DATA, but maps the
 * first 4 union types of UserParamData, and adds additional
 * functionality, to mimic USER_DATA 
 */
typedef struct senior_data {
    DataTypeE dataType;
    union {
    	double 			dVal;  /* for REAL_data */
    	int 			iVal;     /* for INT_data */
    	void 			*eeElemInst; /* for MTRL_data */
    	char 			*strg;   /* for STRG_data */
        ComplexNumber        	cval;
        void                    *subs;
        void                    *data;
    } value;
} SENIOR_USER_DATA;

#define UserParamData SENIOR_USER_DATA
#define SENIOR_USER_PARAM UserParamData


/* Conventional 2-port Noise parameters */
typedef struct
{
  double nFmin;      /* Noise Figure (dB) */
  double magGamma;   /* |opt. source Gamma| */
  double angGamma;   /* <opt. source Gamma (radians) */
  double rnEff;      /* Effective normalized noise resistance */
  double rNorm;      /* Normalizing resistance (ohms) */
} NParType;

/* The following macros are defined in Libra and are copied here */
#ifndef NULL
#define NULL 0L
#endif

#define IN    /* input argument to function */

#ifdef OUT    /* OUT may be declared elsewhere */
#undef OUT
#endif

#define OUT   /* output argument: modified/set by function */ 
#define INOUT /* argument used and modified by function */
#define UNUSED /* unused argument */

#define GND  -1   /* for transient & get_delay_v(), a pin symbol for ground */

typedef struct _UserElemDef UserElemDef;
typedef struct _UserInstDef UserInstDef;
typedef struct _UserNonLinDef UserNonLinDef;
typedef struct _UserTranDef UserTranDef;


/******************************************************************************/
/***             senior user element definition                             ***/
/******************************************************************************/
struct _UserElemDef
{
  char *name;              /* Element name. Not to exceed 8 characters */
  int  numExtNodes;        /* Number of external nodes, max. 20 */
  int  numPars;            /* Number of parameters for this element */
  UserParamType *params;   /* parameter array */

  /* pre-analysis function called after element instance parsed successfully */
  BOOLEAN (*pre_analysis)(INOUT UserInstDef *pInst);

  /* Linear analysis function: called once for each new frequency point.
   * Must return the instance's admittance matrix in yPar array.
   * NULL for nonlinear element
   */
  BOOLEAN (*compute_y)(IN UserInstDef *pInst, IN double omega, OUT COMPLEX *yPar);

  /* Linear noise-analysis function: called once for each new frequency point.
   * Must return the instance's noise-current correlation admittance, normalized
   * to FOUR_K_TO in nCor array.
   * NULL if noiseless
   */
  BOOLEAN (*compute_n)(IN UserInstDef *pInst, IN double omega, IN COMPLEX *yPar, OUT COMPLEX *nCor);

  /* post-analysis: called before new netlist is parsed */
  BOOLEAN (*post_analysis)(INOUT UserInstDef *pInst);

  UserNonLinDef *devDef;  /* User's nonlinear device definition (NULL if linear) */
  struct _SeniorType *seniorInfo; /* Senior user defined type and data (arbitrary) */
  UserTranDef *tranDef;   /* User's transient device definition (NULL if none) */

  /* Followings are new in ADS 2003C */
  int  version;
  /* modify_param function called when any of device parameter values change */
  BOOLEAN (*modify_param)(INOUT UserInstDef *pInst);
};


/******************************************************************************/
/***             senior nonlinear device definition                         ***/
/******************************************************************************/
struct _UserNonLinDef
{
  int numIntNodes; /* # internal nodes of device */

  /* Evaluate linear part (Y-pars) of device model */
  BOOLEAN (*analyze_lin)(IN UserInstDef *pInst, IN double omega);

  /* Evaluate nonlinear part of device model:
   * nonlinear current out of each pin,
   * nonlinear charge at each pin
   * derivative (w.r.t. pin voltage) of each
   * nonlinear pin current, i.e. nonlinear conductance g,
   * derivative (w.r.t. pin voltage) of each
   * nonlinear pin charge, i.e. nonlinear capacitance c
   */
  BOOLEAN (*analyze_nl)(IN UserInstDef *pInst, double *pinVoltage);

  /* Evaluate bias-dependent small-signal AC model:
   * compute total (linear+linearized) Y-pars of device
   */
  BOOLEAN (*analyze_ac)(IN UserInstDef *pInst, IN double *pinVoltage, IN double omega);

  struct _SeniorModel *modelDef; /* user-defined Senior MODEL (arbitrary) */

  /* Evaluate bias-dependent linear noise model:
   * compute total (linear+linearized) noise-current correlation parameters
   * (normalized to FOUR_K_TO, siemens) of device
   */
  BOOLEAN (*analyze_ac_n)(IN UserInstDef *pInst, IN double *pinVoltage, IN double omega);
};

/******************************************************************************/
/***             senior transient device definition                         ***/
/******************************************************************************/

struct _UserTranDef
{
  int numIntNodes; /* # internal nodes of device */
  int numCaps;    /* number of explicit capacitors */ 
  int numInds;    /* number of explicit inductors */
  int numTlines;  /* number of explicit transmission lines */
  BOOLEAN useConvolution;

  /* Evaluate transient model 
   * nonlinear current out of each pin,
   * nonlinear charge at each pin
   * derivative (w.r.t. pin voltage) of each
   * nonlinear pin current, i.e. nonlinear conductance g,
   * derivative (w.r.t. pin voltage) of each
   * nonlinear pin charge, i.e. nonlinear capacitance c
   */
  BOOLEAN (*analyze_tr)(IN UserInstDef *pInst, IN double *pinVoltage);

  /* Pre-transient analysis routine used to allocate, compute and
   * connect ideal transmission lines 
   */
  BOOLEAN (*fix_tr)(IN UserInstDef *pInst);
};

/******************************************************************************/
/***             senior user element instance                               ***/
/******************************************************************************/
struct _UserInstDef
{
  char *tag; /* instance name */
  UserElemDef *userDef; /* access to user-element definition */
  SENIOR_USER_DATA *pData; /* instance's parameters */
  void *eeElemInst; /* EEsof's element instance */
  void *eeDevInst; /* EEsof's nonlinear device instance */
  void *seniorData; /* data allocated/managed/used only by Senior module (arbitrary) */
};

/******************************************************************************/
/***             senior user interface functions                            ***/
/******************************************************************************/

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif


/*
 *  ADS compatibility with SIV design units
 */

/* frequency scale factor in the scope of eeElemInst */
#define get_funit(eeElemInst)  1.0

/* resistance scale factor in the scope of eeElemInst */
#define get_runit(eeElemInst)  1.0

/* conductance scale factor in the scope of eeElemInst */
#define get_gunit(eeElemInst)  1.0

/* inductance scale factor in the scope of eeElemInst */
#define get_lunit(eeElemInst)  1.0

/* capacitance scale factor in the scope of eeElemInst */
#define get_cunit(eeElemInst)  1.0

/* length scale factor in the scope of eeElemInst */
#define get_lenunit(eeElemInst)  1.0

/* time scale factor in the scope of eeElemInst */
#define get_tunit(eeElemInst)  1.0

/* angle scale factor in the scope of eeElemInst */
#define get_angunit(eeElemInst)  1.0

/* current scale factor in the scope of eeElemInst */
#define get_curunit(eeElemInst)  1.0

/* voltage scale factor in the scope of eeElemInst */
#define get_volunit(eeElemInst)  1.0

/* return watt-equivalent of 'power' in eeElemInst's scope */
#define get_watt(eeElemInst, power)  (power)

/* This function searches for data file based on ADS variable SIM_FILE_PATH
 * which is defined in hpeesofsim.cfg, returns absolute path to file if found,
 * otherwise returns NULL.
 */
extern const char* locate_data_file( const char* fileName );

/* The function returns number of external nodes */
extern int get_ucm_num_external_nodes( const UserInstDef *userInst );


/* This function loads the passed instance eeElemInst's RHS parameter values 
 * into pData, which must be big enough to store all parameters. It is mainly 
 * useful to obtain a referred instance's (such as MSUB, TEMP) parameters. 
 * Note that a senior instance's parameters are always available in
 * the 'UserInstDef.pData' array, so there is no need to call this for a 
 * user-instance's own params.
 *
 * It returns TRUE if successful, FALSE otherwise.
 */
extern BOOLEAN get_params (IN void *eeElemInst, OUT UserParamData *pData);

/* This function prints out the instance eeElemInst's parameter names and
 * values to stderr. This function should only be used for debug purpose
 *
 * It returns TRUE if successful, FALSE otherwise.
 */
extern BOOLEAN dump_params( IN void *eeElemInst );

/*------------------------------------------------------------------------------
    The following functions are for querying model parameter value

        int get_ucm_num_of_params( const UserInstDef *userInst );

        const SENIOR_USER_DATA* get_ucm_param_ptr( const UserInstDef* userInst,
                                    int paramIndex, 
                                    char* errorMsg, int repeatIndex );

        const char* get_ucm_param_name( const UserInstDef* userInst,
                                    int paramIndex );

        BOOLEAN is_ucm_repeat_param( const UserInstDef* userInst,
                                    int paramIndex );

        int get_ucm_param_num_repeats( const UserInstDef* userInst,
                                    int paramIndex);

        DataTypeE get_ucm_param_data_type( const SENIOR_USER_DATA *param );

        int get_ucm_param_vector_size( const SENIOR_USER_DATA *param );

        int get_ucm_param_int_value( const SENIOR_USER_DATA *param,
                                    BOOLEAN* status, char* errorMsg );

        double get_ucm_param_real_value( const SENIOR_USER_DATA *param,
                                    BOOLEAN* status, char* errorMsg );

        Complex get_ucm_param_complex_value( const SENIOR_USER_DATA *param,
                                    BOOLEAN* status, char* errorMsg );

        const char* get_ucm_param_string_value( const SENIOR_USER_DATA *param,
                                    BOOLEAN* status, char* errorMsg );

        int get_ucm_param_vector_int_value( const SENIOR_USER_DATA *param,
                                    int index, BOOLEAN* status, char* errorMsg );

        int get_ucm_param_vector_real_value( const SENIOR_USER_DATA *param,
                                    int index, BOOLEAN* status, char* errorMsg );

        int get_ucm_param_vector_complex_value( const SENIOR_USER_DATA *param,
                                    int index, BOOLEAN* status, char* errorMsg );
        
        void print_ucm_param_value( FILE *fp, const SENIOR_USER_DATA *param );
------------------------------------------------------------------------------*/
/* get number of model parameters from userInst* */
extern int get_ucm_num_of_params( const UserInstDef *userInst );

/****************************************************************************** 
 * Get the pointer to a model parameter by parameter index. If the parameter is
 * a repeated parameter, the repeated index is required.
 *
 * \param[in]       userInst            The pointer to ucm device instance 
 * \param[in]       paramIndex          The parameter index in the parameter
 *                                      definition list, staring from 0.
 * \param[out]      errorMsg            Error message
 * \param[in]       repeatIndex         The index of repeated parameter, starting
 *                                      from 0. For example, repeatIndex=1 for
 *                                      myParam[2]. Set repeatedIndex=-1 for 
 *                                      non-repeated parameter.
 */
extern const SENIOR_USER_DATA* get_ucm_param_ptr( const UserInstDef* userInst,
                                           int paramIndex, 
                                           char* errorMsg, int repeatIndex );

extern const char* get_ucm_param_name( const UserInstDef* userInst,
                                int paramIndex );

extern BOOLEAN is_ucm_repeat_param( const UserInstDef* userInst, int paramIndex );

extern int get_ucm_param_num_repeats( const UserInstDef* userInst,
                               int paramIndex);

extern DataTypeE get_ucm_param_data_type( const SENIOR_USER_DATA *param );

extern int get_ucm_param_vector_size( const SENIOR_USER_DATA *param );

extern void print_ucm_param_value( FILE *fp, const SENIOR_USER_DATA *param );

/****************************************************************************** 
 * Get model parameter integer value from the parameter pointer.
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern int get_ucm_param_int_value( const SENIOR_USER_DATA *param,
                             BOOLEAN* status, char* errorMsg );

/****************************************************************************** 
 * Get model parameter real value from the parameter pointer.
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern double get_ucm_param_real_value( const SENIOR_USER_DATA *param,
                                 BOOLEAN* status, char* errorMsg );

/****************************************************************************** 
 * Get model parameter complex value from the parameter pointer.
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern ComplexNumber get_ucm_param_complex_value( const SENIOR_USER_DATA *param,
                                           BOOLEAN* status, char* errorMsg );

/****************************************************************************** 
 * Get model parameter string value from the parameter pointer.
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern const char* get_ucm_param_string_value( const SENIOR_USER_DATA *param,
                                        BOOLEAN* status, char* errorMsg );
 
/****************************************************************************** 
 * Get model parameter int value from the parameter pointer when the parameter
 * has vector value.
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[in]       vectorIndex         The index in the vector, starting from 0.
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern int get_ucm_param_vector_int_value( 
                                const SENIOR_USER_DATA *param,
                                int vectorIndex,
                                BOOLEAN* status, char* errorMsg );

/****************************************************************************** 
 * Get model parameter double value from the parameter pointer when the 
 * parameter has vector value.
 *
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[in]       vectorIndex         The index in the vector, starting from 0.
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern double get_ucm_param_vector_real_value( 
                                const SENIOR_USER_DATA *param,
                                int vectorIndex,
                                BOOLEAN* status, char* errorMsg );

/****************************************************************************** 
 * Get model parameter complex value from the parameter pointer when the 
 * parameter has vector value.
 *
 * \param[in]       param               The pointer to parameter. It can be 
 *                                      obtained from the function 
 *                                          get_ucm_param_ptr(... )
 * \param[in]       vectorIndex         The index in the vector, starting from 0.
 * \param[out]      status              status of the query. It is set to false
 *                                      error occurs.
 * \param[out]      errorMsg            Error message
 */
extern ComplexNumber get_ucm_param_vector_complex_value( 
                                const SENIOR_USER_DATA *param,
                                int vectorIndex,
                                BOOLEAN* status, char* errorMsg );


/* This function returns the value of the ADS global variable 'temp' in kelvin
 *
 */
extern double get_temperature( void );

/* These functions are useful to indicate program status in various stages of
 * execution:  during module bootup, element analyses and pre- or post-analysis.
 */

/* write msg to Status/Progress window */
extern void send_info_to_scn (IN char *msg); 

/* write msg to Errors/Warnings window */
extern void send_error_to_scn (IN char *msg); 

/* write msg to '.inf' file */
extern void send_info_to_file (IN char *msg); 

extern BOOLEAN first_iteration (void);
extern BOOLEAN first_frequency (void);

#ifndef XNOISMOD_H_INCLUDED /* must match EEsof's xnoismod.h */
/* This function computes the complex noise correlation matrix for a passive
 * element, given its Y-pars, operating temperature (Celsius) and # of nodes.
 */
extern BOOLEAN passive_noise (	IN COMPLEX *yPar, 
				IN double tempC, 
				IN int numNodes, 
				OUT COMPLEX *nCor);

/* This function computes the complex noise correlation 2x2 matrix for 
 * an active 3-terminal 2-port
 * element/network, given its Y-pars and measured noise parameters.
 * Note that if 'numFloatPins' is 2, the common (reference) third terminal 
 * is ground.
 */
extern BOOLEAN active_noise (	IN COMPLEX *yPar, 
				IN NParType *nPar, 
				int numFloatPins, 
				OUT COMPLEX *nCor);

#endif /* XNOISMOD_H_INCLUDED */

/* This function must be called (usually from device's analyze_lin(), analyze_ac())
 * to add the linear COMPLEX Y-parameter (iPin, jPin) branch contribution.
 * Note that this call MUST be done even for linear capacitive branches at DC
 * (omega = 0): this will save the jacobian matrix entry location for
 * subsequent non-zero harmonic omega.
 */
extern BOOLEAN add_lin_y (INOUT UserInstDef *userInst, IN int iPin, IN int jPin, IN COMPLEX y);

/* This function must be called from the device's analyze_ac_n() function to add the COMPLEX
 * noise-current correlation term iNcorr (siemens, normalized to FOUR_K_TO) between (iPin, jPin).
 */
extern BOOLEAN add_lin_n (INOUT UserInstDef *userInst, IN int iPin, IN int jPin, IN COMPLEX iNcorr);

/* This function must be called (in device's analyze_nl()) to add the nonlinear conductance and
 * capacitance contribution for the (iPin, jPin) branch:
 * g = d(current(iPin))/d(voltage(jPin))
 * c = d(charge(iPin))/d(voltage(jPin))
 */
extern BOOLEAN add_nl_gc (INOUT UserInstDef *userInst, IN int iPin, IN int jPin, IN double g, IN double c);

/* This function must be called (in device's analyze_nl()) to add the nonlinear current and
 * charge contribution at the device pin iPin
 */
extern BOOLEAN add_nl_iq (INOUT UserInstDef *userInst, IN int iPin, IN double current, IN double charge);

/* This function may be called (from device's analyze_nl()) to get 'tau' seconds delayed
 * (iPin, jPin) voltage difference. GND may be used as jPin to get absolute (w.r.t. ground)
 * delayed pin voltage.
 * Note that 'tau' must NOT be dependent device pin voltages, i.e. it's an ideal delay.
 */
extern BOOLEAN get_delay_v (INOUT UserInstDef *userInst, IN int iPin, IN int jPin, IN double tau, OUT double *vDelay);

/* return the current transient analysis time, in seconds */
extern double get_tr_time(void);

/* This function must be called (in device's analyze_tr()) to add the transient
 *  conductance and capacitance contribution for the (iPin, jPin) branch.
 */
extern BOOLEAN add_tr_gc (INOUT UserInstDef *userInst, IN int iPin, IN int jPin, IN double g, IN double c);

/* This function must be called (in device's analyze_tr()) to add the transient
 * current and charge contribution at the device pin iPin
 */
extern BOOLEAN add_tr_iq (INOUT UserInstDef *userInst, IN int iPin, IN double current, IN double charge);

/* These functions may be called (in device's analyze_tr()) to add a 
 * resistor/capacitor/inductor between pins 1 and 2. Values are
 * in Ohms/Farads/Henries. 
 */
extern BOOLEAN add_tr_resistor  (INOUT UserInstDef *userInst, IN int pin1, IN int pin2, IN double rval);
extern BOOLEAN add_tr_capacitor (INOUT UserInstDef *userInst, IN int pin1, IN int pin2, IN double cval);
extern BOOLEAN add_tr_inductor  (INOUT UserInstDef *userInst, IN int pin1, IN int pin2, IN double lval);

extern BOOLEAN add_tr_lossy_inductor  (INOUT UserInstDef *userInst, IN int pin1, IN int pin2, IN double Rval, IN double lval);
extern BOOLEAN add_tr_mutual_inductor  (INOUT UserInstDef *userInst, IN int indID1, IN int indID2, IN double mval);

/* This function may be called (in a device's fix_tr()) to add an ideal transmission line.
 * The inputs are pin1 (positive) and pin3 (negative),
 * and the outputs are pin2 (positive) and pin4 (negative).
 * the impedance is z0, in Ohms.
 * the delay time is td, in seconds.
 * the loss is an attenuation scale factor; a lossless line has loss=1.0
 */
extern BOOLEAN add_tr_tline (INOUT UserInstDef *userInst, 
                             IN int pin1, IN int pin2, 
                             IN int pin3, IN int pin4,
                             IN double z0, IN double td, IN double loss);   

/* This function must be called by Senior code which wants to use an EEsof element
 * (possibly from a Senior element's "pre_analysis()" function).
 * It returns a pointer to an allocated EEsof instance if successful, NULL otherwise.
 * This pointer must be saved (possibly with the Senior element instance, in
 * its 'seniorData' field) and passed to "ee_compute_y()" or "ee_compute_n()"
 */
extern void *ee_pre_analysis (IN char *elName, IN UserParamData *pData);

/* These functions allow access to EEsof's elements for linear and noise analysis.
 * Note that parameter data 'pData' must be supplied in SI units, where applicable.
 * They return TRUE if successful, FALSE otherwise.
 */
extern BOOLEAN ee_compute_y (INOUT void *eeElemInst, IN UserParamData *pData, IN double omega, OUT COMPLEX *yPar);
extern BOOLEAN ee_compute_n (INOUT void *eeElemInst, IN UserParamData *pData, IN double omega, IN COMPLEX *yPar,
                             OUT COMPLEX *nCor);

/* This function must be called by Senior code (possibly from a Senior element's
 * "post_analysis()" function)for every "ee_pre_analysis()" call to free memory
 * allocated for the EEsof instance 'eeElemInst'
 */
extern BOOLEAN ee_post_analysis (INOUT void *eeElemInst);

/* This returns a pointer to the UserInstDef senior instance if eeElemInst is indeed an
 * instance of a senior element, NULL otherwise
 */
extern UserInstDef *get_user_inst (IN void *eeElemInst);


#ifndef XUTILMOD_H_INCLUDED /* must match EEsof's xutilmod.h */
/* This function converts between S- and Y- parameters:
 * direction = 0: inPar(Y-pars) -> outPar(S-pars).
 * direction = 1: inPar(S-pars) -> outPar(Y-pars).
 * rNorm is the S-parameter normalizing impedance in Ohms.
 * size is the matrix size.
 * It returns TRUE if successful, FALSE otherwise.
 */
extern BOOLEAN s_y_convert (IN COMPLEX *inPar,
			    OUT COMPLEX *outPar,
			    IN int direction, IN double rNorm, IN int size);
#endif /* XUTILMOD_H_INCLUDED */

/* Function to load a single senior module
 * Returns FALSE on failure
 * Loading function for *_h.c file generated by ADS 2003A or earlier 
 */
extern BOOLEAN load_elements (IN UserElemDef *userElem, IN int numElem);

/* new loading function for *_h.c file generated by ADS 2003C or later */
extern BOOLEAN load_elements2 (IN UserElemDef *userElem, IN int numElem);

/* EEsof entry function to boot all senior modules, defined in userindx.c
 * Each senior module must have a call to its booting function here.
 * Returns FALSE on failure
 */
extern BOOLEAN multifile (void);

extern int verify_senior_parameter(SENIOR_USER_DATA *data, DataTypeE type);

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

/* The following is used to translate from senior-libra to senior-gemini:
 */

#define SENIOR_REAL_TYPE		0
#define SENIOR_INTEGER_TYPE		1
#define SENIOR_MTRL_TYPE		2	
#define SENIOR_STRING_TYPE		3
#define SENIOR_UNKNOWN_TYPE		4
#define SENIOR_COMPLEX_TYPE             5
#define SENIOR_SUBSTRATE_TYPE           10 
/******************************************************************************
 *
 * These match HP-internal flags for parameters:
 *
 *****************************************************************************/
#define SENIOR_ARRAY_LIST_TYPE            6
#define SENIOR_REAL_ARRAY_TYPE         	  7
#define SENIOR_COMPLEX_ARRAY_TYPE         8
#define SENIOR_STRING_ARRAY_TYPE          9

#define SENIOR_PARAM_ALLOW_SCALAR             0x00020000
#define SENIOR_PARAM_IS_LENGTH_PARAMETER      0x00040000
#define SENIOR_PARAM_IS_COUPLED_DEVICE_LIST   0x00080000
#define SPARAM_IS_TEMPERATURE_PARAMETER 0x00100000

/* MEM: I don't think the following will ever be valid for a Senior-libra
 * model, so it can probably be removed in future.
 */

#define SENIOR_PARAM_IS_TEMPERATURE_PARAMETER(param) \
                ((param).dataType & SPARAM_IS_TEMPERATURE_PARAMETER)

typedef struct _UserElemDef SENIOR_USER_MODEL;

typedef struct senior_descriptor_data {

    /*
     * MagicMarker MUST BE THE FIRST ENTRY IN THE STRUCTURE.  It is used
     * to determine the type of the structure.  The pUserDescriptor entry
     * in the DeviceDescriptor is used to hold a generic pointer, and the
     * MagicMarker value is used to determine the type of the generic
     * pointer (e.g., user-compiled linear model pointer, user-compiled
     * nonlinear model pointer, etc.).
     */
    int                          MagicMarker;
    UserElemDef                  *model;
} SENIOR_DESCRIPTOR_DATA;

/*****************************************************************************/
/*****************************************************************************/

#if defined(DEBUG) && DEBUG != 0
# define DEBUG_VERIFY_SENIOR_PARAMETER(x, y)   (verify_senior_parameter((x), (y))),
#else
# define DEBUG_VERIFY_SENIOR_PARAMETER(x, y)
#endif


/*****************************************************************************/
/*****************************************************************************/
/* MEM: move to modelmagic.h */

#define SENIOR_MAGIC         	0xA5E4   /* = NONLINEAR_MAGIC +1 */

typedef struct senior_model_descriptor_data {
    /*
     * MagicMarker MUST BE THE FIRST ENTRY IN THE STRUCTURE.  It is used
     * to determine the type of the structure.	The pUserDescriptor entry
     * in the DeviceDescriptor is used to hold a generic pointer, and the
     * MagicMarker value is used to determine the type of the generic
     * pointer (e.g., user-compiled linear model pointer, user-compiled
     * nonlinear model pointer, etc.).
     */
    int				 MagicMarker;
    SENIOR_USER_MODEL		*model;
} SENIOR_MODEL_DESCRIPTOR_DATA;

#define DESCRIPTOR_IS_SENIOR_MODEL(descriptor) \
    ( (((descriptor)->pCktDevDescriptor->pUserDescriptors->pDescriptor) != NULL) && \
      (((SENIOR_MODEL_DESCRIPTOR_DATA *) \
	(descriptor)->pCktDevDescriptor->pUserDescriptors->pDescriptor)->MagicMarker == \
       		SENIOR_MAGIC) \
	)

#define GET_SENIOR_MODEL_FROM_DESCRIPTOR(descriptor) \
    ((SENIOR_USER_MODEL *) (((SENIOR_MODEL_DESCRIPTOR_DATA *) \
		(descriptor)->pCktDevDescriptor->pUserDescriptors->pDescriptor)->model))


#define GET_SENIOR_PARAM_TYPE(x)              ((x).dataType)

#define SENIOR_PARAMETER_TYPE(i, pInst) \
    GET_SENIOR_PARAM_TYPE((pInst)->pModel->pUserModel.Senior->params[i])


#define SSET_DATA_TYPE(x, type)         ((x).dataType = (type))

#define SSET_REAL_VALUE(x, val)         ((x).dataType = REAL_data, \
                                         (x).value.dVal = (val))

#define SSET_INTEGER_VALUE(x, val)      ((x).dataType = INT_data, \
                                         (x).value.iVal = (val))

#define SSET_MTRL_VALUE(x, val)      	((x).dataType = MTRL_data, \
                                         (x).value.eeElemInst = (val))

#define SSET_STRING_VALUE(x, val)       ((x).dataType = STRG_data, \
                                         (x).value.strg = (val))

#define SGET_DATA_TYPE(x)       ((x).dataType)

#define SGET_REAL_VALUE(x)      (DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
                                                        REAL_data) \
                                 (x).value.dVal)

#define SGET_INTEGER_VALUE(x)   (DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
                                                        INT_data) \
                                 (x).value.iVal)

#define SGET_MTRL_VALUE(x)   	(DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
                                                        MTRL_data) \
                                 (x).value.eeElemInst)

#define SGET_STRING_VALUE(x)    (DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
                                                        STRG_data) \
                                 (x).value.strg)

#define SGET_STRING_VECTOR_LENGTH(x)		\
		(((x).dataType == SENIOR_STRING_ARRAY_TYPE) \
		 ? ((SENIOR_SYM_ARRAY *) (x).value.data)->len : -1)

#define SGET_STRING_VECTOR(x)           \
                (((x).dataType == SENIOR_STRING_ARRAY_TYPE) \
                 ? ((SENIOR_SYM_ARRAY *) (x).value.data)->d.sval : NULL)

/*
 * NOTE: in the following, there's a *BIG* problem with naming
 * consistency.  Ideally, the "ARRAY"s should be "VECTOR"s, but we're not
 * copying from a perfect world.
 * MEM: Needed any more?
 */
#define SSET_REAL_ARRAY_TYPE(x, val)	\
		((x).dataType = SENIOR_REAL_ARRAY_TYPE, \
		 (x).value.data = (val))
#define SGET_REAL_ARRAY_TYPE(x)	\
		(DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
					SENIOR_REAL_ARRAY_TYPE) \
		 (x).value.data)
#define SGET_REAL_VECTOR_LENGTH(x)		\
		(((x).dataType == SENIOR_REAL_ARRAY_TYPE) \
		 ? ((SENIOR_SYM_ARRAY *) (x).value.dVal)->len : -1)
#define SGET_REAL_VECTOR(x)		\
		(((x).dataType == SENIOR_REAL_ARRAY_TYPE) \
		 ? ((SENIOR_SYM_ARRAY *) (x).value.dVal)->d.rval : NULL)
#define SGET_COMPLEX_ARRAY_TYPE(x)	\
		(DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
					SENIOR_COMPLEX_ARRAY_TYPE) \
		 (x).value.data)

#define SGET_COMPLEX_VECTOR_LENGTH(x)		\
		(((x).dataType == SENIOR_COMPLEX_ARRAY_TYPE) \
		 ? ((SENIOR_SYM_ARRAY *) (x).value.data)->len : -1)
#define SGET_COMPLEX_VECTOR(x)		\
		(((x).dataType == SENIOR_COMPLEX_ARRAY_TYPE) \
		 ? ((SENIOR_SYM_ARRAY *) (x).value.data)->d.cval : NULL)


#define SSET_COMPLEX_VALUE_REAL(x, val_x, val_y)	\
    ((x).dataType = SENIOR_COMPLEX_TYPE,		\
     (x).value.cval.Real = (val_x),			\
     (x).value.cval.Imag = (val_y))

#define SSET_SUBSTRATE_TYPE(x, val)	((x).dataType = SENIOR_SUBSTRATE_TYPE,\
					 (x).value.subs = (val))

#define SSET_COMPLEX_ARRAY_TYPE(x, val)	\
		((x).dataType = SENIOR_COMPLEX_ARRAY_TYPE, \
		 (x).value.data = (val))
#define SSET_STRING_ARRAY_TYPE(x, val)	\
		((x).dataType = SENIOR_STRING_ARRAY_TYPE, \
		 (x).value.data = (val))
#define SGET_STRING_ARRAY_TYPE(x)	\
		(DEBUG_VERIFY_SENIOR_PARAMETER(&(x), \
					SENIOR_STRING_ARRAY_TYPE) \
		 (x).value.data)

#define SENIOR_PARAMETER_POINTER(i, pInst) \
    (&((pInst)->pSeniorModel->params[i]))


#define GET_SENIOR_PARAM_ARRAY_INITIALIZE_MODE(x) \
	((x).pinfo ? \
	 (((USER_OTHER_PARAM_INFO *)(x).pinfo)->default_flags & \
	  UPARAM_INITIALIZE_ARRAYS_MASK) : 0)
#define SENIOR_PARAM_INITIALIZE_ARRAY_LENGTH_MASK		0x000000F0
#define SENIOR_PARAM_INITIALIZE_ARRAY_LENGTH_TO_DEFAULT	0x00000010
#define SENIOR_PARAM_INITIALIZE_ARRAY_LENGTH_TO_LENGTH	0x00000020

#define ALLOW_SENIOR_PARAM_ARRAYS_ONLY(param) \
                (!((param).dataType & SENIOR_PARAM_ALLOW_SCALAR))

typedef struct {
    int                                 type;
    int                                 len;
    int                                 maxlen;
    union {
        RealNumber                      *rval;
        ComplexNumber                   *cval;
        char                            **sval;
    }                                   d;
} SENIOR_SYM_ARRAY;



#define SENIOR_PARAMETER_NAME(i, pInst) \
    ((pInst)->pSeniorModel->params[i].keyword)

/* Presently, senior doesn't support flags, always return true */
#define SENIOR_PARAMETER_FLAGS(i, pInst) \
    (TRUE)

/*
 * Bitfields for InstanceStatus:
 */
#define SENIOR_PARAMETER_MODIFIED         0x00000001
#define SENIOR_INSTANCE_IS_DISABLED       0x00000002

#define SENIOR_INSTANCE_DISABLED(pInst)           \
    ((pInst)->InstanceStatus & USER_INSTANCE_IS_DISABLED)
#define SENIOR_INSTANCE_PARAMETER_MODIFIED(pInst)         \
    ((pInst)->InstanceStatus & SENIOR_PARAMETER_MODIFIED)

#define SENIOR_PARAM_IS_COUPLED_DEVICE_LIST_PARAMETER(param) \
                ((param).dataType & SENIOR_PARAM_IS_COUPLED_DEVICE_LIST)
#define SENIOR_PARAMETER_IS_READABLE(i, pInst) \
    (SENIOR_PARAMETER_FLAGS(i, pInst) & IP_READABLE)
#define SENIOR_PARAMETER_IS_REQUIRED(i, pInst) \
    (SENIOR_PARAMETER_FLAGS(i, pInst) & IP_REQUIRED)
#define SENIOR_PARAMETER_IS_MODIFIABLE(i, pInst) \
    (SENIOR_PARAMETER_FLAGS(i, pInst) & IP_MODIFIABLE)

#define DEFAULT_SENIOR_PARAMETER_FLAGS   IP_READABLE | IP_MODIFIABLE | \
	IP_SETTABLE

#ifdef TRANSIENT

#define SENIOR_MODEL_USES_HP_TRANSIENT_FEATURES(pInst) \
    (FALSE) 

#endif

#ifdef PARAMETER_SECURITY

#define SENIOR_MODEL_USES_HP_SECURITY_FEATURES(pInst) \
    (TRUE) 

#endif  /* PARAMETER_SECURITY */

#define SENIOR_NO_INIT_NEEDED             (NO_BITS)
#define SENIOR_COEFF_INIT_NEEDED          (BIT0)
#define SENIOR_SPECTRAL_INIT_NEEDED       (BIT1)
#define SENIOR_ALL_INITS_NEEDED           (BIT0 | BIT1 )
#define SENIOR_FREQ_DEPENDENT             (BIT8)


#define SENIOR_MODEL_IS_COUPLING_CONTROLLER(pInst) \
    (FALSE)

#define SENIOR_MODEL_CAN_COMPUTE_S(pInst) \
    (FALSE)

#define SENIOR_MODEL_HANDLES_S_AND_Y(pInst) \
    (FALSE)
#define SENIOR_MODEL_MUST_COMPUTE_S(pInst) \
    (FALSE)
#define SENIOR_MODEL_MUST_COMPUTE_Y(pInst) \
    ((pInst) && ((pInst)->calculating == y_parameter))

#if defined(PRODUCTION_BITS)
# define SENIOR_MODEL_COMPUTES_Y(pInst)	(SENIOR_MODEL_MUST_COMPUTE_Y(pInst))
# define SENIOR_MODEL_COMPUTES_S(pInst)	(SENIOR_MODEL_MUST_COMPUTE_S(pInst))
#else
    /*
     * debugging sanity checks
     */
# define SENIOR_MODEL_COMPUTES_Y(pInst)	\
    ( (senior_model_assert(pInst->calculating == s_parameter || \
		      pInst->calculating == y_parameter)) && \
      (SENIOR_MODEL_MUST_COMPUTE_Y(pInst)) )
# define SENIOR_MODEL_COMPUTES_S(pInst)	\
    ( (senior_model_assert(pInst->calculating == s_parameter || \
		      pInst->calculating == y_parameter)) && \
      (SENIOR_MODEL_MUST_COMPUTE_S(pInst)))
#endif



/********************************* GLOBAL variables *******************************
 */


#endif  /* (#ifndef LIBRA_H_INCLUDED) */

/*************************** end of libra.h ***************************/

#endif /* USERDEFS_H_INCLUDED */

/* Copyright Keysight Technologies 2010 - 2011 */ 
LOCAL const char sccs_cui_circuit_template[]="@(#) $Source: /cvs/sr/src/geminiui/modelbuilder/VariableNodes_R.c,v $ $Revision: 1.4 $ $Date: 2011/08/27 00:17:20 $";

/******************************************************************************
    
   This template file can be modified by the user, it will never be modified
   by the Analog Model Development interface.  The structure of the files
   is (assuming user's model is called XYZ):

   XYZ_h.c         This file may be auto-generated each time during the compile
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

// This model can have variable number external nodes. 
// "NumExtNodes" is required to be one of model parameters. It is used to 
// specify the number of external nodes for the instance.

// Note: This model requires C++ compiler
#include <vector>
#include <stdio.h>

namespace UCM_VariableNodes
{
class MyParam
{
  public:
                bool                    setParamValues( 
                                            const UserInstDef* userInst );
                double                  getResistance( ) const;
                int                     getNumExtNodes( ) const;
  private:
                double                  mResistance;
                int                     mNumExtNodes;
};

} // namespace

using namespace UCM_VariableNodes;

double 
MyParam::getResistance( ) const
{
    return mResistance;
}


int
MyParam::getNumExtNodes( ) const
{
    return mNumExtNodes;
}


bool
MyParam::setParamValues( const UserInstDef* userInst )
{
    mNumExtNodes = get_ucm_num_external_nodes( userInst );
    char errorMsg[2048];

    // get pointer to the parameter based on paramIndex
    // for non-repeat parameter, set repeatIndex = -1;
    int repeatIndex = -1;
    int paramIndex = 1; // for parameter Res
    const SENIOR_USER_DATA *param = get_ucm_param_ptr( userInst,
                   paramIndex, errorMsg, repeatIndex ); 
    if( param )
    {
        BOOLEAN status = TRUE;
        double value = get_ucm_param_real_value( param, &status, errorMsg );
        if( !status )
        {
            fprintf( stderr, "Error: %s\n", errorMsg );
            return false;
        }
        mResistance = value;
    }
    else
    {
        fprintf( stderr, "Error: %s\n", errorMsg );
        return false;
    }
    return true;
}

/* Add Y-parameter function calls here for LINEAR models only (the
   linear portion of a nonlinear model is added in the analyze_lin
   procedure).                                                                */
static boolean compute_y (
  UserInstDef *userInst,
  double omega,
  COMPLEX *yPar)
{
  boolean status = TRUE;
  MyParam *myParam = static_cast<MyParam*> ( userInst->seniorData );

  if( !myParam )
  {
    myParam = new MyParam;
    int stat = myParam->setParamValues( userInst );
    userInst->seniorData = static_cast<void*>( myParam );
  } 
  double resistance = myParam->getResistance( );

  if( resistance < 0 )
  {
    fprintf( stderr, "Error: The total resistance should not be a negative value\n" );
    return FALSE;
  }

  if( resistance < 1e-12 )
    resistance = 1e-12;

  double admittance = 1.0 / resistance;
  yPar[0].real = yPar[3].real = admittance;
  yPar[1].real = yPar[2].real = -admittance;
  yPar[0].imag = yPar[3].imag = 0.0;
  yPar[1].imag = yPar[2].imag = 0.0;


  return status;
}


/* Add pre-analysis routines here.                                            */
static boolean pre_analysis (
  UserInstDef *userInst)
{
  MyParam *myParam = new MyParam;
  bool stat = myParam->setParamValues( userInst );
  if( stat )
  {
      userInst->seniorData = static_cast<void*> ( myParam );
      return TRUE;
  }

  userInst->seniorData = NULL;
  return FALSE;
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
  boolean status = TRUE;

  return status;
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
  
  return status;
}

/* Add setup ideal transmission line calls here                               */
static boolean fix_tr(
  UserInstDef *userInst)
{
  boolean status = TRUE;
  
  return status;
}


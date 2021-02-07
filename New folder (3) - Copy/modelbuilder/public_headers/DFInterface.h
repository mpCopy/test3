#ifndef _DFInterface_h
#define _DFInterface_h
// Copyright  2009 - 2017 Keysight Technologies, Inc  

//-----------------------------------------------------------------------------------
//	Copyright  2009 - 2017 Keysight Technologies 2008.  All rights reserved.
//	DFInterface.h
//		DFInterface class
//-----------------------------------------------------------------------------------

#include "CommonBase.h"
#include "DFPort.h"
#include "DFParam.h"
#include "DFEnumerations.h"

#ifdef ADS_BUILD
#include "ADSCircularBuffer.h"
#else
#include "CircularBuffer.h"
#include "FixedPointEnums.h"
#endif

#include <complex>

namespace SystemVueModelBuilder
{
	class CDFInterfaceImplementation;

	//---------------------------------------------------------------------------------
	//	This class provides an interface between C++ Data Flow model and the simulator.
	//	This class should not be used directly in C++ Data Flow models, instead
	//  macros defined in ModelBuilder.h should be used. These macros creates an object
	//  of this class and call appropriate functions accordingly
	//---------------------------------------------------------------------------------
	class MODELBUILDER_API DFInterface
	{
	private:

		//------------------------------------------------------------------------------
		// For internal use only. 
		//------------------------------------------------------------------------------
		CDFInterfaceImplementation *m_cImplementation;

		//------------------------------------------------------------------------------
		// For internal use only. 
		//------------------------------------------------------------------------------
		DFParam AddParamEnum(int * pidata,const char *pcCodeGenName,const char* pcEnumType);

	public:
		
		//---------------------------------------------------------------------------------
		// The default constructor
		//---------------------------------------------------------------------------------
		DFInterface();

		//---------------------------------------------------------------------------------
		// Destructor
		//---------------------------------------------------------------------------------
		~DFInterface();

		//---------------------------------------------------------------------------------
		// Adds a C++ Data Flow model. pcClassName must be the class name of C++ Data Flow
		// model.
		//
		// This function should not be called directly, instead use ADD_MODEL( model_class_name)
		// macro to add the model. 
		//---------------------------------------------------------------------------------
		void AddModel(const char *pcClassName); 

		//---------------------------------------------------------------------------------
		// Set model description for a C++ Data Flow model. 
		//
		// This function should not be called directly, instead use 
		// SET_MODEL_DESCRIPTION( model_description ) macro to add the model decription. 
		//---------------------------------------------------------------------------------
		void SetModelDescription(const char *pcDescription);

		//---------------------------------------------------------------------------------
		// Set model category for a C++ Data Flow model.
		//
		// This function should not be used directly, instead use 
		// SET_MODEL_CATEGORY( model_category ) macro to set the model category
		//---------------------------------------------------------------------------------
		void SetModelCategory(const char *pcCategory);

		//---------------------------------------------------------------------------------
		// Set a particular symbol for the model. Please make sure that port names  in 
		// the symbol matches exactly with the port names in the model.
		//
		//	This function should not be used directly, instead use
		//  SET_MODEL_SYMBOL( model_symbol_name ) macro to set the symbol name
		//---------------------------------------------------------------------------------
		void SetModelSymbol(const char *pcSymbolName);

		//---------------------------------------------------------------------------------
		// Sets the model name.
		//
		// This function should not be used directly, instead use
		// SET_MODEL_NAME( model_name ) macro to set the model name
		//---------------------------------------------------------------------------------
		void SetModelName(const char *pcName);

		//---------------------------------------------------------------------------------
		// Disable auto part-generation for this model.
		// Call this function when you want to define your own part.
		//---------------------------------------------------------------------------------
		void DisablePartGeneration();

		//---------------------------------------------------------------------------------
		// Disable part and model generation.
		// This function is only useful for internal EEsof development to both the part
		// and model in the SystemVue GUI.  This method may be removed in the future.
		//---------------------------------------------------------------------------------
		void DisablePartAndModelGeneration();

		//---------------------------------------------------------------------------------
		//	Set this model to use a custom UI for parameter input.
		// Currently, this function is only for internal EEsof development, but custom UI
		// support will be fully exposed in the future.
		//---------------------------------------------------------------------------------
		void SetCustomUI( const char* pcCustomUIName );

		//---------------------------------------------------------------------------------
		// Adds a "double" type variable as parameter, pcCodeGenName must be same as the 
		// variable name passed to dData. The value of the variable is set by the simulator
		// to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM( user_param_variable ) macro to add a parameter
		//---------------------------------------------------------------------------------
		DFParam AddParam(double &dData, const char *pcCodeGenName); 

		//---------------------------------------------------------------------------------
		// Adds a "float" type variable as parameter, pcCodeGenName must be same as the 
		// variable name passed to dData. The value of the variable is set by the simulator
		// to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM( user_param_variable ) macro to add a parameter
		//---------------------------------------------------------------------------------
		DFParam AddParam(float &dData, const char *pcCodeGenName); 

		//---------------------------------------------------------------------------------
		// Adds a "double * (double pointer)" type variable as an "array parameter", pcCodeGenName 
		// must be same as the variable name passed to pdData. The memory of the pointer is set 
		// by the simulator and corresponding parameter values are set to the pointer.
		// Size of the pointer in terms of number of elements in the "array parameter" is
		// assigned to iSize variable by the simulator. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_ARRAY_PARAM(user_param_variable, user_array_size_variable) macro to add 
		// an "array parameter".
		//---------------------------------------------------------------------------------
		DFParam AddParamArray(double *&pdData, int &iSize,const char *pcCodeGenName);	

		//---------------------------------------------------------------------------------
		// Adds a "int" type variable as parameter, pcCodeGenName must be same as the 
		// variable name passed to iData. The value of the variable is set by the simulator
		// to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM( user_param_variable ) macro to add a parameter
		//---------------------------------------------------------------------------------
		DFParam AddParam(int &iData,const char *pcCodeGenName);	
		
		//---------------------------------------------------------------------------------
		// Adds a "int * (int pointer)" type variable as an "array parameter", pcCodeGenName 
		// must be same as the variable name passed to piData. The memory of the pointer is set 
		// by the simulator and corresponding parameter values are set to the pointer.
		// Size of the pointer in terms of number of elements in the "array parameter" is
		// assigned to iSize variable by the simulator. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_ARRAY_PARAM(user_param_variable, user_array_size_variable) macro to add 
		// an "array parameter".
		//---------------------------------------------------------------------------------
		DFParam AddParamArray(int *&piData, int &iSize,const char *pcCodeGenName);	
		
		//---------------------------------------------------------------------------------
		// Adds a "std::complex<foat> " type variable as parameter, pcCodeGenName must be 
		// same as the variable name passed to iData. The value of the variable is set by the
		// simulator to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM( user_param_variable ) macro to add a parameter
		//---------------------------------------------------------------------------------
		DFParam AddParam(std::complex<float> &cComplexData,const char *pcCodeGenName);	

		//---------------------------------------------------------------------------------
		// Adds a "Complex " type variable as parameter, pcCodeGenName must be 
		// same as the variable name passed to iData. The value of the variable is set by the
		// simulator to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM( user_param_variable ) macro to add a parameter
		//---------------------------------------------------------------------------------
		DFParam AddParam(std::complex<double> &cComplexData,const char *pcCodeGenName);	
		
		//---------------------------------------------------------------------------------
		// Adds a "Complex  * (std::complex<double>  pointer)" type variable as an 
		// "array parameter", pcCodeGenName must be same as the variable name passed to 
		// pcComplexData. The memory of the pointer is set by the simulator and corresponding 
		// parameter values are set to the pointer. Size of the pointer in terms of number of 
		// elements in the "array parameter" is assigned to iSize variable by the simulator. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_ARRAY_PARAM(user_param_variable, user_array_size_variable) macro to add 
		// an "array parameter".
		//---------------------------------------------------------------------------------
		DFParam AddParamArray(std::complex<double> *&pcComplexData, int &iSize,const char *pcCodeGenName);	
		
		//---------------------------------------------------------------------------------
		// Adds a "char * (character string)" type variable as a "string parameter", pcCodeGenName 
		// must be same as the variable name passed to piData. The memory of the pointer is set 
		// by the simulator and corresponding parameter values are set to the pointer.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "string parameter".
		//---------------------------------------------------------------------------------
		DFParam AddParam(char  *&sData,const char *pcCodeGenName);	

		//---------------------------------------------------------------------------------
		// Adds a "T  (Enum Type)" type variable as an "Enum parameter", pcCodeGenName 
		// must be same as the variable name passed to eEnumData. The value of the variable is set by the
		// simulator to the corresponding parameter
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_ENUM_PARAM(user_param_variable,EnumType) macro to add 
		// an "enum parameter".
		//---------------------------------------------------------------------------------
		template <typename T> DFParam AddParamEnum(T &eEnumData, const char *pcCodeGenName, const char *pcEnumType)
		{
			if(sizeof(T) == sizeof(int)) 
			{
				int *data;
				data = (int *)&eEnumData;
				return AddParamEnum(data,pcCodeGenName,pcEnumType);				
			}
		return DFParam(NULL); 
		}
		
		//---------------------------------------------------------------------------------
		// Adds a "SystemVueModelBuilder::QueryEnum" type variable as a "Enum parameter", pcCodeGenName 
		// must be same as the variable name passed to qData. The corresponding parameter 
		// value is set by the simulator.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "SystemVueModelBuilder::QeueryEnum".
		// 
		// Based on the user input from the schematic. The value of qData will be set to one
		// of the following possible values, which can be used in the rest of the model code
		// * SystemVueModelBuilder::QUERY_NO 
		// * SystemVueModelBuilder::QUERY_YES
		//---------------------------------------------------------------------------------
		DFParam AddParam(QueryEnum  &qData,const char *pcCodeGenName);
		
		//---------------------------------------------------------------------------------
		// Adds a "SystemVueModelBuilder::BooleanEnum" type variable as a "Enum parameter", pcCodeGenName 
		// must be same as the variable name passed to bData. The corresponding parameter 
		// value is set by the simulator.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "SystemVueModelBuilder::BooleanEnum".
		// 
		// Based on the user input from the schematic. The value of bData will be set to one
		// of the following possible values, which can be used in the rest of the model code
		// * SystemVueModelBuilder::BOOLEAN_FALSE 
		// * SystemVueModelBuilder::BOOLEAN_TRUE
		//---------------------------------------------------------------------------------
		DFParam AddParam(BooleanEnum &bData,const char *pcCodeGenName);

		//---------------------------------------------------------------------------------
		// Adds a "SystemVueModelBuilder::SwitchEnum" type variable as a "Enum parameter", pcCodeGenName 
		// must be same as the variable name passed to sData. The corresponding parameter 
		// value is set by the simulator.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "SystemVueModelBuilder::SwitchEnum".
		// 
		// Based on the user input from the schematic. The value of sData will be set to one
		// of the following possible values, which can be used in the rest of the model code
		// * SystemVueModelBuilder::SWITCH_OFF 
		// * SystemVueModelBuilder::SWITCH_ON
		//---------------------------------------------------------------------------------
		DFParam AddParam(SwitchEnum &sData,const char *pcCodeGenName);

		//---------------------------------------------------------------------------------
		// Adds a "char * (character string)" type variable as a "File parameter", pcCodeGenName 
		// must be same as the variable name passed to piData. The memory of the pointer is set 
		// by the simulator and corresponding parameter values are set to the pointer.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "string parameter" and then modify the DFParam type object returned by 
		// ADD_MODEL_PARAM using SetParamAsFile()  mutator function. 
		//---------------------------------------------------------------------------------
		DFParam AddParamFile(const char* pcName, const char *pcDescription, char  *&sData,const char* pcValue="");	

#ifndef ADS_BUILD
		//---------------------------------------------------------------------------------
		// Adds a "SystemVueModelBuilder::FixedPointEnums::Sign" type variable as a "Enum parameter", 
		// pcCodeGenName must be same as the variable name passed to sData. The corresponding 
		// parameter value is set by the simulator.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_PARAM(user_param_variable) macro to add 
		// an "SystemVueModelBuilder::FixedPointEnums::Sign".
		// 
		// Based on the user input from the schematic. The value of sData will be set to one
		// of the following possible values, which can be used in the rest of the model code
		// * SystemVueModelBuilder::FixedPointEnums::TWOS_COMPLEMENT  
		// * SystemVueModelBuilder::FixedPointEnums::UNSIGNED  
		//---------------------------------------------------------------------------------
		DFParam AddParam(FixedPointEnums::Sign &sData,const char *pcCodeGenName);

		///---------------------------------------------------------------------------------
		/// Adds a "SystemVueModelBuilder::FixedPointEnums::QuantizationMode" type variable as a "Enum parameter", 
		/// pcCodeGenName must be same as the variable name passed to sData. The corresponding 
		/// parameter value is set by the simulator.
		///
		/// This function should not be used directly, instead use 
		/// ADD_MODEL_PARAM(user_param_variable) macro to add 
		/// an "SystemVueModelBuilder::FixedPointEnums::QuantizationMode".
		/// 
		/// Based on the user input from the schematic. The value of sData will be set to one
		/// of the following possible values, which can be used in the rest of the model code
		/// <list type="bullet">
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::ROUND - Rounding to Plus infinity </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::ROUND_ZERO - Rounding to Zero </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::ROUND_MINUS_INFINITY - Rounding to Minus infinity </description>  </item>	
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::ROUND_INFINITY - Rounding to infinity </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::ROUND_CONVERGENT - Convergent rounding </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::TRUNCATE -  Truncation </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::TRUNCATE_ZERO -  Truncation to zero </description> </item>
		///	</list>
		///---------------------------------------------------------------------------------
		DFParam AddParam(FixedPointEnums::QuantizationMode &sData,const char *pcCodeGenName);
		

		///---------------------------------------------------------------------------------
		/// Adds a "SystemVueModelBuilder::FixedPointEnums::OverflowMode" type variable as a "Enum parameter", 
		/// pcCodeGenName must be same as the variable name passed to sData. The corresponding 
		/// parameter value is set by the simulator.
		///
		/// This function should not be used directly, instead use 
		/// ADD_MODEL_PARAM(user_param_variable) macro to add 
		/// an "SystemVueModelBuilder::FixedPointEnums::OverflowMode".
		/// 
		/// Based on the user input from the schematic. The value of sData will be set to one
		/// of the following possible values, which can be used in the rest of the model code
		///	<list type="bullet">
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::SATURATE - Saturation </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::SATURATE_ZERO - Saturation to Zero </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::SATURATE_SYMMETRICAL - Symmetrical saturation </description>  </item>	
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::WRAP - Wrap-around </description> </item>
		///		<item> <description>SystemVueModelBuilder::FixedPointEnums::WRAP_SIGN_MAGNITUDE - Sign magnitude wrap-around </description> </item>
		///	</list>
		///---------------------------------------------------------------------------------
		DFParam AddParam(FixedPointEnums::OverflowMode &sData,const char *pcCodeGenName);

		/* ****************************************************************************** */
		/*                                                                                */
		/* SCALAR I/O                                                                     */
		/*                                                                                */
		/* ****************************************************************************** */

		//---------------------------------------------------------------------------------
		// Adds an "int" type variable as a uni-rate input port, pcCodeGenName must be same as the 
		// variable name passed to iData. The value of the variable is set by the simulator
		// to the corresponding input port value. This value can be accessed in "run" method 
		// of C++ Data Flow model.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//---------------------------------------------------------------------------------
		DFPort AddInput(int &iData,const char *pcCodeGenName);  
				
		//---------------------------------------------------------------------------------
		// Adds a "int" type variable as a uni-rate output port, pcCodeGenName must be  
		// same as the variable name passed to iData. This value can be set in
		// "run" method of C++ Data Flow model. Simulator reads the value after each 
		// invokation of "run" method and pass it to the corresponding output port.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an output
		//---------------------------------------------------------------------------------
		DFPort AddOutput(int &iData,const char *pcCodeGenName);  
		
		//---------------------------------------------------------------------------------
		// Adds a "double" type variable as a uni-rate input port, pcCodeGenName must be same as the 
		// variable name passed to dData. The value of the variable is set by the simulator
		// to the corresponding input port value. This value can be accessed in "run" method 
		// of C++ Data Flow model.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//---------------------------------------------------------------------------------
		DFPort AddInput(double &dData,const char *pcCodeGenName); 
				
		//---------------------------------------------------------------------------------
		// Adds a "double" type variable as a uni-rate output port, pcCodeGenName must be  
		// same as the variable name passed to dData. This value can be set in
		// "run" method of C++ Data Flow model. Simulator reads the value after each 
		// invokation of "run" method and pass it to the corresponding output port.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an output
		//---------------------------------------------------------------------------------
		DFPort AddOutput(double &dData,const char *pcCodeGenName); 
			
		//---------------------------------------------------------------------------------
		// Adds a "Complex " type variable as a uni-rate input port, pcCodeGenName must 
		// be same as the variable name passed to ComplexData. The value of the variable is set 
		// by the simulator to the corresponding input port value. This value can be accessed 
		// in "run" method of C++ Data Flow model.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//---------------------------------------------------------------------------------
		DFPort AddInput(std::complex<double> &ComplexData,const char *pcCodeGenName);  

		//---------------------------------------------------------------------------------
		// Adds a "Complex " type variable as a uni-rate output port, pcCodeGenName 
		// must be  same as the variable name passed to ComplexData. This value can be set in
		// "run" method of C++ Data Flow model. Simulator reads the value after each invokation 
		// of "run" method and pass it to the corresponding output port.
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an output
		//---------------------------------------------------------------------------------
		DFPort AddOutput(std::complex<double> &ComplexData,const char *pcCodeGenName);  


		/* ****************************************************************************** */
		/*                                                                                */
		/* Array I/O                                                                      */
		/*                                                                                */
		/* ****************************************************************************** */

		//---------------------------------------------------------------------------------
		// Adds a "int * (int pointer)" type variable as a multi-rate input port, pcCodeGenName 
		// must be same as the variable name passed to iData. The value of the pointer variable 
		// is set by the simulator to the corresponding input port value. This value can be accessed 
		// in "run" method of C++ Data Flow model. Simulator is responsible to manage memory for this 
		// pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_INPUT.
		//---------------------------------------------------------------------------------
		DFPort AddInput(int *&iData,const char *pcCodeGenName);  
		
		//---------------------------------------------------------------------------------
		// Adds a "int * (int pointer)" type variable as a multi-rate output port,  
		// pcCodeGenName must be same as the variable name passed to iData. The value of the  
		// pointer variable can be set in the "run" method of C++ Data Flow model. Simulator  
		// reads the value after each invokation of "run" method and pass it to the corresponding 
		// output port. Simulator is responsible to manage memory for this pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_OUTPUT.
		//---------------------------------------------------------------------------------
		DFPort AddOutput(int *&iData,const char *pcCodeGenName);  
				
		//---------------------------------------------------------------------------------
		// Adds a "double* (double pointer)" type variable as a multi-rate input port, pcCodeGenName 
		//  must be same as the variable name passed to dData. The value of the pointer variable 
		// is set by the simulator to the corresponding input port value. This value can be accessed 
		// in "run" method of C++ Data Flow model. Simulator is responsible to manage memory for this 
		// pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_INPUT.
		//---------------------------------------------------------------------------------
		DFPort AddInput(double *&dData,const char *pcCodeGenName); 
		
		//---------------------------------------------------------------------------------
		// Adds a "double * (double pointer)" type variable as a multi-rate output port,  
		// pcCodeGenName must be same as the variable name passed to dData. The value of the  
		// pointer variable can be set in the "run" method of C++ Data Flow model. Simulator  
		// reads the value after each invokation of "run" method and pass it to the corresponding 
		// output port. Simulator is responsible to manage memory for this pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_OUTPUT.
		//---------------------------------------------------------------------------------
		DFPort AddOutput(double *&dData,const char *pcCodeGenName); 
		
		//---------------------------------------------------------------------------------
		// Adds a "Complex  * (std::complex<double>  pointer)" type variable as a 
		// multi-rate input port, pcCodeGenName must be same as the variable name passed to 
		// ComplexData. The value of the pointer variable is set by the simulator to the 
		// corresponding input port value. This value can be accessed in "run" method of C++ 
		// Data Flow model. Simulator is responsible to manage memory for this pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_INPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_INPUT.
		//---------------------------------------------------------------------------------
		DFPort AddInput(std::complex<double> *&ComplexData,const char *pcCodeGenName);  

		//---------------------------------------------------------------------------------
		// Adds a "Complex  * (std::complex<double>  pointer)" type variable as 
		// a multi-rate output port, pcCodeGenName must be same as the variable name passed 
		// to ComplexData. The value of the pointer variable can be set in the "run" method of 
		// C++ Data Flow model. Simulator reads the value after each invokation of "run" method 
		// and pass it to the corresponding output port. Simulator is responsible to manage 
		// memory for this pointer. 
		//
		// This function should not be used directly, instead use 
		// ADD_MODEL_OUTPUT( user_variable ) macro to add an input
		//
		// By default the rate is "1". To modify the rate, use "AddRateVariable( unsigned &iRate)" 
		// funciton of DFPort object returned by ADD_MODEL_OUTPUT.
		//---------------------------------------------------------------------------------
		DFPort AddOutput(std::complex<double> *&ComplexData,const char *pcCodeGenName);  

#endif

		/* ****************************************************************************** */
		/*                                                                                */
		/* Circular Buffer I/O                                                            */
		/*                                                                                */
		/* ****************************************************************************** */

		/// <summary>
		/// This version of the AddInput method adds a circular buffer input to your model.
		/// <param name="circularBuffer">A circular buffer contained in your model.</param>
		/// <param name="pcCodeGenName">This parameter must be the same as the circular buffer variable name.</param>
		/// <remarks>
		/// You should use the SetRate method of the CircularBuffer to set the multirate attribute on this port, by default it will be 1.
		/// This method is called by the ADD_MODEL_INPUT macro which will automatically fill in the pcCodeGenName appropriately.  This CircularBuffer types supported are:
		/// <list type="bullet">
		/// <item>
		/// <description>IntCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>DoubleCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>Dstd::complex<double>CircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>FloatCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>Fstd::complex<double>CircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>FixedPointCircularBuffer</description>
		/// </item>
		/// </list>
		/// </remarks>
		/// </summary>
		DFPort AddInput( CircularBufferBase& circularBuffer, const char *pcCodeGenName);  

		/// <summary>
		/// This version of the AddOutput method adds a circular buffer output to your model.
		/// <param name="circularBuffer">A circular buffer contained in your model.</param>
		/// <param name="pcCodeGenName">This parameter must be the same as the circular buffer variable name.</param>
		/// <remarks>
		/// You should use the SetRate method of the CircularBuffer to set the multirate attribute on this port, by default it will be 1.
		/// This method is called by the ADD_MODEL_OUTPUT macro which will automatically fill in the pcCodeGenName appropriately.  This CircularBuffer types supported are:
		/// <list type="bullet">
		/// <item>
		/// <description>IntCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>DoubleCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>Dstd::complex<double>CircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>FloatCircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>Fstd::complex<double>CircularBuffer</description>
		/// </item>
		/// <item>
		/// <description>FixedPointCircularBuffer</description>
		/// </item>
		/// </list>
		/// </remarks>
		/// </summary>
		DFPort AddOutput( CircularBufferBase& circularBuffer, const char *pcCodeGenName);

		/* ****************************************************************************** */
		/*                                                                                */
		/* Bus I/O                                                                        */
		/*                                                                                */
		/* ****************************************************************************** */

		/// <summary>
		/// This version of the AddInput method adds a circular buffer bus input to your model.
		/// <param name="circularBufferBus">A circular buffer bus contained in your model.</param>
		/// <param name="pcCodeGenName">This parameter must be the same as the circular buffer variable name.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// <remarks>
		/// You should use the SetRate method of the CircularBuffer to set the multirate attributes on each individual port in the bus, by default it will be 1.
		/// This method is called by the ADD_MODEL_INPUT macro which will automatically fill in the pcCodeGenName appropriately.  This CircularBuffer types supported are:
		/// <list type="bullet">
		/// <item>
		/// <description>IntCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>DoubleCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>Dstd::complex<double>CircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>FloatCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>Fstd::complex<double>CircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>FixedPointCircularBufferBus</description>
		/// </item>
		/// </list>
		/// </remarks>
		/// </summary>
		DFPort AddInput( CircularBufferBus& circularBufferBus, const char *pcCodeGenName);  

		/// <summary>
		/// This version of the AddOutput method adds a circular buffer bus input to your model.
		/// <param name="circularBufferBus">A circular buffer bus contained in your model.</param>
		/// <param name="pcCodeGenName">This parameter must be the same as the circular buffer variable name.</param>
		/// <param name="iNumberItems">The number of items to copy</param>
		/// <remarks>
		/// You should use the SetRate method of the CircularBuffer to set the multirate attributes on each individual port in the bus, by default it will be 1.
		/// This method is called by the ADD_MODEL_OUTPUT macro which will automatically fill in the pcCodeGenName appropriately.  This CircularBuffer types supported are:
		/// <list type="bullet">
		/// <item>
		/// <description>IntCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>DoubleCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>Dstd::complex<double>CircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>FloatCircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>Fstd::complex<double>CircularBufferBus</description>
		/// </item>
		/// <item>
		/// <description>FixedPointCircularBufferBus</description>
		/// </item>
		/// </list>
		/// </remarks>
		/// </summary>
		DFPort AddOutput( CircularBufferBus& circularBufferBus, const char *pcCodeGenName);  

		//------------------------------------------------------------------------------
		// For internal use only. A C++ Data Flow model must not use this at all
		//------------------------------------------------------------------------------
		const char * GetLastError(); 

		//------------------------------------------------------------------------------
		// For internal use only. A C++ Data Flow model must not use this at all
		//------------------------------------------------------------------------------
		const CDFInterfaceImplementation* const GetImplementation() const;

	};
} // end namespace SystemVueModelBuilder

#endif

#ifndef _ModelBuilder_h
#define _ModelBuilder_h
//-----------------------------------------------------------------------------------
//	Copyright (c) Keysight Technologies 2008.  All rights reserved.
//	ModelBuilder.h
//		Definition of essential functions/macros needed to write a C++ Data Flow model
//-----------------------------------------------------------------------------------

#include <vector>
#include "DFModel.h"
#include "DFInterface.h"
#include "DFErrorHandler.h"
#include "RegisterModel.h"

//------------------------------------------------------------------------------
// _MB_QUOTEME(x) and MB_QUOTEME(x) macros are for internal  
// use only. A C++ Data Flow model must not use these at all in its header or 
// cpp file directly.
// 	
//------------------------------------------------------------------------------
#ifndef SV_CODE_GEN
#if defined(_USRDLL)
#define _MB_QUOTEME(x) #x
#define MB_QUOTEME(x) _MB_QUOTEME(x)
#else
#define MB_QUOTEME(x) ""
#endif
#endif

//------------------------------------------------------------------------------
// The macro DECLARE_MODEL_INTERFACE( ModelClass ) must be included in the 
// header file for C++ Data Flow model class under public methods.
// This will declare methods needed to create interface between
// the simulator and Data Flow model class
//
// For example in C++ Data Flow model class named MyClass add
//		public:
//			DECLARE_MODEL_INTERFACE(MyClass)
//------------------------------------------------------------------------------
#ifndef SV_CODE_GEN
#define DECLARE_MODEL_INTERFACE( ModelClass )	\
	\
	static SystemVueModelBuilder::DFModel* Create(const char** pccClassName);\
	virtual bool	DefineInterface( ::SystemVueModelBuilder::DFInterface &model );
#else
#define DECLARE_MODEL_INTERFACE( ModelClass )
#endif

//------------------------------------------------------------------------------
// The macro DEFINE_MODEL_INTERFACE( ModelClass ) must be used in the 
// cpp file for C++ Data Flow model class to specify/define the interface
// between C++ Data Flow model and the simulator.
//
// For example in C++ Data Flow model class named MyClass 
//			DEFINE_MODEL_INTERFACE(MyClass)
//			{
//			  // add the interface code here	
//			}
//------------------------------------------------------------------------------
#ifndef SV_CODE_GEN
#define DEFINE_MODEL_INTERFACE( ModelClass ) \
	\
	SystemVueModelBuilder::CRegisterModel __DFModel_##ModelClass( ##ModelClass::Create, DFInterfaceVersion, MB_QUOTEME(LIBNAME) ); \
	\
	const char* __DFModel_Class_Name__##ModelClass = #ModelClass; \
	SystemVueModelBuilder::DFModel* ModelClass::Create(const char** pccClassName) \
	{ \
		(*pccClassName) = __DFModel_Class_Name__##ModelClass; \
		return new ModelClass ; \
	} \
	\
	bool	ModelClass::DefineInterface(::SystemVueModelBuilder::DFInterface &model)
#else
#define DEFINE_MODEL_INTERFACE( ) \
The_DEFINE_MODEL_INTERFACE_macro_is_not_supported_for_code_generation_see_documentation_for_more_details
#endif

//------------------------------------------------------------------------------------------
// ADD_PARENT_MODEL_INTERFACE( ParentClass ) is used inside DEFINE_MODEL_INTERFACE to add
// the interface defined in in the model from which current model is inherited.
// Optionally you could redfine all the interface by yourself, if you don't call this 
// macro. For example if a Subtractor model is derived from a calss Adder, which is also
// a DFModel then in cpp of Subtractor you could write the following.
//
//	DEFINE_MODEL_INTERFACE(Subtractor)
//	{
//		ADD_PARENT_MODEL_INTERFACE(Adder);
//
//		return true;
//	}
//------------------------------------------------------------------------------------------
#define ADD_PARENT_MODEL_INTERFACE( ParentModelClass )  ParentModelClass::DefineInterface(model)

//------------------------------------------------------------------------------------------
// ADD_MODEL_INPUT( user_variable ) is used inside DEFINE_MODEL_INTERFACE to add
// a public member of C++ Data Flow model class as input port.
//
// For example public member variable
//		int m_iFoo;
// can be added using 
//		ADD_MODEL_INPUT(m_iFoo); 
// format. 
//
// For supported data types consult the C++ Models section of SystemVue documentation at
// User's Guide -> Using SystemVue -> User Defined Models -> C++ Models -> Supported Data 
// Types -> Data Types Used as Inputs/Outputs
// 
// ADD_MODEL_INPUT returns an object of type DFPort. Which can be further used to change
// name, and description, and to add a rate-variable (for non-CircularBuffer data types). 
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------------------
#define ADD_MODEL_INPUT( user_variable )	\
	model.AddInput(user_variable, #user_variable)

//------------------------------------------------------------------------------------------
// ADD_MODEL_OUTPUT( user_variable ) is used inside DEFINE_MODEL_INTERFACE to add
// a public member of C++ Data Flow model class as output port.
//
// For example public member variable
//		int m_iFoo;
// can be added using 
//		ADD_MODEL_OUTPUT(m_iFoo); 
// format. 
//
// For supported data types consult the C++ Models section of SystemVue documentation at
// User's Guide -> Using SystemVue -> User Defined Models -> C++ Models -> Supported Data 
// Types -> Data Types Used as Inputs/Outputs
// 
// ADD_MODEL_OUTPUT returns an object of type DFPort. Which can be further used to change
// name, and description, and to add a rate-variable (for non-CircularBuffer data types). 
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------------------
#define ADD_MODEL_OUTPUT( user_variable )	\
	model.AddOutput(user_variable, #user_variable)


//------------------------------------------------------------------------------
// ADD_MODEL_PARAM( user_param_variable ) is used inside DEFINE_MODEL_INTERFACE 
// to add a public member of C++ Data Flow model class as a non-array parameter.
//
// For example public member variable
//		int m_iFoo;
// can be added using 
//		ADD_MODEL_PARAM(m_iFoo); 
// format. 
//
// Following data types are supported as non-array parameter
// "int", "double", "float", "std::complex<doube>", "std::complex<float>", 
// "char *" , and SystemVue's built in enumerations
//
// Please read User's Guide -> Using SystemVue -> User Defined Models -> C++ Models 
// -> Supported Data Types -> Data Types Used as Parameters for list of Built in 
// enumerations.
// 
// ADD_MODEL_PARAM returns an object of type DFParam. which can be further used to 
// change name, description, default value and to change string type parameter as
// File type with Browse button.
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define ADD_MODEL_PARAM( user_param_variable )	 \
	model.AddParam(user_param_variable, #user_param_variable)

#define ADD_MODEL_PARAMETER(x) ADD_MODEL_PARAM(x)

//------------------------------------------------------------------------------
// ADD_MODEL_ENUM_PARAM( user_param_variable, enum_type_name ) is used inside 
// DEFINE_MODEL_INTERFACE to add a public enum type member of C++ Data Flow model 
// class as a non-array parameter.
//
// For example public member variable
//		MyEnum {A=1, B=5, C};
//		MyEnum m_eFoo;
// can be added using 
//		SystemVueModelBuilder::DFParam cEnum = ADD_MODEL_ENUM_PARAM(m_eFoo, MyEnum); 
// format. 
//
// Only "user defined enums" should be added in this manner. Use ADD_MODEL_PARAM
// for SystemVue's built in enumerations
// 
// ADD_MODEL_ENUM_PARAM returns an object of type DFParam.
// ADD_MODEL_ENUM_PARAM macro must be be followed by sequence of 
// AddEnumeration(char * name, int value) method of returned object of type DFParam.
// 
// In the above example we will need to do 
//		cEnum.AddEnumeration("A",A);
//		cEnum.AddEnumeration("B",B);
// 		cEnum.AddEnumeration("C",C);
// 
//  The returned DFParam object can be further used to change name, description,
// default value.
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define ADD_MODEL_ENUM_PARAM( user_param_variable, enum_type_name )	 \
	model.AddParamEnum<enum_type_name>(user_param_variable,#user_param_variable,#enum_type_name);
#define ADD_MODEL_ENUM_PARAMETER(user_param_variable, enum_type_name) ADD_MODEL_ENUM_PARAM(user_param_variable, enum_type_name)
//------------------------------------------------------------------------------
// ADD_MODEL_ARRAY_PARAM(user_param_variable, user_array_size_variable)
// is used inside DEFINE_MODEL_INTERFACE to add a public member of C++ Data Flow
// model class as a an array parameter.
//
// For example public member variable
//		int *m_iFoo;
//		unsigned m_iFooSize;
// can be added using 
//		ADD_MODEL_ARRAY_PARAM(m_iFoo,m_iFooSize); 
// format. 
//
// Following data types are supported as an array parameter
// "int *", "double *", "std::complex<doube> *"
// 
//  The user_array_size_variable should be of unsigned type which will be set
// by simulator to the number of elements in the array parameter. 
// Simulator will take care of all memory management for pointer data
//
// ADD_MODEL_ARRAY_PARAM returns an object of type DFParam. which can be further
// used to change name, description, and default value.
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define ADD_MODEL_ARRAY_PARAM(user_param_variable, user_array_size_variable)	\
	model.AddParamArray(user_param_variable,user_array_size_variable, #user_param_variable)

#define ADD_MODEL_ARRAY_PARAMETER(x,y) ADD_MODEL_ARRAY_PARAM(x,y)
	

//------------------------------------------------------------------------------
// SET_MODEL_NAME( model_name ) can be used inside DEFINE_MODEL_INTERFACE to 
// change the model name to some value other than the default class name.
// For example 
//		SET_MODEL_NAME("MyAdder");
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define SET_MODEL_NAME( model_name )	\
	model.SetModelName(model_name)


//-------------------------------------------------------------------------------------
// SET_MODEL_DESCRIPTION( model_description ) can be used inside DEFINE_MODEL_INTERFACE  
// to change the model description.
// For example 
//		SET_MODEL_DESCRIPTION("My first Adder");
//
// Please read "C++ Models" documentation for further detail.
//-------------------------------------------------------------------------------------
#define SET_MODEL_DESCRIPTION( model_description )	\
	model.SetModelDescription(model_description)


//--------------------------------------------------------------------------------------
// SET_MODEL_SYMBOL( model_symbol_name ) can be used inside DEFINE_MODEL_INTERFACE  
// to select a pre-built symbol instead of default auto-generated symbol.
// For example 
//		SET_MODEL_SYMBOL("SYM_IntToBits");
//
// Note that if you are selecting a symbol then port names in symbol and model 
// must match.
//
// Please read "C++ Models" documentation for further detail.
//----------------------------------------------------------------------------------------
#define SET_MODEL_SYMBOL( model_symbol_name )	\
	model.SetModelSymbol( model_symbol_name)



//------------------------------------------------------------------------------
// SET_MODEL_CATEGORY( model_category ) can be used inside DEFINE_MODEL_INTERFACE  
// to change the model category.
// For example 
//		SET_MODEL_CATEGORY("Math, numeric");
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define SET_MODEL_CATEGORY( model_category )	\
	model.SetModelCategory( model_category )


//------------------------------------------------------------------------------
// DISABLE_PART_GENERATION() can be used inside DEFINE_MODEL_INTERFACE  
// to disable automatic part generation for this model.  This is called when you 
// create your own part.
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define DISABLE_PART_GENERATION()	\
	model.DisablePartGeneration()

//------------------------------------------------------------------------------
// SET_MODEL_UI( UIname ) can be used inside DEFINE_MODEL_INTERFACE  
// to define which custom UI this model uses as an interface for parameter setting.
// Currently, this is only used by EEsof internal development, however support
// for custom model UI definition will be fully exposed in the future.
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define SET_MODEL_UI( UIname )	\
	model.SetCustomUI( UIname )

//------------------------------------------------------------------------------
// POST_ERROR(const_char_error)  can be used anywhere except inside 
// DEFINE_MODEL_INTERFACE macro and constructors/destrcutor. This posts an Error 
// message and causes the simulation to be aborted.
//
// The parameter (const_char_error) to this macro must be a const char * type
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define POST_ERROR(const_char_error) \
	::SystemVueModelBuilder::DFErrorHandler::PostError(this, const_char_error);

//------------------------------------------------------------------------------
// POST_WARNING(const_char_warning)  can be used anywhere except inside 
// DEFINE_MODEL_INTERFACE macro and constructors/destrcutor. This posts a warning 
// message.
//
// The parameter (const_char_warning) to this macro must be a const char * type
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define POST_WARNING(const_char_warning) \
	::SystemVueModelBuilder::DFErrorHandler::PostWarning(this, const_char_warning);

//------------------------------------------------------------------------------
// POST_INFO(const_char_message)  can be used anywhere except inside 
// DEFINE_MODEL_INTERFACE macro and constructors/destrcutor. This posts an Info 
// message.
//
// The parameter (const_char_message) to this macro must be a const char * type
//
// Please read "C++ Models" documentation for further detail.
//------------------------------------------------------------------------------
#define POST_INFO(const_char_message)	\
	::SystemVueModelBuilder::DFErrorHandler::PostMessage(this, const_char_message);



#endif

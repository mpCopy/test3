/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/compat/win32/utils.h,v $ $Revision: 1.6 $ $Date: 2011/08/25 01:47:10 $ */
/*
 *  UTILITIES
 *
 *  This module contains the type definitions for files in the utilities
 *  directory.
 *
 *  It now also includes the contents of Strings.h.
 *
 *  Author:			Advising professor:
 *      Kenneth S. Kundert	    Alberto Sangiovanni-Vincentelli
 *      UC Berkeley
 *
 */



#ifndef UTILS_H_INCLUDED
#define UTILS_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2014  

#ifndef NUMBERS_H_INCLUDED
# include "../include/Numbers.h"
#endif
#ifndef CEH_H_INCLUDED
# include "../include/ceh.h"
#endif



/* START-DEVELOPER-PUBLIC */

/*
 *  Function type definitions
 */


/* math.c */
#define  RealPositive  0
#define  ImagPositive  1
ComplexNumber CmplxSqrt(ComplexNumber Argument, int Root);
ComplexNumber CmplxCbrt(ComplexNumber Arg, int RootNumber);
ComplexNumber cnexp(ComplexNumber u);
ComplexNumber Add(ComplexNumber Avar, ComplexNumber Bvar);
ComplexNumber CCONJ(ComplexNumber Z);
ComplexNumber ccos(ComplexNumber z);
ComplexNumber ccosh(ComplexNumber Gamma);
ComplexNumber ccsch(ComplexNumber u);
ComplexNumber ccoth(ComplexNumber Gamma);
ComplexNumber cexp(ComplexNumber U);
ComplexNumber cln(ComplexNumber U);
ComplexNumber csin(ComplexNumber z);
ComplexNumber csinh(ComplexNumber Gamma);
ComplexNumber Divide(ComplexNumber Num, ComplexNumber Denom);
ComplexNumber Mult(ComplexNumber Aval, ComplexNumber Bval);
double Norm(ComplexNumber A);
double PhaseRad(ComplexNumber A);
ComplexNumber RealToComplex(double Real, double Imag);
ComplexNumber ScalarMult(double A, ComplexNumber Z);
ComplexNumber Sub(ComplexNumber Avar, ComplexNumber Bvar);
double ArcTanh(double Z);
double Cosh(double Z);
double Coth(double Z);
double Log_10(double A);
double Sinh(double Z);
double Tanh(double Z);
double cot(double X);
double tan_(double X);
double zexp(double x);
RealNumber RealVectorMax(int Size, RealNumber *pData);
RealNumber RealNormalRV(void);
void ComplexNormalRV(ComplexNumber *pCpx);



/* matrix.c */
int DecomposeFullMatrix(register RealMatrix Matrix, register int Size, register int Bandwidth);
/* resources.c */
void StartTimer(void);
double ElapsedTime(void);
void PrintResourceUsage(int Level);
int getpagesize(void);
/* signame.c */
char *SignalName(int Index);
char *StringSave(const char *From);
/* sort.c */
extern void HeapSort(int Size, register RealVector Array);
/* std.c */
int to_upper(int c);
int to_lower(int c);
/* strings.c */
int CountChar(char String2[], int Char2);
int stricmp( const char *s1, const char *s2);
char *strtolower(char *str);
char *trim_string(char *str);
/* utils.c */
char *find_file(char *filename, char *search_paths[], char *input_file);
char *ExpandEnvVariables(char *Buf, char *Path);
char *ExpandTilde(char *Buf, char *Path);
char *signal_to_string(int sig);
int get_trivial_random_number(void);

/* END-DEVELOPER-PUBLIC */

#endif	/* UTILS_H_INCLUDED */

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/PtRng.h,v $ $Revision: 100.14 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PTRNG_H_INCLUDED
#define PTRNG_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2017  

#ifdef __GNUG__
#pragma interface
#endif

#include "gui_math.h"
#include "HPstddefs.h"
#include "ptolemyDll.h"

class ACG;

class Rng 
{
private:

  HPTOLEMY_KERNEL_API static long seed;

public:
  static void setSeed(long);
  static long getSeed(void);
  double urand();
  virtual double operator()() = 0;
};


// This version substitutes for libg++ random-number classes.
// Returns a random number between "lower" and "upper".

class PtUniform : public Rng {
private:
	double minv;
	double scale;
        
public:
	PtUniform(double lower,double upper,ACG* = NULL) :
		minv(lower), scale(upper-lower) {}
	double operator()() {
		return urand()*scale + minv;
	}
};

class PtNormal : public Rng {
private:
	double mean;
	double var;
	double val2;
	int have2;
public:
	PtNormal(double m,double v,ACG* = NULL) : mean(m), var(v), have2(0) {}
	double operator()();
};

inline double PtNormal :: operator()() {
	if (have2) {
		have2 = 0;
		return val2;
	}
	double x, y, r;
	do {
		// get two uniformly distributed r.v.'s in [-1,1]
		x = urand() * 2.0 - 1.0;
		y = urand() * 2.0 - 1.0;
		// form the magnitude squared.
		r = x * x + y * y;
	} while (r >= 1.0);
	r = sqrt(-2.0 * var *log(r) / r);
	val2 = r * x + mean;
	have2 = 1;
	return r * y + mean;
}

class PtNegativeExpntl : public Rng {
private:
        double mean;
public:
        PtNegativeExpntl(double arg, ACG* = NULL) : mean(arg) {}
        double operator()() {
                return -log(urand()) * mean;
        }
};

#endif   /* PTRNG_H_INCLUDED */


// Copyright  2007 - 2017 Keysight Technologies, Inc 
#include <HPstddefs.h>
#include <cmath>
#include <cstdarg>
#include <cstdlib>
#include <cstring>

class          complex
{
private:
    double          real, imag;
public:
    friend void 	abs(const complex &, complex &);
    friend double   mod(const complex &);
    friend double  	real(const complex &);
    friend double  	imag(const complex &);
    
    // simple constructor. Don't need to overload the =
    // operator, as the memory of the class is simple
    complex(double = 0.0, double = 0.0);

    // math operators
    complex operator * (const complex &);
    complex operator / (const complex &);
    complex operator + (const complex &);
    complex operator - (const complex &);
    complex minus();

    // functions
    friend complex exp (const complex &);
    friend complex arg (const complex &);
    // casts
    friend int ctoi(const complex &);

    // compare operators
    bool    operator < (const complex &);
    bool    operator > (const complex &);
    bool    operator == (const complex &);
};

template <class T>
class array {
	T	*c;
	size_t  mysize;

	array<T>	*temp;
	int 		ii;
	int 		jj;
	int        	wi;
	int 		wj;

	public:

	// constructors
	array(int=0,int=0);
	~array();
	void init(int,int);
	void ident();

	void free();

	// access
	T& operator () (int,int);

	// pass a pointer and copy all the memory at this pointer
	array<T> & operator << (T*);
	void copy(array<T>& );
	void rcopy(array<T>&,int,int,int,int );
	void rrcopy(array<T>&,int,int,int,int,int,int );

	// pass each element separately
	array<T> & operator << (T);

	// reinitialise load process
	array<T> & reset();

	// initialise the temporary variables
	array<T>& operator << (array <T> &);

	// return the size of the array
	int geti() {return(ii);}
	int getj() {return(jj);}

	// math operators

	// standard matrix multiplication. If the arrays are single dimention
	// with the correct orientation then a single element multiplication
	// is performend
	array<T> operator*(array<T>&);

	// use this for creating a new copy of the array, including
	// memory allocation
	array<T> operator*(int);

	// scalar multiplication of array
	array<T> operator*(T&);

	array<T> operator+(array<T>&);
	array<T> operator-(array<T>&);
	array<T> operator~();
	void inverse(array<complex>&);
	void rotate();
	T sum();
};

//************************************************************

template < class T>
T sum(array<T> &);

template < class T>
T sum(array<T> &my) {return(my.sum());}

//************************************************************

	template <class T>
void array<T>::free()
{
	delete [] c;
}

//************************************************************

	template <class T>
array<T>::array( int i, int j)
{
	(*this).init(i,j);
}

//************************************************************

	template <class T>
void array<T>::ident()
{
    int i, j;
	for(i=1;i<=ii;i++)
		for (j=1;j<=jj;j++) {
			if (i==j)
				(*this)(i,j)=complex(1.0,0.0);
			else
				(*this)(i,j)=complex(0.0,0.0);
		}
}

//************************************************************

	template <class T>
void array<T>::init( int i, int j)
{
	ii=i;
	jj=j;
	wi=1;
	wj=1;
	// don't initialise the temporary space
	temp = 0;

	if (ii*jj > 0)
	{
		mysize = ii*jj*sizeof(T);
	    c = new T[ii*jj];		
	}	
}

//************************************************************

	template <class T>
array<T>::~array()
{
	// delete [] c;
}

//************************************************************

	template <class T>
T &array<T>::operator() (int i, int j)
{
	int index;
	T *ret;

	index = (i-1)+(j-1)*ii;

	ret = (T*)c;
	return(ret[index]);
}

//************************************************************

	template <class T>
array<T> & array<T>::operator << (T *my)
{
	for(int i=1;i<=ii;i++)
		for(int j=1;j<=jj;j++)
			(*this)(i,j) = *(my++);
	return(*this);
}

//************************************************************

	template <class T>
array<T> & array<T>::operator << (T my)
{
	(*this)(wi,wj) = my;
	wi++;
	if (wi>ii) {
		wi=1;
		wj++;
	}
	return (*this);
}

//************************************************************

	template <class T>
array<T> & array<T>::reset()
{
	wi=1;
	wj=1;
}

//************************************************************

	template < class T>
array<T> & array<T>:: operator << (array <T> &my)
{
	temp = &my;
	return(*this);
}

//************************************************************

	template <class T>
array<T> array<T>::operator*(array<T>& my)
{
	array<T> *x;

	if (jj==my.ii) {
		x=temp;

		for (int i=1;i<=ii;i++)
			for (int j=1;j<=my.jj;j++) {
				(*x)(i,j)=T();
				for (int jjj=1;jjj<=jj;jjj++) {
					// commented out doesn't work??
					// (*x)(i,j)=(*x)(i,j) + (*this)(i,jjj) * my(jjj,j);
					(*x)(i,j)=(*this)(i,jjj) * my(jjj,j) + (*x)(i,j);
				}
			}

	} else if (ii==my.ii) {
		x=temp;
		for (int i=1;i<=ii;i++)
			(*x)(i,1)=(*this)(i,1)*my(i,1);
	}
	return(*x);
}

//************************************************************

	template <class T>
void array<T>::copy(array<T>& my)
{
	for (int i=1;i<=ii;i++)
		for (int j=1;j<=jj;j++)
			(*this)(i,j)=my(i,j);
}

//************************************************************

	template <class T>
void array<T>::rcopy(array<T>& my,int i1, int i2, int j1, int j2)
{
	for (int i=i1;i<=i2;i++)
		for (int j=j1;j<=j2;j++)
			(*this)(i,j)=my(i,j);
}

//************************************************************

	template <class T>
void array<T>::rrcopy(array<T>& my,int oi, int oj, int i1, int i2, int j1, int j2)
{
	for (int i=i1;i<=i2;i++)
		for (int j=j1;j<=j2;j++)
			(*this)(i-i1+oi,j-j1+oj)=my(i,j);
}

//************************************************************

	template <class T>
array<T> array<T>::operator*(int my)
{
	array<T> *x;

	x=temp;

	for (int i=1;i<=ii;i++)
		for (int j=1;j<=jj;j++)
			(*x)(i,j)=(*this)(i,j);
	return(*x);
}

//************************************************************

	template <class T>
array<T> array<T>::operator*(T&scalar)
{
	array<T> *x;

	x=temp;

	for (int i=1;i<=ii;i++)
		for (int j=1;j<=jj;j++)
			(*x)(i,j)=(*this)(i,j) * scalar;
	return(*x);
}

//************************************************************

	template <class T>
array<T> array<T>::operator-(array<T>& my)
{
	array<T> *x;

	x=temp;

	for (int i=1;i<=ii;i++)
		for (int j=1;j<=jj;j++)
			(*x)(i,j)=(*this)(i,j) - my(i,j);
	return(*x);
}

//************************************************************

	template <class T>
array<T> array<T>::operator+(array<T>& my)
{
	array<T> *x;

	x=temp;

	for (int i=1;i<=ii;i++)
		for (int j=1;j<=jj;j++)
			(*x)(i,j)=(*this)(i,j) + my(i,j);
	return(*x);
}

//************************************************************

	template <class T>
array<T> array<T>::operator~()
{
	array<T> *x;
	complex e;

	x=temp;

	e = (*this)(1,1) * (*this)(2,2) - (*this)(1,2) * (*this)(2,1);
	(*x)(1,1) = (*this)(2,2) / e;
	(*x)(1,2) = (*this)(1,2) / e;
	(*x)(2,1) = (*this)(2,1) / e;
	(*x)(2,2) = (*this)(1,1) / e;

	return(*x);
}

//************************************************************

	template <class T>
void array<T>::rotate()
{
	T t;

	t = (*this)(ii,1);
	for (int i=ii;i>1;i--)
		(*this)(i,1) = (*this)(i-1,1);
	(*this)(1,1) = t;
}

//************************************************************

// this only works if T is a non reference type
	template <class T>
T array<T>::sum()
{
	T ret;

	ret = (*this)(1,1);
	for (int i=2;i<=ii;i++)
		ret = (*this)(i,1) + ret;

	return(ret);
}

class timeDomain {
  array <complex> time;
  array <complex> amplitude;
  int steps;
  int mid;

public:

  timeDomain();
  ~timeDomain();

  // simple initialisation of matrices
  void init(int);
  
  // access
  // should change this complex number to a double
  // and also make the access function consistent i.e.
  // .amp()(i,j) or .amp(i,j)
  array <complex> &amp() {return(amplitude);}
  array <complex> &t() {return(time);}
  int whatLength() {return(steps);} 
};

class cursorDomain {
    array < complex > cursors;  

    // signal amplitude at various subcursor position (j,1)
    array < complex > signal;

    // ui - number of subcursor positions
    // pre,post - number of pre and post cursors
    int ui,pre,post;
 
    // sample time ?? Don't think this is used any more
    complex sample;


public:
    cursorDomain() {
       cursors=0;
       signal=0;
    }
    ~cursorDomain() {
 	cursors.free();
	signal.free();
     }

    // create cursor domain given an already interpolated
    // timedomain specifying the pre/post and ui in time steps
    cursorDomain(timeDomain&,int,int,int);
    void extractCursors(timeDomain&, int,int,int);

    // enable dfe equalisation. Initially simple function
    // that zeros the sample point post cursors and adjust
    // the other cursors correctly
    void extractCursorswithdfe(timeDomain&, int,int,int,int, double *);

    // access functions
	array <complex> & c() {return cursors;}
	array <complex> & s() {return signal;}
	int whatLength() {return(pre+post);}
	int whatUI() {return(ui);}
};

class pdf {
    array < array<double> > pdfs;
    complex scale;
    int resolution;
    int scan;
    int ui;

	public :
	pdf();
	~pdf(); 
	pdf(cursorDomain &, int);
	void calcPdf(cursorDomain &, int);
    void createPdf3(array<double>&,complex,complex,complex);
	int createConvolve(array<double>&,complex,complex);
	void jitter(pdf &, double *);
	int what_scan() {return(scan);}
	int what_ui() {return(ui);}
	double what_scale() {return(real(scale));}
	int what_resolution() {return resolution;}
	double p(int j,int r) {return pdfs(j,1)(r,1);}
	};

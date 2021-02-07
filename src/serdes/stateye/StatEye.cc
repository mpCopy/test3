// Copyright 2007 - 2014 Keysight Technologies, Inc  
// #define COMPLEX_DEBUG
#define TOLERANCE 1.0e-12
#include "StatEye.h"

#ifdef _MSC_VER
#include <float.h>
#define isnan(x)	_isnan(x)
#define isinf(x)	(_isnan(x) ? 0 : (_fpclass(x) == _FPCLASS_NINF) ? -1 : (_fpclass(x) == _FPCLASS_PINF) ? 1 : 0)
#endif /* _MSC_VER */

//***********************************************

void abs(const complex &a, complex &b)
{
    b.real = fabs(a.real);
    b.imag = fabs(a.imag);
}

//***********************************************

double imag(const complex &a)
{
    return(a.imag);
}

//***********************************************

double real(const complex &a)
{
    return(a.real);
}

//***********************************************

double mod(const complex &a)
{
    return(sqrt(pow(a.real,2.0) + pow(a.imag,2.0)));
}

//***********************************************

complex::complex(double a, double b)
{
    real = a;
    imag = b;
}

//***********************************************

complex complex::operator*(const complex &a)
{
    complex x;
    x.real = real*a.real - imag*a.imag;
    x.imag = real*a.imag + imag*a.real;
    return(x);
}

//***********************************************

complex complex::operator/(const complex &a)
{
    complex x;

    x.real = (real*a.real + imag*a.imag) / ( pow(a.real,2.0)+pow(a.imag,2.0));
    x.imag = (imag*a.real - real*a.imag) / ( pow(a.real,2.0)+pow(a.imag,2.0));
    return(x);
}

//***********************************************

complex complex::operator+(const complex &a)
{
    complex x;
    x.real = real + a.real;
    x.imag = imag + a.imag;
    return(x);
}

//***********************************************

complex complex::operator-(const complex &a)
{
    complex x;
    x.real = real - a.real;
    x.imag = imag - a.imag;
    return(x);
}

//***********************************************

complex complex::minus()
{
    complex x;
    x.real=-real;
    x.imag=-imag;
    return(x);
}

//***********************************************

complex arg(const complex &a)
{
    complex x;
    x.real = a.real;
    x.imag = -a.imag;
    return(x);
}

//***********************************************

complex exp(const complex &a)
{
    complex x;
    x.real = exp(a.real) * cos(a.imag);
    x.imag = exp(a.real) * sin(a.imag);
    return(x);
}

//***********************************************

int ctoi(const complex &a)
{
    return((int)a.real);
}

//***********************************************

bool complex::operator< (const complex &a)
{
    if (real<a.real)
        return(1);
    else
        return(0);
}

//***********************************************

bool complex::operator>(const complex &a)
{
    if (real>a.real)
        return(1);
    else
        return(0);
}

//***********************************************

bool complex::operator==(const complex &a)
{
    if ( (fabs(real-a.real)<TOLERANCE) && (fabs(imag-a.imag)<TOLERANCE) )
        return(1);
    else
        return(0);
}

//***********************************************

timeDomain::timeDomain() {
	time=0;
	amplitude=0;
	steps=0;
}
timeDomain::~timeDomain() {
	if (steps>0) {
		time.free();
		amplitude.free();
	}
}

//************************************************************

void timeDomain::init(int length)
{
	// assuming I have only the positive frequency points starting from
	// zero
	steps = length;
	mid   = length/2;

	// initilisae the objects arrays for the calc values
	time.init(length,1);
	amplitude.init(length,1);
}

//************************************************************

cursorDomain::cursorDomain(		timeDomain &my,
                             int myui,
                             int mypre,
                             int mypost)
{
    (*this).extractCursors(my, myui, mypre, mypost);
}

//************************************************************

void cursorDomain::extractCursors(	timeDomain &my,
                                   int myui,
                                   int mypre,
                                   int mypost)
{
    // index in the time domain for the maximum of the pulse
    // response
    int index, i, UI, sub;

    // store the main parameters for this extraction, i.e.
    // subcursor scan resolution, number of pre/post cursors
    // again don't think sample is needed anymore
    ui     = myui;
    pre    = mypre;
    post   = mypost;
    sample = my.t()(2,1)-my.t()(1,1);

    // localMax, timeMax - temp variables for finding the
    // maximum amplitude of the pulse response
    complex localMax = my.amp()(1,1);
    index=1;
    for (i=1;i<=my.whatLength();i++)
        if (my.amp()(i,1) > localMax) {
            localMax = my.amp()(i,1);
            index = i;
        }

    // initialise the object appropriately for the
    // extraction parameters
    cursors.init(post+pre,2*ui+1);
    signal.init(2*ui+1,1);

    // scan through the cursors and subcursor positions and
    // extract each cursor. When UI is zero then this is the
    // signal
    i = 1;
    for (UI=-pre;UI<=post;UI++)
    {
        int j=1;
        for (sub=-ui;sub<=ui;sub++)
        {
            // precalc the index and rotate index through array if outside of the array limits
            int t = index+UI*ui+sub;
            if (t<1)
            {
                if (t % my.whatLength() == 0)
                    t = my.whatLength();
                else
                    t = my.whatLength() + t % my.whatLength();
            }    
            if (t>my.whatLength())
            {
                if (t % my.whatLength() == 0)
                    t = my.whatLength();
                else
                    t = t % my.whatLength();
            }    
            
            if (UI==0)
                signal(j,1) = my.amp()(t,1);
            else
                cursors(i,j) = my.amp()(t,1);
            j++;
        }
        if (UI!=0)
            i++;
    }
}

//************************************************************

void cursorDomain::extractCursorswithdfe(	timeDomain &my,
        int myui,
        int mypre,
        int mypost,
        int taps,
        double * dfetaps)
{
    int index, i, sub, UI;

    // store the main parameters for this extraction, i.e.
    // subcursor scan resolution, number of pre/post cursors
    ui     = myui;
    pre    = mypre;
    post   = mypost;

    // localMax, timeMax - temp variables for finding the
    // maximum amplitude of the pulse response
    complex localMax = complex(0,0);
    index=1;    
    complex timeMax;
    for (i=1;i<=my.whatLength();i++)
        if (my.amp()(i,1) > localMax) {
            localMax = my.amp()(i,1);
            timeMax  = my.t()(i,1);
            index = i;
        }

    // from the peak scan left and right cancelling the dfe
    // coefs approprately to find the centre sampling point
    if (taps>0)
    {
        int new_index=0;
        complex isimax, temp;
        int first =1;

        for (sub=-ui;sub<=ui;sub++) {
            complex isi = complex(0,0);
            for (UI=-pre;UI<=post;UI++) {
                int t = index+UI*ui+sub;
                if (t<1)
                {
                    if (t % my.whatLength() == 0)
                        t = my.whatLength();
                    else
                        t = my.whatLength() + t % my.whatLength();
                }    
                if (t>my.whatLength())
                {
                    if (t % my.whatLength() == 0)
                        t = my.whatLength();
                    else
                        t = t % my.whatLength();
                }    

                if (UI==0)
                    isi = isi + my.amp()(t,1);
                else if ((UI<0) || (UI>taps))
                {
                    abs(my.amp()(t,1), temp);
                    isi = isi - temp;
                }    
            }
            if ((isi>isimax) || first) {
                first = 0;
                isimax=isi;
                new_index=index+sub;
                if (new_index<1)
                    new_index = my.whatLength() + new_index;
                if (new_index>my.whatLength())
                    new_index = new_index - my.whatLength();
            }
        }
        index = new_index;
    }

    timeMax  = my.t()(index,1);

    // initialise the object appropriately for the
    // extraction parameters
    cursors.init(post+pre,2*ui+1);
    signal.init(2*ui+1,1);

    // scan through the cursors and subcursor positions and
    // extract each cursor. When UI is zero then this is the
    // signal
    {
        i = 1;
        complex equ;

        for (UI=-pre;UI<=post;UI++) {
            int j=1;

            // again calculate the index into the pulse
            // response in advance and correct if
            // necessary
            int teq = index+UI*ui;
            if (teq<1)
            {
                if (teq % my.whatLength() == 0)
                    teq = my.whatLength();
                else
                    teq = my.whatLength() + teq % my.whatLength();
            }    
            if (teq>my.whatLength())
            {
                if (teq % my.whatLength() == 0)
                    teq = my.whatLength();
                else
                    teq = teq % my.whatLength();
            }    

            if ((UI>0) && (UI<=taps)) {
                equ = my.amp()(teq,1);
				dfetaps[UI-1] = real(equ);

            } else
                equ = complex(0,0);

            for (sub=-ui;sub<=ui;sub++){

                // calculate and correct index into array
                // in advance
                int t   = index+UI*ui+sub;
                if (t<1)
                {
                    if (t % my.whatLength() == 0)
                        t = my.whatLength();
                    else
                        t = my.whatLength() + t % my.whatLength();
                }    
                if (t>my.whatLength())
                {
                    if (t % my.whatLength() == 0)
                        t = my.whatLength();
                    else
                        t = t % my.whatLength();
                }    

                if (UI==0)
                    signal(j,1) = my.amp()(t,1);
                else
                    cursors(i,j) = my.amp()(t,1)-equ;
                j++;
            }
            if (UI!=0)
                i++;
        }
    }
}

pdf::pdf() { 
}

pdf::~pdf() {
        int i;
		if (scan>0) {
			for (i=1;i<=scan;i++)
				pdfs(i,1).free();
			pdfs.free();
		}
}

void pdf::calcPdf(cursorDomain&my,int myResolution)
{
    complex sum, temp;

    // what is the resolution of the amplitude pdf
    resolution = myResolution;
    // what is the resolution of the time axis
    scan       = my.whatUI()*2+1;
    ui         = my.whatUI();
    
    // work out max of pulses and scaling factor
    int i, j;
    for (j=1;j<=scan;j++)
    {
        sum=complex(0.0,0.0);
        for (i=1;i<=my.whatLength();i++)
        {
            abs(my.c()(i,j), temp);
            sum = temp + sum;
        }    
        sum = my.s()(j,1) + sum;
        if (sum>scale)
            scale = sum;
    }

    // usualy fiddle to ensure that through rounding errors the summation
    // of the cursors remain in the array
    scale = scale * complex((resolution+2.0)/resolution,0.0);

    pdfs.init(scan,1);

    // scan across eye
    for (j=1;j<=scan;j++) {
        // create empty array for storing pdf for this offset
        pdfs(j,1).init(resolution*2+1,1);

        // using h0 and 1st two cursors create 1st entry in pdf array
        createPdf3(	pdfs(j,1),
                    my.s()(j,1),
                    my.c()(1,j),
                    my.c()(2,j));

        // add cursors in pairs
        for (i=3;i<=my.whatLength();i=i+2)
            createConvolve(	pdfs(j,1),
                            my.c()(i,j),
                            my.c()(i+1,j));

        double maxFound = pdfs(j,1)(1,1);
        for (i=1;i<=resolution*2+1;i++)
            maxFound = (pdfs(j,1)(i,1) > maxFound) ? pdfs(j,1)(i,1) : maxFound;

        for (i=1;i<=resolution*2+1;i++)
            pdfs(j,1)(i,1) = pdfs(j,1)(i,1) / maxFound;
    }
}

void pdf::createPdf3(array<double>&slice,complex a, complex b, complex c)
{
    int index, i;

    // important to initial the array as this is an integer array and is
    // not by default zero
    for (i=1;i<=resolution*2+1;i++)
        slice(i,1)=0;

    // calculate the 4 four possible deltas assuming equal probability
    index = ctoi( (a+b+c)/scale * complex(resolution*1.0,0.0) ) + resolution +1;
    slice(index,1)++;
    index = ctoi( (a-b-c)/scale * complex(resolution*1.0,0.0) ) + resolution +1;
    slice(index,1)++;
    index = ctoi( (a+b-c)/scale * complex(resolution*1.0,0.0) ) + resolution +1;
    slice(index,1)++;
    index = ctoi( (a-b+c)/scale * complex(resolution*1.0,0.0) ) + resolution +1;
    slice(index,1)++;
}

int pdf::createConvolve(array<double>&slice,complex a,complex b)
{
    array<double> temp;
    int index[5],ii;
    temp.init(resolution*2+1,1);

    // again make sure that the array is initialised
    int i, j;
    for (i=1;i<=resolution*2+1;i++)
        temp(i,1)=0.0;

    // these are the new four deltas to be convolved with
    index[1] = ctoi( (a+b)/scale * complex(resolution*1.0,0.0) ) ;
    index[2] = ctoi( (a-b)/scale * complex(resolution*1.0,0.0) ) ;
    index[3] = ctoi( (a.minus()+b)/scale * complex(resolution*1.0,0.0) ) ;
    index[4] = ctoi( (a.minus()-b)/scale * complex(resolution*1.0,0.0) ) ;

    // scan thru the array
    for (i=1;i<=resolution*2-1;i++) {
        // check each of the possible deltas
        for (j=1;j<=4;j++) {
            // offset in the convolution result array
            ii = i+index[j];

            // are we still within the array?
            if ((ii>=1) && (ii<=resolution*2+1)) {
                // sum the initial array
                temp(i,1) = slice(ii,1) + temp(i,1);
            }
        }
    }

    for (i=1;i<=resolution*2+1;i++)
        slice(i,1) = temp(i,1);

    temp.free();
    
    return (abs(index[1]) + abs(index[2]) + abs(index[3]) + abs(index[4]));
}

void pdf::jitter(pdf &my, double * p)
{
    double t;

    scan = my.scan;
    ui   = my.ui;
    resolution = my.resolution;
    scale = my.scale;

    pdfs.init(scan,1);
    
    int j, r, tau;    
    for (j=1;j<=scan;j++) {
        pdfs(j,1).init(resolution*2+1,1);
        for (r=1;r<resolution*2+1;r++) {
            int k=1;
            pdfs(j,1)(r,1) = 0.0;
            for (tau=-ui;tau<=ui;tau++)
            {
                int i=j+tau;
                if ((i>=1) && (i<=scan)) {
                    t = my.pdfs(i,1)(r,1) * p[k - 1];
                    pdfs(j,1)(r,1) = t + pdfs(j,1)(r,1);
                }
                k++;
            }
        }
    }
}

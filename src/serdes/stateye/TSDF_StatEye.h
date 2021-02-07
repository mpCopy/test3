/* @(#)  $Header: /cvs/china/src/SERDES/stateye/TSDF_StatEye.pl,v 1.21 2012/08/29 05:52:48 feijiahu Exp $ */
#ifndef _TSDF_StatEye_h
#define _TSDF_StatEye_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/wireless-libs/sdfserdes/stateye/TSDF_StatEye.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2007 - 2017 Keysight Technologies, Inc
 */
#include "TSDFStar.h"
#include "StatEye.h"
#include "Contour.h"
#include "TargetTask.h"
#include "IntState.h"
#include "FloatState.h"
#include "StringState.h"
#include "FloatArrayState.h"
#include "CommonEnums.h"
#include "sdfstateyestarsDll.h"

       //! StatEye model
       /*! StatEye is statistical eye diagram.
       */
class TSDF_StatEye:public TSDFStar
{
public:
	TSDF_StatEye();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
	/* virtual */ ~TSDF_StatEye();
	InTSDFPort in;

protected:
	/* virtual */ void go();
	StringState _symbolName;
	IntState RIn;
	FloatState RTemp;
	FloatState BaudRate;
	IntState SampleNum;
	FloatState DJ;
	FloatState RJ;
	IntState PreCursors;
	IntState PostCursors;
	IntState BinNum;
	FloatState RequiredDJ;
	FloatState RequiredQ;
	FloatState RequiredTJ;
	FloatState RequiredEye;
	FloatState TargetBER;
	FloatArrayState BERDisplay;
	QueryState CDREnabled;
	QueryState DFEEnabled;
	IntState DFEtaps;
	StringState SaveDFETapsFile;
	QueryState FFEEnabled;
	IntState FFEtaps;
	QueryState FFEtapsOpt;
	StringState SaveFFETapsFile;
	void mtrxinv (int nRows, double * in, double * out);
	void FFE ();
	void Upsample ();
	void genJitGauss ();
	void CalcCdf (void);
	double erfinv (double y);
	void polyfit (double * ax, double * ay, int N, double * aa, double * bb);
	void ber2djrj (void);
	void measureeye (void);
	void displayeye (void);

private:
#line 287 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/wireless-libs/sdfserdes/stateye/TSDF_StatEye.pl"
int m_innum, m_num, cnt, SamplingRatio, ra, ftap, flag;
        double tstep, m_tstep, * m_dfetaps, TargetUpRatio;
        
        double m_cross_x, m_DJ, m_RJ, m_scale, m_eye;
        double * pg, ** rpt, ** cdf_abs;
        double * m_time_offset, * m_yaxis;
        double * m_sum_pdf, ** m_pdf_norm;
        double * cdf_Q, ** cdf_log;
        int num_rxaxis, num_ryaxis;
        complex * m_in, *m_in1;
            
        SimData * CDF, * Amp, * BER, * Contour, * eyeopen;
        SimData * Q, * Time_UI, * mask_x, * mask_y;
        SimData * _DJ, * _RJ, * CDR, * AftEqu, *FFEtapNum;
        SinkControl sinkControl;
	void resetPointers ();
	void deletepointers ();

};
#endif

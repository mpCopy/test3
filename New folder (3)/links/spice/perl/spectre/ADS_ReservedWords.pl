#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

@ADSReservedWords = qw
(  CostIndex DF_ZERO_OHMS DefaultValue DeviceIndex DF_DefaultInt DF_Value  
   Nsample PrintErrorMessage ScheduleCycle WarnTimeDomainDeembed __fdd __fdd_v   
   _ABM_Phase _ABM_SourceLevel _M _ac_state _bitwise_and _bitwise_asl _bitwise_asr
   _bitwise_not _bitwise_or _bitwise_xnor _bitwise_xor
   _c1 _c10 _c11 _c12 _c13 _c14 _c15 _c16 
   _c17 _c18 _c19 _c2 _c20 _c21 _c22 
   _c23 _c24 _c25 _c26 _c27 _c28 _c29 
   _c3 _c30 _c4 _c5 _c6 _c7 _c8 _c9 
   _dc_state _default _discrete_density _divn 
   _fc _freq1 _freq10 _freq11 _freq12 _freq2  
   _freq3 _freq4 _freq5 _freq6 _freq7 _freq8 _freq9 
   _gaussian _gaussian_tol _get_fnom_freq _get_fnom_freq 
   _get_fund_freq_for_fdd _get_fund_freq_for_fdd 
   _harm _hb_state _i1 _i10 _i11 _i12 _i13 
   _i14 _i15 _i16 _i17 _i18 _i19 _i2 _i20 
   _i21 _i22 _i23 _i24 _i25 _i26 _i27 _i28 
   _i29 _i3 _i30 _i4 _i5 _i6 _i7 _i8 _i9 
   _lfsr _mvgaussian _mvgaussian_cov _n_state _nfmin 
   _p2dInputPower _phase_freq _phase_freq _pwl_density 
   _pwl_distribution _randvar _rn _shift_reg _si 
   _si _si_bb _si_bb _si_d _si_d _si_e _si_e 
   _sigproc_state _sm_state _sopt _sp_state _sv 
   _sv _sv_bb _sv_bb _sv_d _sv_d _sv_e 
   _sv_e _tn _tn _to _to _tr_state _tt 
   _tt _uniform _uniform_tol _v1 _v10 _v11 
   _v12 _v13 _v14 _v15 _v16 _v17 _v18 _v19 
   _v2 _v20 _v21 _v22 _v23 _v24 _v25 
   _v26 _v27 _v28 _v29 _v3 _v30 _v4 _v5 
   _v6 _v7 _v8 _v9 _xcross abs access_all_data
   access_all_data_new access_data access_data_new 
   acos acosh amp_harm_coef 
   arcsinh arctan asin asinh atan atan2 atanh
   attenuator_warn awg_dia bin bitseq boltzmann c0 ceil
   check_indep_limits coef_count complex compute_mp_poly_coef compute_poly_coef  
   conj cos cos_pulse cosh cot coth cpx_gain_poly ctof ctok cxform 
   d_atan2 damped_sin db dbm dbmtoa dbmtov dbmtow 
   dbpolar dbwtow dcSourceLevel deembed deg delay 
   dep_data deriv doeindex doeIter dphase dsexpr 
   dstoarray e e0 echo embedded_ptolemy_exec ensure_ext erf_pulse 
   eval_miso_poly eval_poly exp exp_pulse fetch_envband floor fmod
   fread freq freq_mult_coef freq_mult_poly 
   ftoc ftok gaussian gcdata_to_poly generate_gmsk_iq_spectra 
   generate_gmsk_pulse_spectra generate_piqpsk_spectra 
   generate_pulse_train_spectra generate_qam16_spectra 
   generate_qpsk_pulse_spectra get_LSfreqs get_LSpowrs get_S2D_attribute get_array_size get_attribute 
   get_block get_fund_freq get_indep_limits get_max_points hpvar_to_vs hypot ground  hugereal 
   i icor ilsb imag impulse imt_hbdata_to_array imt_hpvar_to_array include_SSpower index innerprod inoise 
   int internal_generate_gmsk_iq_spectra 
   internal_generate_gmsk_pulse_spectra  
   internal_generate_piqpsk_spectra 
   internal_generate_pulse_train_spectra  
   internal_generate_qam16_spectra 
   internal_generate_qpsk_pulse_spectra  
   internal_get_fund_freq internal_window interp 
   interp1 interp2 interp3 interp4 iss issue_message_set_value itob iusb 
   j jn ktoc ktof length lfsr limit_warn LinearizedElementIndex list 
   ln ln10 log log10 logNodesetScale logRforce logRshunt log_amp 
   log_amp_cas lookup mag makearray max mcTrial 
   mcindex min miximt_coef miximt_poly mp_fetchS21 mp_poly_gain
   multi_freq multivar_access multivar_tree names nf nfmin 
   noise noisefreq norm omega optIter phase phase_noise_pwl
   phasedeg phaserad pi planck polar polarcpx portz pow
   pulse pwl pwlr pwlr_tr qelectron qinterp 
   rad ramp rawtoarray read_data read_lib read_SSpower readdata 
   readlib readraw real rect rem repeat ripple rms 
   rn rpsmooth scale scalearray sens sffm 
   sgn sin sinc sinh sopt sourceLevel spectrum sprintf 
   sqrt status_print ssfreq step strcat stypexform sym_set 
   system tan tanh temp tempkelvin thd time 
   timestep tinyreal toi tranorder transform u0 
   uniform v value version_check vlsb vnoise vss vswrpolar 
   vusb window wtodbm y z
);

@ADSIllegalSubcktNames = qw
(  aele AllParams Allparams allParams allparams 
   All_Params All_params all_Params all_params and
   by define delay discrete distcompname
   doe else elseif end endif
   equals file gauss global globalnode
   ground icor if inline j
   local lognormal model nested nfmin
   no nodoe noise noopt nostat
   not notequals opt or parameters
   pi portz ppt rn sopt
   stat static then to tune unconst
   uniform yes _M _VER _VEr
   _VeR _Ver _vER _vEr _veR
   _ver
);


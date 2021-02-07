1     7.703    0 0
10    11    "UWB_TX_test"    2    1197609371    0    5    341    0
90    "pt_timed_df"  1  1 0 `2`
90    "pt_timed"  1  1 0 `5`
90    "pt_numeric"  1  1 0 `2`
90    "pt_instruments"  1  1 0 `2`
90    "pt_fixpt-analysis"  1  1 0 `1`
90    "pt_edge"  1  1 0 `2`
90    "pt_vsa89600"  1  1 0 `3`
90    "pt_ael_mangling"  1  1 0 `1`
90    "pt_fix_pins"  1  1 0 `1`
90    "pt_msrvsimstars"  1  1 0 `1`
90    "pt_tdscdma"  1  1 0 `2`
90    "pt_wcdma3g"  1  1 0 `2`
90    "pt_wlan"  1  1 0 `1`
20    0    ""    -3375 -4181 7875 2708 1    2 -3 1    1197604778    0    "mil_schematic.prf" "schematic.lay"
30    183344072    1    ""    1    2    0    183236616    198553296    183234448    0    1875 1250 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    183236616    1    ""    2    2    0    0    198553296    195293120    0    2875 1250 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    183236448    1    "Meas_in"    2    0    183236616    183231912    187564040    195293120    0    3250 0 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    183231912    1    "RF_out"    1    1    183344072    0    187564040    183234448    0    1750 0 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    184525528    1    183231912    1    183344072    0    0    0    ""  0
60    3    0    3    1750 0 1875 1250 1    0    0    0    0
70    1750 0    1875 1250
32    184525624    1    183236448    1    183236616    0    0    0    ""  0
60    3    0    3    2875 0 3250 1250 1    0    0    0    0
70    3250 0    2875 1250
40    4    0    0    0
50    4    1750 0 1875 1250 1    0    0    0    0    0    0    0    0    184525528
50    4    2875 0 3250 1250 1    0    0    0    0    0    0    0    0    184525624
50    1    4625 -3875 7875 1750 1    0    0    0    0    0    0    0    0
60    2    0    4    4625 -3875 7875 1750 1    0    0    0    0
70    4625 -3875    7875 1750    4625 0
40    10    0    0    0
50    6    0 1166 1934 1667 1    0    0    0    0    0    0    0    0
62    0    167    9    0 1500 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this "Amplifier2"
DUT with your own
CIRCUIT design.`
50    6    -2000 2375 3923 2708 1    0    0    0    0    0    0    0    0
62    0    333    9    -2000 2375 0    1    0    0    0    24    0   "Arial For CAE Bold"   `                UWB Transmitter Test Bench`
50    6    4750 -3823 7734 1598 1    0    0    0    0    0    0    0    0
62    0    139    9    4750 1459 0    39    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. Enable AVM in "Cosim" setup if fast cosim
    with circuits is desired;

4. CE_TimeStep must be set to equal to or
    less then1/528e6/2^OversamplingOption.
    OversamplingOption is a UWB_TX Signal
    Parameter.


Notes for Sweep and Optimization:

    The SimInstanceName must always use
    "WTB1" for sweep or optimization controller
    regardless of the Envelope controller's
    instance name.

Notes for the BandGroup
     BandgGroup is indexed from 0, which 
     represents BandGroup 1 in the WiMedia 
     specification.

Limitations for using wireless test benches:

1. Envelope "Oscillator Analysis" setup is NOT
    supported;

2. Envelope simulation with wireless test bench
    does NOT save the named nodes data in
    the dataset.`
40    12    0    0    0
50    1    -125 250 3375 1750 1    0    0    0    0    0    0    3    0
60    2    0    4    -125 250 3375 1750 1    0    0    0    0
70    -125 250    3375 1750    -125 0
41    23895424    0    1073741840    "U1"    "UWB_TX_Info"    "SYM_DSN_UWB_TX_Info"    -3375 292 -713 1666 1    0 "" 0
    0    0    5    -3375 750 0 1 1 0 0    0    96    0    0    1110505934    17  ""    -3375 750 -713 1666 1    -3166 292 -2116 667 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 1259 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_TX_Info`
40    7    0    0    0
50    6    209 -458 422 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `U1`
41    197849568    0    0    "WTB"    "Envelope"    "SYM_ENV"    -3250 -2134 -1261 -376 1    0 "" 0
    0    0    4    -3250 -375 0 1 1 0 0    0    104    0    0    1197604740    17  ""    -3250 -844 -1300 -376 1    -3041 -2134 -1261 -927 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 918 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 571 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `WTB`
40    8    0    0    0
50    6    209 -1759 1155 -1592 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1759 0    1    3    0    4    12    0   "Arial For CAE"   `ABM_Mode=`
50    6    209 -1551 1725 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1016 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=3`
50    6    209 -1135 1989 -968 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1135 0    1    3    0    1    12    0   "Arial For CAE"   `Freq[1]=FMeasurement`
80    5    "MaxOrder"    "StdForm"    0    0    "4"    1   0
80    3    "Freq"    "list"    0    1    ""    0   0
80    5    "Freq"    "StdForm"    0    0    "FMeasurement"    0   0
80    3    "Order"    "list"    0    1    ""    0   0
80    5    "Order"    "StdForm"    0    0    "3"    0   0
80    5    "StatusLevel"    "StdForm"    0    0    "1"    1   0
80    5    "FundOversample"    "StdForm"    0    0    "2"    1   0
80    3    "Oversample"    "list"    0    1    ""    1   0
80    5    "Oversample"    "StdForm"    0    0    ""    1   0
80    5    "PackFFT"    "StdForm"    0    0    ""    1   0
80    5    "MaxIters"    "StdForm"    0    0    "10"    1   0
80    5    "GuardThresh"    "StdForm"    0    0    ""    1   0
80    5    "SamanskiiConstant"    "StdForm"    0    0    "2"    1   0
80    6    "Restart"    "No"    0    0    ""    1   0
80    5    "ArcLevelMaxStep"    "StdForm"    0    0    "0.0"    1   0
80    5    "MaxStepRatio"    "StdForm"    0    0    "100"    1   0
80    5    "MaxShrinkage"    "StdForm"    0    0    "1.0e-5"    1   0
80    5    "OutputAllSolns"    "StdForm"    0    0    ""    1   0
80    5    "ArcMaxStep"    "StdForm"    0    0    "0.0"    1   0
80    5    "ArcMinValue"    "StdForm"    0    0    ""    1   0
80    5    "ArcMaxValue"    "StdForm"    0    0    ""    1   0
80    5    "UseGear"    "StdForm"    0    0    ""    1   0
80    5    "EnvIntegOrder"    "StdForm"    0    0    "1"    1   0
80    5    "SweepOffset"    "StdForm"    0    0    ""    1   0
80    5    "EnvNoise"    "StdForm"    0    0    ""    1   0
80    5    "EnvBandwidth"    "StdForm"    0    0    "1"    1   0
80    5    "EnvRelTrunc"    "StdForm"    0    0    ""    1   0
80    5    "EnvAbsTrunc"    "StdForm"    0    0    ""    1   0
80    6    "EnvWarnPoorFit"    "Yes"    0    0    ""    1   0
80    6    "EnvUsePoorFit"    "Yes"    0    0    ""    1   0
80    5    "EnvSkipDC_Fit"    "StdForm"    0    0    ""    1   0
80    5    "ResetOsc"    "StdForm"    0    0    ""    1   0
80    5    "OscMode"    "StdForm"    0    0    ""    1   0
80    5    "OscPortName"    "StringAndReference"    0    0    ""    1   0
80    5    "IgnoreOscErrors"    "StdForm"    0    0    ""    1   0
80    5    "SweepVar"    "StdForm"    0    0    ""time""    1   0
80    5    "UseSweepPlan"    "StdForm"    0    0    ""    1   0
80    5    "SweepPlan"    "StdForm"    0    0    ""    1   0
80    5    "Start"    "StdForm"    0    0    "0 nsec"    1   0
80    5    "Stop"    "StdForm"    0    0    "100 nsec"    1   0
80    5    "Step"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "Center"    "StdForm"    0    0    ""    1   0
80    5    "Span"    "StdForm"    0    0    ""    1   0
80    5    "Lin"    "StdForm"    0    0    ""    1   0
80    5    "Dec"    "StdForm"    0    0    ""    1   0
80    5    "Log"    "StdForm"    0    0    ""    1   0
80    5    "Reverse"    "StdForm"    0    0    ""    1   0
80    5    "Pt"    "StdForm"    0    0    ""    1   0
80    5    "Sort"    "StdForm"    0    0    "LINEAR START STEP"    1   0
80    3    "OutputPlan"    "list"    0    1    ""    1   0
80    5    "OutputPlan"    "StdForm"    0    0    ""    1   0
80    6    "UseNodeNestLevel"    "OutputPlan_BooleanYes"    0    0    ""    1   0
80    5    "NodeNestLevel"    "SingleTextLineInteger"    0    0    "2"    1   0
80    3    "NodeName"    "list"    0    1    ""    1   0
80    5    "NodeName"    "StringAndReference"    0    0    ""    1   0
80    6    "UseEquationNestLevel"    "OutputPlan_BooleanYes"    0    0    ""    1   0
80    5    "EquationNestLevel"    "SingleTextLineInteger"    0    0    "2"    1   0
80    3    "EquationName"    "list"    0    1    ""    1   0
80    5    "EquationName"    "StringAndReference"    0    0    ""    1   0
80    5    "SS_MixerMode"    "StdForm"    0    0    ""    1   0
80    5    "SS_UseSweepPlan"    "StdForm"    0    0    ""    1   0
80    5    "SS_Plan"    "StdForm"    0    0    ""    1   0
80    5    "SS_Start"    "StdForm"    0    0    "1.0 GHz"    1   0
80    5    "SS_Stop"    "StdForm"    0    0    "10.0 GHz"    1   0
80    5    "SS_Step"    "StdForm"    0    0    "1.0 GHz"    1   0
80    5    "SS_Center"    "StdForm"    0    0    ""    1   0
80    5    "SS_Span"    "StdForm"    0    0    ""    1   0
80    5    "SS_Lin"    "StdForm"    0    0    ""    1   0
80    5    "SS_Dec"    "StdForm"    0    0    ""    1   0
80    5    "SS_Log"    "StdForm"    0    0    ""    1   0
80    5    "SS_Reverse"    "StdForm"    0    0    ""    1   0
80    5    "SS_Pt"    "StdForm"    0    0    ""    1   0
80    5    "SS_Sort"    "StdForm"    0    0    "LINEAR START STEP"    1   0
80    5    "SS_Freq"    "StdForm"    0    0    ""    1   0
80    5    "SS_Thresh"    "StdForm"    0    0    ""    1   0
80    5    "UseAllSS_Freqs"    "StdForm"    0    0    "yes"    1   0
80    5    "MergeSS_Freqs"    "StdForm"    0    0    ""    1   0
80    5    "InputFreq"    "StdForm"    0    0    "1 Hz"    1   0
80    5    "NLNoiseMode"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseUseSweepPlan"    "StdForm"    0    0    ""    1   0
80    5    "NoiseFreqPlan"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseStart"    "StdForm"    0    0    "1.0 GHz"    1   0
80    5    "NLNoiseStop"    "StdForm"    0    0    "10.0 GHz"    1   0
80    5    "NLNoiseStep"    "StdForm"    0    0    "1.0 GHz"    1   0
80    5    "NLNoiseCenter"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseSpan"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseLin"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseDec"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseLog"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseReverse"    "StdForm"    0    0    ""    1   0
80    5    "NLNoisePt"    "StdForm"    0    0    ""    1   0
80    5    "NLNoiseSort"    "StdForm"    0    0    "LINEAR START STEP"    1   0
80    5    "FreqForNoise"    "StdForm"    0    0    ""    1   0
80    5    "NoiseInputPort"    "StdForm"    0    0    "1"    1   0
80    5    "NoiseOutputPort"    "StdForm"    0    0    "2"    1   0
80    6    "PhaseNoise"    "No"    0    0    ""    1   0
80    5    "FM_Noise"    "StdForm"    0    0    ""    1   0
80    3    "NoiseNode"    "list"    0    1    ""    1   0
80    5    "NoiseNode"    "StdForm"    0    0    ""    1   0
80    6    "SortNoise"    "NoiseSortOff"    0    0    ""    1   0
80    5    "NoiseThresh"    "StdForm"    0    0    ""    1   0
80    5    "IncludePortNoise"    "StdForm"    0    0    ""    1   0
80    5    "NoisyTwoPort"    "StdForm"    0    0    ""    1   0
80    5    "BandwidthForNoise"    "StdForm"    0    0    "1.0 Hz"    1   0
80    6    "DevOpPtLevel"    "DeviceOpNone"    0    0    ""    1   0
80    5    "InFile"    "StringAndReference"    0    0    " "    1   0
80    5    "UseInFile"    "StdForm"    0    0    "no"    1   0
80    5    "OutFile"    "StringAndReference"    0    0    " "    1   0
80    5    "UseOutFile"    "StdForm"    0    0    "no"    1   0
80    6    "UseKrylov"    "UseDirectSolver"    0    0    ""    1   0
80    5    "UseInitialAWHB"    "StdForm"    0    0    ""    1   0
80    5    "AWHB_WindowSize"    "StdForm"    0    0    ""    1   0
80    5    "GMRES_Restart"    "StdForm"    0    0    ""    1   0
80    5    "KrylovUsePacking"    "StdForm"    0    0    ""    1   0
80    5    "KrylovPackingThresh"    "StdForm"    0    0    ""    1   0
80    5    "KrylovTightTol"    "StdForm"    0    0    ""    1   0
80    5    "KrylovLooseTol"    "StdForm"    0    0    ""    1   0
80    5    "KrylovLooseIters"    "StdForm"    0    0    ""    1   0
80    5    "KrylovMaxIters"    "StdForm"    0    0    ""    1   0
80    5    "AvailableRAMsize"    "StdForm"    0    0    ""    1   0
80    5    "KrylovSS_Tol"    "StdForm"    0    0    ""    1   0
80    5    "KrylovUseGMRES_Float"    "StdForm"    0    0    ""    1   0
80    5    "RecalculateWaveforms"    "StdForm"    0    0    ""    1   0
80    5    "UseCompactFreqMap"    "StdForm"    0    0    ""    1   0
80    6    "KrylovPrec"    "HBKrylovPrecDCP"    0    0    ""    1   0
80    6    "ConvMode"    "HBConvModeADS15"    0    0    ""    1   0
80    5    "ABM_Mode"    "StdForm"    0    0    ""    0   0
80    5    "ABM_MaxPower"    "StdForm"    0    0    "20"    1   0
80    5    "ABM_AmpPts"    "StdForm"    0    0    "21"    1   0
80    5    "ABM_PhasePts"    "StdForm"    0    0    "0"    1   0
80    5    "ABM_FreqPts"    "StdForm"    0    0    "16"    1   0
80    5    "ABM_VTime"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "ABM_VTol"    "StdForm"    0    0    "1e-3"    1   0
80    5    "ABM_ReUseData"    "StdForm"    0    0    ""    1   0
80    5    "ABM_Delay"    "StdForm"    0    0    "0.0 sec"    1   0
80    6    "ABM_FreqComp"    "EnvABM0"    0    0    ""    1   0
80    5    "ABM_ActiveInputNode"    "filename"    0    0    ""    1   0
80    3    "ABM_IQ_Nodes"    "list"    0    1    ""    1   0
80    5    "ABM_IQ_Nodes"    "filename"    0    0    ""    1   0
80    5    "Other"    "OtherForm"    0    0    ""    1   0
80    6    "UseSavedEquationNestLevel"    "OutputPlan_BooleanYes"    0    0    ""    1   0
80    5    "SavedEquationNestLevel"    "SingleTextLineInteger"    0    0    "2"    1   0
80    3    "SavedEquationName"    "list"    0    1    ""    1   0
80    5    "SavedEquationName"    "StringAndReference"    0    0    ""    1   0
80    3    "AttachedEquationName"    "list"    0    1    ""    1   0
80    5    "AttachedEquationName"    "StringAndReference"    0    0    ""    1   0
80    5    "OscUseNodes"    "StdForm"    0    0    ""    1   0
80    5    "OscNodePlus"    "StringAndReference"    0    0    ""    1   0
80    5    "OscNodeMinus"    "StringAndReference"    0    0    ""    1   0
80    5    "OscFundIndex"    "StdForm"    0    0    "1"    1   0
80    5    "OscHarm"    "StdForm"    0    0    "1"    1   0
80    5    "OscNumOctaves"    "StdForm"    0    0    "2.0"    1   0
80    5    "OscSteps"    "StdForm"    0    0    "20.0"    1   0
80    6    "TAHB_Enable"    "TAHBModeAuto"    0    0    ""    1   0
80    5    "StopTime"    "StdForm"    0    0    ""    1   0
80    5    "MaxTimeStep"    "StdForm"    0    0    ""    1   0
80    5    "IV_RelTol"    "StdForm"    0    0    ""    1   0
80    5    "AddtlTranParamsTAHB"    "TAHBOtherForm"    0    0    ""    1   0
80    5    "OneToneTranTAHB"    "StdForm"    0    0    "yes"    1   0
80    5    "OutputTranDataTAHB"    "StdForm"    0    0    ""    1   0
80    3    "Noisecon"    "list"    0    1    ""    1   0
80    5    "Noisecon"    "StdForm"    0    0    ""    1   0
80    5    "NoiseConMode"    "StdForm"    0    0    ""    1   0
80    6    "HBAHB_Enable"    "HBAHBModeAuto"    0    0    ""    1   0
80    6    "MaxItersRobust"    "Yes"    0    0    ""    1   0
80    6    "MaxItersFast"    "No"    0    0    ""    1   0
80    5    "MaxItersCustom"    "StdForm"    0    0    ""    1   0
80    6    "SamanskiiConstantFast"    "Yes"    0    0    ""    1   0
80    6    "SamanskiiConstantRobust"    "No"    0    0    ""    1   0
80    5    "SamanskiiConstantCustom"    "StdForm"    0    0    ""    1   0
80    6    "GMRES_RestartRobust"    "Yes"    0    0    ""    1   0
80    6    "GMRES_RestartLowMemory"    "No"    0    0    ""    1   0
80    5    "GMRES_RestartCustom"    "StdForm"    0    0    ""    1   0
80    6    "GuardThreshFast"    "Yes"    0    0    ""    1   0
80    6    "GuardThreshRobust"    "No"    0    0    ""    1   0
80    5    "GuardThreshCustom"    "StdForm"    0    0    ""    1   0
80    5    "SteadyStateMinTime"    "StdForm"    0    0    ""    1   0
41    198553296    0    1073741824    "DUT"    "Amplifier2"    "SYM_Amplifier"    1709 417 2875 1625 1    0 "" 0
    183344072    0    3    1875 1250 0 1 1 0 0    0    105    0    0    1081471418    17  ""    1875 875 2875 1625 1    1709 417 2486 792 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -166 -625 611 -458 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -625 0    1    1    0    0    12    0   "Arial For CAE"   `Amplifier2`
40    7    0    0    0
50    6    -166 -833 187 -666 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -833 0    1    2    0    0    12    0   "Arial For CAE"   `DUT`
40    8    0    0    0
80    5    "S21"    "StdForm"    0    0    "dbpolar(0,0)"    1   0
80    5    "S11"    "StdForm"    0    0    "polar(0,0)"    1   0
80    5    "S22"    "StdForm"    0    0    "polar(0,180)"    1   0
80    5    "S12"    "StdForm"    0    0    "0"    1   0
80    5    "NF"    "StdForm"    0    0    ""    1   0
80    5    "NFmin"    "StdForm"    0    0    ""    1   0
80    5    "Sopt"    "StdForm"    0    0    ""    1   0
80    5    "Rn"    "StdForm"    0    0    ""    1   0
80    5    "Z1"    "StdForm"    0    0    ""    1   0
80    5    "Z2"    "StdForm"    0    0    ""    1   0
80    6    "GainCompType"    "SML_LIST"    0    0    ""    1   0
80    5    "GainCompFreq"    "StdForm"    0    0    ""    1   0
80    6    "ReferToInput"    "OUTPUT"    0    0    ""    1   0
80    5    "SOI"    "StdForm"    0    0    ""    1   0
80    5    "TOI"    "StdForm"    0    0    ""    1   0
80    5    "Psat"    "StdForm"    0    0    ""    1   0
80    5    "GainCompSat"    "StdForm"    0    0    "5.0 dB"    1   0
80    5    "GainCompPower"    "StdForm"    0    0    ""    1   0
80    5    "GainComp"    "StdForm"    0    0    "1.0 dB"    1   0
80    5    "AM2PM"    "StdForm"    0    0    ""    1   0
80    5    "PAM2PM"    "StdForm"    0    0    ""    1   0
80    5    "GainCompFile"    "s2d"    0    0    ""    1   0
80    6    "ClipDataFile"    "y_n1"    0    0    ""    1   0
80    5    "ImpNoncausalLength"    "StdForm"    0    0    ""    1   0
80    5    "ImpMode"    "StdForm"    0    0    ""    1   0
80    5    "ImpMaxFreq"    "StdForm"    0    0    ""    1   0
80    5    "ImpDeltaFreq"    "StdForm"    0    0    ""    1   0
80    5    "ImpMaxOrder"    "StdForm"    0    0    ""    1   0
80    5    "ImpWindow"    "StdForm"    0    0    ""    1   0
80    5    "ImpRelTol"    "StdForm"    0    0    ""    1   0
80    5    "ImpAbsTol"    "StdForm"    0    0    ""    1   0
41    184704200    0    1082130434    "VAR1"    "VAR"    "SYM_VAR"    -3046 -4181 2759 -2766 1    0 "" 0
    0    0    2    -2875 -2875 90000 1 1 0 0    0    104    0    0    1159344915    17  ""    -3046 -2981 -2721 -2766 1    -2638 -4181 2759 -2766 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 546 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 640 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `VAR1`
40    8    0    0    0
50    6    237 -1306 2210 -1139 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1306 0    1    3    0    5    12    0   "Arial For CAE"   `Fc=FcTable[BandGroup+1]`
50    6    237 -1098 1271 -931 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1098 0    1    3    0    4    12    0   "Arial For CAE"   `BandGroup=0`
50    6    237 -890 5634 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FcTable={3960 MHz,5544 MHz,7128 MHz,8712 MHz,10296MHz,8184 MHz}`
50    6    237 -682 1620 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `FMeasurement=Fc`
50    6    237 -474 2264 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=1/528 MHz/4`
80    3    "Variable Value"    "list"    0    5    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/528 MHz/4"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "Fc"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FcTable"    0   0
80    5    ""    "VarValueForm"    0    0    "{3960 MHz,5544 MHz,7128 MHz,8712 MHz,10296MHz,8184 MHz}"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "BandGroup"    0   0
80    5    ""    "VarValueForm"    0    0    "0"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "Fc"    0   0
80    5    ""    "VarValueForm"    0    0    "FcTable[BandGroup+1]"    0   0
41    187564040    0    1073741848    "UWB_TX"    "UWB_TX"    "SYM_DSN_UWB_TX"    1543 -3248 4171 5 1    0 "" 0
    183236448    0    1    1750 0 0 1 1 0 0    0    105    0    0    1159359627    17  ""    1543 -1126 3543 5 1    1752 -3248 4171 -1209 1    0 0 0 0 0 0
40    6    0    0    0
50    6    2 -1376 693 -1209 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -1376 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_TX`
40    7    0    0    0
50    6    2 -1584 693 -1417 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -1584 0    1    2    0    0    12    0   "Arial For CAE"   `UWB_TX`
40    8    0    0    0
50    6    2 -3248 1889 -3081 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -3248 0    1    3    0    8    12    0   "Arial For CAE"   `EVM_Measurement=NO`
50    6    2 -3040 2155 -2873 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -3040 0    1    3    0    7    12    0   "Arial For CAE"   `SpectrumMeasurement=NO`
50    6    2 -2832 1995 -2665 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -2832 0    1    3    0    6    12    0   "Arial For CAE"   `PowerMeasurement=YES`
50    6    2 -2624 1357 -2457 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -2624 0    1    3    0    5    12    0   "Arial For CAE"   `Constellation=NO`
50    6    2 -2416 2421 -2249 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -2416 0    1    3    0    4    12    0   "Arial For CAE"   `RF_EnvelopeMeasurement=NO`
50    6    2 -2208 2421 -2041 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -2208 0    1    3    0    3    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    2 -2000 2128 -1833 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -2000 0    1    3    0    2    12    0   "Arial For CAE"   `SourcePower=dbmtow(-9.9)`
50    6    2 -1792 2234 -1625 1    0    0    0    0    0    0    0    0
62    0    167    9    2 -1792 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(-9.9)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "MeasurementInfo"    "StringAndReference"    0    0    """"    1   0
80    6    "RF_EnvelopeMeasurement"    "_nUWB_x5fTX_fNO"    0    0    ""    0   0
80    6    "Constellation"    "_nUWB_x5fTX_fNO"    0    0    ""    0   0
80    6    "PowerMeasurement"    "_nUWB_x5fTX_fYES"    0    0    ""    0   0
80    6    "SpectrumMeasurement"    "_nUWB_x5fTX_fNO"    0    0    ""    0   0
80    6    "EVM_Measurement"    "_nUWB_x5fTX_fNO"    0    0    ""    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SourceTemp"    "StdForm"    0    0    "-273.15"    1   0
80    6    "EnableSourceNoise"    "_nUWB_x5fTX_fNO"    0    0    ""    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "TestBenchSeed"    "StdForm"    0    0    "1234567"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "GainImbalance"    "StdForm"    0    0    "0.0 dB"    1   0
80    5    "PhaseImbalance"    "StdForm"    0    0    "0.0"    1   0
80    6    "OversamplingOption"    "_nUWB_x5fTX_fRatio_x5f4"    0    0    ""    1   0
80    6    "DataPattern"    "_nUWB_x5fTX_fPN9"    0    0    ""    1   0
80    5    "BandGroup"    "StdForm"    0    0    "BandGroup"    1   0
80    6    "DataRate"    "_nUWB_x5fTX_f_x5f53_x5f3_x5fMbps"    0    0    ""    1   0
80    5    "DataLength"    "StdForm"    0    0    "100"    1   0
80    6    "PreambleFormat"    "_nUWB_x5fTX_fStandard_x5fFormat"    0    0    ""    1   0
80    6    "TFC_Number"    "_nUWB_x5fTX_fTFC1"    0    0    ""    1   0
80    6    "ScramblerSeed"    "_nUWB_x5fTX_fSeed_x5f00"    0    0    ""    1   0
80    5    "RF_EnvelopeMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "RF_EnvelopeDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "RF_EnvelopeStart"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "RF_EnvelopeStop"    "StdForm"    0    0    "0.5 msec"    1   0
80    5    "RF_EnvelopeSymbols"    "StdForm"    0    0    "96"    1   0
80    5    "ConstellationParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "ConstellationDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "ConstellationFrames"    "StdForm"    0    0    "1"    1   0
80    5    "PowerMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "PowerDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "PowerSymbolsMeasured"    "StdForm"    0    0    "69"    1   0
80    5    "PowerOutputPoint"    "StdForm"    0    0    "500"    1   0
80    5    "SpectrumMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SpecMeasDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "SpecMeasStart"    "StdForm"    0    0    "(42*312.5) nsec"    1   0
80    5    "SpecMeasStop"    "StdForm"    0    0    "(42+12)*312.5"    1   0
80    5    "SpecMeasSymbols"    "StdForm"    0    0    "3"    1   0
80    5    "SpecMeasResBW"    "StdForm"    0    0    "0 Hz"    1   0
80    6    "SpecMeasWindow"    "_nUWB_x5fTX_fnone"    0    0    ""    1   0
80    5    "EVM_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "EVM_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "EVM_Delay"    "StdForm"    0    0    "1 nsec"    1   0
80    5    "EVM_StartFrame"    "StdForm"    0    0    "2"    1   0
80    5    "EVM_FramesToAverage"    "StdForm"    0    0    "3"    1   0
43    195293120    0    ""    183236448    6    ""   0
43    183234448    0    ""    183231912    5    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
44    0    0    0    0    0    0    0
21

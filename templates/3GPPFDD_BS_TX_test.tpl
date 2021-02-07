1     7.701    0 0
10    1    "3GPPFDD_BS_TX_test"    2    1087859723    0    19    1    0
20    0    ""    0 -4622 10500 1958 1    2 -3 1    1087859720    0    "mil_schematic.prf" "schematic.lay"
30    123934976    1    "Meas_in"    2    0    132594288    123935112    111765792    101126832    0    6250 -750 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    123935112    1    "RF_out"    1    1    132594424    0    111765792    101126788    0    4750 -750 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    132594424    1    ""    1    2    0    132594288    111778792    101126788    0    5000 500 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    132594288    1    ""    2    2    0    0    111778792    101126832    0    6000 500 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    111765200    1    123934976    1    132594288    0    0    0    ""  0
60    3    0    3    6000 -750 6250 500 1    0    0    0    0
70    6250 -750    6000 500
32    111775648    1    123935112    1    132594424    0    0    0    ""  0
60    3    0    3    4750 -750 5000 500 1    0    0    0    0
70    4750 -750    5000 500
40    4    0    0    0
50    1    7250 -4250 10500 1000 1    0    0    0    0    0    0    0    0
60    2    0    4    7250 -4250 10500 1000 1    0    0    0    0
70    7250 -4250    10500 1000    7250 0
50    4    6000 -750 6250 500 1    0    0    0    0    0    0    0    0    111765200
50    4    4750 -750 5000 500 1    0    0    0    0    0    0    0    0    111775648
40    10    0    0    0
50    6    1250 1625 8698 1958 1    0    0    0    0    0    0    0    0
62    0    333    9    1250 1625 0    1    0    0    0    24    0   "Arial For CAE Bold"   `3GPP FDD Base Station Transmitter Test Bench`
50    6    7375 -4017 10257 848 1    0    0    0    0    0    0    0    0
62    0    139    9    7375 709 0    35    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. Enable AVM in "Cosim" setup if fast cosim
    with circuits is desired;

4. CE_TimeStep must be set to equal to or
    less then1/3.84e6/SamplesPerChip.
    SamplesPerChip is a 3GPPFDD_BS_TX
    Signal Parameter.


Notes for Sweep and Optimization:

    The SimInstanceName must always use
    "WTB1" for sweep or optimization controller
    regardless of the Envelope controller's
    instance name.


Limitations for using wireless test benches:

1. Envelope "Oscillator Analysis" setup is NOT
    supported;

2. Envelope simulation with wireless test bench
    does NOT save the named nodes data in
    the dataset.`
50    6    3125 416 5043 917 1    0    0    0    0    0    0    0    0
62    0    167    9    3125 750 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this "Amplifier2"
DUT with your own
CIRCUIT design.`
40    12    0    0    0
50    1    3000 -500 6500 1000 1    0    0    0    0    0    0    3    0
60    2    0    4    3000 -500 6500 1000 1    0    0    0    0
70    3000 -500    6500 1000    3000 0
41    135154128    0    0    "WTB"    "Envelope"    "SYM_ENV"    0 -2634 1950 -876 1    0 "" 0
    0    0    1    0 -875 0 1 1 0 0    0    104    0    0    1087859045    17  ""    0 -1344 1950 -876 1    209 -2634 1623 -1427 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 861 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 575 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `WTB`
40    8    0    0    0
50    6    209 -1759 1138 -1592 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1759 0    1    3    0    4    12    0   "Arial For CAE"   `ABM_Mode=`
50    6    209 -1551 1623 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1000 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=3`
50    6    209 -1135 1455 -968 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1135 0    1    3    0    1    12    0   "Arial For CAE"   `Freq[1]=FSource`
80    5    "MaxOrder"    "StdForm"    0    0    "4"    1   0
80    3    "Freq"    "list"    0    1    ""    0   0
80    5    "Freq"    "StdForm"    0    0    "FSource"    0   0
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
80    5    "ABM_ActiveInputNode"    "filename"    0    0    " "    1   0
80    3    "ABM_IQ_Nodes"    "list"    0    1    ""    1   0
80    5    "ABM_IQ_Nodes"    "filename"    0    0    " "    1   0
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
80    5    "OscHarmNum"    "StdForm"    0    0    "1"    1   0
80    5    "OscOctSrch"    "StdForm"    0    0    "2.0"    1   0
80    5    "OscOctStep"    "StdForm"    0    0    "20.0"    1   0
80    5    "TAHB_Enable"    "StdForm"    0    0    ""    1   0
80    5    "StopTime"    "StdForm"    0    0    ""    1   0
80    5    "MaxTimeStep"    "StdForm"    0    0    ""    1   0
80    5    "IV_RelTol"    "StdForm"    0    0    ""    1   0
80    5    "AddtlTranParamsTAHB"    "StdForm"    0    0    ""    1   0
80    5    "OneToneTranTAHB"    "StdForm"    0    0    "yes"    1   0
80    5    "OutputTranDataTAHB"    "StdForm"    0    0    ""    1   0
41    111765288    0    1082130434    "VAR1"    "VAR"    "SYM_VAR"    79 -4015 2641 -3016 1    0 "" 0
    0    0    3    250 -3125 90000 1 1 0 0    0    104    0    0    1081470349    17  ""    79 -3231 404 -3016 1    487 -4015 2641 -3016 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 590 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 687 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `VAR1`
40    8    0    0    0
50    6    237 -890 2215 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FMeasurement=2140 MHz`
50    6    237 -682 1738 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=2140 MHz`
50    6    237 -474 2391 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=1/3.84 MHz/8`
80    3    "Variable Value"    "list"    0    3    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/3.84 MHz/8"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FSource"    0   0
80    5    ""    "VarValueForm"    0    0    "2140 MHz"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "2140 MHz"    0   0
41    111765792    0    1073741848    "3GPPFDD_BS_TX"    "3GPPFDD_BS_TX"    "SYM_DSN_3GPPFDD_BS_TX"    4459 -4622 6943 -750 1    0 "" 0
    123934976    0    17    4750 -750 0 1 1 0 0    0    105    0    0    1081470856    17  ""    4500 -1876 6501 -750 1    4459 -4622 6943 -1959 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -291 -1376 1168 -1209 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -1376 0    1    1    0    0    12    0   "Arial For CAE"   `3GPPFDD_BS_TX`
40    7    0    0    0
50    6    -291 -1584 1168 -1417 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -1584 0    1    2    0    0    12    0   "Arial For CAE"   `3GPPFDD_BS_TX`
40    8    0    0    0
50    6    -291 -3872 1530 -3705 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -3872 0    1    3    0    11    12    0   "Arial For CAE"   `EVM_Measurement=NO`
50    6    -291 -3664 1645 -3497 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -3664 0    1    3    0    10    12    0   "Arial For CAE"   `PCDE_Measurement=NO`
50    6    -291 -3456 1530 -3289 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -3456 0    1    3    0    9    12    0   "Arial For CAE"   `CDP_Measurement=NO`
50    6    -291 -3248 2176 -3081 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -3248 0    1    3    0    8    12    0   "Arial For CAE"   `OccupiedBW_Measurement=NO`
50    6    -291 -3040 1628 -2873 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -3040 0    1    3    0    7    12    0   "Arial For CAE"   `ACLR_Measurement=NO`
50    6    -291 -2832 1548 -2665 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -2832 0    1    3    0    6    12    0   "Arial For CAE"   `PowerMeasurement=NO`
50    6    -291 -2624 2193 -2457 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -2624 0    1    3    0    5    12    0   "Arial For CAE"   `RF_EnvelopeMeasurement=YES`
50    6    -291 -2416 2052 -2249 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -2416 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -291 -2208 1911 -2041 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -2208 0    1    3    0    3    12    0   "Arial For CAE"   `SourcePower=dbmtow(-20.0)`
50    6    -291 -2000 1097 -1833 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -2000 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=FSource`
50    6    -291 -1792 1946 -1625 1    0    0    0    0    0    0    0    0
62    0    167    9    -291 -1792 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "FSource"    "StdForm"    0    0    "FSource"    0   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(-20.0)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "MeasurementInfo"    "StringAndReference"    0    0    """"    1   0
80    6    "RF_EnvelopeMeasurement"    "_n3GPPFDD_x5fBS_x5fTX_fYES"    0    0    ""    0   0
80    6    "PowerMeasurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    6    "ACLR_Measurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    6    "OccupiedBW_Measurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    6    "CDP_Measurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    6    "PCDE_Measurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    6    "EVM_Measurement"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SourceTemp"    "StdForm"    0    0    "-273.15"    1   0
80    6    "EnableSourceNoise"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    6    "MirrorSourceSpectrum"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    6    "MirrorMeasSpectrum"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    6    "RF_MirrorFreq"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    6    "MeasMirrorFreq"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    5    "DUT_DelayBound"    "StdForm"    0    0    "10.0 usec"    1   0
80    5    "TestBenchSeed"    "StdForm"    0    0    "1234567"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "GainImbalance"    "StdForm"    0    0    "0.0 dB"    1   0
80    5    "PhaseImbalance"    "StdForm"    0    0    "0.0"    1   0
80    5    "I_OriginOffset"    "StdForm"    0    0    "0.0"    1   0
80    5    "Q_OriginOffset"    "StdForm"    0    0    "0.0"    1   0
80    5    "IQ_Rotation"    "StdForm"    0    0    "0.0"    1   0
80    5    "SamplesPerChip"    "StdForm"    0    0    "8"    1   0
80    5    "RRC_FilterLength"    "StdForm"    0    0    "16"    1   0
80    6    "SpecVersion"    "_n3GPPFDD_x5fBS_x5fTX_fVersion_x5f12_x5f00"    0    0    ""    1   0
80    6    "SourceType"    "_n3GPPFDD_x5fBS_x5fTX_fTestModel1_x5f16DPCHs"    0    0    ""    1   0
80    5    "RF_EnvelopeMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "RF_EnvelopeDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "RF_EnvelopeStart"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "RF_EnvelopeStop"    "StdForm"    0    0    "(2560/3.84) usec"    1   0
80    5    "RF_EnvelopeSlots"    "StdForm"    0    0    "1"    1   0
80    5    "PowerMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "PowerDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "PowerStartSlot"    "StdForm"    0    0    "0"    1   0
80    5    "PowerSlotsMeasured"    "StdForm"    0    0    "1"    1   0
80    5    "ACLR_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "ACLR_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "ACLR_Start"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "ACLR_Stop"    "StdForm"    0    0    "(2560/3.84) usec"    1   0
80    5    "ACLR_Slots"    "StdForm"    0    0    "0"    1   0
80    5    "ACLR_SpecMeasResBW"    "StdForm"    0    0    "0 Hz"    1   0
80    6    "ACLR_SpecMeasWindow"    "_n3GPPFDD_x5fBS_x5fTX_fACLR_x5fnone"    0    0    ""    1   0
80    5    "OccupiedBW_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "OBW_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "OBW_Start"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "OBW_Stop"    "StdForm"    0    0    "(2560/3.84) usec"    1   0
80    5    "OBW_Slots"    "StdForm"    0    0    "0"    1   0
80    5    "OBW_SpecMeasResBW"    "StdForm"    0    0    "0 Hz"    1   0
80    6    "OBW_SpecMeasWindow"    "_n3GPPFDD_x5fBS_x5fTX_fOBW_x5fnone"    0    0    ""    1   0
80    5    "CDP_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CDP_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "CDP_StartSlot"    "StdForm"    0    0    "0"    1   0
80    5    "PCDE_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "PCDE_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "PCDE_StartSlot"    "StdForm"    0    0    "0"    1   0
80    5    "EVM_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "EVM_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "EVM_Start"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "EVM_SlotsMeasured"    "StdForm"    0    0    "1"    1   0
80    5    "SignalToESG_Parameters"    "StringAndReference"    0    0    ""Category""    1   0
80    6    "EnableESG"    "_n3GPPFDD_x5fBS_x5fTX_fNO"    0    0    ""    1   0
80    5    "ESG_Instrument"    "InstrumentForm"    0    0    ""[GPIB0::19::INSTR][localhost][4790]""    1   0
80    5    "ESG_Start"    "StdForm"    0    0    "0 sec"    1   0
80    5    "ESG_Stop"    "StdForm"    0    0    "(2560/3.84) usec"    1   0
80    5    "ESG_Slots"    "StdForm"    0    0    "15"    1   0
80    5    "ESG_Power"    "StdForm"    0    0    "-20.0"    1   0
80    6    "ESG_ClkRef"    "_n3GPPFDD_x5fBS_x5fTX_fInternal"    0    0    ""    1   0
80    5    "ESG_ExtClkRefFreq"    "StdForm"    0    0    "10 MHz"    1   0
80    6    "ESG_IQFilter"    "_n3GPPFDD_x5fBS_x5fTX_fthrough"    0    0    ""    1   0
80    5    "ESG_SampleClkRate"    "StdForm"    0    0    "30.72 MHz"    1   0
80    5    "ESG_Filename"    "StringAndReference"    0    0    ""3GPPFDD_DL""    1   0
80    6    "ESG_AutoScaling"    "_n3GPPFDD_x5fBS_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_ArbOn"    "_n3GPPFDD_x5fBS_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_RFPowOn"    "_n3GPPFDD_x5fBS_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_EventMarkerType"    "_n3GPPFDD_x5fBS_x5fTX_fEvent1"    0    0    ""    1   0
80    5    "ESG_MarkerLength"    "StdForm"    0    0    "10"    1   0
41    111778792    0    1073741824    "DUT"    "Amplifier2"    "SYM_Amplifier"    4834 -333 6000 875 1    0 "" 0
    132594424    0    4    5000 500 0 1 1 0 0    0    105    0    0    1081471418    17  ""    5000 125 6000 875 1    4834 -333 5594 42 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -166 -625 594 -458 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -625 0    1    1    0    0    12    0   "Arial For CAE"   `Amplifier2`
40    7    0    0    0
50    6    -166 -833 179 -666 1    0    0    0    0    0    0    0    0
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
41    123487920    0    1073741840    "Information"    "3GPPFDD_BS_TX_Info"    "SYM_DSN_3GPPFDD_BS_TX_Info"    0 -458 2662 916 1    0 "" 0
    0    0    19    0 0 0 1 1 0 0    0    104    0    0    1081471014    17  ""    0 0 2662 916 1    209 -458 2042 -83 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 2042 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `3GPPFDD_BS_TX_Info`
40    7    0    0    0
50    6    209 -458 1042 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `Information`
43    101126788    0    ""    123935112    26    ""   0
43    101126832    0    ""    123934976    25    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
44    0    0    0    0    0    0    0
21
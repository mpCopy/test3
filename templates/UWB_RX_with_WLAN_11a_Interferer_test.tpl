1     7.704    0 0
10    1    "UWB_RX_with_WLAN_11a_Interferer_test"    2    1193694648    0    93    341    0
20    0    ""    125 -3334 12250 2458 1    2 -3 1    1193694600    0    "mil_schematic.prf" "schematic.lay"
30    101222768    1    ""    1    2    181331784    186050496    101534888    82146696    0    6750 1000 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    186050496    1    ""    2    2    181331584    0    101534888    185057048    0    7750 1000 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    181331584    1    "Meas_in"    2    0    0    181331784    101226496    185057048    0    8125 -125 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    181331784    1    "RF_out"    1    1    0    0    101226496    82146696    0    6625 -125 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    101645704    1    181331784    1    101222768    0    0    0    ""  0
60    3    0    3    6625 -125 6750 1000 1    0    0    0    0
70    6625 -125    6750 1000
32    82775896    1    181331584    1    186050496    0    0    0    ""  0
60    3    0    3    7750 -125 8125 1000 1    0    0    0    0
70    8125 -125    7750 1000
40    4    0    0    0
50    4    6625 -125 6750 1000 1    0    0    0    0    0    0    0    0    101645704
50    4    7750 -125 8125 1000 1    0    0    0    0    0    0    0    0    82775896
50    1    9000 -3000 12250 2000 1    0    0    0    0    0    0    0    0
60    2    0    4    9000 -3000 12250 2000 1    0    0    0    0
70    9000 -3000    12250 2000    9000 0
40    10    0    0    0
50    6    125 2125 10730 2458 1    0    0    0    0    0    0    0    0
62    0    333    9    125 2125 0    1    0    0    0    24    0   "Arial For CAE Bold"   `                UWB RX Performance with WLAN 11a Interferer Test Bench`
50    6    4875 916 6934 1417 1    0    0    0    0    0    0    0    0
62    0    167    9    4875 1250 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this "Amplifier2"
DUT with your own
CIRCUIT design.`
50    6    9125 -2600 11969 1848 1    0    0    0    0    0    0    0    0
62    0    139    9    9125 1709 0    32    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

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
40    12    0    0    0
50    1    4750 0 8250 1500 1    0    0    0    0    0    0    3    0
60    2    0    4    4750 0 8250 1500 1    0    0    0    0
70    4750 0    8250 1500    4750 0
41    100676912    0    1082130434    "VAR1"    "VAR"    "SYM_VAR"    1500 -3334 5368 -2335 1    0 "" 0
    0    0    89    1671 -2444 90000 1 1 0 0    0    104    0    0    1159501203    17  ""    1500 -2550 1825 -2335 1    1908 -3334 5368 -2335 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 582 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 671 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `VAR1`
40    8    0    0    0
50    6    237 -890 3697 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `CE_TimeStep=1/528 MHz/2^OversamplingOption`
50    6    237 -682 1870 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `OversamplingOption=3`
50    6    237 -474 2109 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `FMeasurement=3960 MHz`
80    3    "Variable Value"    "list"    0    3    ""    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "3960 MHz"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "OversamplingOption"    0   0
80    5    ""    "VarValueForm"    0    0    "3"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/528 MHz/2^OversamplingOption"    0   0
41    103980560    0    1073741840    "Information"    "UWB_Rx_with_WLAN_11a_Interferer_test_Info"    "SYM_DSN_UWB_Rx_with_WLAN_11a_Interferer_test_Info"    1209 0 4640 1374 1    0 "" 0
    0    0    93    1375 458 0 1 1 0 0    0    104    0    0    1161845536    17  ""    1375 458 4037 1374 1    1209 0 4640 375 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -166 -250 3265 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -250 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_Rx_with_WLAN_11a_Interferer_test_Info`
40    7    0    0    0
50    6    -166 -458 625 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -458 0    1    2    0    0    12    0   "Arial For CAE"   `Information`
41    101534888    0    1073741824    "DUT"    "Amplifier2"    "SYM_Amplifier"    6584 167 7750 1375 1    0 "" 0
    101222768    0    92    6750 1000 0 1 1 0 0    0    105    0    0    1081471418    17  ""    6750 625 7750 1375 1    6584 167 7348 542 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -166 -625 598 -458 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -625 0    1    1    0    0    12    0   "Arial For CAE"   `Amplifier2`
40    7    0    0    0
50    6    -166 -833 181 -666 1    0    0    0    0    0    0    0    0
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
41    204252688    0    0    "WTB"    "Envelope"    "SYM_ENV"    1625 -2134 3612 -376 1    0 "" 0
    0    0    91    1625 -375 0 1 1 0 0    0    104    0    0    1193694600    17  ""    1625 -844 3575 -376 1    1834 -2134 3612 -927 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 917 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 570 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `WTB`
40    8    0    0    0
50    6    209 -1759 1153 -1592 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1759 0    1    3    0    4    12    0   "Arial For CAE"   `ABM_Mode=`
50    6    209 -1551 1723 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1015 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=3`
50    6    209 -1135 1987 -968 1    0    0    0    0    0    0    0    0
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
80    6    "UseDeviceCurrentNestLevel"    "OutputPlan_BooleanNo"    0    0    ""    1   0
80    5    "DeviceCurrentNestLevel"    "SingleTextLineInteger"    0    0    ""    1   0
80    3    "DeviceCurrentName"    "list"    0    1    ""    1   0
80    5    "DeviceCurrentName"    "StringAndReference"    0    0    ""    1   0
80    5    "ABM_NoiseLogScale"    "StdForm"    0    0    "no"    1   0
80    5    "ABM_NoiseLogStartFreq"    "StdForm"    0    0    "1.0 Hz"    1   0
80    5    "ABM_NoiseLogPtsPerDec"    "StdForm"    0    0    "2"    1   0
80    5    "ABM_PerformPhaseSweep"    "StdForm"    0    0    ""    1   0
80    5    "ABM_AddDelay"    "StdForm"    0    0    ""    1   0
41    101226496    0    1073741848    "UWB_RX_with_WLAN_11a_Interferer"    "UWB_RX_with_WLAN_11a_Interferer"    "SYM_DSN_UWB_RX_with_WLAN_11a_Interferer"    6209 -2332 8950 -120 1    0 "" 0
    181331584    0    88    6625 -125 0 1 1 0 0    0    105    0    0    1161845422    17  ""    6375 -1250 8399 -120 1    6209 -2332 8950 -1333 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -416 -1375 2325 -1208 1    0    0    0    0    0    0    0    0
62    0    167    9    -416 -1375 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_RX_with_WLAN_11a_Interferer`
40    7    0    0    0
50    6    -416 -1583 2325 -1416 1    0    0    0    0    0    0    0    0
62    0    167    9    -416 -1583 0    1    2    0    0    12    0   "Arial For CAE"   `UWB_RX_with_WLAN_11a_Interferer`
40    8    0    0    0
50    6    -416 -2207 1801 -2040 1    0    0    0    0    0    0    0    0
62    0    167    9    -416 -2207 0    1    3    0    3    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -416 -1999 1756 -1832 1    0    0    0    0    0    0    0    0
62    0    167    9    -416 -1999 0    1    3    0    2    12    0   "Arial For CAE"   `SourcePower=dbmtow(-71.8)`
50    6    -416 -1791 1561 -1624 1    0    0    0    0    0    0    0    0
62    0    167    9    -416 -1791 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(-71.8)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SourceTemp"    "StdForm"    0    0    "16.85"    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "TestBenchSeed"    "StdForm"    0    0    "1234567"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "GainImbalance"    "StdForm"    0    0    "0.0 dB"    1   0
80    5    "PhaseImbalance"    "StdForm"    0    0    "0.0"    1   0
80    6    "DataPattern"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_fPN9"    0    0    ""    1   0
80    6    "DataRate"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_f_x5f106_x5f67_x5fMbps"    0    0    ""    1   0
80    5    "DataLength"    "StdForm"    0    0    "100"    1   0
80    6    "PreambleFormat"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_fStandard_x5fFormat"    0    0    ""    1   0
80    6    "TFC_Number"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_fTFC1"    0    0    ""    1   0
80    5    "OversamplingOption"    "StdForm"    0    0    "OversamplingOption"    1   0
80    6    "ScramblerSeed"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_fSeed_x5f00"    0    0    ""    1   0
80    5    "DataSet"    "_nUWB_x5fRX_x5fwith_x5fWLAN_x5f11a_x5fInterferer_fds_x5ffile"    0    0    ""WLAN_80211a_Source.ds""    1   0
80    5    "Expression"    "StringAndReference"    0    0    ""WLAN_80211a_Source..WLAN11a""    1   0
80    5    "WLAN11aPower"    "StdForm"    0    0    "dbmtow(-17)"    1   0
80    5    "FWLAN11a"    "StdForm"    0    0    "5.19 GHz"    1   0
80    5    "WLAN11aSampleRate"    "StdForm"    0    0    "20*2^5*1e6"    1   0
80    5    "MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "Delay"    "StdForm"    0    0    "1.8939 nsec"    1   0
80    5    "StartBlock"    "StdForm"    0    0    "1"    1   0
80    5    "StopBlock"    "StdForm"    0    0    "50"    1   0
43    185057048    0    ""    186050496    14    ""   0
43    82146696    0    ""    101222768    13    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
90    "FRQPLN0"  3  1 0 `10 1 1 0 GHz GHz GHz`
90    "AFS_STATE"  3  1 0 `0 25 1 0 0.000000 0.000000 GHz GHz uninit 0 local 0 Presentation1 1 0`
44    0    0    0    0    0    0    0
21

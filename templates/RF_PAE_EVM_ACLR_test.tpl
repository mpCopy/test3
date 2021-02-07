# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/wtb/RF_PAE_EVM_ACLR_test.tpl,v $ $Revision: 1.3 $ $Date: 2008/07/02 21:16:55 $
1     7.704    0 0
10    1    "RF_PAE_EVM_ACLR_test"    2    1215033372    0    187    340    0
20    0    ""    -1171 -5000 9875 3241 1    2 -3 1    1215033257    0    "schematic.prf" "schematic.lay"
90    "VIEW_LAYER_NUMBER"  1  1 0 `4`
30    24248872    1    "RF_from_PA"    4    -1    0    24249440    24333474    25475512    0    5250 0 0    0   0   0   0   0   ""   0   ""   0   ""   ""   ""
30    24249440    1    "RF_to_PA"    1    1    24249528    24249396    24333474    25475498    0    0 0 180000    0   0   0   0   0   ""   0   ""   0   ""   ""   ""
30    24249396    1    "VDC_Low_to_PA"    2    -1    24249572    24249484    24333474    25600862    0    1000 0 90000    0   0   0   0   0   ""   0   ""   0   ""   ""   ""
30    24249484    1    "VDC_High_to_PA"    3    -1    0    0    24333474    24078358    0    4250 0 90000    0   0   0   0   0   ""   0   ""   0   ""   ""   ""
30    24249528    1    "P1"    1    2    0    24249572    25463244    25475498    0    625 -1125 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24249572    1    "VL"    2    2    0    24249616    25463244    25600862    0    1000 -625 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24249616    1    "P4"    3    2    24249484    24249660    25463244    24078358    0    1250 -625 -90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24249660    1    "P2"    4    2    24248872    0    25463244    25475512    0    1625 -1125 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    24274128    1    24249440    1    24249528    0    0    0    ""  0
60    3    0    3    0 -1125 625 0 1    0    0    0    0
70    0 0    625 -1125
32    24274896    1    24249660    1    24248872    0    0    0    ""  0
60    2    0    3    1625 -1125 5250 0 1    0    0    0    0
70    1625 -1125    5250 0
32    17560524    1    24249396    1    24249572    0    0    0    ""  0
60    3    0    2    1000 -625 1000 0 1    0    0    0    0
70    1000 0    0 -625
32    17560544    1    24249616    1    24249484    0    0    0    ""  0
60    3    0    3    1250 -625 4250 0 1    0    0    0    0
70    1250 -625    4250 0
40    4    0    0    0
50    1    6250 -4125 9875 1375 1    0    0    0    0    0    0    0    0
60    2    0    4    6250 -4125 9875 1375 1    0    0    0    0
70    6250 -4125    9875 1375    6250 0
50    4    0 -1125 625 0 1    0    0    0    0    0    0    0    0    24274128
50    4    1625 -1125 5250 0 1    0    0    0    0    0    0    0    0    24274896
50    4    1000 -625 1000 0 1    0    0    0    0    0    0    0    0    17560524
50    4    1250 -625 4250 0 1    0    0    0    0    0    0    0    0    17560544
40    5    0    0    0
50    6    -243 2824 6044 3241 1    0    0    0    0    0    0    0    0
62    0    417    9    -243 2824 0    1    0    0    0    30    0   "Arial For CAE Bold"   `RF Power Amplifier Test Bench`
50    6    -250 1347 6082 2737 1    0    0    0    0    0    0    0    0
62    0    278    9    -250 2459 0    5    0    0    0    20    0   "Arial For CAE"   `This design provides simplified RF Power Amplifier
measurements for:
- Power Added Efficiency (PAE),
- Adjacent Channel Leakage Ratio (ACLR), and
- Error Vector Magnitude (EVM)`
40    10    0    0    0
50    6    6500 -3364 9626 1223 1    0    0    0    0    0    0    0    0
62    0    139    9    6500 1084 0    33    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time 
    is set within the RF_PAE_EVM_ACLR (not the
    "Env Setup" Stop time).  

2. Envelope simulation
    Step time (TStep) is defined within the
    RF_PAE_EVM_ACLR

3. Set the Circuit_VAR.values

4. RF_PAE_EVM_ACLR_WTB is pre-set 
    with a 3GPP signal and can be modified by
    the user with any preferred signal. 

5. Push into Information to see instructions for 
    these measurements. 

Notes for Sweep and Optimization:

    This test bench is not designed for use with
    other parameter sweeps, optimizations or
    other controllers.

Limitations for using wireless test benches:

1. Envelope "Oscillator Analysis" setup is NOT
    supported;

2. Envelope simulation with wireless test bench
    does NOT save the named nodes data in
    the dataset.`
50    6    2375 -959 3893 -458 1    0    0    0    0    0    0    0    0
62    0    167    9    2375 -625 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this DUT 
with your own
CIRCUIT design.`
40    12    0    0    0
41    25073690    0    16    "Information"    "PAE_EVM_ACLR_Information"    "PAE_EVM_ACLR_Information"    6375 1417 9037 2791 1    0 "" 0
    0    0    181    6375 1875 0 1 1 0 0    1    105    0    0    1215020095    17  ""    6375 1875 9037 2791 1    6584 1417 8833 1792 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 2458 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `PAE_EVM_ACLR_Information`
40    7    0    0    0
50    6    209 -458 1008 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `Information`
41    24175858    0    0    "SwpPlan2"    "SweepPlan"    "SYM_SWEEPPLAN"    3625 -5000 5677 -3271 1    0 "" 0
    0    0    186    3626 -3271 0 1 1 0 0    0    104    0    0    1213284603    17  ""    3625 -3710 5677 -3271 1    3834 -5000 5098 -3793 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -689 1076 -522 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -689 0    1    1    0    0    12    0   "Arial For CAE"   `SweepPlan`
40    7    0    0    0
50    6    208 -897 977 -730 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -897 0    1    2    0    0    12    0   "Arial For CAE"   `SwpPlan2`
40    8    0    0    0
50    6    208 -1729 1162 -1562 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1729 0    1    3    0    4    12    0   "Arial For CAE"   `Reverse=no`
50    6    208 -1521 1175 -1354 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1521 0    1    3    0    3    12    0   "Arial For CAE"   `SweepPlan=`
50    6    208 -1313 1472 -1146 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1313 0    1    3    0    2    12    0   "Arial For CAE"   `UseSweepPlan=`
50    6    208 -1105 667 -938 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1105 0    1    3    0    1    12    0   "Arial For CAE"   `Pt=15`
80    3    "SweepPlanParm"    "list"    0    1    ""    0   0
80    4    "SweepPlanParm"    "SinglePoint"    0    1    ""    0   0
80    5    "SweepPlan Parm"    "SwpPlanTextForm"    0    0    "15"    0   0
80    5    "UseSweepPlan"    "StdForm"    0    0    ""    0   0
80    5    "SweepPlan"    "StringAndReference"    0    0    ""    0   0
80    5    "Sort"    "StdForm"    0    0    "SINGLE_POINT START STEP "    1   0
80    6    "Reverse"    "No"    0    0    ""    0   0
41    24313122    0    0    "SwpPlan1"    "SweepPlan"    "SYM_SWEEPPLAN"    1125 -5000 3763 -3271 1    0 "" 0
    0    0    187    1126 -3271 0 1 1 0 0    0    104    0    0    1213284624    17  ""    1125 -3710 3177 -3271 1    1334 -5000 3763 -3793 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -689 1076 -522 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -689 0    1    1    0    0    12    0   "Arial For CAE"   `SweepPlan`
40    7    0    0    0
50    6    208 -897 977 -730 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -897 0    1    2    0    0    12    0   "Arial For CAE"   `SwpPlan1`
40    8    0    0    0
50    6    208 -1729 1162 -1562 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1729 0    1    3    0    4    12    0   "Arial For CAE"   `Reverse=no`
50    6    208 -1521 2067 -1354 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1521 0    1    3    0    3    12    0   "Arial For CAE"   `SweepPlan="SwpPlan2"`
50    6    208 -1313 1745 -1146 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1313 0    1    3    0    2    12    0   "Arial For CAE"   `UseSweepPlan=yes`
50    6    208 -1105 2637 -938 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1105 0    1    3    0    1    12    0   "Arial For CAE"   `Start=-10 Stop=10 Step= Lin=3`
80    3    "SweepPlanParm"    "list"    0    1    ""    0   0
80    4    "SweepPlanParm"    "LinearStart"    0    4    ""    0   0
80    5    "Start"    "SwpPlanTextForm"    0    0    "-10"    0   0
80    5    "Stop"    "SwpPlanTextForm"    0    0    "10"    0   0
80    5    "Step"    "SwpPlanTextForm"    0    0    ""    0   0
80    5    "Lin"    "SwpPlanTextForm"    0    0    "3"    0   0
80    5    "UseSweepPlan"    "StdForm"    0    0    "yes"    0   0
80    5    "SweepPlan"    "StringAndReference"    0    0    ""SwpPlan2""    0   0
80    5    "Sort"    "StdForm"    0    0    "LINEAR START POINTS "    1   0
80    6    "Reverse"    "No"    0    0    ""    0   0
41    24313630    0    1082130434    "Circuit_VAR"    "VAR"    "SYM_VAR"    -1171 -4515 586 -3516 1    0 "" 0
    0    0    152    -1000 -3625 90000 1 1 0 0    0    104    0    0    1213634517    17  ""    -1171 -3731 -846 -3516 1    -763 -4515 586 -3516 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 560 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 1117 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `Circuit_VAR`
40    8    0    0    0
50    6    237 -890 1312 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `VDC_High=5.8`
50    6    237 -682 1136 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `VDC_Low=2`
50    6    237 -474 1586 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `RF_Freq=800 MHz`
80    3    "Variable Value"    "list"    0    3    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "RF_Freq"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "VDC_Low"    0   0
80    5    ""    "VarValueForm"    0    0    "2"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "VDC_High"    0   0
80    5    ""    "VarValueForm"    0    0    "5.8"    0   0
41    24297108    0    0    "Env1"    "Envelope"    "SYM_ENV"    -1125 -3292 825 -1950 1    0 "" 0
    0    0    149    -1125 -1949 0 1 1 0 0    0    104    0    0    1211564807    17  ""    -1125 -2418 825 -1950 1    -916 -3292 367 -2501 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 901 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 587 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `Env1`
40    8    0    0    0
50    6    209 -1343 1012 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=5`
50    6    209 -1135 1492 -968 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1135 0    1    3    0    1    12    0   "Arial For CAE"   `Freq[1]=RF_Freq`
80    5    "MaxOrder"    "StdForm"    0    0    "4"    1   0
80    3    "Freq"    "list"    0    1    ""    0   0
80    5    "Freq"    "StdForm"    0    0    "RF_Freq"    0   0
80    3    "Order"    "list"    0    1    ""    0   0
80    5    "Order"    "StdForm"    0    0    "5"    0   0
80    5    "StatusLevel"    "StdForm"    0    0    "1"    1   0
80    5    "FundOversample"    "StdForm"    0    0    "2"    1   0
80    3    "Oversample"    "list"    0    1    ""    1   0
80    5    "Oversample"    "StdForm"    0    0    ""    1   0
80    5    "PackFFT"    "StdForm"    0    0    ""    1   0
80    5    "MaxIters"    "StdForm"    0    0    ""    1   0
80    5    "GuardThresh"    "StdForm"    0    0    ""    1   0
80    5    "SamanskiiConstant"    "StdForm"    0    0    ""    1   0
80    5    "Restart"    "StdForm"    0    0    ""    1   0
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
80    5    "Stop"    "StdForm"    0    0    "2*TStep"    1   0
80    5    "Step"    "StdForm"    0    0    "TStep"    1   0
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
80    5    "UseAllSS_Freqs"    "StdForm"    0    0    ""    1   0
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
80    5    "UseInFile"    "StdForm"    0    0    ""    1   0
80    5    "OutFile"    "StringAndReference"    0    0    " "    1   0
80    5    "UseOutFile"    "StdForm"    0    0    ""    1   0
80    6    "UseKrylov"    "AutoKrylovMode"    0    0    ""    1   0
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
80    6    "ConvMode"    "HBConvModeAuto"    0    0    ""    1   0
80    5    "ABM_Mode"    "StdForm"    0    0    ""    1   0
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
41    24332428    0    0    "Sweep"    "ParamSweep"    "SYM_PARAMSWEEP"    2375 -2916 5430 -1574 1    0 "" 0
    0    0    169    2376 -1575 0 1 1 0 0    0    104    0    0    1213634541    17  ""    2375 -2042 5430 -1574 1    2584 -2916 4686 -2125 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -717 1156 -550 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -717 0    1    1    0    0    12    0   "Arial For CAE"   `ParamSweep`
40    7    0    0    0
50    6    208 -925 687 -758 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -925 0    1    2    0    0    12    0   "Arial For CAE"   `Sweep`
40    8    0    0    0
50    6    208 -1341 2310 -1174 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1341 0    1    3    0    2    12    0   "Arial For CAE"   `SweepVar="RF_Power_dBm"`
50    6    208 -1133 1919 -966 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1133 0    1    3    0    1    12    0   "Arial For CAE"   `SweepPlan="SwpPlan1"`
80    5    "UseSweepPlan"    "StdForm"    0    0    "yes"    1   0
80    5    "SweepPlan"    "StringAndReference"    0    0    ""SwpPlan1""    0   0
80    5    "SweepVar"    "StringAndReference"    0    0    ""RF_Power_dBm""    0   0
80    3    "SimInstanceName"    "list"    0    6    ""    0   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""WTB1""    1   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""    1   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""    1   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""    1   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""    1   0
80    5    "SimInstanceName"    "StringAndReference"    0    0    ""    1   0
80    5    "StatusLevel"    "StdForm"    0    0    "2"    1   0
80    5    "RestoreNomValues"    "StdForm"    0    0    ""    1   0
80    5    "Start"    "StdForm"    0    0    ""    1   0
80    5    "Stop"    "StdForm"    0    0    ""    1   0
80    5    "Step"    "StdForm"    0    0    ""    1   0
80    5    "Center"    "StdForm"    0    0    ""    1   0
80    5    "Span"    "StdForm"    0    0    ""    1   0
80    5    "Lin"    "StdForm"    0    0    ""    1   0
80    5    "Dec"    "StdForm"    0    0    ""    1   0
80    5    "Log"    "StdForm"    0    0    ""    1   0
80    5    "Reverse"    "StdForm"    0    0    ""    1   0
80    5    "Pt"    "StdForm"    0    0    ""    1   0
80    5    "Sort"    "StdForm"    0    0    "LINEAR START STEP "    1   0
41    24333474    0    16    "RF_PAE_EVM_ACLR"    "RF_PAE_EVM_ACLR"    "RF_PAE_EVM_ACLR"    -250 -458 5500 1250 1    0 "" 0
    24248872    0    179    0 0 0 1 1 0 0    0    104    0    0    1213633711    17  ""    -250 0 5500 1250 1    -41 -458 1480 -83 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -41 -250 1480 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -250 0    1    1    0    0    12    0   "Arial For CAE"   `RF_PAE_EVM_ACLR`
40    7    0    0    0
50    6    -41 -458 1480 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -458 0    1    2    0    0    12    0   "Arial For CAE"   `RF_PAE_EVM_ACLR`
41    25463244    0    16    "DUT"    "CktPAwithBias"    "CktPAwithBias"    625 -1833 1919 -625 1    0 "" 0
    24249528    0    151    625 -1125 0 1 1 0 0    0    105    0    0    1211410693    17  ""    625 -1375 1625 -625 1    834 -1833 1919 -1458 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -500 1294 -333 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -500 0    1    1    0    0    12    0   "Arial For CAE"   `CktPAwithBias`
40    7    0    0    0
50    6    209 -708 548 -541 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -708 0    1    2    0    0    12    0   "Arial For CAE"   `DUT`
43    24078358    0    ""    24249616    232    ""   0
43    25600862    0    ""    24249396    231    ""   0
43    25475498    0    ""    24249440    230    ""   0
43    25475512    0    ""    24249660    229    ""   0
44    0    0    0    0    0    0    0
40    0    0    0    0
40    4    0    0    0
40    5    0    0    0
40    11    0    0    0
40    12    0    0    0
40    20    0    0    0
21
20    1    ""    0 0 0 0 0    1 -2 1    0    0    "layout.prf" "layout.lay"
90    "FRQPLN0"  3  1 0 `10 1 1 0 GHz GHz GHz`
90    "AFS_STATE"  3  1 0 `0 25 1 0 0.000000 0.000000 GHz GHz uninit 0 ./localhost 0 Presentation1 1 0`
44    0    0    0    0    0    0    0
21

1     7.704    0 0
10    1    "UWB_RX_Sensitivity_test"    2    1193693762    0    77    341    0
20    0    ""    -125 -4708 10500 1833 1    2 -3 1    1193693709    0    "mil_schematic.prf" "schematic.lay"
30    104509240    1    "Meas_in"    2    0    104510440    104509640    181527736    102498872    0    6375 -625 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    104509640    1    "RF_out"    1    1    104509840    0    181527736    181994600    0    4875 -625 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    104509840    1    ""    1    2    0    104510440    102499592    181994600    0    5000 500 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    104510440    1    ""    2    2    0    0    102499592    102498872    0    6000 500 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    102642440    1    104509640    1    104509840    0    0    0    ""  0
60    3    0    3    4875 -625 5000 500 1    0    0    0    0
70    4875 -625    5000 500
32    83723400    1    104509240    1    104510440    0    0    0    ""  0
60    3    0    3    6000 -625 6375 500 1    0    0    0    0
70    6375 -625    6000 500
40    4    0    0    0
50    4    4875 -625 5000 500 1    0    0    0    0    0    0    0    0    102642440
50    4    6000 -625 6375 500 1    0    0    0    0    0    0    0    0    83723400
50    1    7250 -4625 10500 1125 1    0    0    0    0    0    0    0    0
60    2    0    4    7250 -4625 10500 1125 1    0    0    0    0
70    7250 -4625    10500 1125    7250 0
40    10    0    0    0
50    6    7375 -4448 10400 973 1    0    0    0    0    0    0    0    0
62    0    139    9    7375 834 0    39    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

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
    OversamplingOption is a UWB_RX_Sensitivity
    Signal Parameter.


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
50    6    625 1500 7175 1833 1    0    0    0    0    0    0    0    0
62    0    333    9    625 1500 0    1    0    0    0    24    0   "Arial For CAE Bold"   `                UWB RX Sensitivity Test Bench`
50    6    3125 416 5112 917 1    0    0    0    0    0    0    0    0
62    0    167    9    3125 750 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this "Amplifier2"
DUT with your own
CIRCUIT design.`
40    12    0    0    0
50    1    3000 -500 6500 1000 1    0    0    0    0    0    0    3    0
60    2    0    4    3000 -500 6500 1000 1    0    0    0    0
70    3000 -500    6500 1000    3000 0
41    181527736    0    1073741848    "UWB_RX_Sensitivity"    "UWB_RX_Sensitivity"    "SYM_DSN_UWB_RX_Sensitivity"    4625 -2832 7224 -620 1    0 "" 0
    104509240    0    74    4875 -625 0 1 1 0 0    0    105    0    0    1159342062    17  ""    4625 -1750 6625 -620 1    4834 -2832 7224 -1833 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -41 -1375 1535 -1208 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1375 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_RX_Sensitivity`
40    7    0    0    0
50    6    -41 -1583 1535 -1416 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1583 0    1    2    0    0    12    0   "Arial For CAE"   `UWB_RX_Sensitivity`
40    8    0    0    0
50    6    -41 -2207 2349 -2040 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -2207 0    1    3    0    3    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -41 -1999 2152 -1832 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1999 0    1    3    0    2    12    0   "Arial For CAE"   `SourcePower=dbmtow(-74.5)`
50    6    -41 -1791 2165 -1624 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1791 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(-74.5)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SourceTemp"    "StdForm"    0    0    "16.85"    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "TestBenchSeed"    "StdForm"    0    0    "1234567"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "GainImbalance"    "StdForm"    0    0    "0.0 dB"    1   0
80    5    "PhaseImbalance"    "StdForm"    0    0    "0.0"    1   0
80    6    "DataPattern"    "_nUWB_x5fRX_x5fSensitivity_fPN9"    0    0    ""    1   0
80    5    "BandGroup"    "StdForm"    0    0    "BandGroup"    1   0
80    6    "DataRate"    "_nUWB_x5fRX_x5fSensitivity_f_x5f200_x5fMbps"    0    0    ""    1   0
80    5    "DataLength"    "StdForm"    0    0    "1024"    1   0
80    6    "PreambleFormat"    "_nUWB_x5fRX_x5fSensitivity_fStandard_x5fFormat"    0    0    ""    1   0
80    6    "TFC_Number"    "_nUWB_x5fRX_x5fSensitivity_fTFC1"    0    0    ""    1   0
80    5    "OversamplingOption"    "StdForm"    0    0    "OversamplingOption"    1   0
80    6    "ScramblerSeed"    "_nUWB_x5fRX_x5fSensitivity_fSeed_x5f00"    0    0    ""    1   0
80    5    "MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "Delay"    "StdForm"    0    0    "1/528e6/2^OversamplingOption"    1   0
80    5    "StartBlock"    "StdForm"    0    0    "1"    1   0
80    5    "StopBlock"    "StdForm"    0    0    "200"    1   0
41    191450120    0    1082130434    "VAR1"    "VAR"    "SYM_VAR"    0 -4708 6173 -3085 1    0 "" 0
    0    0    77    171 -3194 90000 1 1 0 0    0    104    0    0    1159342011    17  ""    0 -3300 325 -3085 1    408 -4708 6173 -3085 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 592 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 684 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `VAR1`
40    8    0    0    0
50    6    237 -1514 2299 -1347 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1514 0    1    3    0    6    12    0   "Arial For CAE"   `Fc=FcTable[BandGroup+1]`
50    6    237 -1306 1288 -1139 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1306 0    1    3    0    5    12    0   "Arial For CAE"   `BandGroup=0`
50    6    237 -1098 6002 -931 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1098 0    1    3    0    4    12    0   "Arial For CAE"   `FcTable={3960 MHz,5544 MHz,7128 MHz,8712 MHz,10296MHz,8184 MHz}`
50    6    237 -890 3954 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `CE_TimeStep=1/528 MHz/2^OversamplingOption`
50    6    237 -682 1957 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `OversamplingOption=1`
50    6    237 -474 1682 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `FMeasurement=Fc`
80    3    "Variable Value"    "list"    0    6    ""    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "Fc"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "OversamplingOption"    0   0
80    5    ""    "VarValueForm"    0    0    "1"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/528 MHz/2^OversamplingOption"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FcTable"    0   0
80    5    ""    "VarValueForm"    0    0    "{3960 MHz,5544 MHz,7128 MHz,8712 MHz,10296MHz,8184 MHz}"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "BandGroup"    0   0
80    5    ""    "VarValueForm"    0    0    "0"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "Fc"    0   0
80    5    ""    "VarValueForm"    0    0    "FcTable[BandGroup+1]"    0   0
41    98313048    0    1073741840    "U1"    "UWB_OFDM_RxSensitivity_test_Info"    "SYM_DSN_UWB_OFDM_RxSensitivity_test_Info"    -125 -375 2881 999 1    0 "" 0
    0    0    76    -125 83 0 1 1 0 0    0    96    0    0    1115704903    17  ""    -125 83 2537 999 1    84 -375 2881 0 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 3006 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `UWB_OFDM_RxSensitivity_test_Info`
40    7    0    0    0
50    6    209 -458 435 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `U1`
41    203129352    0    0    "WTB"    "Envelope"    "SYM_ENV"    -125 -2634 1862 -876 1    0 "" 0
    0    0    1    -125 -875 0 1 1 0 0    0    104    0    0    1193693709    17  ""    -125 -1344 1825 -876 1    84 -2634 1862 -1427 1    0 0 0 0 0 0
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
41    102499592    0    1073741824    "DUT"    "Amplifier2"    "SYM_Amplifier"    4834 -333 6000 875 1    0 "" 0
    104509840    0    4    5000 500 0 1 1 0 0    0    105    0    0    1081471418    17  ""    5000 125 6000 875 1    4834 -333 5598 42 1    0 0 0 0 0 0
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
43    181994600    0    ""    104509640    184    ""   0
43    102498872    0    ""    104509240    183    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
90    "FRQPLN0"  3  1 0 `10 1 1 0 GHz GHz GHz`
90    "AFS_STATE"  3  1 0 `0 25 1 0 0.000000 0.000000 GHz GHz uninit 0 local 0 Presentation1 1 0`
44    0    0    0    0    0    0    0
21

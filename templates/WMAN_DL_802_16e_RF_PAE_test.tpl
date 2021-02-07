1     7.704    0 0
10    1    "WMAN_DL_802_16e_RF_PAE_test"    2    1214289996    0    41    341    0
20    0    ""    -2796 -5625 10625 2333 1    2 -3 1    1213931598    0    "mil_schematic.prf" "schematic.lay"
30    28514508    1    "RF_from_PA"    4    -1    27196450    28554478    27939522    28381422    0    6000 125 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    28554478    1    "RF_to_PA"    1    1    27357448    27162968    27939522    28381350    0    750 125 -180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27162968    1    "VDC_Low_to_PA"    2    -1    28548746    28521172    27939522    28381204    0    1750 125 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    28521172    1    "VDC_High_to_PA"    3    -1    27061074    0    27939522    28438148    0    5000 125 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27357448    1    "P1"    1    2    0    28548746    27074060    28381350    0    2125 -1375 -180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    28548746    1    "VL"    2    2    0    27061074    27074060    28381204    0    2500 -875 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27061074    1    "P4"    3    2    0    27196450    27074060    28438148    0    2750 -875 -90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27196450    1    "P2"    4    2    0    0    27074060    28381422    0    3125 -1375 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    25664122    1    28554478    1    27357448    0    0    0    ""  0
60    4    0    3    750 -1375 2125 125 1    0    0    0    0
70    750 125    750 -1375    2125 -1375
32    26593274    1    27196450    1    28514508    0    0    0    ""  0
60    4    0    3    3125 -1375 6000 125 1    0    0    0    0
70    3125 -1375    6000 -1375    6000 125
32    24921328    1    28548746    1    27162968    0    0    0    ""  0
60    4    0    3    1750 -875 2500 125 1    0    0    0    0
70    2500 -875    2500 125    1750 125
32    27315718    1    27061074    1    28521172    0    0    0    ""  0
60    4    0    3    2750 -875 5000 125 1    0    0    0    0
70    2750 -875    2750 125    5000 125
40    4    0    0    0
50    4    750 -1375 2125 125 1    0    0    0    0    0    0    0    0    25664122
50    4    3125 -1375 6000 125 1    0    0    0    0    0    0    0    0    26593274
50    4    1750 -875 2500 125 1    0    0    0    0    0    0    0    0    24921328
50    4    2750 -875 5000 125 1    0    0    0    0    0    0    0    0    27315718
50    1    7375 -4625 10625 1000 1    0    0    0    0    0    0    0    0
60    4    0    4    7375 -4625 10625 1000 1    0    0    0    0
70    7375 -4625    10625 -4625    10625 1000    7375 1000
40    10    0    0    0
50    6    -2125 2000 9983 2333 1    0    0    0    0    0    0    0    0
62    0    333    9    -2125 2000 0    1    0    0    0    24    0   "Arial For CAE Bold"   `Mobile WiMAX Downlink Power Amplifier Power Added Efficiency Test Bench`
50    6    7500 -4434 10458 848 1    0    0    0    0    0    0    0    0
62    0    139    9    7500 709 0    38    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. CE_TimeStep must be set to equal to or
    less then 1/11.2e6/2^OversamplingOption.
    OversamplingOption is a RF_PAE
    Signal Parameter.
 
3. Push into PAE_Information to see 
    instructions for setting the Circuit_VAR and
    RF_PAE instance values. 

Notes for Sweep and Optimization:

    The SimInstanceName must always use
    "WTB1" for sweep or optimization controller
    regardless of the Envelope controller's
    instance name.


Limitations for using wireless test benches:

1. Envelope "Oscillator Analysis" setup is NOT
    supported.

2. Envelope AVM is NOT supported for PAE
    measurement.

3. Envelope simulation with wireless test bench
    does NOT save the named nodes data in
    the dataset.`
50    6    3875 -1209 5271 -708 1    0    0    0    0    0    0    0    0
62    0    167    9    3875 -875 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this DUT 
with your own
CIRCUIT design.`
41    27939522    0    1073741848    "WMAN_DL_802_16e_RF_PAE"    "WMAN_DL_802_16e_RF_PAE"    "SYM_DSN_WMAN_DL_802_16e_RF_PAE"    -2541 -2203 6250 1375 1    0 "" 0
    28514508    0    37    750 875 0 1 1 0 0    0    105    0    0    1213931598    17  ""    500 125 6250 1375 1    -2541 -2203 1407 1292 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -3291 250 -953 417 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 250 0    1    1    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_RF_PAE`
40    7    0    0    0
50    6    -3291 42 -953 209 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 42 0    1    2    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_RF_PAE`
40    8    0    0    0
50    6    -3291 -3078 -1414 -2911 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -3078 0    1    3    0    15    12    0   "Arial For CAE"   `NumFramesMeasured=2`
50    6    -3291 -2870 657 -2703 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -2870 0    1    3    0    14    12    0   "Arial For CAE"   `SegmentMeasured=Preamble+FCH/MAP+DataZone`
50    6    -3291 -2662 -1234 -2495 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -2662 0    1    3    0    13    12    0   "Arial For CAE"   `EnableFrameMarkers=YES`
50    6    -3291 -2454 -1347 -2287 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -2454 0    1    3    0    12    12    0   "Arial For CAE"   `EnableFrameGating=YES`
50    6    -3291 -2246 -2002 -2079 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -2246 0    1    3    0    11    12    0   "Arial For CAE"   `VDC_High=5.8 V`
50    6    -3291 -2038 -2035 -1871 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -2038 0    1    3    0    10    12    0   "Arial For CAE"   `VDC_Low=2.0 V`
50    6    -3291 -1830 -1748 -1663 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -1830 0    1    3    0    9    12    0   "Arial For CAE"   `ZoneNumOfSym=22`
50    6    -3291 -1622 -1688 -1455 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -1622 0    1    3    0    8    12    0   "Arial For CAE"   `ZoneType=DL_PUSC`
50    6    -3291 -1414 -2195 -1247 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -1414 0    1    3    0    7    12    0   "Arial For CAE"   `FFTSize=1024`
50    6    -3291 -1206 -1127 -1039 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -1206 0    1    3    0    6    12    0   "Arial For CAE"   `OversamplingOption=Ratio 2`
50    6    -3291 -998 -1821 -831 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -998 0    1    3    0    5    12    0   "Arial For CAE"   `Bandwidth=10 MHz`
50    6    -3291 -790 -920 -623 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -790 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -3291 -582 -4 -415 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -582 0    1    3    0    3    12    0   "Arial For CAE"   `SourcePower=dbmtow(SourcePower_dBm)`
50    6    -3291 -374 -1922 -207 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -374 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=FSource`
50    6    -3291 -166 -1107 1 1    0    0    0    0    0    0    0    0
62    0    167    9    -3291 -166 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "FSource"    "StdForm"    0    0    "FSource"    0   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(SourcePower_dBm)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    6    "PowerType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fPeak_x5fpower"    0    0    ""    1   0
80    5    "Bandwidth"    "StdForm"    0    0    "10 MHz"    0   0
80    6    "OversamplingOption"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fRatio_x5f2"    0    0    ""    0   0
80    6    "FFTSize"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fFFT_x5f1024"    0    0    ""    0   0
80    5    "CyclicPrefix"    "StdForm"    0    0    "0.125"    1   0
80    6    "FrameMode"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fFDD"    0    0    ""    1   0
80    5    "DL_Ratio"    "StdForm"    0    0    "0.5"    1   0
80    6    "FrameDuration"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_ftime_x5f5_x5fms"    0    0    ""    1   0
80    6    "DLMAP_Enable"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fNO"    0    0    ""    1   0
80    6    "ULMAP_Enable"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fNO"    0    0    ""    1   0
80    6    "DataPattern"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fPN9"    0    0    ""    1   0
80    6    "ZoneType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fDL_x5fPUSC"    0    0    ""    0   0
80    5    "ZoneNumOfSym"    "StdForm"    0    0    "22"    0   0
80    5    "GroupBitmask"    "StringAndReference"    0    0    "{1, 1, 1, 1, 1, 1}"    1   0
80    5    "NumberOfBurst"    "StdForm"    0    0    "1"    1   0
80    5    "BurstWithFEC"    "StdForm"    0    0    "1"    1   0
80    5    "BurstSymOffset"    "StringAndReference"    0    0    "{2}"    1   0
80    5    "BurstSubchOffset"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "BurstNumOfSym"    "StringAndReference"    0    0    "{2}"    1   0
80    5    "BurstNumOfSubch"    "StringAndReference"    0    0    "{30}"    1   0
80    5    "DataLength"    "StringAndReference"    0    0    "{200}"    1   0
80    5    "CodingType"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "Rate_ID"    "StringAndReference"    0    0    "{5}"    1   0
80    5    "RepetitionCoding"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "PowerBoosting"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "VDC_Low"    "StdForm"    0    0    "2.0 V"    0   0
80    5    "VDC_High"    "StdForm"    0    0    "5.8 V"    0   0
80    6    "EnableFrameGating"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    6    "EnableFrameMarkers"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    5    "InitialStartUpDelay"    "StdForm"    0    0    "0 sec"    1   0
80    6    "SegmentMeasured"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fRF_x5fPAE_fPreamble_x5fFCH_x5fMAP_x5fDataZone"    0    0    ""    0   0
80    5    "NumFramesMeasured"    "StdForm"    0    0    "2"    0   0
41    27157202    0    1073741840    "PAE_Information"    "WMAN_DL_802_16e_RF_PAE_Information"    "SYM_DSN_WMAN_DL_802_16e_RF_PAE_Information"    3875 -3250 7357 -1876 1    0 "" 0
    0    0    38    3875 -2792 0 1 1 0 0    0    104    0    0    1213347965    17  ""    3875 -2792 6537 -1876 1    4084 -3250 7357 -2875 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 3482 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_RF_PAE_Information`
40    7    0    0    0
50    6    209 -458 1472 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `PAE_Information`
41    27172582    0    0    "Env1"    "Envelope"    "SYM_ENV"    4000 -5500 5950 -3950 1    0 "" 0
    0    0    5    4000 -3949 0 1 1 0 0    0    104    0    0    1211943050    17  ""    4000 -4418 5950 -3950 1    4209 -5500 5699 -4501 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 904 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 583 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `Env1`
40    8    0    0    0
50    6    209 -1551 1699 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1011 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=5`
50    6    209 -1135 1472 -968 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1135 0    1    3    0    1    12    0   "Arial For CAE"   `Freq[1]=FSource`
80    5    "MaxOrder"    "StdForm"    0    0    "4"    1   0
80    3    "Freq"    "list"    0    1    ""    0   0
80    5    "Freq"    "StdForm"    0    0    "FSource"    0   0
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
80    5    "Stop"    "StdForm"    0    0    "2*CE_TimeStep"    1   0
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
41    28209326    0    0    "SwpPlan1"    "SweepPlan"    "SYM_SWEEPPLAN"    -2500 -5625 47 -3896 1    0 "" 0
    0    0    39    -2499 -3896 0 1 1 0 0    0    104    0    0    1213284624    17  ""    -2500 -4335 -448 -3896 1    -2291 -5625 47 -4418 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -689 1070 -522 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -689 0    1    1    0    0    12    0   "Arial For CAE"   `SweepPlan`
40    7    0    0    0
50    6    208 -897 976 -730 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -897 0    1    2    0    0    12    0   "Arial For CAE"   `SwpPlan1`
40    8    0    0    0
50    6    208 -1729 1110 -1562 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1729 0    1    3    0    4    12    0   "Arial For CAE"   `Reverse=no`
50    6    208 -1521 2058 -1354 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1521 0    1    3    0    3    12    0   "Arial For CAE"   `SweepPlan="SwpPlan2"`
50    6    208 -1313 1731 -1146 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1313 0    1    3    0    2    12    0   "Arial For CAE"   `UseSweepPlan=yes`
50    6    208 -1105 2546 -938 1    0    0    0    0    0    0    0    0
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
41    28176556    0    0    "SwpPlan2"    "SweepPlan"    "SYM_SWEEPPLAN"    500 -5625 2552 -3896 1    0 "" 0
    0    0    41    501 -3896 0 1 1 0 0    0    104    0    0    1213284603    17  ""    500 -4335 2552 -3896 1    709 -5625 1972 -4418 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -689 1070 -522 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -689 0    1    1    0    0    12    0   "Arial For CAE"   `SweepPlan`
40    7    0    0    0
50    6    208 -897 976 -730 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -897 0    1    2    0    0    12    0   "Arial For CAE"   `SwpPlan2`
40    8    0    0    0
50    6    208 -1729 1110 -1562 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1729 0    1    3    0    4    12    0   "Arial For CAE"   `Reverse=no`
50    6    208 -1521 1170 -1354 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1521 0    1    3    0    3    12    0   "Arial For CAE"   `SweepPlan=`
50    6    208 -1313 1471 -1146 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1313 0    1    3    0    2    12    0   "Arial For CAE"   `UseSweepPlan=`
50    6    208 -1105 656 -938 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1105 0    1    3    0    1    12    0   "Arial For CAE"   `Pt=15`
80    3    "SweepPlanParm"    "list"    0    1    ""    0   0
80    4    "SweepPlanParm"    "SinglePoint"    0    1    ""    0   0
80    5    "SweepPlan Parm"    "SwpPlanTextForm"    0    0    "15"    0   0
80    5    "UseSweepPlan"    "StdForm"    0    0    ""    0   0
80    5    "SweepPlan"    "StringAndReference"    0    0    ""    0   0
80    5    "Sort"    "StdForm"    0    0    "SINGLE_POINT START STEP "    1   0
80    6    "Reverse"    "No"    0    0    ""    0   0
41    27500320    0    0    "Sweep"    "ParamSweep"    "SYM_PARAMSWEEP"    376 -3687 3431 -2345 1    0 "" 0
    0    0    40    377 -2346 0 1 1 0 0    0    104    0    0    1213514970    17  ""    376 -2813 3431 -2345 1    585 -3687 3037 -2896 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -717 1230 -550 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -717 0    1    1    0    0    12    0   "Arial For CAE"   `ParamSweep`
40    7    0    0    0
50    6    208 -925 729 -758 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -925 0    1    2    0    0    12    0   "Arial For CAE"   `Sweep`
40    8    0    0    0
50    6    208 -1341 2660 -1174 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1341 0    1    3    0    2    12    0   "Arial For CAE"   `SweepVar="SourcePower_dBm"`
50    6    208 -1133 2058 -966 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1133 0    1    3    0    1    12    0   "Arial For CAE"   `SweepPlan="SwpPlan1"`
80    5    "UseSweepPlan"    "StdForm"    0    0    "yes"    1   0
80    5    "SweepPlan"    "StringAndReference"    0    0    ""SwpPlan1""    0   0
80    5    "SweepVar"    "StringAndReference"    0    0    ""SourcePower_dBm""    0   0
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
41    28210424    0    1082130434    "Circuit_VAR"    "VAR"    "SYM_VAR"    -2796 -3598 -90 -2391 1    0 "" 0
    0    0    3    -2625 -2500 90000 1 1 0 0    0    104    0    0    1213931070    17  ""    -2796 -2606 -2471 -2391 1    -2388 -3598 -90 -2391 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 571 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 1145 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `Circuit_VAR`
40    8    0    0    0
50    6    237 -1098 2141 -931 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1098 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=800 MHz`
50    6    237 -890 1640 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FSource=800 MHz`
50    6    237 -682 2161 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `CE_TimeStep=1/11.2e6/2`
50    6    237 -474 2535 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `SourcePower_dBm=-10 _dBm`
80    3    "Variable Value"    "list"    0    4    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "SourcePower_dBm"    0   0
80    5    ""    "VarValueForm"    0    0    "-10 _dBm"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/11.2e6/2"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FSource"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
41    27074060    0    16    "DUT"    "CktPAwithBias"    "CktPAwithBias"    2125 -2083 3443 -875 1    0 "" 0
    27357448    0    6    2125 -1375 0 1 1 0 0    0    105    0    0    1211410693    17  ""    2125 -1625 3125 -875 1    2334 -2083 3443 -1708 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -500 1318 -333 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -500 0    1    1    0    0    12    0   "Arial For CAE"   `CktPAwithBias`
40    7    0    0    0
50    6    209 -708 543 -541 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -708 0    1    2    0    0    12    0   "Arial For CAE"   `DUT`
43    28438148    0    ""    28521172    245    ""   0
43    28381204    0    ""    27162968    244    ""   0
43    28381350    0    ""    28554478    243    ""   0
43    28381422    0    ""    28514508    242    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
44    0    0    0    0    0    0    0
21

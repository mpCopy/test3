1     7.704    0 0
10    1    "EDGE_RF_PAE_test"    2    1215019971    0    8    341    0
20    0    ""    -4546 -6854 8375 1083 1    2 -3 1    1215012965    0    "mil_schematic.prf" "schematic.lay"
30    24270118    1    "RF_from_PA"    4    -1    0    24270074    24261868    25235076    0    4500 -875 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270074    1    "RF_to_PA"    1    1    24270206    24188964    24261868    25235062    0    -750 -875 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24188964    1    "VDC_Low_to_PA"    2    -1    24270250    24270162    24261868    25362910    0    250 -875 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270162    1    "VDC_High_to_PA"    3    -1    0    0    24261868    25226980    0    3500 -875 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270206    1    "P1"    1    2    0    24270250    25238412    25235062    0    -125 -2000 -180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270250    1    "VL"    2    2    0    24270294    25238412    25362910    0    250 -1500 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270294    1    "P4"    3    2    24270162    24270338    25238412    25226980    0    500 -1500 -90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    24270338    1    "P2"    4    2    24270118    0    25238412    25235076    0    875 -2000 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    24253082    1    24270074    1    24270206    0    0    0    ""  0
60    3    0    3    -750 -2000 -125 -875 1    0    0    0    0
70    -750 -875    -125 -2000
32    24133480    1    24270338    1    24270118    0    0    0    ""  0
60    2    0    3    875 -2000 4500 -875 1    0    0    0    0
70    875 -2000    4500 -875
32    24241010    1    24188964    1    24270250    0    0    0    ""  0
60    3    0    2    250 -1500 250 -875 1    0    0    0    0
70    250 -875    0 -1500
32    24270382    1    24270294    1    24270162    0    0    0    ""  0
60    3    0    3    500 -1500 3500 -875 1    0    0    0    0
70    500 -1500    3500 -875
40    4    0    0    0
50    4    -750 -2000 -125 -875 1    0    0    0    0    0    0    0    0    24253082
50    4    875 -2000 4500 -875 1    0    0    0    0    0    0    0    0    24133480
50    4    250 -1500 250 -875 1    0    0    0    0    0    0    0    0    24241010
50    4    500 -1500 3500 -875 1    0    0    0    0    0    0    0    0    24270382
50    1    5125 -5250 8375 375 1    0    0    0    0    0    0    0    0
60    4    0    4    5125 -5250 8375 375 1    0    0    0    0
70    5125 -5250    8375 -5250    8375 375    5125 375
40    10    0    0    0
50    6    1625 -1834 3021 -1333 1    0    0    0    0    0    0    0    0
62    0    167    9    1625 -1500 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this DUT 
with your own
CIRCUIT design.`
50    6    -3500 750 5717 1083 1    0    0    0    0    0    0    0    0
62    0    333    9    -3500 750 0    1    0    0    0    24    0   "Arial For CAE Bold"   `EDGE Power Amplifier Power Added Efficiency Test Bench`
50    6    5250 -5059 8208 223 1    0    0    0    0    0    0    0    0
62    0    139    9    5250 84 0    38    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. CE_TimeStep must be set to equal to or
    less then ((48/13) usec)/SamplesPerSymbol.
    SamplesPerSymbol is a RF_PAE
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
41    24261868    0    1073741848    "RF_PAE"    "EDGE_RF_PAE"    "EDGE_RF_PAE"    -4416 -2995 4750 375 1    0 "" 0
    24270118    0    2    -750 -875 0 1 1 0 0    0    105    0    0    1215012965    17  ""    -1000 -875 4750 375 1    -4416 -2995 -996 292 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -3666 1000 -2396 1167 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 1000 0    1    1    0    0    12    0   "Arial For CAE"   `EDGE_RF_PAE`
40    7    0    0    0
50    6    -3666 792 -2991 959 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 792 0    1    2    0    0    12    0   "Arial For CAE"   `RF_PAE`
40    8    0    0    0
50    6    -3666 -2120 -1738 -1953 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -2120 0    1    3    0    14    12    0   "Arial For CAE"   `NumFramesMeasured=2`
50    6    -3666 -1912 -566 -1745 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -1912 0    1    3    0    13    12    0   "Arial For CAE"   `FractionalFrameSegmentMeasured=1/8`
50    6    -3666 -1704 -752 -1537 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -1704 0    1    3    0    12    12    0   "Arial For CAE"   `FractionalFrameSegmentIgnored=5/8`
50    6    -3666 -1496 -1694 -1329 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -1496 0    1    3    0    11    12    0   "Arial For CAE"   `InitialStartUpDelay=0 sec`
50    6    -3666 -1288 -1516 -1121 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -1288 0    1    3    0    10    12    0   "Arial For CAE"   `EnableFrameMarkers=YES`
50    6    -3666 -1080 -1650 -913 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -1080 0    1    3    0    9    12    0   "Arial For CAE"   `EnableFrameGating=YES`
50    6    -3666 -872 -2342 -705 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -872 0    1    3    0    8    12    0   "Arial For CAE"   `VDC_High=5.8 V`
50    6    -3666 -664 -2351 -497 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -664 0    1    3    0    7    12    0   "Arial For CAE"   `VDC_Low=2.0 V`
50    6    -3666 -456 -1054 -289 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -456 0    1    3    0    6    12    0   "Arial For CAE"   `FrameSlotState="0 0 1 0 1 1 0 0"`
50    6    -3666 -248 -1934 -81 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -248 0    1    3    0    5    12    0   "Arial For CAE"   `SamplesPerSymbol=8`
50    6    -3666 -40 -1730 127 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 -40 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=FSource`
50    6    -3666 168 -246 335 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 168 0    1    3    0    3    12    0   "Arial For CAE"   `SourcePower=dbmtow(SourcePower_dBm)`
50    6    -3666 376 -2245 543 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 376 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=FSource`
50    6    -3666 584 -1392 751 1    0    0    0    0    0    0    0    0
62    0    167    9    -3666 584 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "FSource"    "StdForm"    0    0    "FSource"    0   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(SourcePower_dBm)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FSource"    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SamplesPerSymbol"    "StdForm"    0    0    "8"    0   0
80    5    "FrameSlotState"    "StringAndReference"    0    0    ""0 0 1 0 1 1 0 0""    0   0
80    5    "MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "VDC_Low"    "StdForm"    0    0    "2.0 V"    0   0
80    5    "VDC_High"    "StdForm"    0    0    "5.8 V"    0   0
80    6    "EnableFrameGating"    "_nEDGE_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    6    "EnableFrameMarkers"    "_nEDGE_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    5    "InitialStartUpDelay"    "StdForm"    0    0    "0 sec"    0   0
80    5    "FractionalFrameSegmentIgnored"    "StdForm"    0    0    "5/8"    0   0
80    5    "FractionalFrameSegmentMeasured"    "StdForm"    0    0    "1/8"    0   0
80    5    "NumFramesMeasured"    "StdForm"    0    0    "2"    0   0
41    24238106    0    16    "PAE_Information"    "EDGE_PAE_Information"    "EDGE_PAE_Information"    2000 -4208 4662 -2834 1    0 "" 0
    0    0    1    2000 -3750 0 1 1 0 0    0    97    0    0    1215012958    17  ""    2000 -3750 4662 -2834 1    2209 -4208 4039 -3833 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 2039 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `EDGE_PAE_Information`
40    7    0    0    0
50    6    209 -458 1472 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `PAE_Information`
41    24238244    0    1082130434    "Circuit_VAR"    "VAR"    "SYM_VAR"    -4546 -4598 -1696 -3391 1    0 "" 0
    0    0    3    -4375 -3500 90000 1 1 0 0    0    104    0    0    1213522046    17  ""    -4546 -3606 -4221 -3391 1    -4138 -4598 -1696 -3391 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 584 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 1179 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `Circuit_VAR`
40    8    0    0    0
50    6    237 -1098 2183 -931 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1098 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=800 MHz`
50    6    237 -890 1675 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FSource=800 MHz`
50    6    237 -682 2679 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `CE_TimeStep=((48/13) usec)/8`
50    6    237 -474 2580 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `SourcePower_dBm=-10 _dBm`
80    3    "Variable Value"    "list"    0    4    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "SourcePower_dBm"    0   0
80    5    ""    "VarValueForm"    0    0    "-10 _dBm"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "((48/13) usec)/8"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FSource"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
41    25195150    0    0    "Env1"    "Envelope"    "SYM_ENV"    2250 -6250 4200 -4700 1    0 "" 0
    0    0    5    2250 -4699 0 1 1 0 0    0    104    0    0    1211943050    17  ""    2250 -5168 4200 -4700 1    2459 -6250 3949 -5251 1    0 0 0 0 0 0
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
41    25205344    0    0    "SwpPlan2"    "SweepPlan"    "SYM_SWEEPPLAN"    -1501 -6854 551 -5125 1    0 "" 0
    0    0    8    -1500 -5125 0 1 1 0 0    0    104    0    0    1213284603    17  ""    -1501 -5564 551 -5125 1    -1292 -6854 -28 -5647 1    0 0 0 0 0 0
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
41    25205906    0    0    "Sweep"    "ParamSweep"    "SYM_PARAMSWEEP"    -1500 -4666 1555 -3324 1    0 "" 0
    0    0    4    -1499 -3325 0 1 1 0 0    0    104    0    0    1213514970    17  ""    -1500 -3792 1555 -3324 1    -1291 -4666 1213 -3875 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -717 1233 -550 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -717 0    1    1    0    0    12    0   "Arial For CAE"   `ParamSweep`
40    7    0    0    0
50    6    208 -925 727 -758 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -925 0    1    2    0    0    12    0   "Arial For CAE"   `Sweep`
40    8    0    0    0
50    6    208 -1341 2703 -1174 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1341 0    1    3    0    2    12    0   "Arial For CAE"   `SweepVar="SourcePower_dBm"`
50    6    208 -1133 2061 -966 1    0    0    0    0    0    0    0    0
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
41    25237828    0    0    "SwpPlan1"    "SweepPlan"    "SYM_SWEEPPLAN"    -4501 -6854 -1954 -5125 1    0 "" 0
    0    0    7    -4500 -5125 0 1 1 0 0    0    104    0    0    1213284624    17  ""    -4501 -5564 -2449 -5125 1    -4292 -6854 -1954 -5647 1    0 0 0 0 0 0
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
41    25238412    0    16    "DUT"    "CktPAwithBias"    "CktPAwithBias"    -125 -2708 1193 -1500 1    0 "" 0
    24270206    0    6    -125 -2000 0 1 1 0 0    0    105    0    0    1211410693    17  ""    -125 -2250 875 -1500 1    84 -2708 1193 -2333 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -500 1318 -333 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -500 0    1    1    0    0    12    0   "Arial For CAE"   `CktPAwithBias`
40    7    0    0    0
50    6    209 -708 543 -541 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -708 0    1    2    0    0    12    0   "Arial For CAE"   `DUT`
43    25226980    0    ""    24270294    32    ""   0
43    25362910    0    ""    24188964    31    ""   0
43    25235062    0    ""    24270074    30    ""   0
43    25235076    0    ""    24270338    29    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
44    0    0    0    0    0    0    0
21

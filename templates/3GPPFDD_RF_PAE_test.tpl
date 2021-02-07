# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/wtb/3GPPFDD_RF_PAE_test.tpl,v $ $Revision: 1.2 $ $Date: 2008/06/15 09:46:49 $
1     7.704    0 0
10    1    "3GPPFDD_RF_PAE_test"    2    1213521220    0    226    340    0
20    0    ""    -3921 -6500 9125 1458 1    2 -3 1    1213521194    0    "schematic.prf" "schematic.lay"
90    "VIEW_LAYER_NUMBER"  1  1 0 `4`
30    23980256    1    "RF_from_PA"    4    -1    0    27414258    23980152    27474316    0    5125 -500 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27414258    1    "RF_to_PA"    1    1    0    27414302    23980152    27183670    0    -125 -500 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27414302    1    "VDC_Low_to_PA"    2    -1    26499248    27414346    23980152    27170166    0    875 -500 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    27414346    1    "VDC_High_to_PA"    3    -1    0    0    23980152    27170152    0    4125 -500 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    26499204    1    "P1"    1    2    27414258    26499248    27169978    27183670    0    625 -1625 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    26499248    1    "VL"    2    2    0    26499292    27169978    27170166    0    1000 -1125 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    26499292    1    "P4"    3    2    27414346    26499336    27169978    27170152    0    1250 -1125 -90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    26499336    1    "P2"    4    2    23980256    0    27169978    27474316    0    1625 -1625 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    23978790    1    26499204    1    27414258    0    0    0    ""  0
60    3    0    3    -125 -1625 625 -500 1    0    0    0    0
70    625 -1625    -125 -500
32    23978750    1    26499336    1    23980256    0    0    0    ""  0
60    2    0    3    1625 -1625 5125 -500 1    0    0    0    0
70    1625 -1625    5125 -500
32    23978710    1    27414302    1    26499248    0    0    0    ""  0
60    3    0    3    875 -1125 1000 -500 1    0    0    0    0
70    875 -500    1000 -1125
32    23978670    1    26499292    1    27414346    0    0    0    ""  0
60    3    0    3    1250 -1125 4125 -500 1    0    0    0    0
70    1250 -1125    4125 -500
40    4    0    0    0
50    4    -125 -1625 625 -500 1    0    0    0    0    0    0    0    0    23978790
50    4    1625 -1625 5125 -500 1    0    0    0    0    0    0    0    0    23978750
50    4    875 -1125 1000 -500 1    0    0    0    0    0    0    0    0    23978710
50    4    1250 -1125 4125 -500 1    0    0    0    0    0    0    0    0    23978670
50    1    5875 -4875 9125 750 1    0    0    0    0    0    0    0    0
60    2    0    4    5875 -4875 9125 750 1    0    0    0    0
70    5875 -4875    9125 750    5875 0
40    5    0    0    0
40    10    0    0    0
50    6    -2750 1125 7733 1458 1    0    0    0    0    0    0    0    0
62    0    333    9    -2750 1125 0    1    0    0    0    24    0   "Arial For CAE Bold"   `3GPP FDD RF Power Amplifier Power Added Efficiency Test Bench`
50    6    6000 -4684 8970 598 1    0    0    0    0    0    0    0    0
62    0    139    9    6000 459 0    38    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. CE_TimeStep must be set to equal to or
    less then 1/3.84e6/SamplesPerChip.
    SamplesPerChip is an RF_PAE
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
50    6    2375 -1459 3843 -958 1    0    0    0    0    0    0    0    0
62    0    167    9    2375 -1125 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this DUT 
with your own
CIRCUIT design.`
40    12    0    0    0
41    23980152    0    1073741848    "RF_PAE"    "3GPPFDD_RF_PAE"    "3GPPFDD_RF_PAE"    -3916 -2828 5375 750 1    0 "" 0
    23980256    0    222    -125 -500 0 1 1 0 0    0    105    0    0    1213521194    17  ""    -375 -500 5375 750 1    -3916 -2828 -537 667 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -3791 1000 -2189 1167 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 1000 0    1    1    0    0    12    0   "Arial For CAE"   `3GPPFDD_RF_PAE`
40    7    0    0    0
50    6    -3791 792 -3115 959 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 792 0    1    2    0    0    12    0   "Arial For CAE"   `RF_PAE`
40    8    0    0    0
50    6    -3791 -2328 -2064 -2161 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -2328 0    1    3    0    15    12    0   "Arial For CAE"   `NumSlotsMeasured=2`
50    6    -3791 -2120 -1013 -1953 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -2120 0    1    3    0    14    12    0   "Arial For CAE"   `FractionalSlotSegmentMeasured=1`
50    6    -3791 -1912 -1201 -1745 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -1912 0    1    3    0    13    12    0   "Arial For CAE"   `FractionalSlotSegmentIgnored=0`
50    6    -3791 -1704 -1826 -1537 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -1704 0    1    3    0    12    12    0   "Arial For CAE"   `InitialStartUpDelay=0 sec`
50    6    -3791 -1496 -1864 -1329 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -1496 0    1    3    0    11    12    0   "Arial For CAE"   `EnableSlotMarkers=YES`
50    6    -3791 -1288 -1976 -1121 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -1288 0    1    3    0    10    12    0   "Arial For CAE"   `EnableSlotGating=YES`
50    6    -3791 -1080 -2464 -913 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -1080 0    1    3    0    9    12    0   "Arial For CAE"   `VDC_High=5.8 V`
50    6    -3791 -872 -2502 -705 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -872 0    1    3    0    8    12    0   "Arial For CAE"   `VDC_Low=2.0 V`
50    6    -3791 -664 -938 -497 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -664 0    1    3    0    7    12    0   "Arial For CAE"   `SourceType=TestModel1_16DPCHs`
50    6    -3791 -456 -2277 -289 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -456 0    1    3    0    6    12    0   "Arial For CAE"   `SamplesPerChip=2`
50    6    -3791 -248 -1576 -81 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -248 0    1    3    0    5    12    0   "Arial For CAE"   `SpecVersion=Version 12-00`
50    6    -3791 -40 -1313 127 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 -40 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -3791 168 -412 335 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 168 0    1    3    0    3    12    0   "Arial For CAE"   `SourcePower=dbmtow(SourcePower_dBm)`
50    6    -3791 376 -2339 543 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 376 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=FSource`
50    6    -3791 584 -1513 751 1    0    0    0    0    0    0    0    0
62    0    167    9    -3791 584 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
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
80    6    "SpecVersion"    "_n3GPPFDD_x5fRF_x5fPAE_fVersion_x5f12_x5f00"    0    0    ""    0   0
80    5    "SamplesPerChip"    "StdForm"    0    0    "2"    0   0
80    5    "FilterLength"    "StdForm"    0    0    "16"    1   0
80    6    "SourceType"    "_n3GPPFDD_x5fRF_x5fPAE_fTestModel1_x5f16DPCHs"    0    0    ""    0   0
80    5    "MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "VDC_Low"    "StdForm"    0    0    "2.0 V"    0   0
80    5    "VDC_High"    "StdForm"    0    0    "5.8 V"    0   0
80    6    "EnableSlotGating"    "_n3GPPFDD_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    6    "EnableSlotMarkers"    "_n3GPPFDD_x5fRF_x5fPAE_fYES"    0    0    ""    0   0
80    5    "InitialStartUpDelay"    "StdForm"    0    0    "0 sec"    0   0
80    5    "FractionalSlotSegmentIgnored"    "StdForm"    0    0    "0"    0   0
80    5    "FractionalSlotSegmentMeasured"    "StdForm"    0    0    "1"    0   0
80    5    "NumSlotsMeasured"    "StdForm"    0    0    "2"    0   0
41    27581898    0    0    "SwpPlan2"    "SweepPlan"    "SYM_SWEEPPLAN"    -750 -6500 1302 -4771 1    0 "" 0
    0    0    225    -749 -4771 0 1 1 0 0    0    104    0    0    1213284603    17  ""    -750 -5210 1302 -4771 1    -541 -6500 723 -5293 1    0 0 0 0 0 0
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
41    27521066    0    0    "Sweep"    "ParamSweep"    "SYM_PARAMSWEEP"    -750 -4416 2305 -3074 1    0 "" 0
    0    0    169    -749 -3075 0 1 1 0 0    0    104    0    0    1213521032    17  ""    -750 -3542 2305 -3074 1    -541 -4416 1986 -3625 1    0 0 0 0 0 0
40    6    0    0    0
50    6    208 -717 1246 -550 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -717 0    1    1    0    0    12    0   "Arial For CAE"   `ParamSweep`
40    7    0    0    0
50    6    208 -925 733 -758 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -925 0    1    2    0    0    12    0   "Arial For CAE"   `Sweep`
40    8    0    0    0
50    6    208 -1341 2735 -1174 1    0    0    0    0    0    0    0    0
62    0    167    9    208 -1341 0    1    3    0    2    12    0   "Arial For CAE"   `SweepVar="SourcePower_dBm"`
50    6    208 -1133 2084 -966 1    0    0    0    0    0    0    0    0
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
41    27579336    0    0    "Env1"    "Envelope"    "SYM_ENV"    3125 -6000 5075 -4450 1    0 "" 0
    0    0    149    3125 -4449 0 1 1 0 0    0    104    0    0    1211943050    17  ""    3125 -4918 5075 -4450 1    3334 -6000 4824 -5001 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 891 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 584 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `Env1`
40    8    0    0    0
50    6    209 -1551 1699 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1017 -1176 1    0    0    0    0    0    0    0    0
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
41    27183506    0    0    "SwpPlan1"    "SweepPlan"    "SYM_SWEEPPLAN"    -3875 -6500 -1237 -4771 1    0 "" 0
    0    0    226    -3874 -4771 0 1 1 0 0    0    104    0    0    1213284624    17  ""    -3875 -5210 -1823 -4771 1    -3666 -6500 -1237 -5293 1    0 0 0 0 0 0
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
41    26713344    0    1082130434    "Circuit_VAR"    "VAR"    "SYM_VAR"    -3921 -4348 -1149 -3141 1    0 "" 0
    0    0    152    -3750 -3250 90000 1 1 0 0    0    104    0    0    1213520944    17  ""    -3921 -3356 -3596 -3141 1    -3513 -4348 -1149 -3141 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 587 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 1188 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `Circuit_VAR`
40    8    0    0    0
50    6    237 -1098 2201 -931 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -1098 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=800 MHz`
50    6    237 -890 1688 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FSource=800 MHz`
50    6    237 -682 2451 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `CE_TimeStep=1/3.84 MHz/2`
50    6    237 -474 2601 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `SourcePower_dBm=-10 _dBm`
80    3    "Variable Value"    "list"    0    4    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "SourcePower_dBm"    0   0
80    5    ""    "VarValueForm"    0    0    "-10 _dBm"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1/3.84 MHz/2"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FSource"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
80    4    "Variable Value"    "VarFormEditcompPowerVar"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "800 MHz"    0   0
41    26695638    0    16    "PAE_Information"    "3GPPFDD_PAE_Information"    "3GPPFDD_PAE_Information"    2750 -3958 5412 -2584 1    0 "" 0
    0    0    224    2750 -3500 0 1 1 0 0    0    97    0    0    1212106630    17  ""    2750 -3500 5412 -2584 1    2959 -3958 4993 -3583 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -250 2243 -83 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -250 0    1    1    0    0    12    0   "Arial For CAE"   `3GPPFDD_PAE_Information`
40    7    0    0    0
50    6    209 -458 1395 -291 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -458 0    1    2    0    0    12    0   "Arial For CAE"   `PAE_Information`
41    27169978    0    16    "DUT"    "CktPAwithBias"    "CktPAwithBias"    625 -2333 1919 -1125 1    0 "" 0
    26499204    0    151    625 -1625 0 1 1 0 0    0    105    0    0    1211410693    17  ""    625 -1875 1625 -1125 1    834 -2333 1919 -1958 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -500 1294 -333 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -500 0    1    1    0    0    12    0   "Arial For CAE"   `CktPAwithBias`
40    7    0    0    0
50    6    209 -708 548 -541 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -708 0    1    2    0    0    12    0   "Arial For CAE"   `DUT`
43    27170152    0    ""    26499292    492    ""   0
43    27170166    0    ""    27414302    491    ""   0
43    27183670    0    ""    26499204    490    ""   0
43    27474316    0    ""    26499336    489    ""   0
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

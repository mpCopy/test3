1     7.702    0 0
10    1    "WMAN_DL_802_16e_TX_test"    2    1160448052    0    11    341    0
20    0    ""    0 -4250 10500 1958 1    2 -3 1    1159435816    0    "mil_schematic.prf" "schematic.lay"
90    "SIM_HOST_MODE"  3  1 0 `SingleHost`
90    "SIM_SWEEP_VAR"  3  1 0 `CE_TimeStep`
90    "SIM_SWEEP_START"  3  1 0 `1`
90    "SIM_SWEEP_STOP"  3  1 0 `10`
90    "SIM_SWEEP_STEP"  3  1 0 `1`
90    "SIM_BER_STATE"  3  1 0 `OFF`
90    "SIM_BER_NUMBER"  3  1 0 `5`
30    136515376    1    "Meas_in"    2    0    136521256    136515516    123675944    132069796    0    6250 -750 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    136515516    1    "RF_out"    1    1    136521396    0    123675944    132069136    0    4750 -750 90000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    136521396    1    ""    1    2    0    136521256    123352344    132069136    0    5000 500 180000    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
30    136521256    1    ""    2    2    0    0    123352344    132069796    0    6000 500 0    0   0   1   0   0   ""   0   ""   0   ""   ""   ""
32    113310712    1    136515516    1    136521396    0    0    0    ""  0
60    3    0    3    4750 -750 5000 500 1    0    0    0    0
70    4750 -750    5000 500
32    115456360    1    136515376    1    136521256    0    0    0    ""  0
60    3    0    3    6000 -750 6250 500 1    0    0    0    0
70    6250 -750    6000 500
40    4    0    0    0
50    4    4750 -750 5000 500 1    0    0    0    0    0    0    0    0    113310712
50    4    6000 -750 6250 500 1    0    0    0    0    0    0    0    0    115456360
50    1    7250 -4250 10500 1000 1    0    0    0    0    0    0    0    0
60    2    0    4    7250 -4250 10500 1000 1    0    0    0    0
70    7250 -4250    10500 1000    7250 0
40    10    0    0    0
50    6    7375 -4017 10194 848 1    0    0    0    0    0    0    0    0
62    0    139    9    7375 709 0    35    0    0    0    10    0   "Arial For CAE"   `Notes for setting up Envelope simulation:

1. Envelope simulation stop time is set by the
    wireless test bench measurements (not
    "Env Setup" Stop time);

2. Add additional tones to the "Env Setup" if
    tones other than FSource are required for
    Envelope analysis;

3. Enable AVM in "Cosim" setup if fast cosim
    with circuits is desired;

4. CE_TimeStep must be set to equal to or less
    than 1/RF_SamplingRate.
    Bandwidth and OversamplingOption are
    WMAN_DL_802_16e_TX Signal Parameters.


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
50    6    1750 1625 9254 1958 1    0    0    0    0    0    0    0    0
62    0    333    9    1750 1625 0    1    0    0    0    24    0   "Arial For CAE Bold"   `Mobile WiMAX Downlink Transmitter Test Bench`
50    6    3125 416 5070 917 1    0    0    0    0    0    0    0    0
62    0    167    9    3125 750 0    3    0    0    0    12    0   "Arial For CAE Bold Italic"   `Replace this "Amplifier2"
DUT with your own
CIRCUIT design.`
40    12    0    0    0
50    1    3000 -500 6500 1000 1    0    0    0    0    0    0    3    0
60    2    0    4    3000 -500 6500 1000 1    0    0    0    0
70    3000 -500    6500 1000    3000 0
41    123675944    0    1073741848    "WMAN_DL_802_16e_TX"    "WMAN_DL_802_16e_TX"    "SYM_DSN_WMAN_DL_802_16e_TX"    4500 -4205 7134 -745 1    0 "" 0
    136515376    0    6    4750 -750 0 1 1 0 0    0    105    0    0    1159435816    17  ""    4500 -1875 6500 -745 1    4709 -4205 7134 -1958 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -41 -1375 1808 -1208 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1375 0    1    1    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_TX`
40    7    0    0    0
50    6    -41 -1583 1808 -1416 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1583 0    1    2    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_TX`
40    8    0    0    0
50    6    -41 -3455 1744 -3288 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -3455 0    1    3    0    9    12    0   "Arial For CAE"   `EVM_Measurement=NO`
50    6    -41 -3247 2000 -3080 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -3247 0    1    3    0    8    12    0   "Arial For CAE"   `SpectrumMeasurement=NO`
50    6    -41 -3039 1771 -2872 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -3039 0    1    3    0    7    12    0   "Arial For CAE"   `PowerMeasurement=NO`
50    6    -41 -2831 1259 -2664 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -2831 0    1    3    0    6    12    0   "Arial For CAE"   `Constellation=NO`
50    6    -41 -2623 2384 -2456 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -2623 0    1    3    0    5    12    0   "Arial For CAE"   `RF_EnvelopeMeasurement=YES`
50    6    -41 -2415 2256 -2248 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -2415 0    1    3    0    4    12    0   "Arial For CAE"   `FMeasurement=FMeasurement`
50    6    -41 -2207 1908 -2040 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -2207 0    1    3    0    3    12    0   "Arial For CAE"   `SourcePower=dbmtow(10)`
50    6    -41 -1999 1304 -1832 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1999 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=FSource`
50    6    -41 -1791 2110 -1624 1    0    0    0    0    0    0    0    0
62    0    167    9    -41 -1791 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=CE_TimeStep`
80    5    "RequiredParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "CE_TimeStep"    "StdForm"    0    0    "CE_TimeStep"    0   0
80    5    "WTB_TimeStep"    "StringAndReference"    0    0    """"    1   0
80    5    "FSource"    "StdForm"    0    0    "FSource"    0   0
80    5    "SourcePower"    "StdForm"    0    0    "dbmtow(10)"    0   0
80    5    "FMeasurement"    "StdForm"    0    0    "FMeasurement"    0   0
80    5    "MeasurementInfo"    "StringAndReference"    0    0    """"    1   0
80    6    "RF_EnvelopeMeasurement"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    0   0
80    6    "Constellation"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    0   0
80    6    "PowerMeasurement"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    0   0
80    6    "SpectrumMeasurement"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    0   0
80    6    "EVM_Measurement"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    0   0
80    5    "BasicParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SourceR"    "StdForm"    0    0    "50 Ohm"    1   0
80    5    "SourceTemp"    "StdForm"    0    0    "-273.15"    1   0
80    6    "EnableSourceNoise"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "MeasR"    "StdForm"    0    0    "50 Ohm"    1   0
80    6    "MirrorSourceSpectrum"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "MirrorMeasSpectrum"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "RF_MirrorFreq"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "MeasMirrorFreq"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "TestBenchSeed"    "StdForm"    0    0    "1234567"    1   0
80    5    "SignalParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "GainImbalance"    "StdForm"    0    0    "0.0 dB"    1   0
80    5    "PhaseImbalance"    "StdForm"    0    0    "0.0"    1   0
80    5    "I_OriginOffset"    "StdForm"    0    0    "0.0"    1   0
80    5    "Q_OriginOffset"    "StdForm"    0    0    "0.0"    1   0
80    5    "IQ_Rotation"    "StdForm"    0    0    "0.0"    1   0
80    5    "Bandwidth"    "StdForm"    0    0    "10 MHz"    1   0
80    6    "OversamplingOption"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fRatio_x5f2"    0    0    ""    1   0
80    6    "FFTSize"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fFFT_x5f1024"    0    0    ""    1   0
80    5    "CyclicPrefix"    "StdForm"    0    0    "0.125"    1   0
80    6    "FrameMode"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fTDD"    0    0    ""    1   0
80    5    "DL_Ratio"    "StdForm"    0    0    "0.5"    1   0
80    6    "FrameDuration"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_ftime_x5f5_x5fms"    0    0    ""    1   0
80    6    "DLMAP_Enable"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "ULMAP_Enable"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "PreambleIndex"    "StdForm"    0    0    "3"    1   0
80    5    "FrameNumber"    "StdForm"    0    0    "0"    1   0
80    6    "FrameIncreased"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "DL_PermBase"    "StdForm"    0    0    "9"    1   0
80    5    "DCD_Count"    "StdForm"    0    0    "1"    1   0
80    5    "BSID"    "StringAndReference"    0    0    "{0X00, 0X00, 0X00, 0X00, 0X00, 0X01}"    1   0
80    5    "PRBS_ID"    "StdForm"    0    0    "0"    1   0
80    6    "DataPattern"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fPN9"    0    0    ""    1   0
80    6    "AutoMACHeaderSetting"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    5    "MAC_Header"    "StringAndReference"    0    0    "{0XA2, 0X48, 0X22, 0X4F, 0X93, 0X0E}"    1   0
80    6    "CRC32_Mode"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fMSB_x5ffirst"    0    0    ""    1   0
80    6    "ZoneType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fDL_x5fPUSC"    0    0    ""    1   0
80    5    "ZoneNumOfSym"    "StdForm"    0    0    "4"    1   0
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
80    5    "DLMAP_CodingType"    "StdForm"    0    0    "0"    1   0
80    5    "DLMAP_RepetitionCoding"    "StdForm"    0    0    "0"    1   0
80    5    "ULMAP_CodingType"    "StdForm"    0    0    "0"    1   0
80    5    "ULMAP_Rate_ID"    "StdForm"    0    0    "0"    1   0
80    5    "ULMAP_RepetitionCoding"    "StdForm"    0    0    "0"    1   0
80    5    "ULMAP_PowerBoosting"    "StdForm"    0    0    "0"    1   0
80    6    "UL_ZoneType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fUL_x5fPUSC"    0    0    ""    1   0
80    5    "UL_ZoneSymOffset"    "StdForm"    0    0    "0"    1   0
80    5    "UL_ZoneNumOfSym"    "StdForm"    0    0    "24"    1   0
80    5    "UL_PermBase"    "StdForm"    0    0    "0"    1   0
80    6    "UL_AllSCIndicator"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "UCD_Count"    "StdForm"    0    0    "1"    1   0
80    5    "UL_NumberOfBurst"    "StdForm"    0    0    "1"    1   0
80    5    "UL_CID"    "StringAndReference"    0    0    "{1}"    1   0
80    5    "UL_CodingType"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "UL_Rate_ID"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "UL_BurstAssignedSlot"    "StringAndReference"    0    0    "{96}"    1   0
80    5    "UL_RepetitionCoding"    "StringAndReference"    0    0    "{0}"    1   0
80    5    "RF_EnvelopeMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "RF_EnvelopeDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "RF_EnvelopeStart"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "RF_EnvelopeStop"    "StdForm"    0    0    "5 msec"    1   0
80    5    "RF_EnvelopeBursts"    "StdForm"    0    0    "3"    1   0
80    5    "ConstellationParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "ConstellationDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "PowerMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "PowerDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "PowerBursts"    "StdForm"    0    0    "3"    1   0
80    5    "SpectrumMeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "SpectrumDisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "SpecMeasStart"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "SpecMeasStop"    "StdForm"    0    0    "5 msec"    1   0
80    5    "SpecMeasBursts"    "StdForm"    0    0    "3"    1   0
80    5    "SpecMeasResBW"    "StdForm"    0    0    "100 kHz"    1   0
80    6    "SpecMeasWindow"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fKaiser_x5f7_x5f865"    0    0    ""    1   0
80    5    "EVM_MeasurementParameters"    "StringAndReference"    0    0    ""Category""    1   0
80    5    "EVM_DisplayPages"    "StringAndReference"    0    0    """"    1   0
80    5    "EVM_Start"    "StdForm"    0    0    "0.0 sec"    1   0
80    6    "EVM_AverageType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fRMS_x5f_x5fVideo_x5f"    0    0    ""    1   0
80    5    "EVM_FramesToAverage"    "StdForm"    0    0    "5"    1   0
80    6    "EVM_PulseSearch"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    5    "EVM_SymbolTimingAdjust"    "StdForm"    0    0    "-3.125"    1   0
80    6    "EVM_TrackAmplitude"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "EVM_TrackPhase"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    6    "EVM_TrackTiming"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    6    "EVM_EqualizerTraining"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fChan_x5fEstimation_x5fSeq_x5fOnly"    0    0    ""    1   0
80    5    "SignalToESG_Parameters"    "StringAndReference"    0    0    ""Category""    1   0
80    6    "EnableESG"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fNO"    0    0    ""    1   0
80    5    "ESG_Instrument"    "InstrumentForm"    0    0    ""[GPIB0::19::INSTR][localhost][4790]""    1   0
80    5    "ESG_Start"    "StdForm"    0    0    "0.0 sec"    1   0
80    5    "ESG_Stop"    "StdForm"    0    0    "100.0 usec"    1   0
80    5    "ESG_Bursts"    "StdForm"    0    0    "3"    1   0
80    5    "ESG_Power"    "StdForm"    0    0    "-20.0"    1   0
80    6    "ESG_ClkRef"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fInternal"    0    0    ""    1   0
80    5    "ESG_ExtClkRefFreq"    "StdForm"    0    0    "10 MHz"    1   0
80    6    "ESG_IQFilter"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fthrough"    0    0    ""    1   0
80    5    "ESG_SampleClkRate"    "StdForm"    0    0    "80 MHz"    1   0
80    5    "ESG_Filename"    "StringAndReference"    0    0    ""WMAN_DL_16e""    1   0
80    6    "ESG_AutoScaling"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_ArbOn"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_RFPowOn"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fYES"    0    0    ""    1   0
80    6    "ESG_EventMarkerType"    "_nWMAN_x5fDL_x5f802_x5f16e_x5fTX_fEvent1"    0    0    ""    1   0
80    5    "ESG_MarkerLength"    "StdForm"    0    0    "10"    1   0
41    123454736    0    1073741840    "Information"    "WMAN_DL_802_16e_TX_Info"    "SYM_DSN_WMAN_DL_802_16e_TX_Info"    0 -625 2662 809 1    0 "" 0
    0    0    11    0 -107 0 1 1 0 0    0    104    0    0    1158659917    17  ""    0 -107 2662 809 1    84 -625 2284 -250 1    0 0 0 0 0 0
40    6    0    0    0
50    6    84 -310 2284 -143 1    0    0    0    0    0    0    0    0
62    0    167    9    84 -310 0    1    1    0    0    12    0   "Arial For CAE"   `WMAN_DL_802_16e_TX_Info`
40    7    0    0    0
50    6    84 -518 899 -351 1    0    0    0    0    0    0    0    0
62    0    167    9    84 -518 0    1    2    0    0    12    0   "Arial For CAE"   `Information`
41    123468728    0    1082130434    "VAR1"    "VAR"    "SYM_VAR"    79 -4015 2720 -3016 1    0 "" 0
    0    0    2    250 -3125 90000 1 1 0 0    0    104    0    0    1156390402    17  ""    79 -3231 404 -3016 1    487 -4015 2720 -3016 1    0 0 0 0 0 0
40    6    0    0    0
50    6    237 -58 557 109 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -58 0    1    1    0    0    12    0   "Arial For CAE"   `VAR`
40    7    0    0    0
50    6    237 -266 649 -99 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -266 0    1    2    0    0    12    0   "Arial For CAE"   `VAR1`
40    8    0    0    0
50    6    237 -890 2314 -723 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -890 0    1    3    0    3    12    0   "Arial For CAE"   `FMeasurement=3407.0 MHz`
50    6    237 -682 1838 -515 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -682 0    1    3    0    2    12    0   "Arial For CAE"   `FSource=3407.0 MHz`
50    6    237 -474 2470 -307 1    0    0    0    0    0    0    0    0
62    0    167    9    237 -474 0    1    3    0    1    12    0   "Arial For CAE"   `CE_TimeStep=1.0/11.2 MHz/4`
80    3    "Variable Value"    "list"    0    3    ""    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "CE_TimeStep"    0   0
80    5    ""    "VarValueForm"    0    0    "1.0/11.2 MHz/4"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FSource"    0   0
80    5    ""    "VarValueForm"    0    0    "3407.0 MHz"    0   0
80    4    "Variable Value"    "VarFormStdForm"    0    2    ""    0   0
80    5    ""    "VarNameForm"    0    0    "FMeasurement"    0   0
80    5    ""    "VarValueForm"    0    0    "3407.0 MHz"    0   0
41    123236536    0    0    "WTB"    "Envelope"    "SYM_ENV"    0 -2634 2181 -876 1    0 "" 0
    0    0    3    0 -875 0 1 1 0 0    0    104    0    0    1156390134    17  ""    0 -1344 1950 -876 1    209 -2634 1649 -1427 1    0 0 0 0 0 0
40    6    0    0    0
50    6    209 -719 1112 -552 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -719 0    1    1    0    0    12    0   "Arial For CAE"   `Envelope`
40    7    0    0    0
50    6    209 -927 695 -760 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -927 0    1    2    0    0    12    0   "Arial For CAE"   `WTB`
40    8    0    0    0
50    6    209 -1759 1501 -1592 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1759 0    1    3    0    4    12    0   "Arial For CAE"   `ABM_Mode=`
50    6    209 -1551 2181 -1384 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1551 0    1    3    0    3    12    0   "Arial For CAE"   `Step=CE_TimeStep`
50    6    209 -1343 1251 -1176 1    0    0    0    0    0    0    0    0
62    0    167    9    209 -1343 0    1    3    0    2    12    0   "Arial For CAE"   `Order[1]=3`
50    6    209 -1135 1862 -968 1    0    0    0    0    0    0    0    0
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
80    5    "TAHB_Enable"    "StdForm"    0    0    ""    1   0
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
41    123352344    0    1073741824    "DUT"    "Amplifier2"    "SYM_Amplifier"    4834 -333 6000 875 1    0 "" 0
    136521396    0    5    5000 500 0 1 1 0 0    0    105    0    0    1081385571    17  ""    5000 125 6000 875 1    4834 -333 5574 42 1    0 0 0 0 0 0
40    6    0    0    0
50    6    -166 -625 574 -458 1    0    0    0    0    0    0    0    0
62    0    167    9    -166 -625 0    1    1    0    0    12    0   "Arial For CAE"   `Amplifier2`
40    7    0    0    0
50    6    -166 -833 170 -666 1    0    0    0    0    0    0    0    0
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
43    132069136    0    ""    136515516    62    ""   0
43    132069796    0    ""    136515376    61    ""   0
44    0    0    0    0    0    0    0
21
20    1    ""    0 0 0 0 0    1 -4 1    0    0    "mil_layout.prf" "layout.lay"
90    "FRQPLN0"  3  1 0 `10 1 1 0 GHz GHz GHz`
90    "AFS_STATE"  3  1 0 `0 25 1 0 0.000000 0.000000 GHz GHz uninit 0 local 0 Presentation1 1 0`
44    0    0    0    0    0    0    0
21

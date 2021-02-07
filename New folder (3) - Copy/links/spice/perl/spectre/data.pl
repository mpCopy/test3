#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

# If we are inside of a Spectre "section" the
# name gets stored here. This is needed so we
# can properly process subcircuits contained
# within sections.
$CUR_SECTION = "";

# Keeps hash of resistors that have an
# InoiseBD element in parallel with it.
%Flicker = ();

# This gets set true when we are parsing
# user defined functions.
$GotFunction = 0;

#This gets set true when we are parsing if else block
$Found_ifElse=0;

#This acts as a global flag for statistics block
$Found_statistics=0;
# This acts as a global flag to find the exit of statistics block
$StatisticExit_Flag=0;

# This contains the user defined function
# It is used in conjunction with $GotFunction.
$UserFunction = "";

# This is used to store comments while parsing the file.
@clist = ();

# This is used to write out a WARNING message to
# the log file only once while parsing a subckt.
# This message is put out when we have subckt
# parameters that reference each other - ADS
# does not support this and a warning is put out.
$Equation_Msg_Toggle = 1;

# This is concatenated with ADS_VAR_ so we can
# generate unique variables for dynamically created
# equations. This is only used if $PreserveSubcktParams
# is enabled.
#
#  If we have:
#    pw=(sl*1e6!=200)*fach
# This gets translated to:
#    ADS_VAR_1=if (sl*1e6!=200) then 1 else 0 endif
#    pw=ADS_VAR_1*fach
#
$VarCnt = 0;

# This is related to the issue above and only used 
# if $PreserveSubcktParams is enabled.
@EqList = ();

# This is used to write out an informational statement
# to the log file only once when a section reference
# is found.
$Section_Msg_Toggle = 1;

# We need to strip off this character. Files
# modified under Windows will contain this character.
$CTRL_M = chr(13);

# This is used to keep track of all circuit parameter
# values that have equations. This allows us to check
# for parameters that reference each other.
@CktParamStack = ();

# It's possible to have separate "parameters" lines in a subckt - this
# keeps track of the number of ckt parameters.
@CKT_ValueCount_STACK = ();
$CKT_ValueCount = 0;

# This is set to 0 after we record the netlist header line.
# It's needed because recursive calls to read include files
# can set the $FirstTime flag to true...
$RecordHeader = 1;

# This is the main entry point into the Spectre to ADS param hash.
%SpecMap = ();

# This hash maps Spectre math functions into ADS functions
%FunctionMap = ();

# This is the name of the Spectre rules mapping file.
$rulesFile = "spectre.rul";

# Circuit Counter - This reflects the total number of circuits (starting at 0).
#  includes subcircuits and sections
$CKT = 0;

# Subcircuit Counter - This reflects the total number of subcircuits (starting at 0).
# This is only used to verify the number of subcircuits only.  Goes directly to
# the log output file for user comparison to number of subcircuits written.
$SUBCKT = 0;

# The current circuit we are parsing on - could change from $CKT if we are
# dealing with nested subcircuits.
$CUR_CKT = 0;

# The subcircuit stack level is pushed and popped as we traverse
# through nested subcircuits.
@CKT_STACK;

# Parameter Counter for the current circuit being parsed.
# When the circuit is done being parsed then
# "$SpiceCktT[$CUR_CKT]{numElements}=$PC" is set to "remember" the number of
# circuit elements so it can be recalled if we go back to parsing it later.
$PC = 0;

# If the first line of a spice file is a comment then this line is stored here
# if we are processing ADS gemini netlist output.
$geminiHeader = "";

$DefaultTemp = 0;
$lineCommChar = "";
$inlineCommChar = "";
$GeminiCommChar = ";";

# The following are indexes into the CallBack hash "$SpecMap{$comp}{CB}[x]"
# where "$comp" is some Spectre component type and "x" is an index below.
$outputTypeCB_idx = 0;
$pinCB_idx = 1;
$paramCB_idx = 2;
$modelCB_idx = 3;
$lastChanceCB_idx = 4;

# This hash is used to determine what files have already been
# "required()" during post processing. Once a Call Back has
# been read in a flag is to prevent it from being read in again.
%CB_fileRead = ();

# This hash returns "TRUE" if we
# encounter an ADS reserved word.
# It's configured in main.pl
%ADSReservedWord = ();

# This hash returns "TRUE" if we 
# encounter an illegal ADS subcircuit name.
# It's configured in main.pl
%ADSIllegalSubcktName = ();

$islegal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";

$islegal_subckt =
   "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-~";

$notlegal_node = "~*()[]{}/\\<>?,.:\" |';";

# These are ok to use but the node must be made a quoted string.
#   Note: the "\" in front of the "$" because strange things 
#         can happen when the split routine is run on this...
$islegal_node = "`@#&+-=^\$%!";

# This is to support the ability for the 
# user to toggle on and off warnings and
# or errors.
$PrintWarnings = 1;
$PrintErrors   = 1;

# This global gets toggled to "1" if we are processing
# a library section. Otherwise it stays "0". This is
# needed because "$Section" can be set but we might need
# to look through the file until the proper section is found.
# If $InSection=0 AND $Section="SomeSection" then we look
# through the file until "SomeSection" is found and then
# toggle $InSection=1
$InSection = 0;

# The current library section we are processing.
$Section = "";

# This keeps the Section names for nested includes.
@SectionHistory = ();

# Indicates if we just read an include file.
$IncludeJustRead = 0;

# This needs to be global because it contains the
# next line to be processed and it needs to be
# referenced in various places due to "include" file
# processing.
$next_line = "";

# $next_line gets pushed here when we process include files.
# When we are finished reading the include file we can reference
# this to pick up where we left off.
@SavedLine = ();

# This gets set to the first line of a bsim binning
# model. Once the line is stored here we gather all
# of the parameter data and then go back and store
# the model.
@BinningModel = ();

# Flag indicating that we are in the middle of processing
# a bin model.
$ProcessingBinModel = 0;

@BinList = ();

@ParamStruct = 
{
   name      => "",
   value     => "",
   unitType  => -1,
   check     => 1,    # TRUE if param needs to be checked in post-processing
   used      => 1
};

@PinStruct = { name      => "" };

@SpiceElement =
{
   ItemType    => "",  # Element, Model, or subcircuit
   outputType  => "",  # If element - which type resistor, capacitor etc...
   SpectreType => "",  # This holds the Spectre name for the component
   tmpType     => "",  # This holds the Spectre data type. The post 
                       # processing will use this to set outputType.
   tagName     => "",  # Name of device
   bsimName    => "",  # Original name of a bsim model. Spectre uses
                       # one model name to reference the binning
                       # characteristics. ADS requires separate
                       # models so we append "_1", "_2" etc to the
                       # the original bsim name. We need the original
                       # bsim name to match up referencing components
                       # in post processing.

   subcktName  => "",  # Name of subcircuit
   numPins     => 0,
   pinArray    => [ @PinStruct ],
   numParams   => 0,   # This is the number of Spectre params
   $paramArray => [ @ParamStruct ],
   used        => 0,   # This is checked on the C side and a warning is
                       # issued if the component is not found in the
                       # spectre.rul file and it's not a model reference.
   includeRef  => 0,   # For elements that reference models, we need to
                       # record if it's in an include file. This is to
                       # support the supression of components in subcircuits 
                       # when $SuppressIncludeComponents is set from the
                       # command line. It's used in post processing.
   cktDuplicateIndex => 0 # If the same subcircuit name is contained in 
                          # multiple sections, it's "index" refers to
                          # which subcircuit to search for.
};

@VarStructT {
    name     => "",
    value    => ""
};

$SpiceCktT =
{
   name           => "",
   numPins        => "",
   pinArray       => [ @PinStruct ],
   numParams      => "", 
   $paramArray    => [ @ParamStruct ],
   numElements    => "",
   elementArray   => [ @SpiceElement ],
   $varArray      => [ @VarStructT ],  # For .param statements...
   numWires       => 0,
   paramReference => 0
};

%ItemType = 
(
   comment    => 0,
   element    => 1,
   model      => 2,
   data_item  => 3, # netlist output looks like an element, but it has no pins like a model
   var        => 4,
   subcir     => 5,
   subcir_def => 6, # place holder in ckt0 for original location of .subckt line
   lib_section_ref => 7,
   lib_section_def => 8,
   ahdl_include => 9,
   spectre_lang_ref=> 10,
   inline_subcir_def=> 11
);

%ModelType = 
(
   UNKNOWN_MODEL => -1,
   NPN_MODEL     => 0,
   PNP_MODEL     => 1,
   D_MODEL       => 2,
   NJF_MODEL     => 3,
   PJF_MODEL     => 4,
   NMOS_MODEL    => 5,
   PMOS_MODEL    => 6,
   NMF_MODEL     => 7,
   PMF_MODEL     => 8,
   GASFET_MODEL  => 9,
   LTRA_MODEL    => 10,
   URC_MODEL     => 11,
   TRN_MODEL     => 12,
   SPICE_R_MODEL => 13,
   SPICE_C_MODEL => 14,
   SPICE_L_MODEL => 15,
   MM9_MODEL     => 16
);

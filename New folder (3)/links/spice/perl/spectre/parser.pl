#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# read_component()
#
#   Spectre syntax for a COMPONENT is as follows:
#
#      instance (node 1 node 2 ...) component param=value ....
#
#   In order to figure out where to start parsing the file we need to find
#   the first name/value pair. Once that is found we have knowledge of where
#   things are.
#
#   NOTE: We just store the data here - we don't make any determination
#         as to it's type. We don't set outputType here - it's
#         taken care of in the post processing.
#
###############################################################################
sub read_component
{
   my (@L) = @_;

   my $numParams=0, my $index=0, my $MinElemParams=3;
   my $tagName="", my $store="", my $done=0, my $x=0;
   my $circ_with_no_params=0, my $NumOfDefaults=0;
   my $analogmodel=0;
   my $temp_x=0, my $NonLinComp=0;

   $numParams = @L;

   if (($numParams <= $MinElemParams) && @L[1] ne "options")
   {
      #print("** Warning: Not enough component parameters ($numParams).\n");
      #print("            Skipping \"(@L)\"\n");
      if ($PrintWarnings)
      {
         &main::WriteToLog("WARNING: Not enough parameters ($numParams)\n");
         &main::WriteToLog("         Skipping \"@L\"");
      } # if
      return(FALSE);
   } # if

   #########################################################
   # Since there could be multiple nodes the only way to
   # determine the starting point is to find the first name
   # value pair and work backwards. The first element before
   # that is the component type (i.e. resistor, capacitor
   # etc...). 
   #########################################################
   $x = 0;
   while (!($done))
   {
      if ($x > (@L-1)) { $done = 1; $circ_with_no_params=1;} # Probably have a subckt reference
      elsif ((@L[$x] =~ /=/) || (@L[$x] eq "=")) { $done = 1; }
      else { $x++; }
   } # while

   # We save the indexing into the parameters
   # by setting $paramIndex to $x.
   if (@L[$x] =~ /^=/) { $x--; }
   $paramIndex = $x;

   # Now decrement so we're looking at the component reference
   $x--;
   
   # When we have '(' as component type in case of parenthesis then skip this
   # e.g: Rr25 (MINUS 5)  resistor  ( r = rval4) Spectre_Trans.200 Ramesh
   if (@L[$x] eq '(')
   { $x--; }
   # analogmodel is a special case. See spectre -h analogmodel
   if (@L[$x] eq "analogmodel") { $analogmodel = 1; }

   # Store the Spectre component reference so that
   # outputType and ItemType can be set in post processing.
   &main::Record_LiteralElementTypeE(@L[$x],$PC);
   
   if( !$backwardCompatible && (@L[$x] eq "cccs"||@L[$x] eq "ccvs"||@L[$x] eq "vccs"||@L[$x] eq "vcvs" ||
      @L[$x] eq "pcccs"||@L[$x] eq "pccvs"||@L[$x] eq "pvccs"||@L[$x] eq "pvcvs" ||@L[$x] eq "bsource" || 
      @L[$x] eq "options" || @L[$x] eq "paramtest"))
   {
      if($WantGeminiOutput)
      {
         # Record this as spectre_lang_ref type as opposed to an element, model or subcircuit etc.)
         &Record_ItemType($CUR_CKT,$ItemType{spectre_lang_ref},$PC);
      }
   }
   elsif(!$backwardCompatible && (@L[$x] eq "resistor" ||@L[$x] eq "capacitor"||@L[$x] eq "inductor")) 
   {  
     $temp_x=$x+1;
     while( ($temp_x)< @L)
     {   
       #Check for r=v(...), r=i(...),c=v(...), c=i(...),l=v(...), l=i(...)
       #e.g: r=rmid*mmatr*s/pbar*v(1,2)
       if((@L[$temp_x]  =~ /\=.+v\(.+\)/i) || (@L[$temp_x]  =~/\=.+i\(.+\)/i))
	{  &Record_ItemType($CUR_CKT,$ItemType{spectre_lang_ref},$PC);$NonLinComp=1;}
       $temp_x++;
     }
     if(!$NonLinComp)
        {
	  &Record_ItemType($CUR_CKT,$ItemType{element},$PC);
	  $NumOfDefaults = &RecordDefaults("element");
	  $NonLinComp=0;
	}
   }
   elsif( $backwardCompatible && (@L[$x] eq "bsource" || @L[$x] eq "options"))
   {
      print("ADS Netlist Translator doesn't support element \" @L[$x]\" with \"-bc\" option \n");
      WriteToLog("WARNING:ADS Netlist Translator doesn't support element \" @L[$x]\" with \"-bc\" option \n");
      # Record this as comment type (as opposed to spectre_lang_ref, element or subcircuit etc.)
      &Record_ItemType($CUR_CKT,$ItemType{comment},$PC);
   }
   else
   {
      # Record this as an element type (as opposed to a model or subcircuit etc.)
      &Record_ItemType($CUR_CKT,$ItemType{element},$PC);

      # We need to store any parameters that have default values set in the
      # spectre.rul file. The parameter values can be overridden in the 
      # &RecordParams() call below.
      # NOTE: In &RecordParams we need to check if a value has already 
      #       been set and override the value. The reason we need to 
      #       do a check is because we don't want to reallocate another
      #       parameter with the same name. It is here that we set a value called
      #       $NumOfDefaults. Every parameter we encounter in &RecordParams()
      #       is checked against all of the defaults (we search from 0 to 
      #       $NumOfDefaults-1).
      #
      $NumOfDefaults = &RecordDefaults("element");
   }
   # Decrement to start indexing into the nodes.   
   $x--;
   &RecordRawNodes($x, $CUR_CKT, @L);

   &Record_name(@L[0],$PC);

   # Now it's time to save all of the parameters for this component.
   # Note: These parameter names are stored in raw form and mapped into
   #       the proper ADS names during post processing.
   if (!($circ_with_no_params))
      { &RecordParams($NumOfDefaults, $paramIndex, @L); }

   if ($analogmodel)
   {
      # We have to search for the "modelname" parameter and 
      # change it to "Model"....
      my $np = $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams};
      $x = 0;
      while ($x < $np)
      {
         if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$x]{name} eq "modelname")
         { 
            $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$x]{name} = "Model"; 
            last; # Jump out of here.
         }
         $x++;
      } # while

   } # if

   &RecordincludeRef($CUR_CKT, $PC);

   # If the element was part of an include file and
   # we are suppressing its output, then we check that here.
   if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef})
      { &Record_Usage($CUR_CKT,$PC,0); }
   else
      { &Record_Usage($CUR_CKT,$PC,1); }

   $main::PC++;  # Bump up the Parameter Counter

   return(TRUE);

} # sub read_component


###############################################################################
#
# read_model()
#
#   Spectre syntax for a MODEL is as follows:
#
#      model <name> <master> [<param1>=<value1> <param2>=<value2> ...]
#
#   The <master> refers to the type of model such as a resistor, bjt etc.
#
#   NOTE: We just store the data here - we don't make any determination
#         as to it's type. We don't set ItemType and outputType here - it's
#         taken care of in the post processing.
#
###############################################################################
sub read_model
{
   my (@L) = @_;

   my ($numParams, $index, $done, $x) = 0;
   my $MinModelParams = 2;
   my ($tagName, $store) = "";
   my $nameIndex = 1;  # The name of the model index is here.
   my $typeIndex = 2;  # The model type is indexed here.
   my $pramIndex = 3;  # The param name value pairs start indexing here.

   $numParams = @L;

   if ($numParams <= $MinModelParams)
   {
      print("** Warning: Not enough model parameters ($numParams).\n");
      print("            Skipping \"@L\"\n");
      &main::WriteToLog("WARNING: Not enough parameters ($numParams)\n");
      &main::WriteToLog("         Skipping \"@L\"");
      return(FALSE);
   } # if

   if ( (@L[$typeIndex] =~ /bsim/) && (@L[$typeIndex+1] =~ /\{/) )
   { 
      # Save the first line of the bsim binning model
      # and we'll let the file reader grab the next
      # line of parameters and then process those.
      @BinningModel = @L;
      $ProcessingBinModel = 1;
      return(TRUE);
   } # if

   # Store the Spectre component reference so that
   # outputType and ItemType can be set in post processing.
   &main::Record_LiteralElementTypeE(@L[$typeIndex],$PC);
   
   &Record_name(@L[$nameIndex],$PC);
   
   if( @L[$typeIndex] =~ /phy_res/ )
   {       
       $temp = join " ", @L;
       &Record_SpectreStatement($temp);   
       return(TRUE);  
   }
   else
   {
       # Record this as a model type (as opposed to a element or subcircuit etc.)
       &Record_ItemType($CUR_CKT,$ItemType{model},$PC);
   }
   
   # We need to store any parameters that have default values set in the
   # spectre.rul file. The parameter values can be overridden in the 
   # &RecordParams() call below.
   # NOTE: In &RecordParams we need to check if a value has already 
   #       been set and override the value. The reason we need to 
   #       do a check is because we don't want to reallocate another
   #       parameter with the same name. It is here that we set a value called
   #       $NumOfDefaults. Every parameter we encounter in &RecordParams()
   #       is checked against all of the defaults (we search from 0 to 
   #       $NumOfDefaults-1).
   #
   $NumOfDefaults = &RecordDefaults("model");

   # Now it's time to save all of the parameters for this component.
   # Note: There is no translation done here to ADS names. That will
   # be done in post processing.
   &RecordParams($NumOfDefaults, $pramIndex, @L);

   # Models contain no pins
   &main::Record_NumberOfPins(0, $PC);

   &RecordincludeRef($CUR_CKT, $PC);

   # If the model was part of an include file and
   # we are suppressing its output, then we check that here.
   if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef})
      { &Record_Usage($CUR_CKT,$PC,0); }
   else
      { &Record_Usage($CUR_CKT,$PC,1); }

   $main::PC++;  # Bump up the Parameter Counter

   # For unknown model in ADS return FALSE
   if($NumOfDefaults eq "FALSE")
   { return(FALSE);}
   
   else
   {return(TRUE);}
   

} # sub read_model

###############################################################################
#
# read_bsim()
#
#   Spectre syntax for a bsim model is as follows:
#
#      model modelName <type> parameter=value ...
#
#      NOTE: <type> may be either bsim1, bsim2, bsim3, or bsim3v3
#
#   Auto model selection (binning) has the following syntax:
#
#      model ModelName ModelType { 
#
#        1:     <model parameters> lmin=2 lmax=4 wmin=1 wmax=2 
#        2:     <model parameters> lmin=1 lmax=2 wmin=2 wmax=4 
#        3:     <model parameters> lmin=2 lmax=4 wmin=4 wmax=6 
#      }
#
###############################################################################
sub read_bsim
{
   my (@L) = @_;

   my $nameIndex = 1;  # The name of the model index is here.
   my $typeIndex = 2;  # The model type is indexed here.
   my $tmp = "";

#   print("(@L)\n");

   # Store the Spectre component reference so that
   # outputType and ItemType can be set in post processing.
   &main::Record_LiteralElementTypeE(@BinningModel[$typeIndex],$PC);

   # Record the name of the model. This name will be
   # used in post processing to set the "BinModel" 
   # card name. All referencing components will be
   # entered in this new model card with the setting
   # of the $tmp name below. Since the bin model sections
   # refer to the same model name we check to be sure
   # it's not already stored.
   $tmp = @BinList;

   # There is an issue of the same BinModel names being used in
   # different circuits. Here we first check to see if the previous
   # subcircuit was different than the one we are in now - if so
   # then go ahead and record the BinModel. If we are in the same
   # subcircuit as before then we just check to be sure the name
   # is different so we don't create multiple BinModel cards with
   # the same name. This was an issue with the JAZZ design kits.
   if (@BinList[$tmp-1] ne $CUR_CKT)
      { push(@BinList,@BinningModel[$nameIndex]); 
        push(@BinList,$CUR_CKT); }
   elsif (@BinList[$tmp-2] ne @BinningModel[$nameIndex])
      { push(@BinList,@BinningModel[$nameIndex]); 
        push(@BinList,$CUR_CKT); }

   # We need to breakout each model section into a 
   # separate model - here we create a unique name
   # by grabbing the model indexing number and appending
   # it to the name.
   ($tmp = @L[0]) =~ s/:.*//;
   $tmp = @BinningModel[$nameIndex] . "_" . $tmp;

   &Record_name($tmp,$PC);

   # We need the original bsim name to match up
   # referencing components in post processing.
   &Record_BSIM_name(@BinningModel[$nameIndex],$PC);

   # Record this as a model type (as opposed to a element or subcircuit etc.)
   &Record_ItemType($CUR_CKT,$ItemType{model},$PC);

   # We need to store any parameters that have default values set in the
   # spectre.rul file. The parameter values can be overridden in the 
   # &RecordParams() call below.
   # NOTE: In &RecordParams we need to check if a value has already 
   #       been set and override the value. The reason we need to 
   #       do a check is because we don't want to reallocate another
   #       parameter with the same name. It is here that we set a value called
   #       $NumOfDefaults. Every parameter we encounter in &RecordParams()
   #       is checked against all of the defaults (we search from 0 to 
   #       $NumOfDefaults-1).
   #
   $NumOfDefaults = &RecordDefaults("model");

   # Now it's time to save all of the parameters for this component.
   # Note: We will map the Xspice names to the ADS equivelent names.
   &RecordParams($NumOfDefaults, 1, @L);

   # Models contain no pins
   &main::Record_NumberOfPins(0, $PC);

   &RecordincludeRef($CUR_CKT, $PC);

   # If the element or model was part of an include file and
   # we are suppressing its output, then we check that here.
   if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef})
      { &Record_Usage($CUR_CKT,$PC,0); }
   else 
      { &Record_Usage($CUR_CKT,$PC,1); }

   $main::PC++;  # Bump up the Parameter Counter

   return(TRUE);

} # sub read_bsim


###############################################################################
#
# read_subckt()
#
#   Spectre syntax for a subcircuit is as follows:
#
# subckt SubcircuitName [(] node1 ... nodeN [)]
#             [ parameters name1=value1 ... [nameN=valueN]]
#     .
#     .
#     .
#
# ends [SubcircuitName]
#
###############################################################################
sub read_subckt
{
   my (@L) = @_;

   my ($x, $numPins, $params, $numParams) = 0;
   my $cktName="";
   my $MinElemParams=2;

   $numParams = @L;

   # We can have "inline subckt" or just "subckt" - we
   # adjust accordingly here...
   # 2005A onwards "inline subckt" handled by sub read_inline_subckt  Ramesh
   
   if (@L[1] =~ /\(/)
   {
      # We have something like "cktName(pin1"...
      $cktName = $`;
      @L[1] =~ s/.*\(//;
      $x = 1;
   } # if
   else { $cktName = @L[1]; $x = 2; }

   # If this subcircuit is contained within a Spectre "section" 
   # we record that here.
   if ($CUR_SECTION)
   {
      my $x = $SpiceCktT[$CUR_CKT]{numElements};
      &Record_Usage($CUR_CKT,$x,1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tagName} = $cktName;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{cktDuplicateIndex} = &CheckDuplicateCKT_Names($cktName);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{ItemType} = $ItemType{subcir_def};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numParams} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numPins} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tmpType} = "resolved";
      $SpiceCktT[$CUR_CKT]{numElements}++;
      $PC=$SpiceCktT[$CUR_CKT]{numElements};
   } # if

   &InitializeNewCkt;

   while ($x < (@L))
   {
      #if (@L[$x] eq "(") { } #just ignore
      if (@L[$x] eq "(" || @L[$x] eq "") { } #ignore "" Spectre_Tran.217   Ramesh Jan31,05
      elsif (@L[$x] =~ /\(/)
      {
         # Strip off the paren
         @L[$x] =~ s/\(//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif

      elsif    (@L[$x] eq ")") { } #just ignore
      elsif (@L[$x] =~ /\)/)
      {
         # Strip off the paren
         @L[$x] =~ s/\)//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif
      else
      {
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # else

      $x++;
   } # while

   &store_subckt_def($CUR_CKT, $cktName, $numPins);

   # Be sure to check that we are allowing include file 
   # subcircuits and components to be output.
   # See Spectre_Tran.37
   if (! (($IncludeCount >= 0) && $SuppressIncludeComponents))
   {
         # We now need to store this subcircuit reference
         # into the top level circuit (0) so it can be looked
         # up later in the C code by the writer. We don't do
         # this if this subcircuit is contained within a "section"
         # (which is considered internally to our data structure as
         # a subcircuit).
         if (! ($CUR_SECTION))
         {
            $x = $SpiceCktT[0]{numElements};
            &Record_Usage(0,$x,1);
            $SpiceCktT[0]->{elementArray}[$x]->{tagName} = $cktName;
            $SpiceCktT[0]->{elementArray}[$x]->{ItemType} = $ItemType{subcir_def};
            $SpiceCktT[0]->{elementArray}[$x]->{tmpType} = "resolved";
            $SpiceCktT[0]{numElements}++;
         } # if
   } # if

   #print("name      = ($SpiceCktT[$CUR_CKT]{name})\n");
   #print("pins      = ($SpiceCktT[$CUR_CKT]{numPins})\n");
   #print("numParams = ($SpiceCktT[$CUR_CKT]{numParams})\n");

   return(TRUE);
} # sub read_subckt
sub read_inline_subckt
{
   my (@L) = @_;

   my ($x, $numPins, $params, $numParams) = 0;
   my $cktName="";
   my $MinElemParams=2;

   $numParams = @L;

  if (@L[2] =~ /\(/)
      {
         # We have something like "cktName(pin1"...
         $cktName = $`;
         @L[2] =~ s/.*\(//;
         $x = 2;
      } # if
      else { $cktName = @L[2]; $x = 3; }
  
   # If this subcircuit is contained within a Spectre "section" 
   # we record that here.
   if ($CUR_SECTION)
   {
      #print("parser.pl: Reading subckt in the section: $CUR_CKT:$cktName \n");
      my $x = $SpiceCktT[$CUR_CKT]{numElements};
      &Record_Usage($CUR_CKT,$x,1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tagName} = $cktName;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{cktDuplicateIndex} = &CheckDuplicateCKT_Names($cktName);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{ItemType} = $ItemType{inline_subcir_def};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numParams} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numPins} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tmpType} = "resolved";
      $SpiceCktT[$CUR_CKT]{numElements}++;
      $PC=$SpiceCktT[$CUR_CKT]{numElements};
   } # if

   &InitializeNewCkt;

   while ($x < (@L))
   {
      #if (@L[$x] eq "(") { } #just ignore
      if (@L[$x] eq "(" || @L[$x] eq "") { } #ignore "" Spectre_Tran.217   Ramesh Jan31,05
      elsif (@L[$x] =~ /\(/)
      {
         # Strip off the paren
         @L[$x] =~ s/\(//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif

      elsif    (@L[$x] eq ")") { } #just ignore
      elsif (@L[$x] =~ /\)/)
      {
         # Strip off the paren
         @L[$x] =~ s/\)//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif
      else
      {
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # else

      $x++;
   } # while
   
   &store_subckt_def($CUR_CKT, $cktName, $numPins);
   
   # Be sure to check that we are allowing include file 
   # subcircuits and components to be output.
   # See Spectre_Tran.37
   if (! (($IncludeCount >= 0) && $SuppressIncludeComponents))
   {
         # We now need to store this subcircuit reference
         # into the top level circuit (0) so it can be looked
         # up later in the C code by the writer. We don't do
         # this if this subcircuit is contained within a "section"
         # (which is considered internally to our data structure as
         # a subcircuit).
         if (! ($CUR_SECTION))
         {
            $x = $SpiceCktT[0]{numElements};
            &Record_Usage(0,$x,1);
            $SpiceCktT[0]->{elementArray}[$x]->{tagName} = $cktName;
            $SpiceCktT[0]->{elementArray}[$x]->{ItemType} = $ItemType{inline_subcir_def};
            $SpiceCktT[0]->{elementArray}[$x]->{tmpType} = "resolved";
            $SpiceCktT[0]{numElements}++;
         } # if
   } # if
   return(TRUE);
} # sub read_inline_subckt
###############################################################################
#
# InitializeNewCkt()
#
#    This routine handles the adjustment of the circuit counter
#    as well as some other tasks related to circuit creation.
#
###############################################################################

sub InitializeNewCkt
{
   $Equation_Msg_Toggle = 1;

   # Record the Param Count ($PC) for the current subcircuit
   $SpiceCktT[$CUR_CKT]{numElements}=$PC;
   
   $SUBCKT++;  # count of subcircuits for log file
   $CKT++;  # This is the ONLY place where the CKT counter gets bumped... for subcircuits that is... Sections also use this variable.

   # Reset the number of parameters for this circuit to zero.
   push(@CKT_ValueCount_STACK, $CKT_ValueCount);
   $CKT_ValueCount = 0;
 
   # Push onto the list the previous circuit
   # We will pop this list when we leave this
   # new subcircuit.
   push(@CKT_STACK, $CUR_CKT);

   $CUR_CKT = $CKT;

   # Set the Param Counter for this subckt to 0.
   $PC = 0;

} # sub InitializeNewCkt

###############################################################################################
#
#  CheckIncludePath : This subroutine will search the file in the Path taken from command line
#  only when the file is not found in the path specified in the netlist syntax
#  Here we assume that the include path conatins the directory name (absolute or relative )
#  And netlist syntax contains the file name only 
#  File name returned will be the file name appended to the include path
#
###############################################################################################
sub CheckIncludePath
{
      my ($tmpFile)=@_;
      my $tcount=0;
      my @tempPath=();
      my $dir_delimit="";
      
      # Setting path delimiter '/' for unix and '\' for PC.
      if( $^O =~ "MSWin")
      { $dir_delimit= "\\"; }
      else
      { $dir_delimit= "\/"; }
      
      if ($ENV{"HOME"})
      {  $IncludePath =~ s/\~/$ENV{HOME}/g;  }
      
      @tempPath= split(",",$IncludePath );
      
      for ($tcount=0; $tcount< @tempPath; $tcount++)
      {
	 $File = $tempPath[$tcount].$dir_delimit.$tmpFile;
	 
	 if(-f $File)
	 {  return($File);   }
		
       } # for loop ending
       return($tmpFile);
	
} # sub CheckIncludePath


###############################################################################
#
# ReadInclude()
#
#   We pass the passed in file to &ReadFile()...this is called
#   recursively to support nested includes. 
#
#   We also check for references to environment variables in the
#   include path.
#
###############################################################################
sub ReadInclude
{
   my (@L) = @_;

   my $File=@L[1];
   my $env_var="";
   my $using_env=0;

   # Strip off the quotes if any
   $File =~ s/\"//g;

   # Spectre supports environment variables in
   # the path of the form "${HOME}" and apparently
   # "$HOME". Here we check for that. Note: we are
   # using a character class here for the match because
   # it's a little more efficient. Another option would
   # be to use m/\${.+?}/

   # NOTE: We need to support this without { and }
     
   while ($File =~ m/\$\{[^}]+}/)
   {
      $env_var = $&;
      $env_var =~ s/\$//;
      $env_var =~ s/\{//;
      $env_var =~ s/\}//;
      $env_var = $ENV{"$env_var"};

      # We now substitute the environment
      # variable with the literal string.
      $File =~ s/\$\{[^}]+}/$env_var/;
      $using_env = 1;
   } # if
   
   if ($ENV{"HOME"})
   {  $File =~ s/\~/$ENV{HOME}/g;  }
   
   unless(-f $File ) 
    { $File = &CheckIncludePath($File);}
      
   if (-f $File)
   {
      # Not Required .    Spectre_Tran.226,228   Ramesh Mar17,05 
      # $IncludeJustRead = 1;

      # Record the nesting level.
      # if ($IncFile) { $IncludeCount=2; $IncFile=""; $PrevFile=1; }
      # elsif ($IncludeCount ne 0) { $IncludeCount++; $PrevFile=1; }
      if ($IncFile) { $IncludeCount=2; $IncFile="";  }
      elsif ($IncludeCount ne 0) { $IncludeCount++;  }

      # We now need to check for a library section statement...
      if (@L[2] =~ /^section/i)
      {
         $Section = &ReturnValue(2,@L);
         
         push(@SectionHistory,$Section);

         # We are jumping to another
         # section so set this to false.
         $InSection = 0;
      } #if

      &WriteToLog("Processing include file \"$File\".\n");

      # Here we make the call to actually read the file.
      &ReadFile(0,$File);

      # Set this to indicate we haven't finished
      # processing the previous file (it got set
      # true after reading the include file).
      $FileDone = 0;

   } # if
   else
   {
      print("WARNING: Include file \"$File\" could not be found.\n");
      &WriteToLog("WARNING: Include file \"$File\" could not be found.");
      if ($using_env)
      {
         print("   Note: This include statement is referencing an environment variable. Be sure to check the environment variable(s) to be sure they\'re accurate.\n");
         &WriteToLog("   Note: This include statement is referencing an environment variable. Be sure to check the environment variable(s) to be sure they\'re accurate.");
      } # if
      return(FALSE);
     
   } #else

   return(TRUE);
} # sub ReadInclude

###############################################################################
#
# ReadAhdlInclude()
#
#   Need to read the AHDL files to look for modules, which will essentially 
#   be like having a subcircuit reference. 
#
#   Need to check for references to environment variables in the
#   include path.
#
#   Need to output an appropriate #load line in the final netlist.
#
###############################################################################
sub ReadAhdlInclude
{
   my (@L) = @_;

   my $File=@L[1];
   my $env_var="";
   my $using_env=0;

   # Strip off the quotes if any
   $File =~ s/\"//g;

   # Spectre supports environment variables in
   # the path of the form "${HOME}" and apparently
   # "$HOME". Here we check for that. Note: we are
   # using a character class here for the match because
   # it's a little more efficient. Another option would
   # be to use m/\${.+?}/

   # NOTE: We need to support this without { and }

   while ($File =~ m/\$\{[^}]+}/)
   {
      $env_var = $&;
      $env_var =~ s/\$//;
      $env_var =~ s/\{//;
      $env_var =~ s/\}//;
      $env_var = $ENV{"$env_var"};

      # We now substitute the environment
      # variable with the literal string.
      $File =~ s/\$\{[^}]+}/$env_var/;
      $using_env = 1;
   } # if

   &WriteToLog("Processing AHDL file \"$File\".\n");

   # Record the file name
   &Record_name($File,$PC);
   # Record this as an ahdl include type
   &Record_ItemType($CUR_CKT,$ItemType{ahdl_include},$PC);

   # If the element was part of an include file and
   # we are suppressing its output, then we check that here.
   if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef})
      { &Record_Usage($CUR_CKT,$PC,0); }
   else
      { &Record_Usage($CUR_CKT,$PC,1); }

   $main::PC++;  # Bump up the Parameter Counter

   # Look for modules inside of the file...
   
   if ($ENV{"HOME"})
   {  $File =~ s/\~/$ENV{HOME}/g;  }
  
   unless(-f $File )
   { $File = &CheckIncludePath($File);}
    
   if( -f $File)
   {    &ReadAhdlFile($File); }
   else
   {
      print("WARNING: Include file \"$File\" could not be found.\n");
      &WriteToLog("WARNING: Include file \"$File\" could not be found.");
      if ($using_env)
      {
         print("   Note: This include statement is referencing an environment variable. Be sure to check the environment variable(s) to be sure they\'re accurate.\n");
         &WriteToLog("   Note: This include statement is referencing an environment variable. Be sure to check the environment variable(s) to be sure they\'re accurate.");
      } # if
      return(FALSE);
     
   } #else
  
   return(TRUE);
   
}

#This code for statistics block is not effective now, 2005A onwards
#A new sub Record_statistics is written in utility.pl in accordance to Spectre compatible PDK  Ramesh Jan27, 05
###############################################################################
#
# read_statistics()
#
#   Spectre syntax for a statistics process is as follows:
#
#      vary variable_name dist=gauss std=0.1000
#
#   We need to translate the above to the following form:
#
#      variable_name=1.000 stat{gauss +/- 0.1000}
#
#      For this example, we assume that "variable_name" has the value 1.000
#      The code below searches for the value of the variable so it can
#      be used in the translated stat{} line.
#
###############################################################################
#sub read_statistics
#{
#   my (@L) = @_;

#   my ($x, $numP, $TheValue) = 0;

#   my $VarName = @L[1];
   
   # We need to search for the $VarName and determine
   # its value.
#   if ($CUR_CKT == 0)
#   {
#      $numP = $SpiceCktT[$CUR_CKT]{numElements};
#      while ($x < $numP)
#      {
#         if ($SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[0]{name} eq $VarName)
#         {
#            #print(" $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[0]{name} =");
#            #print(" $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[0]{value}\n");
#            $TheValue = $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[0]{value};
#            last;
#         }
#         $x++;
#      } # while
#   }
#   else
#   { 
#      $numP = $SpiceCktT[$CUR_CKT]{numParams};
#      while ($x < $numP)
#      {
#         if ($SpiceCktT[$CUR_CKT]->{paramArray}[$x]{name} eq $VarName)
#         {
#            #print(" $SpiceCktT[$CUR_CKT]->{paramArray}[$x]{name} =");
#            #print(" $SpiceCktT[$CUR_CKT]->{paramArray}[$x]{value}\n");
#            $TheValue = $SpiceCktT[$CUR_CKT]->{paramArray}[$x]{value};
#            last;
#         }
#         $x++;
#      } # while
#
#   }
#   @dist = split("=",@L[2]);
#   @std = split("=",@L[3]);
#   $TheValue = $TheValue . " stat{ @dist[1] +/- @std[1] }";

#   # We now need to save this as an equation
#   &Record_NameValue_Pair($CUR_CKT, 0, $VarName, $TheValue, $PC, 1);
#   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
#   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
#   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
#   if ($SuppressIncludeComponents && ($IncludeCount > 0))
#      { &Record_Usage($CUR_CKT,$PC,0); }
#   else
#      { &Record_Usage($CUR_CKT,$PC,1); }

#   $PC++;
#   $SpiceCktT[$CUR_CKT]{numElements} = $PC;

#   return(TRUE);

#} # sub read_statistics

###############################################################################
#
# read_function()
#
# Spectre functions are single line expressions, all arguments are real,
# and can be defined at the top level only. Only functions of type "real"
# are supported.
#
# Spectre syntax:
# ---------------
# real myfunc( [real arg1, ... real argn] ) {
#    return <expr of arg1..argn>
# }
#
# Gemini syntax:
# --------------
# myfunc(arg1, ... argn)=<expr of arg1..argn>
#
###############################################################################
sub read_function
{
   my (@L) = @_;

   my $i = 0;
   my $val = "";

   # If $GotFunction==1 then we have the actual function.
   # Otherwise we have the left hand side of the equation.
   if (!($GotFunction)) # Then we are looking at a "real" declaration
   {
      while ( (@L[$i] !~ /\{/) && ($i < @L) )
      {
         @L[$i] =~ s/real//;
         $UserFunction = $UserFunction . @L[$i];
        $i++;
      } # while

      if ($i > @L) { return(FALSE); } # We expect a "{" at the end

      $GotFunction = 1;
   }
   else # We have the rest of the equation.
   {
      # The next line is probably "}" to end the
      # function. That gets captured in the read_element()
      # routine. We check here to see if it's tacked onto
      # the line just in case.
      if (@L[@L-1] eq "}") { $GotFunction = 0; }

      # @L[0] should be the word "return" so we start indexing at 1.

      $i = 1;
      while ($i < @L)
      {
         $val = $val . @L[$i];
         $i++;
      } # while
      @L[$i-1] =~ s/;//; # Get rid of the ending semi-colon.

      &Record_NameValue_Pair($CUR_CKT, 0, $UserFunction, $val, $PC, 1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else
         { &Record_Usage($CUR_CKT,$PC,1); }

      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;

      $UserFunction = "";

   }

   return(TRUE);

} # sub read_function

###############################################################################
#
# read_global_node()
#
# Syntax: global <ground> <node> ...
#
# Any number of global nodes may be specified using the global statement.
# The first node name that appears in this list is taken to be the name of
# the ground node. Ground is also known as the datum or reference node. If
# a global statement is not used, 0 is taken to be the name of the ground
# node.
#
# At most one global statement is allowed and, if present, it must be the
# first statement in the file (however, you can have simulator
# lang=spectre  statement, before the global statement so that you can use
# mixed case names for the node names). Ground is always treated as global
# even if a global statement is not used.
#
###############################################################################
sub read_global_nodes
{
   my (@L) = @_;

   my ($glist, $tmp) = "";

   my $gn = "";

   shift(@L);

   if ($WantGeminiOutput)
   {
      $tmp = FixNodeChars(shift(@L));
      # prepend $adsNodeName if only a number and it's not 0 (ground)
      if (($tmp ne "0") && ($tmp =~ /^[0-9]*$/)) { $tmp = "$adsNodeName$tmp"; }
   
      # The first node listed is the global ground node.
      # We record this after the "globalnode" because Gemini
      # demands that this be first in the netlist.
      if ($ADSReservedWord{$tmp} eq "TRUE")
      {
         $tmp .= "_n";
      } # if
      $gn = "ground" . " " . $tmp;

      $glist = "globalnode";
      while (@L)
      {
         $tmp = FixNodeChars(shift(@L));
         # prepend $adsNodeName if only a number and it's not 0 (ground)
         if (($tmp ne "0") && ($tmp =~ /^[0-9]*$/)) { $tmp = "$adsNodeName$tmp"; }
         $glist = $glist . " " . $tmp;
      } # while

      if ($glist ne "globalnode")
      {
         $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = "GLOBALNODE";
         $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $glist;
         $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
      } # if

   }
   else # We have schematic import
   {
      # Get rid of ground node...it should be zero anyway.
      # There is no mechanism to re-name ground via the UI.
      shift(@L);

      while (@L) 
      {
         $tmp = FixNodeChars(shift(@L));
         # prepend $adsNodeName if only a number and it's not 0 (ground)
         if (($tmp ne "0") && ($tmp =~ /^[0-9]*$/)) { $tmp = "$adsNodeName$tmp"; }
 
         $glist = $glist . $tmp . ",";
      } # while
      $glist =~ s/\,$//;

      $glist = "list(" . $glist . ")";

      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = "GLOBALNODE";
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = "GlobalNodes";
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{data_item};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
      &Record_NameValue_Pair($CUR_CKT, 0, "Node", $glist, $PC, 0);
   } # else

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

   if ($SuppressIncludeComponents && ($IncludeCount > 0))
      { &Record_Usage($CUR_CKT,$PC,0); }
   else
      { &Record_Usage($CUR_CKT,$PC,1); }

   $PC++;
   $SpiceCktT[$CUR_CKT]{numElements} = $PC;

   # If we found a global node earlier - we record it here.
   if ($gn)
   {
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $gn;
   
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};

      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

      if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else
         { &Record_Usage($CUR_CKT,$PC,1); }
      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;
   } # if

   return(TRUE);

} # sub read_global_nodes

###############################################################################
#
# read_ahdl_module()
#
# verilogA modules are single line definitions, with the module name followed 
# by the parenthesis enclosed module nodes.
#
# verilogA syntax:
# ---------------
# module myModule( [port1, ... real portn] )
#
# Gemini syntax:
# --------------
# Not output.  The module is stored so that instances that reference the 
# module will be mapped properly.  Gemini will use the verilogA file directly 
# through the Tiburon add-on module.
#
###############################################################################
sub read_ahdl_module
{
   my (@L) = @_;

   my ($x, $numPins, $params, $numParams) = 0;
   my $cktName="";
   my $MinElemParams=2;

   $numParams = @L;

   if (@L[1] =~ /\(/)
   {
      # We have something like "cktName(pin1"...
      $cktName = $`;
      @L[1] =~ s/.*\(//;
      $x = 1;
   } # if
   else 
   { 
      $cktName = @L[1]; $x = 2; 
   }

   # If this module is contained within a Spectre "section" 
   # we record that here.
   if ($CUR_SECTION)
   {
      my $x = $SpiceCktT[$CUR_CKT]{numElements};
      &Record_Usage($CUR_CKT,$x,1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tagName} = $cktName;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{cktDuplicateIndex} = &CheckDuplicateCKT_Names($cktName);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{ItemType} = $ItemType{subcir_def};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numParams} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numPins} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{used} = 0;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tmpType} = "resolved";
      $SpiceCktT[$CUR_CKT]{numElements}++;
      $PC=$SpiceCktT[$CUR_CKT]{numElements};
   } # if

   &InitializeNewCkt;

   while ($x < (@L))
   {
      if (@L[$x] eq "(") { } #just ignore
      elsif (@L[$x] =~ /\(/)
      {
         # Strip off the paren
         @L[$x] =~ s/\(//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif

      elsif    (@L[$x] eq ")") { } #just ignore
      elsif (@L[$x] =~ /\)/)
      {
         # Strip off the paren
         @L[$x] =~ s/\)//;
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # elsif
      else
      {
         $SpiceCktT[$CUR_CKT]->{pinArray}[$numPins]{name} = @L[$x];
         $numPins++;
      } # else

      $x++;
   } # while

   &store_subckt_def($CUR_CKT, $cktName, $numPins);
   
   return(TRUE);
} # sub read_ahdl_module

###############################################################################
#
# read_ahdl_module_parameter()
#
# verilogA module parameters are single line definitions, with the parameter name followed
# by the parameter type, followed by the name of the parameter and its default value
#
# verilogA syntax:
# ---------------
# parameter real l=1
#
# Gemini syntax:
# --------------
# Not output.  The module is stored so that instances that reference the 
# module will be mapped properly.  Gemini will use the verilogA file directly 
# through the Tiburon add-on module.  The parameter keyword is read in strictly 
# so that the dummy subcircuit definition will have the appropriate parameters.
#
###############################################################################
sub read_ahdl_module_parameter
{
   my (@Line) = @_;

   my $y=0, $FirstTime=1;
   my @Right=(), @Left=(), @tmp=();
   my $R="", $newLeft="";

   # @Line[0] should be "parameter" and @Line[1] should be the parameter type.
   # Start with the third field of the line
   $x=2;
   while ($x < @Line)
   {
      #@Line[$x] =~ s/\s//;
      # Case "foo =bar" or "foo = bar"
      if ( (@Line[$x] =~ /^=/) && (@Line[$x] !~ /^==/) && (@Line[$x] !~ /^<=/) && (@Line[$x] !~ /^>=/) && (@Line[$x] !~ /^!=/))
      {
         if ($FirstTime) { $Left = @Line[$x-1]; $FirstTime = 0;}
         else # Already been storing...
         {
            # Grab the new left hand side
            $newLeft = pop(@Right);

            $R = join "", @Right;
            $R =~ s/=//;
            $R =~ s/\;//; # Get rid of the ending semicolon if one exists
            
            $R = &FixEquation($Left, $R);

            &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R);

            $CKT_ValueCount++;
            @Right = ();
            $Left = $newLeft;
         } # if
      } # if

      # Check if we have the either "foo=bar" or "foo= bar"
      # We try and match "=" and ignore cases where we have
      # ">=", "<=", "==", and "!=" in the line...
      elsif ( (@Line[$x] =~ m/([^=!><])=([^=])/) || 
             ((@Line[$x] =~ m/([^=!><])=/) && 
              (@Line[$x] !~ m/([^=!><])==/)) )
      {
         @tmp = split("=",$&);
         if ($FirstTime)
         {
            @tmp = split("=",@Line[$x]);
            $Left = @tmp[0]; # Save the left hand side of the equation
            @Line[$x] =~ s/$Left//; # Get rid of what we just stored
            $FirstTime = 0;
         } # if
         else
         {
            $newLeft =  $` . @tmp[0];  # Store the left hand side for the next equation

            $R = join "", @Right;
            $R =~ s/=//;
            $R =~ s/\;//; # Get rid of the ending semicolon if one exists

            $R = &FixEquation($Left, $R);

            &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R);

            $CKT_ValueCount++;
            @Right = ();
            $Left = $newLeft;  # Store the left hand side

            # NOTE: The left side should only have parens if
            #       we are processing some logic like "nse1=(nstripes==1)". 
            $Left =~ s/(\))?(\()//g;

            @Line[$x] =~ s/\Q$Left\E//; # Get rid of what we just stored
         } # if
      } # elsif

      if (&CheckForNoDefault($x, @Line))
      {
         &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, @Line[$x], "NO_DEFAULT");

         $CKT_ValueCount++;
      } # if
      # Push the right hand side pieces of this equation...
      elsif (!($FirstTime)) { push(@Right,@Line[$x]); }

      $x++;
   } # while

   $R = join "", @Right;
   $R =~ s/=//;
   $R =~ s/\;//; # Get rid of the ending semicolon if one exists

   $R = &FixEquation($Left, $R);
   # Store the last name value pair.
   &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R);
   $CKT_ValueCount++;
   &Record_NumberOfCktParams($CKT_ValueCount);

   return(TRUE);
} # sub read_ahdl_module_parameter

return(1);

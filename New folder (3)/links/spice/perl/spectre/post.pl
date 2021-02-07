#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

require("data.pl");
require("rules.pl");
require("eqRules.pl");

###############################################################################
#
# PostProcess()
#
#   This function kicks off the post processing after the file(s) have been
#   read and stored to the CktArray.
#
###############################################################################
sub PostProcess
{
   &ConnectCktReferences();
   &CompNameReferences();
   &ReservedWordReferences();
   #Following subroutine called for controlled sources,bsource and nonlinear R,C,L components
   &SpectreWrapper();
   &ParamReferences();
   # Check for callbacks and execute if necessary...
   &CheckCallBacks();

   # Add in Spectre default parameters to the top level.
   &AddSpectreMathAndPhysicalConstants();

   if ($PreserveSubcktParams)
   {
      AddSpectreBooleanEquationEquivalents();
   }
      
   return(1);
} # sub PostProcess

###############################################################################
#
# CheckCallBacks()
#
#   Check for callbacks and execute if necessary...
#
###############################################################################

sub CheckCallBacks
{
   my $tmpCKT=0, my $PC=0, my $XspiceType="", my $numE="";
   my @CLBK=();

   while ($tmpCKT <= $CKT)
   {
      $PC=0;
      $numE = $SpiceCktT[$tmpCKT]{numElements};
      while ($PC < $numE)
      {
         $T = &Get_ItemType($tmpCKT, $PC);
         $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{SpectreType};
         if($T ne "spectre_lang_ref")
	 {
           # Execute the "Pin or Node" callback if one exists
           @CLBK = split(",",$SpecMap{$T}{$XspiceType}{CB}[$pinCB_idx]);
           if (@CLBK)
              { &Execute_CallBack($tmpCKT, $PC, @CLBK); }

           # Execute the "Parameter Name" callback if it exists...
           @CLBK = split(",",$SpecMap{$T}{$XspiceType}{CB}[$paramCB_idx]);
           if (@CLBK)
             { &Execute_CallBack($tmpCKT, $PC, @CLBK); }

           # Execute the "Models" callback if it exists...
           @CLBK = split(",",$SpecMap{$T}{$XspiceType}{CB}[$modelCB_idx]);
           if (@CLBK)
              { &Execute_CallBack($tmpCKT, $PC, @CLBK); }
         }
         $PC++;
      } # while
      $tmpCKT++;
   } # while

   # We now check for a "Last Chance" callback. We do this
   # after all of the other callbacks are done so we don't
   # have any dependancies to worry about.

   $tmpCKT = 0;
   while ($tmpCKT <= $CKT)
   {
      $PC=0;
      $numE = $SpiceCktT[$tmpCKT]{numElements};
      while ($PC < $numE)
      {
         $T = &Get_ItemType($tmpCKT, $PC);
         
         $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{SpectreType};
         if($T ne "spectre_lang_ref")
	 {     
           # Execute the "Last Chance" callback if one exists
           @CLBK = split(",",$SpecMap{$T}{$XspiceType}{CB}[$lastChanceCB_idx]);
           if (@CLBK)
            { &Execute_CallBack($tmpCKT, $PC, @CLBK); }
	  }
         $PC++;
      } # while
      $tmpCKT++;
   } # while
} # sub CheckCallBacks

###############################################################################
#
# ConnectCktReferences()
#
#   This routine cycles through each component and checks to see if it's
#   a reference to a subcircuit. Subcircuit references in Spectre aren't
#   explicitly stated so we have to search for them.
#
###############################################################################

sub ConnectCktReferences
{
   my ($tmpCKT, $x, $y) = 0;
   my $ref="";
   my $tempx=0;
   my $ReferencedModel= "FALSE";
   my @ModelNames=();
   
   # Cycle through each subcircuit and check each component
   while ($tmpCKT <= $CKT)
   {
      @ModelNames=();$tempy=0;
      while($tempy < $SpiceCktT[$tmpCKT]{numElements})
      { 
        if ($SpiceCktT[$tmpCKT]->{elementArray}[$tempy]->{ItemType} eq $ItemType{model})
        {
	   push(@ModelNames,$SpiceCktT[$tmpCKT]->{elementArray}[$tempy]->{tagName}); 
        }
        $tempy++;
      }
      while ($x < $SpiceCktT[$tmpCKT]{numElements})
      {
        $ReferencedModel= "FALSE";
       
        # Check if we have a model defined in the same subckt.
	if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{ItemType} eq $ItemType{element})
        {
            $ref = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tmpType};
	    foreach(@ModelNames)
	    { 
	       if ($_ eq "$ref")
               {  $ReferencedModel= "TRUE";  last; }
	    }
	 }
	 # Only look at ones marked as "element" types...
	 # And only when a model definition for $ref is not in the subcircuit that we are already in.
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{ItemType} eq $ItemType{element} && $ReferencedModel ne "TRUE" )
         {
            #$ref = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tmpType};
            # Check all circuits to see if we have a reference match.
            # Note: We skip circular references - we can't have a
            # call to a subcircuit that we are already in. There are
            # cases where we have model references that have the same
            # name of the subcircuit - this check eliminates the
            # confusion of matching up a circuit reference with an existing
            # model.
            while ($y <= $CKT)
            {
               if ( ($ref eq $SpiceCktT[$y]{name}) && ($y ne $tmpCKT) )
               {
                  # Record the subcircuit name that is being referenced.
                  &Record_subcircuit($tmpCKT, $ref, $x);
                  # Commenting the following line to prevent the warning with schematic import.
                  # &Record_outputType($tmpCKT,-1, $x);
                  &Record_ItemType($tmpCKT, $ItemType{subcir}, $x);
                  $includeRef = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{includeRef};
                  if ($includeRef) { &Record_Usage($tmpCKT,$x,0); }
                  else { &Record_Usage($tmpCKT,$x,1); }
                  &CheckMultiplicity($tmpCKT,$x);
               } # if
               $y++;
            } # while
         } # if
         $y=1;
         $x++;
      } # while
      $x=0;
      $tmpCKT++;
   } # while
} # sub ConnectCktReferences

###############################################################################
#
# CompNameReferences()
#
#   This routine cycles through each circuit and calls MapCktComponents
#   to provide post processing on each component of the circuit.
#
###############################################################################
sub CompNameReferences
{
   my $ck = 0;

   while ($ck <= $CKT)
   {
      &FirstPass($ck);
      $ck++;
   } # while
} # sub CompNameReferences

###############################################################################
#
# FirstPass()
#
#   The first pass on the circuit does the following:
#
#      1.) Record the outputName for the element
#          Note: This involves calling the outputName
#                CallBack if it exists. If it's a model
#                then "spiceType" also gets set.
#      2.) If it's a model then find the associated 
#          component. The component wont have it's outputName
#          set because it was waiting for this step to set it.
#          The outputName is hashed from the Model type.
#
###############################################################################

sub FirstPass
{
   my ($tmpCKT) = @_;

   my ($x, $foundit, $ck) = 0;
   my $ItemType="";

   while ($x < $SpiceCktT[$tmpCKT]{numElements})
   {
      # We have already hooked the subcircuit references 
      # together and therefore "subcktName" has been set.
      # All other "subcktName" references are "" so we only
      # process those components (which is probably the
      # majority of them....)
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{subcktName} eq "")
      {
         &RecordOutputType($tmpCKT,$x,"");
         $ItemType = &Get_ItemType($tmpCKT, $x);
         if ($ItemType eq "model") { $foundit = &FindComponent($tmpCKT, $x); }
      } # if
      $x++;
   } # while
} # sub FirstPass

###############################################################################
#
# FindComponent()
#
#
###############################################################################
sub FindComponent
{
   my ($tmpCKT, $PC) = @_;

   my ($foundit, $circ_counter, $Found) = 0;

   # Check if we are dealing with a BSIM model reference.
   # Because we break out an indexed Spectre binning model into
   # individual ADS models the tagName gets changed so we want
   # to match the models "bsimName" (not modified tagName) to
   # the component that references it. The "bsimName" (the name
   # that the component uses for reference) will be added to an
   # ADS BinModel card.
   if ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{bsimName})
      { $TheMatch = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{bsimName}; }
   else
      { $TheMatch = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName}; }

   # Save the model type....
   $ModType  = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tmpType};

   if ($tmpCKT == 0)
   {
      # We need to cycle the global circuit as
      # well as all the other circuits since 
      # this model is global.
      while ($circ_counter <= $CKT)
      {
         $foundit = &CycleElements($circ_counter,$TheMatch,$ModType);

         if ($foundit) { $Found = 1; }
         $circ_counter++;
      } # while
   } # if
   else
   {
      # Since this model is not contained in the
      # top level (0) subcircuit we first check
      # this subcircuit and then if not found, the
      # others.
      $foundit = &CycleElements($tmpCKT,$TheMatch,$ModType);

      # Check the other subcircuits. It's possible that the
      # model reference might be in a different "section".
      if (!$foundit)
      {
         $circ_counter=0;
         while ($circ_counter <= $CKT)
         {
            if ($circ_counter != $tmpCKT)
               { $foundit = &CycleElements($circ_counter,$TheMatch,$ModType); }

            if ($foundit) { $Found = 1; }
            $circ_counter++;
         } # while
      } # if
      if ($foundit) { $Found = 1; }
   } # else

   if (!$Found)
   {
      # The model doesn't have any references. We don't need to
      # flag the user - sometimes the foundry kits will have 
      # the model references in other files. 
   } # if

   return($Found);

} # sub FindComponent

###############################################################################
#
#
#
###############################################################################
sub CycleElements
{
   my ($tmpCKT, $TheMatch, $ModType) = @_;

   my ($ParamCount, $foundit, $numP, $includeRef, $PinCount) = 0;
   my $includeRef="";

   # We used to jump out when we found a reference - however it
   # wasn't hooking multiple references to one model. We now cycle
   # all elements.
   # while ( ($ParamCount < $SpiceCktT[$tmpCKT]{numElements}) && (!$foundit) )

   while ($ParamCount < $SpiceCktT[$tmpCKT]{numElements})
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{tmpType} eq $TheMatch)
      {
         # We need to set "outputType" for this element since
         # it couldn't be set before because we didn't know
         # what kind of model it was referencing. Since we now
         # have the model we get its type. We then call 
         # &RecordOutputType() which hashes out the proper
         # component based on the model type passed to it.
         &RecordOutputType($tmpCKT,$ParamCount,$ModType);

         # Now record the reference of the Model as a parameter.
         # Here we are hooking the component and model together.
         $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numParams};
         &Record_NameValue_Pair($tmpCKT, $numP, "Model", $TheMatch, $ParamCount, 1);

         $includeRef = $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{includeRef};
         # Record this element as being recognized by ADS
         if ($includeRef) { &Record_Usage($tmpCKT,$ParamCount,0); }
         else { &Record_Usage($tmpCKT,$ParamCount,1); }

         # We need to record the nodes again for this - this time 
         # we can do the pin mapping from the hash since we know
         # its component type.
         while ($PinCount < $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins})
         {
            &Record_ElementNode(
               $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{pinArray}[$PinCount]{name},
               $PinCount,
               $ParamCount,
               $tmpCKT);
            $PinCount++;
         } # while

         # Now bump up the number of parameters
         $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numParams}++;

         if ($SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{outputType} eq "vbic")
         {
            # If we have a vbic reference with only three 
            # nodes then we need to add a fourth node
            # (the substrate) and set it to ground.
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins} == 3)
            {
               $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{pinArray}[3]{name} = 0;
               $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins}++;
            } # if
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins} == 5)
               {$SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins}--; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins} == 6)
            {
               $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins}--;
               $SpiceCktT[$tmpCKT]->{elementArray}[$ParamCount]->{numPins}--;
            } # elsif
         } # if

         $foundit = 1;
      } # if
      $ParamCount++;
   } # while

   return($foundit);

} # sub CycleElements

###############################################################################
#
# Check to see if a component has a Node CallBack.
#
###############################################################################
sub ReservedWordReferences
{
   my ($PC, $tmpCKT) = 0;
   my ($XspiceType, $T) = "";
   
   while ($tmpCKT <= $CKT)
   {

      # Check to be sure the subcircuit name doesn't
      # collide with a reserved word.
      &Fix_CKT_Name($tmpCKT);

      # Check if there are special character conflicts and
      # reserved word name collisions
      &Fix_CKT_NodeNames($tmpCKT);

      $PC=0;
      while ($PC < $SpiceCktT[$tmpCKT]{numElements})
      {
         # Check if there are special character conflicts and
         # reserved word name collisions
         &FixElementNodes($tmpCKT,$PC);

         # Check if there are reserved word name collisions for element names
         &FixElementName($tmpCKT,$PC);

         $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tmpType};

         # Determine if this is an element or a model.
         $T = &Get_ItemType($tmpCKT, $PC);

         $PC++;
      } # while
      $tmpCKT++;
   } # while
} # sub ReservedWordReferences

###############################################################################
#
# Check to be sure a circuit name doesn't collide with an ADS reserved word.
#
###############################################################################
sub Fix_CKT_Name
{
   my ($tmpCKT) = @_;

   # Let's first get rid of any illegal characters if they exist
   my $cName = $SpiceCktT[$tmpCKT]->{name};
   $SpiceCktT[$tmpCKT]->{name} = &FixChars($cName);

   # Now check the hash to see if we have a reserved word
   if ($ADSIllegalSubcktName{$cName} eq "TRUE")
   {
      $SpiceCktT[$tmpCKT]->{name} = $cName . "xE";
      if ($PrintWarnings) {
         WriteToLog("WARNING: Appended \"xE\" to subcircuit reference \"$cName\" due to a conflict with an ADS reserved word."); }
   } # if

} # sub Fix_CKT_Name


###############################################################################
#
# Check to be sure a circuit pin name doesn't collide with an ADS reserved word.
#
###############################################################################
sub Fix_CKT_NodeNames
{
   my ($tmpCKT) = @_;

   my $x=0, my $pName="";

   while ($x < $SpiceCktT[$tmpCKT]{numPins})
   {
      $pName = $SpiceCktT[$tmpCKT]->{pinArray}[$x]{name};

      # prepend $adsNodeName if only a number and it's not 0 (ground)
      if (($pName ne "0") && ($pName =~ /^[0-9]*$/)) { $pName = "$adsNodeName$pName"; }

      # Be sure we take care of special characters that ADS doesn't like
      $pName = &FixNodeChars($pName);
      &Record_SubcircuitNode($tmpCKT, $pName, $x);

      if ($ADSReservedWord{$pName} eq "TRUE")
      {
         if ($PrintWarnings) {
            WriteToLog("WARNING: Appended \"_n\" to node \"$pName\" for circuit $SpiceCktT[$tmpCKT]{name} due to a conflict with an ADS reserved word."); }
         $pName = $pName . "_n";
         &Record_SubcircuitNode($tmpCKT, $pName, $x);         
      } # if
      $x++;
   } # while
} # sub Fix_CKT_NodeNames

###############################################################################
#
# We first check to be sure a node doesn't have any special characters that
# ADS doesn't like. We then check it against the ADS reserved words.
#
###############################################################################
sub FixElementNodes
{
   my ($tmpCKT, $P) = @_;

   my $x=0;
   my ($pName, $c) = "";
   my @chars=();

   while ($x < $SpiceCktT[$tmpCKT]->{elementArray}[$P]->{numPins})
   {
      $pName = $SpiceCktT[$tmpCKT]->{elementArray}[$P]->{pinArray}[$x]{name};

      # Not needed...this was done with hspice due to insensitive name issues.
      # $pName =~ tr/A-Z/a-z/; # Translate to lower case

      # prepend $adsNodeName if only a number and it's not 0 (ground)
      if (($pName ne "0") && ($pName =~ /^[0-9]*$/)) { $pName = "$adsNodeName$pName"; }

      # Be sure we take care of special characters that ADS doesn't like
      $pName = &FixNodeChars($pName);

      # Change the name of the node...
      $SpiceCktT[$tmpCKT]->{elementArray}[$P]->{pinArray}[$x]{name} = $pName;

      if ($ADSReservedWord{$pName} eq "TRUE")
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$P]->{pinArray}[$x]{name} = 
            $pName . "_n";
         if ($PrintWarnings) {
            WriteToLog("WARNING: Appended \"_n\" to node \"$pName\" for element $SpiceCktT[$tmpCKT]->{elementArray}[$P]->{tagName} due to a conflict with an ADS reserved word."); }
      } # if
      $x++;
   } # while
} # sub FixElementNodes

###############################################################################
#
# Check to be sure an element name doesn't collide with an ADS reserved word.
#
#   For example if we have a resistor named "ramp" (which happens to be a
#   reserved word) it will change the name to "rampxE" to avoid a name 
#   conflict.
#
###############################################################################
sub FixElementName
{
   my ($tmpCKT, $PC) = @_;

   my $eName="";

   # Don't bother with stored comments nor ckt vars.
   # Circuit vars are special custom equations.
   if  ( ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{ItemType} ne $ItemType{comment}) &&
         ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{ItemType} ne $ItemType{var}) &&
         ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{ItemType} ne $ItemType{ahdl_include}) )
   {
      # Let's first get rid of any illegal characters if they exist
      $eName = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName};
      $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName} = &FixChars($eName);

      # Now check the hash to see if we get a reserved word
      if ($ADSIllegalSubcktName{$eName} eq "TRUE")
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName} = 
            $eName . "xE";
         
         # We don't need to put a warning out if it's a subcircuit
         # reference. This is being done in the &Fix_CKT_Name() routine.
         if ( ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{ItemType} ne $ItemType{subcir_def})
               & $PrintWarnings)
            { WriteToLog("WARNING: Appended \"xE\" to element \"$eName\" due to a conflict with an ADS reserved word."); }
      } # if
   } # if
} # sub FixElementName
###############################################################################
#
# This will generate the final tag name after compiling different peices together
# No processing required in the backend c-code
#
###############################################################################
sub SpectreWrapper 
{
  my $tmpCKT=0, my $PC=0, my $x=0,my $y=0, my $numE="";
  my $XspiceType="", my $tagName="", $NextItemType ="", $PrevItemType ="";
  my $tmpParamName="", my $tmpParamValue="", my $tmpParamNameValPair="";
  my @nodeNames=(), my @paramNameVal=();
    
  while ($tmpCKT <= $CKT)
   {
      $PC=0;
      $numE = $SpiceCktT[$tmpCKT]{numElements};
      while ($PC < $numE)
      {
         $T = &Get_ItemType($tmpCKT, $PC);
         if ($T eq "spectre_lang_ref")
	 {
	    $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{SpectreType};
            $tagName=$SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName};
	    $NextItemType=&Get_ItemType($tmpCKT, $PC+1);
	    if ($PC==0)
	     {  $PrevItemType = "comment";}
	    else
	     {  $PrevItemType = &Get_ItemType($tmpCKT, $PC-1); }
	    
	    if($PrevItemType ne "spectre_lang_ref") 
	    {  $tagName="simulator lang=spectre\n"."$tagName";  }
	    #else     { } #$tagName=$tagName ;
	    $x=0;
	    @nodeNames=();
	    while ($x < $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{numPins})
	    {
              $pName = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{pinArray}[$x]{name};
	      push (@nodeNames,$pName);
	      $x++;
	    }# while
	    
	    $tagName="$tagName"." "."@nodeNames";
	    $tagName=$tagName." "."$XspiceType";
	    
	    $y = 0;
	    $tmpParamName="";
	    $tmpParamValue="";
	    $tmpParamNameValPair="";
	    @paramNameVal=();
	    
	    while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{numParams})
            {
	       $tmpParamName =  $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{paramArray}[$y]{name}; 
	       $tmpParamValue = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{paramArray}[$y]{value};
	       $tmpParamNameValPair= $tmpParamName."=".$tmpParamValue;
	       push (@paramNameVal,$tmpParamNameValPair);
	       $y++;
            } # while 
	    
	    $tagName=$tagName." "."@paramNameVal";
	    if($NextItemType ne "spectre_lang_ref")
	    {  $tagName=$tagName."\n"."simulator lang=ads";  }
	    #else    { }#$tagName=$tagName ;	    
	         
            $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{outputType} = 0;
            $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{ItemType} = $ItemType{spectre_lang_ref};
            $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{spiceType} = -1;
            $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName} = $tagName;
            $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{subcktName} = "resolved";

            if ($SuppressIncludeComponents && ($IncludeCount > 0))
             { $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{used} = 0; }
            else
             { $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{used} = 1; } 
	   	
       	}#if
	elsif ($backwardCompatible && ($T eq "element")) 
	{
	   $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{SpectreType};
	   if(($XspiceType eq "pcccs"||$XspiceType eq "pccvs") && ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{numPins} >2) || ($XspiceType eq "pvccs"||$XspiceType eq "pvcvs") 
	        && ($SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{numPins} >4) )
	    {  
	       WriteToLog("WARNING:ADS Netlist Translator does not support multi-input \"$XspiceType\" with \"-bc\" option. ");
	       WriteToLog("\tOnly Single input node pair supported for \"$XspiceType\" ");
	       
	       $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{outputType} = 0;
	       $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = "comment";
	       $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{tagName} ="";
	       $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{subcktName} = "resolved";
	       
	       if ($SuppressIncludeComponents && ($IncludeCount > 0))
		 { $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{used} = 0; }
	       else
		 { $SpiceCktT[$tmpCKT]->{elementArray}[$PC]->{used} = 1; } 
	    }
	}#elsif
	$PC++;
      } # while
      $tmpCKT++;
   } # while
} #sub SpectreWrapper



###############################################################################
#
# Map all of the Xspice parameters into ADS names. We also check
# math functions and map them as appropriate.
#
###############################################################################
sub ParamReferences
{
   my ($x, $y, $tmpCKT) = 0;
   my ($XspiceType, $ItemType, $paramName, $EName, $T) = "";
   my @Ltmp = ();
   my $UnkownInstance=0;
   my $Output_type = "";
   
   while ($tmpCKT <= $CKT)
   {
      $x=0;
      while ($x < $SpiceCktT[$tmpCKT]{numElements})
      {
         $XspiceType = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{SpectreType};
         
         # Determine if this is an element or a model.
         $T = &Get_ItemType($tmpCKT, $x);
         
         # Let's map names from the hash
         # Determine if this is an element or a model type
         $ItemType = &Get_ItemType($tmpCKT, $x);

         @CLBK = split(",",$SpecMap{$ItemType}{$XspiceType}{CB}[$outputTypeCB_idx]);
	 $Output_type = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType} ; 
         	 
	 $UnkownInstance=0;	 
	 if ( ($ItemType eq "element") && ( ($Output_type =~ /HASH/i) || ($outType eq "") ) )
	 { 
	   if (!@CLBK) # We've not got a CallBack for this
  	   { 
	     $UnkownInstance=1;	    
	     if($WantGeminiOutput)
	     {
	        print("WARNING: ADS Netlist Translator could not find a definition for \"$XspiceType\" . \n");
	        print("\t A valid definition for \"$XspiceType\" is required. \n");
	        WriteToLog("WARNING: ADS Netlist Translator could not find a definition for \"$XspiceType\" .");
	        WriteToLog("\t A valid definition for \"$XspiceType\" is required. \n"); 
	        #$Output_type=$XspiceType;
	        $Output_type= ";".$XspiceType;
	     
	        #$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType}=$XspiceType;
	        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType}=$Output_type;
	     }
	     else
	     {
	        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType}=$XspiceType;
	        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{used}=0;
	     }
	   }
	   
	 }
	 
	 # Only want an element or a model
         if ( ($ItemType ne "subcir") && ($ItemType ne "lib_section_def") && ($ItemType ne "var") && ($ItemType ne "comment") 
	       && ($ItemType ne "spectre_lang_ref"))
         {
            $y=0;
            while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
            {
               $Output_type = " ";
	       # For any special name/value pairs we don't want
               # to map from the hash - we first check for that.
               if ($SpiceCktT[$tmpCKT]->
                     {elementArray}[$x]->
                        {paramArray}[$y]{check})
               {
                  $EName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{SpectreType};
   
                  $paramName = $SpiceCktT[$tmpCKT]->
                                  {elementArray}[$x]->
                                     {paramArray}[$y]{name};
                  if (($paramName ne "Model") && ($paramName ne "_M")) # "Model" and "_M" are special cases.
                  {
                     # Make the call into the hash !!!
                     @Ltmp = split(",",$SpecMap{$ItemType}{$EName}{$paramName});
                     # @Ltmp[0] is the name and @Ltmp[1] is its default value
                     # (if it even has one).
                     if (@Ltmp[0])
                     {
                        $SpiceCktT[$tmpCKT]->
                           {elementArray}[$x]->
                              {paramArray}[$y]{name} = @Ltmp[0];
                        #my $func = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
                        #$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =  &FixEquation($func);
                     } # if
                     elsif($UnkownInstance)
		     {
		       if($WantGeminiOutput)
		       {
		         $SpiceCktT[$tmpCKT]->
                             {elementArray}[$x]->
                                {paramArray}[$y]{name} = $paramName;
		       }
		     }
		     else
                     {
                        # Set name and value to "" so it can be disregarded
                        # by the backend C code...
                        if (! &SpecialCase($tmpCKT, $x, $y) )
                        { 
                           $SpiceCktT[$tmpCKT]->
                                {elementArray}[$x]->
                                   {paramArray}[$y]{name} = "";
                           if ($PrintWarnings)
                              { WriteToLog("WARNING: The following parameter from element $SpiceCktT[$tmpCKT]->{elementArray}[$x]{tagName} is not supported by ADS and will be ignored in translation:\n    $paramName=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value}"); }
                        } # if
                     } #elsif
                  } # if
               } # if
               $y++;
            } #while
         } # if
         $x++;
      } # while
      $tmpCKT++;
   } # while
} # sub ParamReferences

###############################################################################
#
# Here is the place to check for special processing for parameters
# that don't map straight across.
#
###############################################################################
sub SpecialCase
{
   my ($tmpCKT, $x, $y) = @_;

   my ($yy, $np, $PC) = 0;
   my $modName = "";

   # We now support the resistor "af" and "kf" parameters
   # directly so we don't need this code anymore. I'm commenting 
   # it out but leaving it here in case we run into a similar
   # situation down the road.
   return(0);

   # Spectre resistor models allow for flicker-noise parameters.
   # Gemini doesn't directly support this, however we can
   # we can use an InoiseBD in parallel with the resistor to
   # achieve a similar result. See Spectre_Tran.89

   # First check if we have an R_Model and a param is
   # either "kf" or "af". If the conditions are met 
   # then we look for the component(s) that use this
   # and create an InoiseBD in parallel with the resistor.
#   if ($SpiceCktT[$tmpCKT]->
#          {elementArray}[$x]->
#             {outputType} eq "R_Model")
#   {
#      if ($SpiceCktT[$tmpCKT]->
#             {elementArray}[$x]->
#                {paramArray}[$y]{name} eq "kf")
#      {
#         return( &AddFlickerNoise($tmpCKT, $x, $y, "kf") )
#      } # if
#      elsif ($SpiceCktT[$tmpCKT]->
#                {elementArray}[$x]->
#                   {paramArray}[$y]{name} eq "af")
#      {
#         return ( &AddFlickerNoise($tmpCKT, $x, $y, "af") )
#      } # elsif
#
#      else { return(0); }
#
#   } # if
#   else
#      { return(0); }
} # sub SpecialCase

###############################################################################
#
# Here we handle the details of hooking up an InoiseBD
# element in parallel with the given resistor.
#
# Note: We only need to set the ADS flicker noise if kf and
# af are specified (which is what we are doing here). The 
# flicker noise defaults to kf=0 which basically disables
# the equation by setting it to zero.
#
###############################################################################
sub AddFlickerNoise
{
   my ($tmpCKT, $x, $y, $var) = @_;

   my ($kf, $af) = "";
   my ($yy, $np, $pcount, $tcount, $numE) = 0;   

   if ($var eq "kf")
   {
      $kf = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
      while ($yy < $SpiceCktT[$tmpCKT]->{elementArray}[$x]{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->
                {elementArray}[$x]->
                   {paramArray}[$yy]{name} eq "af")
         {
            $af = $SpiceCktT[$tmpCKT]->
                       {elementArray}[$x]->
                          {paramArray}[$yy]{value};
            last; # Jump out of here
         } # if
         $yy++;
      } # while
   } # if
   else # must be "af" parameter
   {
      $af = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
      while ($yy < $SpiceCktT[$tmpCKT]->{elementArray}[$x]{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->
                {elementArray}[$x]->
                   {paramArray}[$yy]{name} eq "kf")
         {
            $kf = $SpiceCktT[$tmpCKT]->
                       {elementArray}[$x]->
                          {paramArray}[$yy]{value};
            last; # Jump out of here
         } # if
         $yy++;
      } # while
   } # else

   $modName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName};
   $pcount=0;
   $numE = $SpiceCktT[$tmpCKT]{numElements};
   while ($pcount < $numE)
   {
      $np = $SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{numParams};
      $yy = 0;
      while ($yy < $np)
      {
         if ( ($SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{paramArray}[$yy]{name} eq "Model") 
           && ($SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{paramArray}[$yy]{value} eq $modName) )
         {
            # Found it! There may be others so we don't just 
            # jump out of this loop when we're done with this one.
            $paramName = $SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{tagName};

            if ($SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{used})
            {
               # Need to check hash to see if we've already 
               # set an InoiseBD component for this resistor.
               # Since both kf and af params get used here it
               # could have already been set by a previous 
               # param.
               if   ( $Flicker{$paramName} eq "SET" ) { return(1); }
               else { $Flicker{$paramName} = "SET"; }

               my $pin1 = $SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{pinArray}[0]{name};
               my $pin2 = $SpiceCktT[$tmpCKT]->{elementArray}[$pcount]->{pinArray}[1]{name};

               # Note: for Gemini the name is: InoiseBD
               #       for schematic import:   I_NoiseBD

               $tcount = $SpiceCktT[$tmpCKT]{numElements};
 
               if ($WantGeminiOutput)
                   { $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->
                       {outputType} = InoiseBD; }
               else
                  { $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->
                       {outputType} = I_NoiseBD; }

               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{tagName} = "$paramName_Noise";

               &Record_NameValue_Pair($tmpCKT, 0, "K", $kf, $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 1, "Ie", $af, $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 2, "A0", "0", $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 3, "A1", "1", $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 4, "Fe", "1", $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 5, "Elem", "\"$paramName\"", $tcount, 0);
               &Record_NameValue_Pair($tmpCKT, 6, "Pin", "\"1\"", $tcount, 0);
               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{numParams} = 7;

               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{numPins} = 2;

               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->
                     {pinArray}[0]{name} = $pin1;
               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->
                     {pinArray}[1]{name} = $pin2;

               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{spiceType} = -1;
               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{tmpType} = "resolved";
               $SpiceCktT[$tmpCKT]->{elementArray}[$tcount]->{subcktName} = "resolved";

               &Record_ItemType($tmpCKT,$ItemType{element},$tcount);

               &Record_Usage($tmpCKT,$tcount,1);
   
               $SpiceCktT[$tmpCKT]{numElements}++;

               $PC = $SpiceCktT[$tmpCKT]{numElements};

               if ($PrintWarnings)
                  { WriteToLog("WARNING: The Spectre resistor model \"$modName\" is using the flicker\nnoise paramter(s) kf and/or af. These parameters are not directly\nsupported by the ADS resistor model. An InoiseBD element is being\ninserted in parallel with the resistor \"$paramName\" (which is referencing\nthe model) to model the flicker noise."); }
            } # if

         } # if
         $yy++;
      } # while
            
      $pcount++;
   } # while
    
   return(1);

} # sub AddFlickerNoise

###############################################################################
#
# Add in Spectre Math and Physical constants as variables.
# The constants are not being checked for in parameter values, equations, 
# or variables, and it will be more trouble than its worth to try and 
# convert them; its simpler to just make the constants, and use the ADS 
# internal values where appropriate.
#
# Note: Ideally, there should be an include wrapper around the constants, 
#       #ifndef SPECTRE_CONSTANTS
#       #define SPECTRE_CONSTANTS
#       .
#       .
#       .
#       #endif
#
#       This will require some additional logic in the write routines.
#
# The list of constants required is:
#
# Math constants
#
#  M_E = e
#  M_LOG2E = 1.4426950408889634074
#  M_LOG10E = log(e)
#  M_LN2 = ln(2)
#  M_LN10 = ln10
#  M_PI = pi
#  M_TWO_PI = 2*pi
#  M_PI_2 = pi/2
#  M_PI_4 = pi/4
#  M_1_PI = 1/pi
#  M_2_PI = 2/pi
#  M_2_SQRTPI = 2/sqrt(pi)
#  M_SQRT2 = sqrt(2)
#  M_SQRT1_2 = sqrt(1/2)
#  M_DEGPERRAD = 57.2957795130823208772
#
# Physical constants
#
#  P_Q = qelectron
#  P_C = c0
#  P_K = boltzmann
#  P_H = planck
#  P_EPS0 = e0
#  P_U0 = u0
#  P_CELSIUS0 = 273.15
#
###############################################################################

sub AddSpectreMathAndPhysicalConstants()
{
   my $topCkt=0;
   my $CUR_CKT=0;
   my $NameValueCount=1;
   $PC=$SpiceCktT[$CUR_CKT]{numElements};
   if($WantGeminiOutput)
   {
      StoreCommentLine("Spectre Math Constants\n#ifndef SPECTRE_MATH_CONSTANTS");
      StoreCommentLine("Define a CPP variable so the constants will not be redefined\n#define SPECTRE_MATH_CONSTANTS");
   }
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_E", "e");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_LOG2E", 1.4426950408889634074);
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_LOG10E", "log(e)");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_LN2", "ln(2)");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_LN10", "ln10");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_PI", "pi");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_TWOPI", "2*pi");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_PI_2", "pi/2");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_PI_4", "pi/4");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_1_PI", "1/pi");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_2_PI", "2/pi");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_2_SQRTPI", "2/sqrt(pi)");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_SQRT1_2", "sqrt(1/2)");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_DEGPERRAD", "57.2957795130823208772");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "M_SQRT2", "sqrt(2)");
   if($WantGeminiOutput)
   {
      StoreCommentLine("End of Spectre Math Constants\n#endif\n");

      StoreCommentLine("Spectre Physical Constants\n#ifndef SPECTRE_PHYSICAL_CONSTANTS");
      StoreCommentLine("Define a CPP variable so the constants will not be redefined\n#define SPECTRE_PHYSICAL_CONSTANTS");
   }
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_Q", "qelectron");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_C", "c0");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_K", "boltzmann");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_H", "planck");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_EPS0", "e0");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_U0", "u0");
   &AddSpectreMathAndPhysicalConstants_addVar($CUR_CKT, $SpiceCktT[$CUR_CKT]{numElements}, "P_CELSIUS0", "273.15");
   if($WantGeminiOutput)
   {
      StoreCommentLine("End of Spectre Physical Constants\n#endif\n");
   }
}

sub AddSpectreMathAndPhysicalConstants_addVar()
{
   my ($CUR_CKT, $tmpPC, $name, $value) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{ItemType} = $ItemType{var};
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{outputType} = "VAR";
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{name} = "VAR";
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{tagName} = "";
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{numParams} = 1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{tmpType} = "resolved";
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{used} = 1;      
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{paramArray}[$NameValueCount]{name} = $name;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{paramArray}[$NameValueCount]{value} = $value;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{paramArray}[$NameValueCount]{check} = 1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$tmpPC]->{paramArray}[$NameValueCount]{used} = 1;
   #$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams}++;
   $SpiceCktT[$CUR_CKT]{numElements}++;
   $PC=$SpiceCktT[$CUR_CKT]{numElements};
}

###############################################################################
#
# AddSpectreBooleanEquationEquivalents
#
# Add in Spectre Boolean function equivalents for use with the -pp option.
#
###############################################################################

sub AddSpectreBooleanEquationEquivalents()
{
   my $topCkt=0;
   my $CUR_CKT=0;
   my $NameValueCount=1;
   $PC=$SpiceCktT[$CUR_CKT]{numElements};
   if($WantGeminiOutput)
   {
      StoreCommentLine("Spectre boolean function replacements\n#ifndef SPECTRE_BOOLEAN_EQUATIONS");
      StoreCommentLine("Define a value so the functions will not be included multiple times\n#define SPECTRE_BOOLEAN_EQUATIONS");
      StoreCommentLine("Spectre Equals\nADS_SCS_EQ(x,y)=if (x == y) then 1 else 0 endif");
      StoreCommentLine("Spectre Not Equal\nADS_SCS_NEQ(x,y)=if (x != y) then 1 else 0 endif");
      StoreCommentLine("Spectre Less Than\nADS_SCS_LT(x,y)=if (x < y) then 1 else 0 endif");
      StoreCommentLine("Spectre Greater Than\nADS_SCS_GT(x,y)=if (x > y) then 1 else 0 endif");
      StoreCommentLine("Spectre Less Than or Equal To\nADS_SCS_LTE(x,y)=if (x <= y) then 1 else 0 endif");
      StoreCommentLine("Spectre Greater Than or Equal To\nADS_SCS_GTE(x,y)=if (x >= y) then 1 else 0 endif");
      StoreCommentLine("Spectre Trinary\nADS_SCS_TRINARY(z,x,y)=if (z == 1) then x else y endif");
      StoreCommentLine("End of the Spectre boolean function replacement block\n#endif\n");
   }
}

return(1);

#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# ReturnValue()
#
# IN  : array index for the eqn and the line
# OUT : incremented array index as well as the assignment value
#
#    Assumes the passed in index is pointing to an equation of the form:
#     Case 1: value=4
#     Case 2: value=(white space)4
#     Case 3: value(white space)=4
#     Case 4: value(white space)=(white space)4
#
# e.g. if we have: @L = "Rr1 1 2 R = 50"
#      the indexes are:  0   1 2 3 4 5
#
#      then an index of 3 and @L would be passed in.
#      The return parameters would be an index of 6 and a value of 50.
#
###############################################################################
sub ReturnValue
{
   my ($index, @L) = @_;
   my $x=$index;
   my $t;

   if ($L[$index] =~ /.=./)     # Case 1: value=4
   {
      # Get rid of "value="
      ($t = $L[$index]) =~ s/.*=//;
      return($index+1,$t);
   } # if

   elsif ($L[$index] =~ /.=/)   # Case 2: value=(white space)4
   {
      return($index+2,$L[$x+1]);
   } # if

   elsif ($L[$index+1] =~ /=./) # Case 3: value(white space)=4
   {
      # Get rid of "="
      ($t = $L[$index+1]) =~ s/=//;
      return($index+2, $t);
   } # if

   else                         # Case 4: value(white space)=(white space)4
   {
      return($index+3,$L[$x+2]);
   } # if

} # sub ReturnValue()

###############################################################################
#
# CheckForCommentLine()
#
#  Returns TRUE if the entire line is a comment.
#
###############################################################################
sub CheckForCommentLine
{
   my ($line) = @_;

   # The Spectre comment characters are "//" and "*".
   # We ignore any white space before the comment.
   # If a line is full of just white space we consider this
   # a comment.
   # Also, Reading ";" as comment. Spectre_Tran.259

   if (($line =~ /^\s+$/) || ($line =~ /^(\s*)?\/\//) || ($line =~ /^(\s*)?\*/) || ($line =~ /^(\s*)?\;/) || ($line eq "")) 
        { return(1); }

   else { return(0); }

} # sub CheckForCommentLine

###############################################################################
#
# CheckForInlineComment()
#
#  Returns TRUE if a comment is embedded within a line
#  
###############################################################################
sub CheckForInlineComment
{
   my ($line) = @_;

   #$lcc = "\\$inlineCommChar";

   if ( ($line !~ /^\/\//) && ($line =~ /\/\//) ) {return(1);}
   else { return(0); }

} # sub CheckForInlineComment

###############################################################################
# Record_NameValue_Pair()
#
#   This routine stores name/value pairs
#
#   IN  : $NameValueCount - This counter keeps track of the number of
#                           name/value pairs for this particular component.
#         $name  - Hash name entry
#         $value - Hash value entry
#         $PC    - This is the element counter for the given circuit
#         $check  - If TRUE then this param name is checked in post
#                  processing to map it over to the proper ADS name.
#
#   RETURNS : N/A - The global $SpiceCktT[$CKT]->{elementArray} paramArray is
#             updated...
#
###############################################################################
sub Record_NameValue_Pair
{
   my ($CUR_CKT, $NameValueCount, $name, $value, $PC, $check) = @_;

   # Check to see if the parameter is "m", and that the element type is a sucircuit.  If it is, 
   # the parameters will not be mapped because subcircuits do not have an entry in spectre.rul.
   # The mapping needs to be done here.
    
   if( $name eq "m" && ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 5) )
       { $name="_M"; }
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$NameValueCount]{name} = $name;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$NameValueCount]{value} = $value;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$NameValueCount]{check} = $check;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$NameValueCount]{used} = 1;

} # sub Record_NameValue_Pair

###############################################################################
# Record_SubCkt_NameValue_Pair()
#
#   This routine stores name/value pairs
#
#   IN  : $NameValueCount - This counter keeps track of the number of
#             name/value pairs for this particular component.
#         $name  - Hash name entry
#         $value - Hash value entry
#
#   RETURNS : N/A - The global $SpiceCktT[$CKT]->{elementArray} paramArray is
#             updated...
#
###############################################################################
###############################################################################
sub Record_SubCkt_NameValue_Pair
{
   my ($CUR_CKT, $NameValueCount, $name, $value) = @_;

   my ($numP, $numE, $SpecialCount) = 0;

   if ($CUR_CKT ne 0)
   {  
      push(@CktParamStack,$name);
     if(!$backwardCompatible)
     {
      # Check $value for any nondigit characters
      if ( ($value =~ /\D/) ) #&& ($GenSpectreEqns) )
      {
         # We need to check if a previous ckt parameter is being
         # used in this equation. If it is we then drop this from
         # the circuit param list and make it an ADS equation.
         if (&CktParamReference($value))
         {
            $SpiceCktT[$CUR_CKT]->{paramReference}=1;
            # Move the parameter off the parameters line.  The user will have to go in and determine 
            # if this was appropriate or not.
            &Record_NameValue_Pair($CUR_CKT, 0, $name, $value, $PC,1);
            $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
            $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
            $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
            if ($SuppressIncludeComponents && ($IncludeCount > 0))
               { &Record_Usage($CUR_CKT,$PC,0); }
            else
               { &Record_Usage($CUR_CKT,$PC,1); }
   
            $PC++;
            $SpiceCktT[$CUR_CKT]{numElements} = $PC;
           
         } # if
         else
         {
            $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
            $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = $value;
	    
	 } # else
      } # if
      else
      {
         $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
         $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = $value;
      } # else
    }
    elsif($backwardCompatible)
    { 
      # Check $value for any nondigit characters
      if ( ($value =~ /\D/) && ($GenSpectreEqns) )
      {  
         # We need to check if a previous ckt parameter is being
         # used in this equation. If it is we then drop this from
         # the circuit param list and make it an ADS equation.
         if (&CktParamReference($value))
         {
            if ($Equation_Msg_Toggle)
            {
               $Equation_Msg_Toggle = 0; # Gets turned on when in new ckt
               if ($PrintWarnings && $PreserveSubcktParams)
               {
                  WriteToLog("\nWARNING: The subcircuit \"$SpiceCktT[$CUR_CKT]{name}\" contained parameters that reference each other.");
                  WriteToLog("         Because the -pp option was specified, a set of ADS_ variables have been created, which will");
                  WriteToLog("         attempt to duplicate the logic that existed in the original Spectre netlist.  Note that these");
                  WriteToLog("         equations will use generic names, and will be difficult to debug.\n");
               }
               elsif ($PrintWarnings)
               {
                  WriteToLog("\nWARNING: The subcircuit \"$SpiceCktT[$CUR_CKT]{name}\" contained parameters that reference each other.");
                  WriteToLog("         These parameters have been moved so they are no longer passed in parameters for the subcircuit.");
                  WriteToLog("         Make sure to verify that the paramters that have been moved are not required to be available");
                  WriteToLog("         for instance pass in.  You may alternatively specify the -pp option on the command line.");
                  WriteToLog("         This will cause the netlist translator to create intermediate variables that mimic the ");
                  WriteToLog("         spectre logic, but will leave all of the spectre parameters available for pass in.");
               } # if
            } # if
            if ($PreserveSubcktParams)
            {
               # Make sure that $name has not already been accounted for
               unless (grep /$name/, @SubstitutionList)
               {
                  push(@SpecialEquation,$name);
                  push(@SpecialEquation,$value);
               }
               $SpecialCount = @SpecialEquation/2;
               $value = "";
               $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
               $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = "\"UNDEF\"";
            } # if
            else
            {
               # Move the parameter off the parameters line.  The user will have to go in and determine 
               # if this was appropriate or not.
               &Record_NameValue_Pair($CUR_CKT, 0, $name, $value, $PC,1);
               $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
               $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
               $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
               if ($SuppressIncludeComponents && ($IncludeCount > 0))
                  { &Record_Usage($CUR_CKT,$PC,0); }
               else
                  { &Record_Usage($CUR_CKT,$PC,1); }
   
               $PC++;
               $SpiceCktT[$CUR_CKT]{numElements} = $PC;
               #$SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
               #$SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = $value;

            } # else
         } # if
         else
         {
            $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
            $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = $value;
	    
	    #$PC++;
            #$SpiceCktT[$CUR_CKT]{numElements} = $PC;
         } # else
      } # if GenSpectreEqns
     
      else
      {  
         $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{name} = $name;
         $SpiceCktT[$CUR_CKT]->{paramArray}[$NameValueCount]{value} = $value;
         #Spectre_Tran.226, related to "-se" option    
         #$PC++;
         #$SpiceCktT[$CUR_CKT]{numElements} = $PC;
      } # else
     
     }#elseif backwardCompatible
   } # if
   else # $CUR_CKT eq 0
   {
      &Record_NameValue_Pair($CUR_CKT, 0, $name, $value, $PC, 1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else 
         { &Record_Usage($CUR_CKT,$PC,1); }

      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;
   } # else

} # sub Record_SubCkt_NameValue_Pair
###############################################################################
# Record_ZeroPinSubCkt_NameValuePair()
#
#   This routine stores name/value pairs
#
#   IN  : $NameValueCount - This counter keeps track of the number of
#             name/value pairs for this particular component.
#         $name  - Hash name entry
#         $value - Hash value entry
#
###############################################################################
sub Record_ZeroPinSubCkt_NameValuePair
{
   my ($CUR_CKT, $NameValueCount, $name, $value) = @_;
   my $SpecialCount=0;
   my $numP=0, my $numE=0;

   &Record_NameValue_Pair($CUR_CKT, 0, $name, $value, $PC, 1);
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";

   if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else
         { &Record_Usage($CUR_CKT,$PC,1); }
   # When the value of a parameter contains an expression with the operators that are
   # not directly supported and thus needs to be translated using equations, the value
   # is made "" in FixShiftOperators()...
   if($value ne "")
   {
      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;
   }
} # sub Record_ZeroPinSubCkt_NameValuePair

###############################################################################
# CktParamReference()
#
#   Checks the parameter stack to see if this equation is
#   referencing a previously allocated paramter in this same
#   circuit param list. ADS does not allow this and we have
#   to provide special processing to take care of it.
#
###############################################################################
sub CktParamReference
{
   my ($value) = @_;

   my $x=0;

   if ($value !~ /^\d$/)
   {
      while ($x < @CktParamStack)
      {
         # IMPORTANT MATCH...see if previous ckt var is referenced...
         # We match like this:
         #   <possible nonword chars>value<possible nonword chars>
         if ( ($value eq @CktParamStack[$x]) ||
              ($value =~ /^@CktParamStack[$x]\W+?/) ||
              ($value =~ /\W+?@CktParamStack[$x]\W+?/) ||
              ($value =~ /\W+?@CktParamStack[$x]$/))
         { return(1); }
         $x++;
      } # while
   } # if

   return(0);

} # sub CktParamReference

###############################################################################
# CheckForDuplicate()
#
#   Return TRUE if a duplicate element name is found.
#
###############################################################################
sub CheckForDuplicate
{
   my ($ElemName) = @_;
   my $x=0;

   while ($x++ < $SpiceCktT[$CUR_CKT]{numElements})
   {
      if ($SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tagName} eq $ElemName)
      {
         if ($PrintWarnings) {
         &WriteToLog("WARNING: Duplicate element ($ElemName) - skipping."); }
         return(1);
      } # if
   } # while
   return(0);
} # sub CheckForDuplicate

###############################################################################
#
# StoreCommentLine()
#
#  The comment line is stored in the tagName variable.
#
###############################################################################
sub StoreCommentLine
{
   (my $line) = @_;
 
   my $ok = 1;

   my $lcc = $lineCommChar;
   my @L=();
   my $CommentLength = "";
   
   # Unknown model parameters discarded
   if($line=~"^model") 
   { 
      @L=split(" ",$line);
      $line=  @L[0]." ".@L[1]." ".@L[2];
    }
   # Check for "//" or "*" at the begining of 
   # a line - otherwise we just have a blank line.
   if ( ($line =~ /^\/\//) || ($line =~ /^\*/) )
   {
      # Get rid of "//" characters.
      $line =~ s/^\*//;
      $line =~ s/^\/\///;
      
      $line = $GeminiCommChar . $line;

   } # if
   elsif ($line !~ /^\s*$/)
      { $line = $GeminiCommChar . $line; }
   
   # For comment length is greater then 1024, nettrans gives segment fault .
   # Fault was at char tagName[1024], function: StoreSubckt() in spcread_pl.c
   # ATM: Spectre_Tran.173
   
   $CommentLength = length($line);
   if($CommentLength >= 1024)
   {  
      @L=split(" ",$line);
      $line=  @L[0]." ".@L[1]." ".@L[2];
   }
   
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $line;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

   if ($SuppressIncludeComponents && ($IncludeCount > 0))
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
   else
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; } 
   $PC++;  # Bump up the Parameter Counter
   $SpiceCktT[$CUR_CKT]{numElements} = $PC;

} # sub StoreCommentLine

###############################################################################
#
# StoreInlineComment()
#
#  The comment part of the line is stored in the tagName variable.
#
###############################################################################
sub StoreInlineComment
{
   (my $line) = @_;

   my $lcc = "\\$inlineCommChar";
   my $comment;
   my $TheElement = $SpiceCktT[$CUR_CKT]->{elementArray}[$PC];

   # We now leave the line intact.
   #   ($comment = $line) =~ s/.*$lcc//;

   # We have to get rid of the inline comment character 
   # because it causes problems for the ADS simulator.
   ($comment = $line) =~ s/$lcc//;

   # Prepend the the gemini comment character
   $comment = $GeminiCommChar . " " . $comment;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $comment;

   if ($SuppressIncludeComponents && ($IncludeCount > 0))
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
   else
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; }
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

   if ($SuppressIncludeComponents && ($IncludeCount > 0))
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
   else
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; } 

   $PC++;  # Bump up the Parameter Counter

   $line =~ s/$lcc.*//;

   return($line);

} # sub StoreInlineComment
sub store_ifElse
{
   (my $line) = @_;

   # Check for backward compatability
   my $ok = 1;

   if($backwardCompatible)
   {
     WriteToLog("WARNING: Statement \"$line\" is not supported with backward compatible mode \"-bc\" option. \n");  
     &StoreCommentLine($line);
   }
   else
   {         
    	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $line;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

        if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
       else
         { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; } 
       $PC++;  # Bump up the Parameter Counter
       $SpiceCktT[$CUR_CKT]{numElements} = $PC;
   }
} #store_ifElse
sub Record_statistics
{
   (my $line) = @_;
   my $ok = 1;
   
   # Check for backward compatability
   if($backwardCompatible)
   {
     WriteToLog("WARNING: Statement \"$line\" is not supported with backward compatible mode \"-bc\" option. \n");  
     &StoreCommentLine($line);
   }
   else
   {    
        if (($line =~ /^statistics \{/) && $StatisticExit_Flag == 0 )
	{ $line="simulator lang=spectre"."\n".$line;}
	if($line =~ "{")
	{$StatisticExit_Flag++;}
	if($line =~ "^}")
	{
	   $StatisticExit_Flag--;
	   if( $StatisticExit_Flag == 0)
	   { $line =$line."\n"."simulator lang=ads";}
	}
        	
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $line;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";

        if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
       else
         { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; } 
       $PC++;  # Bump up the Parameter Counter
       $SpiceCktT[$CUR_CKT]{numElements} = $PC;
       
   }
} #Record_statistics

sub Record_SpectreStatement
{
   (my $line) = @_;
   my $ok = 1;
   
   # Check for backward compatability
   if($backwardCompatible)
   {
     WriteToLog("WARNING: Statement \"$line\" \n\t\t is not supported with backward compatible mode \"-bc\" option. \n");  
     &StoreCommentLine($line);
   }
   else
   {
        $line="simulator lang=spectre"."\n".$line;
	$line =$line."\n"."simulator lang=ads";
	
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = 0;
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{comment};
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = -1;
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $line;
	$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = "resolved";
	
	if ($SuppressIncludeComponents && ($IncludeCount > 0))
	{ $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 0; }
	else
	{ $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = 1; } 
	$PC++;  # Bump up the Parameter Counter
	$SpiceCktT[$CUR_CKT]{numElements} = $PC;
   }
} #Record_SpectreStatement

###############################################################################
# CheckForNameValuePair()
#
#   When this routine is called it is assumed that we are looking at either
#   name value pair or something else.
#
#   If we find a name value pair then we return FALSE.
#   Otherwise - return TRUE.
#
#   e.g.: "X1"              will return FALSE
#         "X1 m=2"          will return FALSE
#
#         "Rmodel=75ohms"   will return TRUE
#         "Rmodel =75ohms"  will return TRUE
#
###############################################################################
sub CheckForNameValuePair
{
   my ($index, @L) = @_;

   if ( ($L[$index] =~ /=/) || ($L[$index+1] =~ /^=/) ) { return(1); }

   else { return(0); } #### We have a subcircuit node

} # sub CheckForNameValuePair

###############################################################################
# Record_subcircuit()
#
###############################################################################
sub Record_subcircuit
{
   my ($CUR_CKT, $a_name, $PC) = @_;

   # We need to be sure that reserved words are
   # being checked for. We don't need to output
   # a warning to the log - that's done in the
   # Fix_CKT_Name() routine. Otherwise, we would
   # have too many messages in the log making it
   # more confusing than it already is...
   $a_name = &FixChars($a_name);
   if ($ADSIllegalSubcktName{$a_name} eq "TRUE")
      { $a_name = $a_name . "xE"; }

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{subcktName} = $a_name;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{cktDuplicateIndex} = &CheckDuplicateCKT_Names($a_name);
} # sub Record_subcircuit

###############################################################################
# Record_name()
#
#   Note: ADS wants the element name to be in lower case
#  
#     IN: $a_name - The name of the component
#         $PC     - This is the element counter for the given circuit
#
###############################################################################
sub Record_name
{
   my ($a_name, $PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tagName} = $a_name;
} # sub Record_name

###############################################################################
# Record_BSIM_name()
#
#     Store the original name of a bsim model. Spectre uses
#     one model name to reference the binning characteristics.
#     ADS requires separate models so we append "_1", "_2" etc
#     to the the original bsim name for the different sections
#     of the model. We need the original bsim name to match up
#     referencing components in post processing.
#  
#     IN: $a_name - The name of the component
#         $PC     - This is the element counter for the given circuit
#
###############################################################################
sub Record_BSIM_name
{
   my ($a_name, $PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{bsimName} = $a_name;
} # sub Record_BSIM_name

###############################################################################
# Record_SubcircuitNode()
#
#   IN: $a_name   - node name
#       $a_number - number of the node
#
###############################################################################
sub Record_SubcircuitNode
{
   my ($CUR_CKT, $a_name, $a_number) = @_;

   $SpiceCktT[$CUR_CKT]->{pinArray}[$a_number]{name} = $a_name;
} # Record_SubcircuitNode

###############################################################################
# Record_ElementNode()
#
#   IN: $a_name   - node name
#       $a_number - number of the node
#       $PC       - This is the element counter for the given circuit
#
###############################################################################
sub Record_ElementNode
{
   my ($a_name, $a_number, $PC, $CUR_CKT) = @_;
   
      my $comp = $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{SpectreType};
      my $a_num = $SpecMap{element}{$comp}{pin}[$a_number];

      # $a_num might be "" if this is a model reference instance.
      # If that's the case this routine will get called again in
      # post processing once the component type has been looked up.

      if ($a_num eq "") { $a_num = $a_number; }
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{pinArray}[$a_num]{name} = $a_name;
} # Record_ElementNode

###############################################################################
# Record_outputType()
#
#   IN: $type - The type of element/model we have - from the mapping rules
#               file.
#       $PC   - This is the element counter for the given circuit
#       
#
###############################################################################
sub Record_outputType
{
   my ($CUR_CKT, $type, $PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{outputType} = $type;
} # Record_outputType

###############################################################################
# Record_LiteralElementTypeE()
#
#   IN: $type - The original element name before translation in post processing
#       $PC   - This is the element counter for the given circuit
#
###############################################################################
sub Record_LiteralElementTypeE
{
   my ($type,$PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = $type;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{SpectreType} = $type;
} # Record_LiteralElementTypeE

###############################################################################
# Get_ItemType()
#
#   IN: $PC   - This is the element counter for the given circuit
#
#      This routine returns the type of item we are dealing with.
#      The verbiage supports the rule mapping file references.
#
###############################################################################
sub Get_ItemType
{
   my ($CUR_CKT, $PC) = @_;

   if ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 0)
      { return("comment"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 1)
      { return("element"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 2)
      { return("model"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 3)
      { return("data_item"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 4)
      { return("var"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 5)
      { return("subcir"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 6)
      { return("subcir_def"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 7)
      { return("lib_section_ref"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 8)
      { return("lib_section_def"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 9)
      { return("ahdl_include"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 10)
      { return("spectre_lang_ref"); }
   elsif ($SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} == 11)
      { return("inline_subcir_def"); }  
   else { return("comment"); }
   
} # sub Get_ItemType

###############################################################################
# Record_ItemType()
#
#   IN: $type - Item Type - i.e.: element, model, subcircuit, comment from 
#               %ItemType
#       $PC   - This is the element counter for the given circuit
#
###############################################################################
sub Record_ItemType
{
   my ($CUR_CKT, $type, $PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $type;
} # sub Record_ItemType

###############################################################################
# Record_ModelType()
#
#   IN: Model Type
#       From the %ModelType hash
#
###############################################################################
sub Record_ModelType
{
   my ($type,$PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{spiceType} = $type;
} # sub Record_ModelType

###############################################################################
# Record_NumberOfPins()
#
#   IN: Total number of pins for this item type.
#
###############################################################################
sub Record_NumberOfPins
{
   my ($a_number,$PC) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numPins} = $a_number;
} # sub Record_NumberOfPins

###############################################################################
# Record_NumberOfCktParams()
#
###############################################################################
sub Record_NumberOfCktParams
{
   my ($a_value) = @_;

   $SpiceCktT[$CUR_CKT]->{numParams} = $a_value;
} # sub Record_NumberOfCktParams

###############################################################################
# Record_NumberOfParams()
#
#   IN: Total number of params for this item type. 
#
###############################################################################
sub Record_NumberOfParams
{
   my ($CUR_CKT, $PC, $a_number) = @_;
   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = $a_number;
} # sub Record_NumberOfParams

###############################################################################
# Record_Usage()
#
#   IN: Boolean indicating whether this item type is actually used or not
#
###############################################################################
sub Record_Usage
{
   my ($CUR_CKT,$PC,$used) = @_;

   $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{used} = $used;

} # sub Record_Usage 

###############################################################################
# RecordincludeRef()
#
#   For elements that reference models, we need to check record if it's in 
#   an include file. This is to support the supression of components in
#   subcircuits when $SuppressIncludeComponents is set from the command line.
#   It's used in post processing.
#
###############################################################################
sub RecordincludeRef
{
   my ($CUR_CKT, $PC) = @_;
   if ($SuppressIncludeComponents && ($IncludeCount > 0))
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef} = 1; }
   elsif ($PrevFile && $SuppressIncludeComponents)
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef} = 1; }
   else
      { $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{includeRef} = 0; }

} # sub RecordincludeRef

###############################################################################
#
# RecordOutputType()
#
#   This routine maps the type of component we have from $SpecMap{}.
#   $SpecMap{} is configured when the mapping rules file is read.
#
###############################################################################

sub RecordOutputType
{
   my ($k,$x,$XspiceModelType) = @_;

   my $XspiceType="", $T="", $CB_fun="";
   my @CLBK;

   # Determine if this is an element or a model.
   $T = &Get_ItemType($k,$x);

   if ($XspiceModelType)
   {
      # This parameter gets passed in when
      # An element is being resolved in post
      # processing. The passed in parameter
      # is the model type. We map this back
      # to get the element type. This is done
      # when resolving model references.
      $XspiceType = $XspiceModelType;
   } # if
   else
   {
      # $XspiceType is the component that we need to map into an ADS component.
      # We grab the Xspice name here.
      $XspiceType = $SpiceCktT[$k]->{elementArray}[$x]->{tmpType};

   } # else

   # Check to see if we have a CallBack for this.
   @CLBK = split(",",$SpecMap{$T}{$XspiceType}{CB}[$outputTypeCB_idx]);

#print("----------------------------($T)-----------------------\n");
   if (@CLBK) # We've got a CallBack for this
   {
      # We need to source in the CallBack file if it hasn't already been done.
      if (!($CB_fileRead{@CLBK[0]}))
      { 
         if (@CLBK[0]) { require("@CLBK[0]"); }
         else { print("*** ERROR: No CallBack specified: (@CLBK)\n"); }
         $CB_fileRead{@CLBK[0]} = 1; # Set this CallBack as being read.
      } # if

      $CB_fun = @CLBK[1];

      # Call the CallBack routine and pass the Xspice type.
      # The return value should be the ADS equivalent name.
      $outType = &$CB_fun($SpecMap{$T}{$XspiceType});

      # If the element or model was part of an include file and
      # we are suppressing its output, then we check that here.
      if ($SpiceCktT[$k]->{elementArray}[$x]->{includeRef})
         { &Record_Usage($k,$x,0); }
      else { &Record_Usage($k,$x,1); }

      if ( ($outType =~ /HASH/i) || ($outType eq "") )
      { 
         # We have an unknown type!! Save the original 
         # name it is probably a model reference.
         # We can match it up later.
         $outType = $XspiceType;

         # Set this to false...if it's actually a model
         # reference we will set it to 1. If this turns
         # out to not be a model reference then this is
         # an unsupported device.
         &Record_Usage($k,$x,0);

      } # if

      &Record_outputType($k,$outType,$x);
      # Mark this name as being resolved if the name
      # to be translated was explicitly passed in
      if ($XspiceModelType)
      {
         $SpiceCktT[$k]->{elementArray}[$x]->{tmpType} = "resolved";
         # Save the Xspice name for this component so its parameter
         # names can be hashed into the ADS names.
         $SpiceCktT[$k]->{elementArray}[$x]->{SpectreType} = $XspiceModelType;
      } # if

   } # if
   else # No CallBack....just check the hash.
   {
      if ( ($SpiceCktT[$k]->{elementArray}[$x]->{tmpType} ne "resolved") &&
           ($SpiceCktT[$k]->{elementArray}[$x]->{ItemType} ne $ItemType{ahdl_include}) )
      {
         # If the element or model was part of an include file and
         # we are suppressing its output, then we check that here.
         if ($SpiceCktT[$k]->{elementArray}[$x]->{includeRef})
            { &Record_Usage($k,$x,0); }
         else 
            { &Record_Usage($k,$x,1); }

         $outType = $SpecMap{$T}{$XspiceType};
         if ( ($outType =~ /HASH/i) || ($outType eq "") )
         {
            # We have an unknown type!! Save the original 
            # name it is probably a model reference.
            # We can match it up later.
            # For Unknown model instance, $outType will be set in post.pl sub ParamReferences
	    if( $T ne "element")  
	    {
	      $outType = $XspiceType;

            # Set this to false...if it's actually a model
            # reference we will set it to 1. If this turns 
            # out to not be a model reference then this is
            # an unsupported device.
              &Record_Usage($k,$x,0);
	    }

         } # if
         &Record_outputType($k,$outType,$x);
      } # if
   } # else
} # sub RecordOutputType



###############################################################################
#
# store_subckt_def
#
#  IN:
#     circ_number  : The index for this subcircuit
#     name         : Subcircuit name - defaults to name of spice file
#     numPins      : Number of pins
#
#     All other subcircuit parameters are stored on the fly...
#
###############################################################################

sub store_subckt_def
{
   my ($circ_number, $name, $numPins) = @_;
   $name =~ s/^.*\///;
   $name =~ s/^.*\\//;
   $name =~ s/\..*$//;
   $SpiceCktT[$circ_number]{name} = $name;
   $SpiceCktT[$circ_number]{numPins} = $numPins;
   $SpiceCktT[$circ_number]{numParams} = 0;
   $SpiceCktT[$circ_number]{numElements} = 0;
   $SpiceCktT[$circ_number]{numWires} = 0;

} # sub store_subckt_def

###############################################################################
# FixNodeChars()
#
#   IN: Node name
#  OUT: Node name with illegal characters replaced with a "_"
#
#       We first check $notlegal_node and replace any matches
#       with "_". We also check $islegal_node - if we have a
#       match then the node needs to be a quoted string if we
#       are generating netlist output (if IFF don't quote node).
#
###############################################################################
sub FixNodeChars
{
   my ($N) = @_;

   my @chars=(), @notlegal=(), @legal=();
   my $x=0, $y=0, $quoteNode=0, $Node="", $ch="";

   @chars    = split("", $N);
   @notlegal = split("", $notlegal_node);

   # If we have one of these then we have to put quotes around the node name
   @legal = split("", $islegal_node);

   while ($x < @chars)
   {
      $ch = @chars[$x];
      $y = 0;
      while ( $y < @notlegal)
      {
         # If we have a match jump out of loop and try new character
         if ($ch eq @notlegal[$y]) { $ch = "_"; last;}
         $y++;
      } # while
      $Node = $Node . $ch;
      $x++;
   } # while

   if ($WantGeminiOutput)  # See if we need to quote the node
   {
      $x = 0;
      while ($x < @chars)
      {
         $ch = @chars[$x];
         $y = 0;
         while ( $y < @legal)
         {
            # If we have a match set flag and jump out of here...
            if ($ch eq @legal[$y]) { $quoteNode=1; last;}
            $y++;
         } # while
  
         if ($quoteNode)
         {
            # Put quotes around the node name
            $Node = "\"" . $Node . "\"";
            last; # We found a match so jump out of here...
         } # if
         $x++;
      } # while
   } # if

   return($Node);

} # sub FixNodeChars

###############################################################################
# FixChars()
#
#   IN: String name
#  OUT: Name with illegal characters replaced with a "x"
#
#       We check all characters with $islegal - if we don't have
#       a match then we replace the character with an "x".
#
#       This routine is called to fix element names (tagName) and
#       model names.
#   
###############################################################################
sub FixChars
{
   my ($N) = @_;

   my @chars=();
   my $x=0, $y=0, $Node="", $ch="";

   if ($N)
   {
      @chars    = split("", $N);

      while ($x < @chars)
      {
         $ch = @chars[$x];
         $y = 0;

         # If the character isn't in the list then replace it...
         if (!($islegal =~ /\Q$ch\E/)) { $ch = "x"; }

         $Node = $Node . $ch;
         $x++;
      } # while
   } # if

   return($Node);

} # sub FixChars

###############################################################################
#
# RecordRawNodes() : Record all of the nodes of the component.
#
#    Post processing on the nodes to check for special 
#    characters and reserved words will be done later.
#
###############################################################################
sub RecordRawNodes
{
   my ($x, $CUR_CKT, @L) = @_;
   my $nodeCount = 0;
   my $newx=0;
   my $newy=1;
   
   # For blank  space between '(' and First node name Spectre_Tran.222  Ramesh Feb11, 2005
   # Required specifically for controlled sources, however may be applicable for other cases too.
   while ($newx < $x)
   {
     if (@L[$newx] eq "(" )
      { 
       $newy=1;
        while ($newy < $x)
         {
    	    @L[$newy]=@L[$newy+1];
            $newy++;
	 } # while
	$x = $x -1 ;
	}
     $newx++;
   } #while
   while ($x > 0)
   {
      # We set $x-1 in the index because as we traverse
      # backwards the last node should be stored at index 0.

      @L[$x] =~ s/[()]//;  # Strip off any parens if they exist.
     if (@L[$x] ne "")
      {  
         &main::Record_ElementNode(@L[$x], $x-1, $PC, $CUR_CKT);
         $nodeCount++;
      } # if
      elsif ($x == 1)
      {
         # Corner case shouldn't happen very often.
         # Takes care of "( node1 node2)" condition - we
         # need to re-index all nodes down one...
         my $y = 0;
         while ($y < $nodeCount)
         {
    	    $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{pinArray}[$y]{name} = $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{pinArray}[$y+1]{name};
    	    $y++;
         } # while 
      } # elsif
      $x--;
   } # while
   &main::Record_NumberOfPins($nodeCount, $PC);

} # sub RecordRawNodes

###############################################################################
#
# RecordDefaults() : Record all of the default parameters of the component.
#                    This is only done if they are different from the ADS
#                    default (or are otherwise set in the spectre.rul file).
#
##############################################################################
sub RecordDefaults
{
   my ($ItemType) = @_;

   my $valueCount=0;
   my $ParamKey="";
   my @Val=();
   my $EName=$SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{SpectreType};
   my $T=&Get_ItemType($CUR_CKT, $PC);
   my $knownModelFound=TRUE;
   my $Commentline="";
   #Check if its item type is a model
   if ($T eq "model")
   {
      if (!keys %{$SpecMap{$ItemType}{$EName} } && $WantGeminiOutput)
      { 
         print("Warning: ADS Netlist Translator found unknown model \"$EName\".\n\t It will be commented in ADS netlist and its parameters discarded.  \n");
         if ($PrintWarnings)
	 {
            WriteToLog("WARNING: ADS Netlist Translator found unknown model \"$EName\".  \n");
            WriteToLog("\t You may have to find an alternate way to implement this in ADS.  \n");
         }
         $Commentline="ADS Netlist Translator found unknown model \"$EName\" \n\;You may have to find an alternative way to implement this in ADS.";
         $knownModelFound=FALSE;
         # store the  model and parameters in comment line from main.pl
         &StoreCommentLine($Commentline); 
      } 
   }
   for $ParamKey (keys %{$SpecMap{$ItemType}{$EName} } )
   {
      @Val = split(",",$SpecMap{$ItemType}{$EName}{$ParamKey});

      if (@Val[1])
      {
         #print("**********************************\n");
         #print("Spectre Name = ($ParamKey)\n");
         #print("ADS Name = (@Val[0])\n");
         #print("      Default Value=(@Val[1])\n");
         #print("($ItemType),($EName),($ParamKey)\n");
         #print("**********************************\n");

         # @Val[0] is the name and @Val[1] is the value.
         &Record_NameValue_Pair($CUR_CKT, $valueCount, $ParamKey, @Val[1], $PC, 1);
         ##############Following line Commented temporarily, more investigation needed
	 #&Record_NumberOfParams($$CUR_CKT, $PC, $valueCount);
         $valueCount++;

      } # if
      # else no default value - ignore.
   } # for

   if($knownModelFound eq "FALSE")
   { return (FALSE);}
   else
   {return($valueCount);}

} # sub RecordDefaults

###############################################################################
#
# RecordParams() : Record all of the parameters of the component.
#
#    NOTE: An added wrinkle of Spectre is that it allows for 
#          white space in equations. This algorithm takes
#          that into account.
#
##############################################################################
sub RecordParams
{
   my ($NumOfDefaults, $x, @Line) = @_;

   my $y=0, my $FirstTime=1, my $defCount=0;
   my @Right=(), my @Left=();
   my $R="", my $newLeft="";
   my $Left=""; #Spectre_Tran.195 Ramesh Feb.1,2005
   my $valueCount=$NumOfDefaults;
   my $LeftParenth_paramName_found=0;
   my $LeftParenth_paramVal_found=0;
   
   # e.g: Rr25 (MINUS 5)  resistor  ( r = rval4)
   if( $Line[$x-1] eq '(')
   { $LeftParenth_paramName_found=1; }
   
   # Shift out all the stuff leading up to the name value pairs.
   while ($y != ($x)) { shift(@Line); $y++;}

   # Need to do special processing if we have "coeffs" specifed.
   # These are used for VCVS and VCCS instances.
   ($valueCount,@Line) = &Check_coeffs($valueCount,@Line);
   
   # Need to do special processing if we have "wave" specifed.
   # These are used for VSOURCE and ISOURCE instances.
   ($valueCount,@Line) = &Check_wave($valueCount,@Line);
   
   $x=0;
   while ($x < @Line)
   {
      # Case "foo =bar" or "foo = bar"
      if (@Line[$x] =~ /^=/)
      {
         if ($FirstTime) { $Left = @Line[$x-1]; $FirstTime = 0;}
         else # Already been storing...
         {
            # Grab the new left hand side
            $newLeft = pop(@Right);

            $R = join "", @Right;
            $R =~ s/=//;
           
            if (!(&DefaultExists($Left, $R, $NumOfDefaults)))
            {
               $R = &FixEquation($Left, $R);
	       &Record_NameValue_Pair($CUR_CKT, $valueCount, $Left, $R, $PC, 1);
               $valueCount++;
            } # if
            @Right = ();
            $Left = $newLeft;
         } # if
      } # if
      elsif (@Line[$x] =~ /=/) # We have the either "foo=bar" or "foo= bar"
      {
         if ($FirstTime)
         {
            @tmp = split("=",@Line[$x]);
            $Left = @tmp[0]; # Save the left hand side of the equation
            if ($Left =~ /^\(/)  { $Left = $' ;}
            @Line[$x] =~ s/$Left//; # Get rid of what we just stored
            $FirstTime = 0;
         } # if
         else
         {
            $newLeft = $`;  # Store the left hand side for the next equation

            $R = join "", @Right;
            $R =~ s/=//;
   	    	    
	    if (!(&DefaultExists($Left, $R, $NumOfDefaults)))
            {
               $R = &FixEquation($Left, $R);
               &Record_NameValue_Pair($CUR_CKT, $valueCount, $Left, $R, $PC, 1);
               $valueCount++;
            } # if
            @Right = ();
            $Left = $newLeft;  # Store the left hand side
            if ($Left =~ /^\(/)  { $Left = $' ;}
            @Line[$x] =~ s/$Left//; # Get rid of what we just stored
         } # if
      } # elsif

      # Push the right hand side pieces of this equation...
      if (!($FirstTime)) { push(@Right,@Line[$x]); }

      $x++;
   } # while

   $temp = join " ", @Right;
   if($temp =~ /^=\"/ ) #ATM169
   {
      $R = $temp;      
   }
   else
   {      
      $R = join "", @Right;
   }
   $R =~ s/=//;

    # Ignore the first character '(' of the parameter name in case of parenthesis
   if ($Left =~ /^\(/) 
   { $Left="$'"; $LeftParenth_paramName_found=1; }

   #Following code is commented because we don't want to ignore parenth. around param values. Ramesh Jan11,05
   # Ignore the first character '(' of the parameter value in case of parenthesis
   #if ($R =~ /^\(/) 
   #{ $R="$'"; $LeftParenth_paramVal_found=1;}

   # Ignore the last character ')' of the parameter value in case of parenthesis
   if ($LeftParenth_paramName_found==1 || $LeftParenth_paramVal_found==1)
   {
     if ($R =~ /\)$/) 
      { $R="$`";}
    }

   if (!(&DefaultExists($Left, $R, $NumOfDefaults)))
   {
      $R = &FixEquation($Left, $R);
      &Record_NameValue_Pair($CUR_CKT, $valueCount, $Left, $R, $PC, 1);
      #$valueCount++;
      if($Left ne "")   #Spectre_Tran.195 Ramesh Feb.1,2005
      {
        $valueCount++;
      }
   } # if
   &Record_NumberOfParams($CUR_CKT, $PC, $valueCount);

} # sub RecordParams

###############################################################################
#
# DefaultExists() :
#
#   Here we check to see if parameter has already been allocated as a
#   default. If it has we need to override the default. We do this check
#   so we don't allocate two of the same variables with different values.
#
#   If a parameter has already been allocated then we return "1" otherwise
#   we return "0".
#
##############################################################################
sub DefaultExists
{
   my ($Left, $R, $NumOfDefaults) = @_;

   my $defCount=0;

   while ($defCount < $NumOfDefaults)
   {
      if ($Left eq $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{paramArray}[$defCount]{name})
      {
         # Already recorded this parameter.
         # Override the default with a new value.
         $R = &FixEquation($Left, $R);
         &Record_NameValue_Pair($CUR_CKT, $defCount, $Left, $R, $PC, 1);
         return(1);
      } # if
      $defCount++;
   } # while

   # A default wasn't specified for this parameter.
   return(0);

} # sub DefaultExists

###############################################################################
#
# Check_coeffs() :
#
#   Here we check for an equation of the form "coeffs=[0 0 0 1]".
#   If it exists we extract this from the list of equations
#   and return a new line without it.
#
##############################################################################
sub Check_coeffs
{
   my ($valueCount,@Line) = @_;

   my $Left="", my $Right="";
   my $x=0, my $sz=0;
   my @tmpLine=();
   my @ReturnLine=();

   # Check to be sure that we are indeed looking at coeffs of the 
   # form "coeffs=[0 0 0 0 1]"

   $tmpLine = join "", @Line;
   if ( ($tmpLine !~ /coeffs/) && ($tmp !~ /\]/) ) { return($valueCount,@Line); }

   $sz = @Line;

   while (@Line[0] !~ /coeffs/) { push(@ReturnLine,shift(@Line)); }

   $x=0;
   while ( (@Line[0] !~ /\]/) && ($x<$sz) )
   {
      push(@tmpLine,shift(@Line));
      $x++;
   } # while

   push(@tmpLine, shift(@Line));

   if (@tmpLine[0] =~ /=/)
   {
      $Left = $`;
      @tmpLine[0] =~ s/.*=//;
   } # if
   else
   {
      $Left = @tmpLine[0];
      @tmpLine[0] =~ s/.*//;
      @tmpLine[1] =~ s/=//;
   } # else

   @tmpLine[0] =~ s/.*=//;

   $x=0;
   while ($x < @tmpLine)
   {
      if ($Right eq "" ) { $Right = @tmpLine[$x]; }
      elsif (@tmpLine[$x] ne "") { $Right = $Right . " " . @tmpLine[$x]; }
      $x++;
   } # while

   # Now that we've extracted the coeffs=[0 0 0 1] segment
   # we put the rest of the line back together.
   while (@Line) { push(@ReturnLine,shift(@Line)); }

   &Record_NameValue_Pair($CUR_CKT, $valueCount, $Left, $Right, $PC, 1);
   &Record_NumberOfParams($CUR_CKT, $PC, $valueCount);
   $valueCount++;

   return($valueCount,@ReturnLine);
} # sub Check_coeffs

sub Check_wave
{
   my ($valueCount,@Line) = @_;

   my $Left="", my $Right="";
   my $x=0, my $sz=0;
   my @tmpLine=();
   my @ReturnLine=();

   # Check to be sure that we are indeed looking at wave of the 
   # form "wave=[0 0 0 0 1]"

   
   $tmpLine = join "", @Line;
      
   #if ( ($tmpLine !~ /coeffs/ ) && ($tmp !~ /\]/) ) { return($valueCount,@Line); }
   if ( ($tmpLine !~ /wave/ ) && ($tmp !~ /\]/) ) { return($valueCount,@Line); }
   $sz = @Line;

   while (@Line[0] !~ /wave/ ) { push(@ReturnLine,shift(@Line)); }

   $x=0;
   while ( (@Line[0] !~ /\]/) && ($x<$sz) )
   {
      push(@tmpLine,shift(@Line));
      $x++;
   } # while

   push(@tmpLine, shift(@Line));

   if (@tmpLine[0] =~ /=/)
   {
      $Left = $`;
      @tmpLine[0] =~ s/.*=//;
   } # if
   else
   {
      $Left = @tmpLine[0];
      @tmpLine[0] =~ s/.*//;
      @tmpLine[1] =~ s/=//;
   } # else

   @tmpLine[0] =~ s/.*=//;

   $x=0;
   while ($x < @tmpLine)
   {
      if ($Right eq "" ) { $Right = @tmpLine[$x]; }
      elsif (@tmpLine[$x] ne "") { $Right = $Right . " " . @tmpLine[$x]; }
      $x++;
   } # while

   # Now that we've extracted the wave=[0 0 0 1] segment
   # we put the rest of the line back together.
   while (@Line) { push(@ReturnLine,shift(@Line)); }

   &Record_NameValue_Pair($CUR_CKT, $valueCount, $Left, $Right, $PC, 1);
   &Record_NumberOfParams($CUR_CKT, $PC, $valueCount);
   $valueCount++;
      
   return($valueCount,@ReturnLine);
} # sub Check_wave

###############################################################################
#
# vector2List():  Convert Spectre vector format into ADS list format.
#  
#     This is used to convert from the Spectre coeffs to the ADS Coeffs
#      EX:
#       (Spectre) coeffs = [ 0 1 2 3 ]
#       (ADS)     Coeffs = list(0,1,2,3)
#     It is meant for passive component callbacks that use the Coeffs 
#     parameter.  This handles many oddball cases, hence it looks ugly in
#     parts.
#
#   IN:  Spectre vector  Ex:[0 1 2 3]
#   OUT: ADS list        Ex:list(0,1,2,3)
#
###############################################################################
sub vector2List
{
   my $vector=shift;
   my $list="";
   my @prelist=();

   $vector =~ s/[\[\]]//g;
   if (! ($vector =~ /[\(\)]/) )
   {
      # if they are not using parenthesis on the vector, 
      # this should get them on the fast lane
      @prelist = split(" ",$vector);
   }
   else
   {
      #  Here is where things get ugly. 
      #  Spaces are delimiters, however spaces are not 
      #  necessary as delimiters when one of the adjoining
      #  values is enclosed by parenthesis. Inside parenthesis
      #  spaces are not delimiters for the vector...
      #  Commas are also delimiters that appear to act exactly
      #  as spaces (commas with no value between them are 
      #  ignored).  
      my @atoms=();
      my $tempAtom="";
      my $depth=0;

      # @atoms is an array of individual characters for parsing
      @atoms = split //,$vector;
      foreach my $atom (@atoms)
      {
         # open parenthesis
         if ($atom eq "(")
         {
            #  First check if there is value without a delimiter
            #  before the parenthesis. This is automatically delimited
            if (($depth == 0) && ($tempAtom ne ""))
            {
                  push @prelist, $tempAtom;
                  $tempAtom = "";
            }
            $depth++;
            $tempAtom .= $atom;
         }
         # close parenthesis
         elsif ($atom eq ")")
         {
            if ($depth > 0)
            {
               $depth--;
               $tempAtom .= $atom;
               if ($depth == 0)
               {
                  push @prelist, $tempAtom;
                  $tempAtom = "";
               }
            }
            else
            {
               # if we are in here the vector has more close parenthesis.
               # than open parenthesis.  We will ignore the extra parenthesis.
               WriteToLog("WARNING: Vector $vector appears to have unbalanced parenthesis.  Attempting to correct... Please verify that the translated netlist is correct.");
               $depth = 0;
            }
         }
         elsif ((($atom eq " ") || ($atom eq ",")) && ($depth == 0))
         {
             # delimiter found outside of parenthesis
             # conditional below helps us ignore extra delimiters
             #  and yes... extra commas should be ignored even with
             #  whitespace between (based on tests run with Spectre
             #  5.0.0)
             if ($tempAtom ne "")
             {
                push @prelist, $tempAtom;
                $tempAtom = "";
             }
         }
         else
         {
            $tempAtom .= $atom;
         }
      }

      # capture the last value
      if (($tempAtom ne "") && ($depth == 0))
      {
         push @prelist, $tempAtom;
         $tempAtom = "";
      }

      #  in case the parenthesis was left open somewhere
      if ($depth != 0)
      {
         WriteToLog("WARNING: Vector $vector appears to have unbalanced parenthesis.  Please verify that the translated netlist is correct.");
         if ($tempAtom ne "")
         {
             push @prelist, $tempAtom;
             $tempAtom = "";
             $depth=0;
         }
         $depth=0;
      }
   }  # end else (vectors w/ parenthesis)
   $list = "list(" . join(",",@prelist) . ")";
   return $list;
} #vector2list


###############################################################################
#
# RecordCktParams() : Record all of the parameters of a subcircuit.
#
#    These parameters are being stored as is. There is no
#    translation here for the equivalent ADS names. This
#    will be handled in the post processing.
#
#    NOTE: An added wrinkle of Spectre is that it allows for 
#          white space in equations. This algorithm takes
#          that into account.
#
##############################################################################
sub RecordCktParams
{
   my (@Line) = @_;

   my $y=0, $FirstTime=1;
   my @Right=(), @Left=(), @tmp=();
   my $R="", $newLeft="";

   $x=1;
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

            $R = &FixEquation($Left, $R);

            if ($SpiceCktT[$CUR_CKT]{numPins} eq 0)
               { &Record_ZeroPinSubCkt_NameValuePair($CUR_CKT, $CKT_ValueCount, $Left, $R); }
            else
               { &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R); }

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

            $R = &FixEquation($Left, $R);

            if ($SpiceCktT[$CUR_CKT]{numPins} eq 0)
               { &Record_ZeroPinSubCkt_NameValuePair($CUR_CKT, $CKT_ValueCount, $Left, $R); }
            else
               { &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R); }

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
         if ($SpiceCktT[$CUR_CKT]{numPins} eq 0)
            { &Record_ZeroPinSubCkt_NameValuePair($CUR_CKT, $CKT_ValueCount, $Left, $R); }
         else
            { &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, @Line[$x], "NO_DEFAULT"); }

         $CKT_ValueCount++;
      } # if
      # Push the right hand side pieces of this equation...
      elsif (!($FirstTime)) { push(@Right,@Line[$x]); }

      $x++;
   } # while

   $R = join "", @Right;
   $R =~ s/=//;
   
   $R = &FixEquation($Left, $R);
   # Store the last name value pair.
   if ($SpiceCktT[$CUR_CKT]{numPins} eq 0)
      { &Record_ZeroPinSubCkt_NameValuePair($CUR_CKT, $CKT_ValueCount, $Left, $R); }
   else
      { &Record_SubCkt_NameValue_Pair($CUR_CKT, $CKT_ValueCount, $Left, $R); }
   $CKT_ValueCount++;

   if ($CUR_CKT ne 0) 
   {
      # If the subcircuit has 0 pins then it's really a "section" reference
      # and the params are stored as stand alone equations and not part of
      # the subcircuit parameter list.
      if ($SpiceCktT[$CUR_CKT]{numPins} ne 0)
           { &Record_NumberOfCktParams($CKT_ValueCount); }
      else { &Record_NumberOfCktParams(0); }

      if ($backwardCompatible && $PreserveSubcktParams)
      {
         # In case any of the circuit parameters are referencing
         # each other we fix that here. ADS does not allow circuit
         # parameters to reference each other.
         &Generate_CKT_Equations;
      } # if
   } # if

} # sub RecordCktParams

###############################################################################
#
# Generate_CKT_Equations()
#
###############################################################################
sub Generate_CKT_Equations
{
   my $x="";
   my $left="";
   my $right="";
   my $ADS_leftP="";
   my $tmp="";

   #@SpecialEquation/2+1;

   # Divide the number of name/value pairs and add one to start
   # incrementing an ADS_VAR_x value...
   if (@SpecialEquation)
      { $x=@SpecialEquation/2+1; } # Get the number of equations plus 1
   #else { print("WARNING: @SpecialEquation = \"\"\n"); return(1); } # should never happen
   else { return(1); } # should never happen

   $y = 1;

   while (@SpecialEquation)
   {
      $left = shift(@SpecialEquation);
      $right = shift(@SpecialEquation);

      $ADS_leftP = "ADS_" . $left . "_" . $VarCnt;
      $VarCnt++;

      &Record_NameValue_Pair($CUR_CKT, 0, $ADS_leftP, $right, $PC, 1);
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else
         { &Record_Usage($CUR_CKT,$PC,1); }

      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;

      $right = "if ($left == \"UNDEF\") then $ADS_leftP else $left endif\n";
      $ADS_leftP = "ADS_" . $left . "_" . $VarCnt;
      &Record_NameValue_Pair($CUR_CKT, 0, $ADS_leftP, $right, $PC, 1);

      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
      $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      if ($SuppressIncludeComponents && ($IncludeCount > 0))
         { &Record_Usage($CUR_CKT,$PC,0); }
      else
         { &Record_Usage($CUR_CKT,$PC,1); }

      $PC++;
      $SpiceCktT[$CUR_CKT]{numElements} = $PC;

      # We push onto the list the variable and it's replacement.
      push(@SubstitutionList,$left);
      push(@SubstitutionList,$ADS_leftP);
      $VarCnt++;

      if ($WantGeminiOutput) { &StoreCommentLine(""); }
 
      $x++;
      $y++;
      
   } # while

   # Set these globals to empty so they can be used next time.
   @CktParamStack   = ();
   @SpecialEquation = ();

} # sub Generate_CKT_Equations


###############################################################################
#
# CheckForNoDefault()
#
# If the following is satisfied then we know it's a
# parameter with no default value.
#    1.) The current parameter is all alphnumeric
#    2.) The last character of the previous string
#        is either alphanumeric, ")", "]", or "}".
#    3.) The next string doesn't begin with an equal sign.
#
##############################################################################
sub CheckForNoDefault
{
   my ($x, @Line) = @_;

   if ( (@Line[$x] =~ /^\w.*$/) &&
        (@Line[$x-1] =~ /\w$|\)$|\]$|\}$/) &&
        (@Line[$x+1] !~ /^=/) )

        { return(1); }
   else { return(0); }

} # sub

###############################################################################
# WriteToLog()
#
#   IN: Text string that is appened to the log file.
#
###############################################################################
sub WriteToLog
{
   my ($msg) = @_;

   unless (open(SPC_LOG, ">>nettrans.log"))
      { print("*** Warning: Can't open nettrans.log\n"); }

   print SPC_LOG "$msg\n";
   close(SPC_LOG);

} # sub WriteToLog

###############################################################################
# Execute_CallBack()
#
#   IN: The two item list consisting of the Perl file and the routine
#       in that file to be called.
#
###############################################################################
sub Execute_CallBack
{
   my ($tmpCKT, $PC, @CLBK) = @_;

   if (@CLBK) # Check to be sure we actually have something passed in.
   {
      # We need to source in the CallBack file if it hasn't already been done.
      if (!($CB_fileRead{@CLBK[0]}))
      { 
         if (@CLBK[0]) { require("@CLBK[0]"); }
         else { print("*** ERROR: No CallBack specified: (@CLBK)\n"); }
         $CB_fileRead{@CLBK[0]} = 1; # Set this CallBack as being read.
      } # if

      $CB_fun = @CLBK[1];

      &$CB_fun($tmpCKT, $PC);
   } #if
   else
   {
      WriteToLog("Warning: Execute_CallBack called with empty reference");
      print("Warning: Execute_CallBack called with empty reference\n");
   } # else
} # sub Execute_CallBack

###############################################################################
#
# CheckDuplicateCKT_Names()
#
#  In case we have subcircuits with the same name that exist
#  in different sections, we check set an index number so we
#  know which one they belong to. Here we check to see how many
#  duplicates we have. This index number is used later
#  to determine wich subcircuit to use for the #ifdef
#  "library" statements.
#
###############################################################################

sub CheckDuplicateCKT_Names
{
   my ($cktName) = @_;

   my ($dupes, $x) = 0;
   $x= 0;
   
   while ($x <= $CKT)
   {
      if ($x == 0) 
       { 
         #Don't Increment $dupes, otherwise it will not write the subckt in backend c.  Spectre_Tran.155
         if ($SpiceCktT[$x]{name} eq $cktName)
          {  WriteToLog("ADS Netlist Translator found duplicate name for top level circuit  \"$cktName\" \n"); } 
       }
      elsif ($SpiceCktT[$x]{name} eq $cktName)
         { $dupes++; }
      $x++;
   } # while

   return($dupes);

} # sub CheckDuplicateCKT_Names


###############################################################################
# StoreSection()
#
#   This is used to handle Corner Cases. This is only invoked if we
#   are translating to netlist format.
#
###############################################################################
sub StoreSection
{
   my ($lib_section_type,@Line) = @_;

   my $N="";
   my $F="";
   my @name=();

   if (@Line[1])
   {
      if ($lib_section_type eq $ItemType{lib_section_ref})
      {
         if (@Line[2] eq "=")
            { $F = @Line[2]; $N = @Line[3]; }
         elsif (@Line[2] =~ /=/)
         {
            @name = split("=",@Line[2]);
            $F = @Line[1];
            if (@name[1] eq "") { $N = @Line[3]; }
            else { $N = @name[1]; }
         } # elsif
         else
         {
            $F = @Line[1];
            $N = @Line[4];
         } # else

         my $x = $SpiceCktT[$CUR_CKT]{numElements};
         if ($SuppressIncludeComponents && ($IncludeCount > 0))
            { &Record_Usage($CUR_CKT,$x,0); }
         else
            { &Record_Usage($CUR_CKT,$x,1); }
         # Storing include file name in outputType. It was unused before. Ramesh March09,2005
	 $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{outputType} = $F;
	 $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tagName} = $N;
         $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{ItemType} = $lib_section_type;
         $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{tmpType} = "resolved";
         $SpiceCktT[$CUR_CKT]{numElements}++;
         $PC = $SpiceCktT[$CUR_CKT]{numElements};
        
	if($backwardCompatible)
	{
          WriteToLog("Found library section reference: file=$F  section=$N");
          if ($Section_Msg_Toggle)
          {
             WriteToLog("    If this reference is to an external file, that file will not be translated"); 
             WriteToLog("    automatically. Please translate any required library files separately.");
             WriteToLog("    See the user's guide for instructions on how to use a translated library");
             WriteToLog("    section.");
             $Section_Msg_Toggle = 0;
          } # if
	}
      } # if
      else
      {
         $N = @Line[1];
   
         &store_subckt_def($CUR_CKT, $N, 0);

         # We now need to store this subcircuit reference
         # into the top level circuit (0) so it can be looked
         # up later in the C code by the writer...
         my $x = $SpiceCktT[0]{numElements};
         if ($SuppressIncludeComponents && ($IncludeCount > 0))
            { &Record_Usage(0,$x,0); }
         else
            { &Record_Usage(0,$x,1); }
         $SpiceCktT[0]->{elementArray}[$x]->{tagName} = $N;
         $SpiceCktT[0]->{elementArray}[$x]->{ItemType} = $lib_section_type;
         $SpiceCktT[0]->{elementArray}[$x]->{tmpType} = "resolved";
         $SpiceCktT[0]{numElements}++;
      }

      $CUR_SECTION = $N;

   } # if
   
} # sub StoreSection


###############################################################################
#
# Translate all of the Spectre functions into the ADS equivalent.
#
###############################################################################
sub FixEquation
{
   my ($Left, $func) = @_;

   my $newVal="", my $leftside="", my $rightside="", my $tt="";
   my $recon="", my $M="", my $stat="";
   my @F=();
   
   # Match all "word" characters (alphanumerics plus "_")
   $tt = $func;
   while (1)
   {
      # If no "word" characters just exit
      if ($tt !~ /\w+/) { $recon = $recon . $rightside; last; }
      $tt  =~ /\w+/;
      $M = $&;
      $rightside = $';
      #print("($`), ($&), ($')\n");
      if ($FunctionMap{$M}) { $recon = $recon . $` . $FunctionMap{$M}; }
      else { $recon = $recon . $` . $M; }
      $tt = $rightside; 
   } # while

   if ($backwardCompatible) 
    { 
      &GenerateWarnings($Left,$recon);
    }
   elsif(($CUR_CKT eq 0) ||($T eq "element")||($T eq "model"))
   { 
     # spectre: x ^ y = Bitwise xor(x,y). ADS: x ^ y = x to the power y
     # Converting "^" to "_^" because "**" is translated to "^". 
     # Operator "_^" is translated to _bitwise(x,y) in FixBitWiseOperators
     if($recon =~ /\^/) { $recon =~ s/\^/\_\^/g; }
   }
   # Check for all occurances of "**" and replace with "^"
   if ($recon =~ /\*\*/) { $recon =~ s/\*\*/\^/g; }

   # Translate percentage references (e.g. 8% to 0.08)
   while ($recon =~ /\%/)
   {
      #print("($`), ($&), ($')\n");
      $rightside = $';
      ($stat = $`) =~ /(\d.)?\d+$/;
      $leftside = $`;
      $stat = $&;
      if ($stat) { $stat = $stat/100; }
      $stat = $leftside . $stat . $rightside;
      $recon = $stat;
   } # if

   # Get rid of any "escape" characters.
   $recon =~ s/\\//g;
   
   my $T=&Get_ItemType($CUR_CKT, $PC);
   
   if ($backwardCompatible && $PreserveSubcktParams)
      { $recon=&FixBooleanEqns($Left, $recon); }
   elsif(($CUR_CKT eq 0) ||($T eq "element")||($T eq "model"))    #!$backwardCompatible
      { $recon=&FixShiftOperators($Left, $recon); }
  
   return($recon);

} # sub FixEquation

################################################################################
#
# Look for the following Unsupported spectre boolean operators and generate warnings.
# Bitwise Operator        Spectre Operator     ADS Function
#  AND     	             &              
#  OR           	     |     
#  NOT               	     ~           
#  XOR                       ^     
#  NAND                      &~                 
#  NOR                       |~                 
#  XNOR                     ~^, ^~                 
#
################################################################################

sub GenerateWarnings
{
  my ($Left,$recon_t) = @_; 

  if(($recon_t =~ /\^/) && !($recon_t =~ /\^~/) && !($recon_t =~ /~\^/) ||
     ($recon_t =~ /&/ && $recon_t !~ /&&/) ||($recon_t =~ /\|/ && $recon_t !~ /\|\|/)||
     ($recon_t =~ /&~/) ||($recon_t =~ /\|~/) ||
     ($recon_t =~ /~/ && $recon_t !~ /\^~/ && $recon_t !~ /~\^/) || ($recon_t =~ /~\^/) || ($recon_t=~ /\^~/) )
      {
        print("WARNING: ADS Netlist Translator Found Unsupported Boolean Operator \"$&\".\n");
	print("\tYou need to resolve this with a workaround for Simulation in ADS.\n") ;
        print("\tExpression: $Left=$recon_t \n");
	if($PrintWarnings)
	{
	  WriteToLog("WARNING: ADS Netlist Translator Found Unsupported Boolean Operator \"$&\".");
	  WriteToLog("\tYou need to resolve this with a workaround for Simulation in ADS.") ;
	  WriteToLog("\tExpression: $Left=$recon_t ");
	}
      } 
} #sub GenerateWarnings

###############################################################################
#
# This routine cycles through the circuits and calls &SubstituteEqn().
# &SubstituteEqn replaces variables based on the contents of the
# @SubstitutionList.
#
###############################################################################
sub SubstituteVars
{
   my $k=0;

   while ($k <= $CKT)
   {
      my $x = 0;
      my $y = 0;

      if ($x < $SpiceCktT[$k]{numParams})
      {
         #print("Name/Value pairs:\n");
         while ($x < $SpiceCktT[$k]{numParams})
         {
            $SpiceCktT[$k]->{paramArray}[$x]{value} = 
               &SubstituteEqn($SpiceCktT[$k]->{paramArray}[$x]{value});
            $x++;
         } # while 
      } # if 
      $x = 0;

      while ($x < $SpiceCktT[$k]{numElements})
      {
         $y = 0;

         while ($y < $SpiceCktT[$k]->{elementArray}[$x]->{numParams})
         {
            if ($SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{used})
            {
                $SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{value} = 
                   &SubstituteEqn($SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{value});
            } # if
            $y++;
         } # while 
         $y = 0;
         $x++;
      } # while 
      $k++;
   } # while
} # SubstituteVars

###############################################################################
#
# This routine cycles through the current subcircuit and calls &SubstituteEqn().
# &SubstituteEqn replaces variables based on the contents of the
# @SubstitutionList.
#
###############################################################################
sub SubstituteVarsInSubckt
{
   # Add "m" (multiplicity), which must always be substituted with _M in ADS.
   push @SubstitutionList, "m";
   push @SubstitutionList, "_M";

   my $val="";
   my $x=0;
   if ($x < $SpiceCktT[$CUR_CKT]{numParams})
   {
      #print("Name/Value pairs:\n");
      while ($x < $SpiceCktT[$CUR_CKT]{numParams})
      {
         $SpiceCktT[$CUR_CKT]->{paramArray}[$x]{value} = &SubstituteEqn($SpiceCktT[$CUR_CKT]->{paramArray}[$x]{value});
         $x++;
      } # while 
   } # if 

   $val="";
   $x = 0;
   while ($x < $SpiceCktT[$CUR_CKT]{numElements})
   {
      $y = 0;

      while ($y < $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{numParams})
      {
         if ($SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[$y]{used})
         {
            $SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[$y]{value} = 
               &SubstituteEqn($SpiceCktT[$CUR_CKT]->{elementArray}[$x]->{paramArray}[$y]{value});
         } # if
         $y++;
      } # while 
      $y = 0;
      $x++;
   } # while
   @SubstitutionList = ();
} # SubstituteVarsInSubckt

###############################################################################
#
# This routine substitutes an original Spectre variable with an
# ADS_<var>_xx. This is a workaround to the problem of subcircuit
# parameters that reference each other. ADS does not allow this
# so we have to break these out of the subcircuit param list and
# do some equation manipulation.
#
# The Substitution list contains pairs of names. The first is the
# name of the variable to replace, the second is its replacement.
# 
# So if we have nrea and ADS_nrea_135 paired up then the following
# equation would get changed as appropriate:
#
#      ADS_var_178=nvaf*nrea+nvafhb*hb*nrea
#
#            would become:
#
#      ADS_var_178=nvaf*ADS_nrea_135+nvafhb*hb*ADS_nrea_135
#
###############################################################################
sub SubstituteEqn
{
   my ($eqn) = @_;

   my $x=0;
   my $y=0;
   my $tv=0; # Temp Var holder
      
   # The UNDEF holds the original name - don't want to overwrite that!
   if ($eqn !~ /UNDEF/)
   {
      # Split across all of the operators and punctuations that are possible
      my @tmp1=split /([ ,=,\<,\>,\(,\),!,?,:,|,&,\*,\/,+,-])/, $eqn;
      my @tmpEqn=();
   
      # Eliminate the empty fields that split generates because of the multiple field possibilities
      my $el;
      while(@tmp1)
      {
         $el=shift(@tmp1);
         unless($el eq "")
         {
            push @tmpEqn,$el;
         }
      }

      # Check each field to see if it needs to be replaced.
      while ($x < @SubstitutionList)
      {
         $y=0;
         while ($y < @tmpEqn)
         {
            if ( $tmpEqn[$y] eq $SubstitutionList[$x] )
            {
               $tmpEqn[$y]=$SubstitutionList[$x+1];
            }
            $y++;
         }
         $x = $x + 2;

      } # while
      $eqn=join '', @tmpEqn;
   } # if

   return($eqn);
} # sub SubstituteEqn

###############################################################################
#
# FixBooleanEqnsLookBack
#
# This routine checks a value looking for close parenthesis, bitwise and, or 
# bitwise or operators.
#
###############################################################################

sub FixBooleanEqnsLookBack
{
   my ($k, @tmp)=@_;
   my $l=1;
   my $tmpEq="";
   my $parenCount=0;
   my $cont=1;
   my $bitwise=0;
   
   while($cont)
   {  
      #Earlier only "(" was being checked assuming that expression can only be inside parenethesis.
      # Now  expression without parenthesis also supported. Checking "" for this. ATM190,214  Ramesh Jan11,05
      if(@tmp[$k-$l] eq "(" or @tmp[$k-$l] eq "")
      {
         if($parenCount)
         {
            # This closes an internal parenthesis
            $parenCount--;
            $tmpEq=@tmp[$k-$l] . $tmpEq;
            @tmp[$k-$l]="";
         }
         else
         {
            # This is the end of the boolean comparison
            $tmpEq="(" . $tmpEq;
            $l--;
            $cont=0;
         }
      }
      elsif(@tmp[$k-$l] eq ")")
      {
         # This is the start of an internal parenthesis that represents 
         # an equation of some sort for the boolean comparison
         $tmpEq=@tmp[$k-$l] . $tmpEq;
         @tmp[$k-$l]="";
         $parenCount++;
      }
      elsif((@tmp[$k-$l] eq "|") || (@tmp[$k-$l] eq "&"))
      {
         # This is a bitwise or or bitwise and operator.  It represents the marker for the  
         # start of the current comparison.
         $tmpEq="(" . $tmpEq;
         @tmp[$k-$l]="";
         $cont=0;
         $bitwise=1;
      }
      else
      {
         # This is regular text the comprises the left side of the boolean comparison.  Add 
         # it to the current temporary equation.
         $tmpEq=@tmp[$k-$l] . $tmpEq;
         @tmp[$k-$l]="";
      }

      if($k == $l)
      {
         # This means that we're at the beginning of the string.  Stop processing to avoid 
         # an error.
         #ATM190,214  Ramesh March27,05
	 if($tmpEq !~ /^\(/)
	 { $tmpEq = '('.$tmpEq;}
	 $cont=0;
      }
      else
      {
         # Increase the counter to move to an earlier field.
         $l++;
      }
   }

   # Return the field count, the temporary equation, and the modified temporary list.
   return( $l, $tmpEq, $bitwise, @tmp);
}

# Look forward until a close parenthesis, bitwise and, or bitwise or is found.
sub FixBooleanEqnsLookForward
{
   my ($k, $f, @tmp)=@_;
   
   my $cont=1;
   my $tmpEqForward="";
   my $parenCount=0;
   my $cont=1;
   my $trinary=0;
   my $trinaryArg1="";
   my $trinaryArg2="";
   my $bitwise=0;
   my $FoundParenth_at_fplusOne=0;
   my $fplusOne=$f+1;
   
   if(@tmp[$k+$fplusOne] eq ")")
   { $FoundParenth_at_fplusOne=1;  }
   
   while($cont)
   {
      # ATM190,214  Ramesh Jan11,05. Spectre_Tran.227 March10,05
      if((@tmp[$k+$f] eq ")" &&  @tmp[$k+$f+1] ne "?" )  or @tmp[$k+$f] eq "")
      {
         if($parenCount)
         {
            $parenCount--;
            if( $trinary == 1 )
            {
               $trinaryArg1=$trinaryArg1 . @tmp[$k+$f];
            }
            elsif( $trinary == 2 )
            {
               $trinaryArg2=$trinaryArg2 . @tmp[$k+$f];
            }
            else
            {
               $tmpEqForward=$tmpEqForward . @tmp[$k+$f];
            }
            @tmp[$k+$f]="";
         }
         else
         {
            # This is the end of the boolean comparison
            if( $trinary > 0 )
            {
               if ($FoundParenth_at_fplusOne)
	       {  $tmpEqForward=$tmpEqForward ; }
	       else
	       {  $tmpEqForward=$tmpEqForward . ")"; }
            }
            else
            {
               $tmpEqForward=$tmpEqForward . "))";
            }
            @tmp[$k+$f]="";
            $cont=0;
         }
      }
      elsif(@tmp[$k+$f] eq "(")
      {
         if( $trinary == 1 )
         {
            $trinaryArg1=$trinaryArg1 . @tmp[$k+$f];
         }
         elsif( $trinary == 2 )
         {
            $trinaryArg2=$trinaryArg2 . @tmp[$k+$f];
         }
         else
         {
            $tmpEqForward=$tmpEqForward . @tmp[$k+$f];
         }
         @tmp[$k+$f]="";
         $parenCount++;
      }
      elsif(@tmp[$k+$f] eq "?")
      {
         # Trinary operator.
         $trinary=1;
         @tmp[$k+$f]="";
      }
      elsif(@tmp[$k+$f] eq ":")
      {
         # Trinary separator
         $trinary=2;
         @tmp[$k+$f]="";
      }
      elsif((@tmp[$k+$f] eq "|") || (@tmp[$k+$f] eq "&"))
      {
         #$tmpEqForward=$tmpEqForward . ")+";
         # Leave the operator intact, so the trailing part of the or operator can find it.
	 
	 # Not replacing the | and & operators by "+". Keeping them unchanged.
	 # These operators will be fixed after the logical operators because of precedance.
         $tmpEqForward=$tmpEqForward . ")@tmp[$k+$f]";
	 
	 $cont=0;
         $bitwise=1;
      }
      else
      {
         if( $trinary == 1 )
         {
            $trinaryArg1=$trinaryArg1 . @tmp[$k+$f];
         }
         elsif( $trinary == 2 )
         {
            $trinaryArg2=$trinaryArg2 . @tmp[$k+$f];
         }
         else
         {
            $tmpEqForward=$tmpEqForward . @tmp[$k+$f];
         }
         @tmp[$k+$f]="";
      }

      if($f == @tmp)
      {
          # This means that we're at the end of the string.  Stop processing.
          $cont=0;
      }
      else
      {
         $f++;
      }
   }
   return( $f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp);

}

###############################################################################
#
# FixBooleanEqns
#
# Look for the following boolean expressions, and replace them as follows:
# Operator          Spectre Operator     ADS Function
#  Equal               ==                 ADS_SCS_EQ(x,y)
#  Greator or Equal    >=                 ADS_SCS_GTE(x,y)
#  Greator than        >                  ADS_SCS_GT(x,y)
#  Less than           <                  ADS_SCS_LT(x,y)
#  Less or Equal       <=                 ADS_SCS_LTE(x,y)
#  Trinary             ?x:y               ADS_SCS_TRINARY(f(z),x,y)
#  Not equal           !=                 ADS_SCS_NEQ(x,y)
#
#  If we have:
#
#    pw=(sl*1e6!=200)*fach
#    l=(lc<0|lc==0)*0.18um+(lc>0)*lc
#
# Then this gets translated to:
#
#    pw=ADS_SCS_NEQ(sl*1e6,200)*fach
#    l=ADS_SCS_OR(ADS_SCS_LT(lc,0),ADS_SCS_EQ(lc,0))*0.18um+ADS_SCS_GT(lc,0)*lc
#
# NOTE: The ADS_SCS_* equations are added as a section at the end of the file
#       during post processing.
#
###############################################################################
sub FixBooleanEqns
{
   my ($Left, $func) = @_;

   my $tokenCnt=0;
   my $tokenType="";
   my $match=""; my $L1=""; my $L2=""; my $R2=""; my $RestOfRight="";

   my @tmp = ();

   @EqList = ();
   
   # Split the value up based on the boolean operators that are supported by Spectre.
   # Boolean operators must be enclosed in parenthesis in Spectre, so the parenthesis 
   # are also included in the split.
   my @tmp1 = split /([=,\<,\>,\(,\),!,?,:,|,~,&])/, $func;
      
   # Eliminate the empty fields that split generates because of the multiple field possibilities
   my $x;
   while(@tmp1)
   {
      $x=shift(@tmp1);
      unless($x eq "")
      {
         push @tmp,$x;
      }
   }
   
   my $k=0;
   my $l=0;
   my $f=0;
   my $cont=1;
   my $parenCount=0;
   my $fixedFunc="";
   my $equationWasFixed=0;
   my $tmpEq;
   my $tmpEqForward;
   my $trinary;
   my $trinaryArg1;
   my $trinaryArg2;
   my $bitwise;
   my $line="";
   
   while ($k < @tmp)
   {
      if((@tmp[$k] eq "=") && (@tmp[$k+1] eq "="))
      {
         $fixedFunc="ADS_SCS_EQ";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         # ATM190,214  Ramesh Jan11,05
	 if($tmpEq !~ /^\(/)
	 { $tmpEq = '('.$tmpEq;}
	 
	 if($trinary > 0)
         {
            #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         
         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq ">") && (@tmp[$k+1] eq "="))
      {
         $fixedFunc="ADS_SCS_GTE";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         if($trinary > 0)
         {
            #$fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))";
	    #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq ">") && (@tmp[$k+1] eq ">"))
      {
         if ($PrintWarnings)
	 {  
	    WriteToLog("WARNING: ADS Netlist Translator Found Unsupported \">>\" operator.");
	    WriteToLog("\tIf X is an Integer then the possible Workaround is: X>>Y=int(int(X)/int(2*Y)).");
	    WriteToLog("\tExpression: $Left=@tmp ");
	 } 
	 print("WARNING: ADS Netlist Translator Found Unsupported \">>\" operator.\n");
	 print("\tIf X is an Integer then the possible Workaround is: X>>Y=int(int(X)/int(2*Y)).\n") ; 
	 print("\tExpression: $Left=@tmp \n");
	 
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         #@tmp[$k-$l]=$fixedFunc;
         
	 @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=0;
      }
      elsif((@tmp[$k] eq ">") && !(@tmp[$k+1] eq "=") && !(@tmp[$k+1] eq ">"))
      {
         $fixedFunc="ADS_SCS_GT";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 1, @tmp);        

         if($trinary > 0)
         {
            #$fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))";
	    #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "<") && !(@tmp[$k+1] eq "=") && !(@tmp[$k+1] eq "<"))
      {
         $fixedFunc="ADS_SCS_LT";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 1, @tmp);        

         if($trinary > 0)
         {
            #$fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))";
	    #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "<") && (@tmp[$k+1] eq "="))
      {
         $fixedFunc="ADS_SCS_LTE";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         if($trinary > 0)
         {
            #$fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))";
	    #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         # Eliminate the boolean fields
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "<") && (@tmp[$k+1] eq "<"))
      {  
         if ($PrintWarnings)
	 {
	   WriteToLog("WARNING: ADS Netlist Translator Found Unsupported \"<<\" operator.");
	   WriteToLog("\tIf X is an Integer then the possible Workaround is: X<<Y=int(x)*2*int(Y).") ; 
	   WriteToLog("\tExpression: $Left=@tmp");
	 }
	 print("WARNING: ADS Netlist Translator Found Unsupported \"<<\" operator.\n");
	 print("\tIf X is an Integer then the possible Workaround is: X<<Y=int(x)*2*int(Y).\n") ; 
	 print("\tExpression: $Left=@tmp \n");
	 
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        
 
	 #@tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=0;
      }
      
      if((@tmp[$k] eq "!") && (@tmp[$k+1] eq "="))
      {
         $fixedFunc="ADS_SCS_NEQ(";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         if($trinary > 0)
         {
            #$fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))";
	    #Spectre_Tran.227
	    if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }

      $k++;
   }

   my $T=&Get_ItemType($CUR_CKT, $PC);
   if( $equationWasFixed )
   {
      if(($T eq "element") || ($T eq "model"))
      {   
         my $NE = join "", @tmp;
         my $ADSname = $Left;
         push(@EqList,$ADSname);
         push(@EqList,$NE);
         $func=$NE;
      }
      else
      {
         my $NE = join "", @tmp;
         my $ADSname = "ADS_" . $Left . "_" . $VarCnt;
         $VarCnt++;

         # Save our equation so we can pop them off later.
         push(@EqList,$ADSname);
         push(@EqList,$NE);

         $NE = "if ($Left==\"UNDEF\") then $ADSname else $Left endif\n";
         $ADSname = "ADS_" . $Left . "_" . $VarCnt;
         $VarCnt++;

         # Save our equation so we can pop them off later.
         push(@EqList,$ADSname);
         push(@EqList,$NE);

         push(@SubstitutionList,$Left);
         push(@SubstitutionList,$ADSname);

         $fund="\"UNDEF\"";
      }
   }
   if((!$equationWasFixed ) && (($T eq "element") || ($T eq "model")))
   {
       my $NE = $func;
       my $ADSname = $Left;
       # Save our equation so we can pop them off later.
       push(@EqList,$ADSname);
       push(@EqList,$NE);
   }
   my $rt="";
   my $lt="";
   
   while (@EqList)
   {
      # Get the left and right hand sides...
      $lt = shift(@EqList);
      $rt = shift(@EqList);

      my $T=&Get_ItemType($CUR_CKT, $PC);
      
      if(($T ne "element") && ($T ne "model")) 
      {   
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
        if ($SuppressIncludeComponents && ($IncludeCount > 0))
           { &Record_Usage($CUR_CKT,$PC,0); }
        else
           { &Record_Usage($CUR_CKT,$PC,1); }

        $PC++;
        $SpiceCktT[$CUR_CKT]{numElements} = $PC;

        &Record_NameValue_Pair($CUR_CKT, 0, $lt, $rt, $PC, 1);
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
        if ($SuppressIncludeComponents && ($IncludeCount > 0))
           { &Record_Usage($CUR_CKT,$PC,0); }
        else
           { &Record_Usage($CUR_CKT,$PC,1); }


        $PC++;
        $SpiceCktT[$CUR_CKT]{numElements} = $PC;
      }
   } # while
   
   return($func);

} # sub FixBooleanEqns()

###############################################################################
#
#
#
###############################################################################
sub GenerateEquation
{
   my ($Left, $L1, $L2, $tokenType, $M, $R) = @_;

   my $x=0;
   my $NE="";

   $ADSname = "\"UNDEF\"";

   $NE = "if ($L2$tokenType$M) then 1 else 0 endif";

   $ADSname = "ADS_" . $Left . "_" . $VarCnt;
   $M =  $L1 . $ADSname . $R;

   $VarCnt++;

   # Save our equation so we can pop them off later.
   push(@EqList,$ADSname);
   push(@EqList,$NE);

   $NE = "if ($Left==\"UNDEF\") then $ADSname else $Left endif\n";
   $ADSname = "ADS_" . $Left . "_" . $VarCnt;
   $VarCnt++;

   # Save our equation so we can pop them off later.
   push(@EqList,$ADSname);
   push(@EqList,$NE);

   push(@SubstitutionList,$Left);
   push(@SubstitutionList,$ADSname);


   return("\"UNDEF\"");

} # sub GenerateEquation

###########################################################################
#
#  Look for the Shift operators and replace them as follows:
#  Operator          Spectre Operator     ADS Function
#  Right shift          >>                _bitwise_asr(x,y)
#  Left shift           <<                _bitwise_asl(x,y)
#
# Note:  This subroutine is called for the expressions in top level ckt
#        and for the parameter value(expressions) of the element/model
###########################################################################
sub FixShiftOperators
{
   my ($Left, $func) = @_;

   my $tokenCnt=0;
   my $tokenType="";
   my $match=""; my $L1=""; my $L2=""; my $R2=""; my $RestOfRight="";

   my @tmp = ();

   @EqList = ();
   
   # Split the value up based on the boolean operators that are supported by Spectre.
   # Boolean operators must be enclosed in parenthesis in Spectre, so the parenthesis 
   # are also included in the split.
   my @tmp1 = split /([=,\<,\>,\(,\),!,?,:,|,~,&])/, $func;
      
   # Eliminate the empty fields that split generates because of the multiple field possibilities
   my $x;
   while(@tmp1)
   {
      $x=shift(@tmp1);
      unless($x eq "")
      {
         push @tmp,$x;
      }
   }
   
   my $k=0;
   my $l=0;
   my $f=0;
   my $cont=1;
   my $parenCount=0;
   my $fixedFunc="";
   my $equationWasFixed=0;
   my $tmpEq;
   my $tmpEqForward;
   my $trinary;
   my $trinaryArg1;
   my $trinaryArg2;
   my $bitwise;
   my $line="";
   
   while ($k < @tmp)
   {
     if((@tmp[$k] eq ">") && (@tmp[$k+1] eq ">"))
      {
         $fixedFunc="_bitwise_asr";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "<") && (@tmp[$k+1] eq "<"))
      {
         $fixedFunc="_bitwise_asl";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        

         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      $k++;
   }
   my $func1="";
   if( $equationWasFixed )
   {
      my $NE = join "", @tmp;
      my $ADSname = $Left;
      $func1=&FixBitWiseOperators($ADSname, $NE);
   }
   else
   {  $func1=&FixBitWiseOperators($Left, $func);}
      
   return($func1);
} # sub FixShiftOperators()

###########################################################################
#
#  Look for the Shift operators and replace them as follows:
#  Operator          Spectre Operator     ADS Function
#  Bitwise AND          &                 _bitwise_and(x,y)
#  Bitwise OR           |                 _bitwise_or(x,y)
#  Bitwise NOT          ~                 _bitwise_not(x,y)
#  Bitwise XOR          ^                 _bitwise_xor(x,y)
#  Bitwise XNOR        ~^,^~              _bitwise_xnor(x,y)
#  Bitwise NAND         &~                 Not Supported
#  Bitwise NOR          |~                 Not Supported
#
# Note:  This subroutine is called for the expressions in top level ckt
#        and for the parameter value(expressions) of the element/model 
#
###########################################################################
sub FixBitWiseOperators
{
   my ($Left, $func2) = @_;

   my $tokenCnt=0;
   my $tokenType="";
   my $match=""; my $L1=""; my $L2=""; my $R2=""; my $RestOfRight="";

   my @tmp = ();

   @EqList = ();
   # print("utility.pl:FixBitWiseOperators : $Left= $func \n");
   # Split the value up based on the boolean operators that are supported by Spectre.
   # Boolean operators must be enclosed in parenthesis in Spectre, so the parenthesis 
   # are also included in the split.
   my @tmp1 = split /([=,\<,\>,\(,\),!,?,:,|,~,&,_,\^])/, $func2;
      
   # Eliminate the empty fields that split generates because of the multiple field possibilities
   my $x;
   while(@tmp1)
   {
      $x=shift(@tmp1);
      unless($x eq "")
      {
         push @tmp,$x;
      }
   }
   
   my $k=0;
   my $l=0;
   my $f=0;
   my $cont=1;
   my $parenCount=0;
   my $fixedFunc="";
   my $equationWasFixed=0;
   my $tmpEq;
   my $tmpEqForward;
   my $trinary;
   my $trinaryArg1;
   my $trinaryArg2;
   my $bitwise;
   my $line="";
   
    while ($k < @tmp)
   {
     if((@tmp[$k] eq "&") && !(@tmp[$k+1] eq "&") && !(@tmp[$k+1] eq "~"))
      {
         $fixedFunc="_bitwise_and";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 1, @tmp);        

         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "&") && (@tmp[$k+1] eq "~"))
      {
         # $fixedFunc="_bitwise_nand";
         if ($PrintWarnings)
	 {  
	    WriteToLog("WARNING: ADS Netlist Translator Found Unsupported \"&~\" operator.");
            WriteToLog("\tExpression: $Left=@tmp");
	 } 
         print("WARNING: ADS Netlist Translator Found Unsupported \"|~\" operator.\n");
         print("\tExpression: $Left=@tmp\n");
	 
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
	 $equationWasFixed=0;
      }
      elsif((@tmp[$k] eq "|") && !(@tmp[$k+1] eq "|") && !(@tmp[$k+1] eq "~"))
      {
         $fixedFunc="_bitwise_or";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 1, @tmp);        
         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "|") && (@tmp[$k+1] eq "~"))
      {
         # $fixedFunc="_bitwise_nor";
         if ($PrintWarnings)
	 {  
	    WriteToLog("WARNING: ADS Netlist Translator Found Unsupported \"|~\" operator.");
            WriteToLog("\tExpression: $Left=@tmp");
	 } 
         print("WARNING: ADS Netlist Translator Found Unsupported \"|~\" operator.\n");
         print("\tExpression: $Left=@tmp\n");
	 
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
	 $equationWasFixed=0;
      }
      elsif((@tmp[$k] eq "~") && !(@tmp[$k+1] eq "|") && !(@tmp[$k+1] eq "&") && !(@tmp[$k+1] eq "_"))
      {
         $fixedFunc="_bitwise_not";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 1, @tmp);        
         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif(((@tmp[$k] eq "~") && (@tmp[$k+1] eq "_") && (@tmp[$k+2] eq "\^")) ||
            ((@tmp[$k] eq "_") && (@tmp[$k+1] eq "\^") && (@tmp[$k+2] eq "~")) )
      {
         $fixedFunc="_bitwise_xnor";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 3, @tmp);        
         
         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
	 @tmp[$k+2]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      elsif((@tmp[$k] eq "_") && (@tmp[$k+1] eq "\^") ) 
      {
         $fixedFunc="_bitwise_xor";
         # Look backward until an open parenthesis, bitwise and, or bitwise or is found.
         ($l, $tmpEq, $bitwise, @tmp)=&FixBooleanEqnsLookBack($k, @tmp);

         # Look forward until a close parenthesis, bitwise and, or bitwise or is found.
         ($f, $tmpEqForward, $trinary, $trinaryArg1, $trinaryArg2, @tmp)=&FixBooleanEqnsLookForward($k, 2, @tmp);        
         
         if($trinary > 0)
         {
            if(@tmp[$k-3] eq "(")
	    {  $fixedFunc="ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
	    else
	    {  $fixedFunc="(ADS_SCS_TRINARY(" . $fixedFunc . $tmpEq . "," . $tmpEqForward . "," . $trinaryArg1 . "," . $trinaryArg2 . "))"; }
         }
         elsif( $bitwise > 0 )
         {
            $fixedFunc=$fixedFunc . $tmpEq . "," . $tmpEqForward;
         }
         else
         {
            $fixedFunc="(" . $fixedFunc . $tmpEq . "," . $tmpEqForward;
         }

         @tmp[$k-$l]=$fixedFunc;
         @tmp[$k]="";
         @tmp[$k+1]="";
         # Skip over the fields that were just processed
         $k=$k+$f;
         $equationWasFixed=1;
      }
      $k++;
   }
   if( $equationWasFixed )
   {
      my $NE = join "", @tmp;
      my $ADSname = $Left;
      
      # Save our equation so we can pop them off later.
      push(@EqList,$ADSname);
      push(@EqList,$NE);
      
   }

   my $rt="";
   my $lt="";
     
   while (@EqList)
   {
      # Get the left and right hand sides...
      $lt = shift(@EqList);
      $rt = shift(@EqList);
      
      my $T=&Get_ItemType($CUR_CKT, $PC);
      if(($T eq "element") || ($T eq "model"))
      {   
      $func2=$rt;
      }
      else
      {
        $func2="";
        
        &Record_NameValue_Pair($CUR_CKT, 0, $lt, $rt, $PC, 1);
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{ItemType} = $ItemType{var};
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{numParams} = 1;
        $SpiceCktT[$CUR_CKT]->{elementArray}[$PC]->{tmpType} = "resolved";
      
      
       if ($SuppressIncludeComponents && ($IncludeCount > 0))
     	{ &Record_Usage($CUR_CKT,$PC,0); }
       else
     	{ &Record_Usage($CUR_CKT,$PC,1); }
       
       $PC++;
       $SpiceCktT[$CUR_CKT]{numElements} = $PC;
      }
      
   } # while
   
    return($func2);
} # sub FixBitWiseOperators()

###############################################################################
#
# Check and set the Multiplicity factor.
#
###############################################################################
sub CheckMultiplicity
{
   my ($ckt, $x) = @_;

   my $y = 0;

   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      if ($SpiceCktT[$tmpCKT]->
             {elementArray}[$x]->
                {paramArray}[$y]{name} eq "m")
      {
         $SpiceCktT[$tmpCKT]->
            {elementArray}[$x]->
               {paramArray}[$y]{name} = "_M";
      } # if
      $y++;
   } # while

} # sub CheckMultiplicity


return(1);

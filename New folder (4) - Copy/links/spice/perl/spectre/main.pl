#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# SetSpectrePath : called from cmain()
#
###############################################################################
sub SetSpectrePath
{
   # We need to setup the @INC array before doing anything...

      my $tmp="";
      if ($ENV{"NETTRANS_DIR"}) 
      {
         $tmp = $ENV{"NETTRANS_DIR"} . "/links/spice/perl/spectre";
         push(@INC,$tmp);
      } # if
      if ($ENV{"HOME"})
      {
         $tmp = $ENV{"HOME"} . "/hpeesof/links/spice/perl/spectre"; 
         push(@INC,$tmp);
      } # if
      if ($ENV{"HPEESOF_DIR"})
      {
         $tmp = $ENV{"HPEESOF_DIR"} . "/links/spice/perl/spectre";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/lib/perl5/5.8.0";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/lib/";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/perl/lib";
         push(@INC,$tmp);
      } # if
} # sub SetSpectrePath

###############################################################################
#
# SetSpectrePath : called from cmain()
#
###############################################################################
sub SetDialect
{
      (my $SpiceDialect) = @_;

      my $tmp="";
      if ($ENV{"NETTRANS_DIR"}) 
      {
         $tmp = $ENV{"NETTRANS_DIR"} . "/links/spice/perl/$SpiceDialect";
         push(@INC,$tmp);
      } # if
      if ($ENV{"HOME"})
      {
         $tmp = $ENV{"HOME"} . "/hpeesof/links/spice/perl/$SpiceDialect"; 
         push(@INC,$tmp);
      } # if
      if ($ENV{"HPEESOF_DIR"})
      {
         $tmp = $ENV{"HPEESOF_DIR"} . "/links/spice/perl/$SpiceDialect";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/lib/perl5/5.8.0";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/perl/lib";
         push(@INC,$tmp);
      } # if
} # sub SetSpectrePath

###############################################################################
#
# cmain() : called from C
#
# IN: 
#     Spice dialect (spectre, or ? ...)
#     Name of the spice file
#     Flag indicating whether the first line should be ignored or not.  This 
#          flag should be ignored by Spectre, because Spectre never assumes that
#          the first line is a comment.
#     Flag indicating gemini output
#     Flag indicating whether we should attempt to translate Spectre
#          equations that contain logic that isn't directly supported 
#          by the ADS simulator.
#     Flag to disable the output of Warnings
#     $IncFile contain the name of a file that we are to include however we
#          don't output any of its contents in the translated file. This is
#          used for model resolution where the Foundry wants the models
#          output but not anything else.
#     PreserveSubcktParams: This value should be enabled if we are going to
#       do special handling with subcircuit equations.
#       ADS does not support self referencing parameters.
#       Enabling this will work around this problem.
#
###############################################################################
sub cmain()
{

   ($SpiceDialect,$FileName,$ignoreFirstLine,$WantGeminiOutput,$GenSpectreEqns,$PrintWarnings,$IncFile,$PreserveSubcktParams,$backwardCompatible,$adsNodeName,$IncludePath) = @_;

   BEGIN { &SetSpectrePath;}

   if ($SpiceDialect ne "spectre")
      { &SetDialect($SpiceDialect); }
   
   use Symbol;
   require("data.pl");
   require("utility.pl");
   require("parser.pl");
   require("post.pl");
   require("ADS_ReservedWords.pl");

   # Read in the mapping rules file so ADS parameters can be
   # mapped. This needs to be done here instead of post processing
   # since we don't want to store parameters that ADS might not support.
   &ReadRulesFile();

   # Create a hash of ADS reserved words
   &ADS_ReservedWords();

   # Create a hash of illegal ADS subcircuit names
   &ADS_IllegalSubcktNames();

   # Create a hash that will map Spectre functions into ADS functions
   &ReadFunctionRulesFile;

   # Set defaults for this version of the dialect (like comment chars etc...)
   &set_defaults($SpiceDialect);

   # Set default values for the subcircuit
   &store_subckt_def($CUR_CKT, $FileName, 0);

   if ($IncFile)
   {
      $SuppressIncludeComponents = 1;
      $IncFile = "#include" . " " . $IncFile;
      my @tmpL = split(" ", $IncFile);
      &ReadInclude(@tmpL);
   } # if
   else { $SuppressIncludeComponents = 0; }

   # Go read the file.
   $ignoreFirstLine=0;
   $ok = &ReadFile($ignoreFirstLine, $FileName,"");


   # if ($ok) { print("File successfully read.\n"); }
   if ( (!$ok) && ($PrintWarnings) )
   {
      WriteToLog("WARNING: one or more components could not be translated.");
      print("WARNING: one or more components could not be translated.\n");
   } # elsif
   #print("ok=$ok PrintWarnings=$PrintWarnings\n");

   $SpiceCktT[$CUR_CKT]{numElements} = $PC;

   # Do the post processing.
   $ok = &PostProcess;

   # This is the workaround that leaves all parameters
   # on the subcircuit list. The ADS simulator does not
   # allow parameters to reference each other on the
   #if ($PreserveSubcktParams)
   #   { &SubstituteVars; }

   if ($ok) 
   {
      WriteToLog("Post Processing successfully done.");
   } # if
   elsif ($PrintWarnings)
   {
      WriteToLog("WARNING: One or more errors during post processing.");
      print("WARNING: One or more errors during post processing.\n");
   } # elsif

   if (0) # dump contents of all circuits
   { 
      $ck = 0;
      while ($ck <= $CKT) { print("\nCIRCUIT #$ck\n");&dumper($ck); $ck++;}
   } # if

   #exit(0);

   # Return the number of subcircuits to C
   # Note that $CKT includes the # of sections and subcircuits
   #           $SUBCKT is just the # of subckts.
   return($CKT,$SUBCKT);

} # sub cmain()

###############################################################################
#
# ReadFile : called from cmain()
#
###############################################################################
sub ReadFile
{
   my ($ignoreFirstLine,$FileName) = @_;

   my ($line, $contline, $nextline) = "";
   my ($EverFail, $FileDone) = 0;
   my $status = TRUE;
   my $FirstTime = 1;

   # Generate a unique file handle. This is needed
   # because "nested includes" will recursively call
   # this routine. The package "symbol" helps us here...
   my $FH = gensym();

   #if ($Section) { print("IN SECTION: file=($FileName), Section=($Section)\n"); exit(0); }

   #print("main.pl: file name is ($FileName)\n");

   unless (open($FH, "<$FileName"))
      { die("cannot open $FileName\n"); }

   $line = <$FH>;

   while (! $FileDone)
   {
      # CleanupLine() returns the $line (all continuation lines
      # are accounted for), the next line in the file, and whether
      # or not we have reached the end of file.
      ($line, $nextline, $FileDone) = &CleanupLine($line, $FH);

      # If we just finished reading an include file we need to
      # retrieve the last line we were working on. We have to do
      # this because we are always reading one line ahead and that
      # line would get lost if we didn't push it on a stack.

      # Not Required .    Spectre_Tran.226,228   Ramesh Mar17,05 
      #if ($IncludeJustRead) { $line = pop(@SavedLine); $IncludeJustRead = 0; }

      #print("\nProcessing: ($line)");

      if ($FirstTime)
      {
         $FirstTime = 0;
         if ( !$ignoreFirstLine )
         {
            if ( &CheckForCommentLine($line) && $WantGeminiOutput )
               { &StoreCommentLine($line); }
            elsif(&CheckForCommentLine($line) && !$WantGeminiOutput ) 
            {  }  # Do nothing for iff. Spectre.Tran.232
	    else
            {
               $status = &read_element($line);
               if ($status) { $SpiceCktT[$CUR_CKT]{numElements} = $PC; }
            } # else
         } # if
         elsif ( ($WantGeminiOutput) && ($RecordHeader) )  # Store line #1 as comment
         {
            $geminiHeader = $line;
            $geminiHeader =~ s/^\/\///;
            $RecordHeader = 0;
         } # else
	 elsif($ignoreFirstLine && !&CheckForCommentLine($line))
	 { 
	    if ($PrintWarnings)
            {
              WriteToLog("WARNING: First line is not a comment, thus it can't be ignored:");
              WriteToLog("	   $line");
           } # if
	   $status = &read_element($line);
           if ($status) { $SpiceCktT[$CUR_CKT]{numElements} = $PC; }
	}
      } # elsif
      elsif ($line ne "")
      {
         # If we have a line full of white space store it as comment.
         if (&CheckForCommentLine($line))
         {
            if ($WantGeminiOutput)
               { &StoreCommentLine($line); }
         } # if
         else
         {
            $status = &read_element($line);
            if ($status) { $SpiceCktT[$CUR_CKT]{numElements} = $PC; }
         } # else
      } #elsif

      # We have a blank line...
      elsif ($WantGeminiOutput) { &StoreCommentLine($line); }

      if    ($status eq "FALSE") { $EverFail = 1; }
      elsif ($status eq "endsection")
      { 
         # Get the current section we are in. If
         # we are dealing with nested includes we
         # may be in a section that has a name. Otherwise,
         # for the top level section, it's just "".
         $Section = pop(@SectionHistory); 
         if ($Section) { $InSection = 1; }
         else { $InSection = 0; }
         last; # We are done reading the file - jump out of here...
      } # elsif
      #print "status=$status EverFail=$EverFail\n";

      $PrevFile=0;
      $line = $nextline;

   } # while
   if ($IncludeCount > 0) { $IncludeCount--; }

   # In case we have any lingering comments - store them.
   if ( ($WantGeminiOutput) && (@clist) )
      { &StoreCommentLine(shift(@clist)); }

   # This is a kludge until I fix the main parser. If we are
   # supressing the output of include file components, then
   # we look at this flag to indicate that the previous component
   # belonged to an include file.
   $PrevFile=1;

   close($FH);
   return(!$EverFail);

} # ReadFile

###############################################################################
#
# CleanupLine
#
###############################################################################
sub CleanupLine
{
   my ($line, $FH) = @_;

   my ($contline, $nextline) = "";
   my ($done, $StoringContLines) = 0;

   chomp($line);
   $line =~ s/$CTRL_M$//;

   while (@clist)
   {
      if ($WantGeminiOutput)
         { &StoreCommentLine(shift(@clist)); }
      else 
         { @clist = (); } # Prevent possible infinite loop
   } # while

   while (!($done))
   {
      if (!($nextline = <$FH>)) { return($line, "", 1) }

      chomp($nextline);

      # Get rid of CTRL_M's from PC
      $nextline =~ s/$CTRL_M$//;

      # Get rid of any leading white space
      $nextline =~ s/^\s*//;

      if (&CheckForInlineComment($nextline))
      {
         if ($WantGeminiOutput)
            { push(@clist,$nextline); }
         # Get rid of comment
         $nextline =~ s/\/\/.*//;
         #else { $nextline =~ s/$inlineCommChar.*//; } # Get rid of comment
      } # if

      if ($line =~ /\\[\s]*$/)
      {
         # This could be a comment line with a continuation
         # character at the end. Save it and move on.
         if (&CheckForCommentLine($line))
         {
            if ( $StoringContLines && $WantGeminiOutput )
               { push(@clist,$line); }
            elsif ($WantGeminiOutput)
               { &StoreCommentLine($line); }
            $line = $nextline;
         } # if
         else
         {
            if (&CheckForCommentLine($nextline))
            {
               if ($WantGeminiOutput)   
                  { &StoreCommentLine($nextline); }
            } # if
            else # We have continuation line!
            {
               # Get rid of the trailing "\"
               $line =~ s/\\[\s]*$//;
               $line = $line . " " . $nextline;
            }
            $StoringContLines = 1;
         } # else
      } # if
      elsif ($nextline =~ /^\+/)
      {
         $nextline =~ s/^\+//;

         # It could just be comment - check for that.
         # NOTE: It's possible that we have an equation that is
         #       using "+ * cos(x)" on the next line - this would not 
         #       be a comment! Using "//" however would be a comment.
         #       We use the CheckForCommentLine() routine but negate
         #       the case where we have a "*".
         if ( &CheckForCommentLine($nextline) && ($nextline !~ /^(\s*)?\*/) )
         {
            if ($WantGeminiOutput)   
               { push(@clist,$nextline); }
         } # if
         else
          { $line = $line . " " . $nextline; }
         $StoringContLines = 1;
      } # elsif
      elsif (&CheckForCommentLine($nextline))
      {
         # if ( $StoringContLines && $WantGeminiOutput )
         #    { push(@clist,$nextline); }
         # elsif ($WantGeminiOutput)
         #    { &StoreCommentLine($nextline); }
         if ($WantGeminiOutput ) { push(@clist,$nextline); }
      } # elsif
      else { $done=1; }

   } # while

   # Set $next_line - this global is used to keep
   # track of the next line after we read an include
   # file.
   $next_line = $nextline;

   return($line, $nextline, 0);

} # sub CleanupLine

###############################################################################
#
# read_element
#
###############################################################################
sub read_element
{
   my ($line) = @_;
   
   #If ADS has a model corresponding to spectre model then its mapped
   #Else a warning is generated and spectre model commented in ADS netlist
   my $knownModelFound=TRUE;
   
   # this is used to detect errors in element translation (TRUE=ok FALSE=error)
   my $status = TRUE;

   # We assume we are in the correct library "section"
   # If we do in fact have a library section that we
   # are looking for then we set this to 0 until we
   # find it.
   my $FoundSection = 1;
   my @L = ();

   # The split routine gets rid of leading/trailing/embedded white space
   @L = split(" ", $line);

   # To recognise "1:type" and "1: type" for binning Spectre_Trans.140 Ramesh
   if($L[0] =~ ':')
    { $L[0] = $`.$&;}
   # Check if the lines matches an Include section
   # Be sure list has more than one element otherwise @L[1] and
   # $Section may be "" in which case they would match...
   if ( (@L > 1) && (@L[1] eq $Section) && (@L[0] !~ /endsection/) )
   { 
      $InSection = 1;
      $FoundSection = 1;
   } # if
   # Check if we want a section but we haven't found it yet.
   elsif ( ($Section) && (!($InSection)) )
   {
      $FoundSection = 0;
   } # elsif
   elsif ($FoundSection)
   {
      # Store inline comment (if one exists)
      if (&CheckForInlineComment($line))
      {
         if ($WantGeminiOutput) { $line = &StoreInlineComment($line); }
         else { $line =~ s/$inlineCommChar.*//; } # Get rid of comment stuff for IFF
         # Generate new @L without the inline comments
         @L = split(" ", $line);
      } # if

      if ($L[0] eq "model")
      { 
        $knownModelFound=&read_model(@L);
        #Unmatched model is commented in ADS netlist Ramesh Jan14
	if ($knownModelFound eq "FALSE")
	{  &StoreCommentLine($line); }
      }
      elsif ($L[0] =~ /^inline/i) 
         { $status=&read_inline_subckt(@L); }
      elsif ( ($L[0] =~ /^subckt/i)) # || ($L[0] =~ /^inline/i) )
         { $status=&read_subckt(@L); }
      elsif ($L[0] eq "ends" || $L[0] eq "end" )
      { 
         # This is the workaround that leaves all parameters
         # on the subcircuit list. The ADS simulator does not
         # allow parameters to reference each other on the
         if ($PreserveSubcktParams)
         { 
            &SubstituteVarsInSubckt;
         }
         $status=&FinishSubckt;

      }
         
      elsif ($L[0] =~ /^parameters/)
         { &RecordCktParams(@L); }

      elsif ($L[0] =~ /^ahdl_include/)
         { &ReadAhdlInclude(@L); }

      elsif ( ($L[0] =~ /^include/) || ($L[0] =~ /^#include/) )
      {
         if ( (@L[2] =~ /section/i) && ($WantGeminiOutput) )
            { &StoreSection($ItemType{lib_section_ref},@L); }
         else
         {
            # Save the $next_line so when we finish the include 
            # we can pick up from where we left off...
            # Not Required .    Spectre_Tran.226,228   Ramesh Mar17,05 
	    # push(@SavedLine,$next_line);

            # Go open and read the include file
            &ReadInclude(@L);
         } # else
      } # elsif

      #elsif ($L[0] =~ /^[0-9]*:/)
      # I've seen cases where a design kit had
      # something of the form 12_sbc: for bin models.
      elsif ($L[0] =~ /^[0-9]*.*:$/)
         { $status=&read_bsim(@L); }

      elsif ( ($L[0] eq "}") && ($ProcessingBinModel) )
         { $ProcessingBinModel = 0; }

      elsif ($L[0] =~ /^simulator/ && $L[0] !~ /^simulatorOptions/)
         { if ($WantGeminiOutput) { &StoreCommentLine($line); } }

      elsif ($L[0] =~ /^section/)
         { if ($WantGeminiOutput) { &HandleSection(@L); } }

      elsif ($L[0] =~ /^endsection/)
      {
         if ($WantGeminiOutput)
            { &HandleEndSection(); }  
         elsif ($Section) { return("endsection"); }
      } # elsif
      elsif ( ($L[0] =~ /^library/) || ($L[0] =~ /^endlibrary/) )
         { if ($WantGeminiOutput) { &StoreCommentLine($line); } }
      elsif ($L[0] =~ /^global/)
         { $status=&read_global_nodes(@L); }
      #elsif ($L[0] =~ /^vary/)
      #   { &read_statistics(@L); }
      elsif ($L[0] =~ /^real/)
         { $status=&read_function(@L); }
      elsif ($GotFunction && ($L[0] eq "}"))
         { $GotFunction = 0; }
      elsif ($GotFunction)
         { $status=&read_function(@L); }
      elsif (($L[0] eq "if" )  || ($L[0] eq "}" && $L[1] eq "else") ||($Found_ifElse && ($L[0] =~ /^\}/)) )
         { $Found_ifElse=1; if ($WantGeminiOutput) { &store_ifElse($line); } } 
      elsif (($L[0] =~ /^statistics/ && $L[1] eq "{")||($L[0] =~ /^process/ && $L[1] eq "{") ||
     	     ($L[0] =~ /^mismatch/ && $L[1] eq "{") || ($L[0] =~ /^correlate/)||
     	     ($L[0] =~ /^truncate/)||($L[0] =~ /^vary/)||($Found_statistics && ($L[0] =~ /^\}/)))
      {  $Found_statistics=1; if ($WantGeminiOutput) {  &Record_statistics($line); } }
      elsif ( ($L[0] =~ /^#define/) ||
              ($L[0] =~ /^real/) || ($L[0] =~ /^\}/) || ($L[0] =~ /^return/) ||              
              ( ($L[0] =~ /^modelParameter/) && ($L[1] =~ /^info/) ) ||
              ( ($L[0] =~ /^element/) && ($L[1] =~ /^info/) ) ||
              ( ($L[0] =~ /^outputParameter/) && ($L[1] =~ /^info/) ) ||
              ($L[0] =~ /^.model/) || ($L[0] =~ /^.SUBCKT/) || ($L[0] =~ /^section/) ||
              ($L[0] =~ /^endsection/) || ($L[0] =~ /^save/) )
      {
         if ($WantGeminiOutput) 
	 {   
	    &StoreCommentLine($line); 
            if ($PrintWarnings)
            {
               &WriteToLog("WARNING: The following line is either not supported or not needed:");
               &WriteToLog("         $line");
            } # if
            $status=FALSE;
	 }
      } # elsif
      else { $status=&read_component(@L); }

   } # if

   return($status);
} # sub read_element()

###############################################################################
#
# read_ahdl_element
#
###############################################################################
sub read_ahdl_element
{
   my ($line) = @_;
   
   # this is used to detect errors in element translation (TRUE=ok FALSE=error)
   my $status = TRUE;

   # We assume we are in the correct library "section"
   # If we do in fact have a library section that we
   # are looking for then we set this to 0 until we
   # find it.
   my $FoundSection = 1;
   my @L = ();

   # The split routine gets rid of leading/trailing/embedded white space
   @L = split(" ", $line);

   # Store inline comment (if one exists)
   if (&CheckForInlineComment($line))
   {
      $line =~ s/$inlineCommChar.*//;
      # Generate new @L without the inline comments
      @L = split(" ", $line);
   } # if

   if ($L[0] eq "'include") 
   { 
      #&read_ahdl_include(@L); 
      $status = TRUE; # ignore for now.
   }
   elsif ( $L[0] eq "module" )
   { 
      # Read the module statement.  This will be stored as a subcircuit reference
      # so that components that utilize the module will not be discarded from the 
      # final netlist.  The module statement will have the tag name and the 
      # nodes.
      $status=&read_ahdl_module(@L); 
   }
   elsif ( $L[0] eq "parameter" )
   { 
      # Read the ahdl parameter, and add it to the current subcircuit definition.
      # Parameters are defined one per line.
      $status=&read_ahdl_module_parameter(@L); 
   }
   elsif ($L[0] eq "endmodule")
   { 
      # Finish the module.  This will be the equivalent of finishing an included 
      # subcircuit reference.  Make sure the subcircuit is set up so it is not 
      # output into the final netlist - it should exist only so that components that 
      # reference it are not discarded as unknown components.
      $status=&FinishAhdlModule;
   }
         
   return($status);
} # sub read_element()

###############################################################################
#
# C_StoreCktTopLevel() : Send the top level subcircuit definitions to C.
#
###############################################################################
sub C_StoreCktTopLevel
{
   my ($k) = @_;

   return(
      $SpiceCktT[$k]{name},
      $SpiceCktT[$k]{numPins},
      $SpiceCktT[$k]{numParams},
      $SpiceCktT[$k]{numElements},
      $SpiceCktT[$k]{numWires},
      $SpiceCktT[$k]{paramReference}
   );

} # sub C_StoreCktTopLevel

###############################################################################
#
# StoreCktPinArray() : Sends the pinArray to the C code.
#
# IN: $k - index into subcircuit
#     $p - index into pin array
#
###############################################################################
sub C_StoreCktPinArray
{
   my ($k, $p) = @_;
      return(
         "$SpiceCktT[$k]->{pinArray}[$p]{name}"
      );
} # sub C_StoreCktPinArray

###############################################################################
#
# C_StoreCktParamArray() : Sends the circuit name/value pairs to the C code.
#
# IN: $k - index into subcircuit
#     $p - index into param array
#
###############################################################################
sub C_StoreCktParamArray
{
   # NOTE: "value" is treated like a string after it's passed to the C code

   my ($k, $p) = @_;
      return(
         $SpiceCktT[$k]->{paramArray}[$p]{name},
         $SpiceCktT[$k]->{paramArray}[$p]{value},
      );
} # sub C_StoreCktParamArray

###############################################################################
#
# StoreElementTopLevel() : Send the top level subcircuit definitions to C.
#
# IN: $k - index into subcircuit
#     $i - index into element array
#
###############################################################################
sub C_StoreElementTopLevel
{
   my ($k, $i) = @_;

   if ($SpiceCktT[$k]->{elementArray}[$i]->{cktDuplicateIndex} eq "")
      { $SpiceCktT[$k]->{elementArray}[$i]->{cktDuplicateIndex} = 0; }
   return(
       $SpiceCktT[$k]->{elementArray}[$i]->{ItemType},
       $SpiceCktT[$k]->{elementArray}[$i]->{outputType},
       $SpiceCktT[$k]->{elementArray}[$i]->{used},
       $SpiceCktT[$k]->{elementArray}[$i]->{tagName},
       $SpiceCktT[$k]->{elementArray}[$i]->{subcktName},
       $SpiceCktT[$k]->{elementArray}[$i]->{numPins},
       $SpiceCktT[$k]->{elementArray}[$i]->{numParams},
       $SpiceCktT[$k]->{elementArray}[$i]->{cktDuplicateIndex}
   );

} # sub C_StoreElementTopLevel

###############################################################################
#
# StoreElementPinArray() : Sends the pinArray to the C code.
#
# IN: $k - index into subcircuit
#     $i - index into element array
#     $p - index into pin array
#
###############################################################################
sub C_StoreElementPinArray
{

   my ($k, $i, $p) = @_;
      return(
         "$SpiceCktT[$k]->{elementArray}[$i]->{pinArray}[$p]{name}"
      );
} # sub C_StoreElementPinArray

###############################################################################
#
# StoreElementParamArray() : Sends the element name/value pairs to the C code.
#
# IN: $k - index into subcircuit
#     $i - index into element array
#     $p - index into param array
#
###############################################################################
sub C_StoreElementParamArray
{

   # NOTE: "value" is treated like a string after it's passed to the C code

   my ($k, $i, $p) = @_;

      return(
         $SpiceCktT[$k]->{elementArray}[$i]->{paramArray}[$p]{name},
         $SpiceCktT[$k]->{elementArray}[$i]->{paramArray}[$p]{value}
      );

} # sub C_StoreElementParamArray

###############################################################################
#
# C_StoreGeminiHeader() : Return the leading comment line from the netlist
#
###############################################################################
sub C_StoreGeminiHeader
{
   return($geminiHeader);
} # sub C_StoreGeminiHeader

###############################################################################
#
# set_defaults() : Set the circuits default params for the spice type.
#
# IN: $spice_flavor - type of spice file we are operating on.
#
###############################################################################
sub set_defaults
{
   my ($spice_flavor) = @_;

   # If another dialect is going to be supported, the defaults can
   # get set here. For now we just set the defaults for any spice
   # dialect.
   # if ($spice_flavor =~ /spectre/i)
   if (1)
   {
      $DefaultTemp = 0;

      # Currently this is "hard coded" in &CheckForCommentLine()
      # because of difficulties in expression matching a variable.
      # I just haven't had time to fine tune it...GM
      #$lineCommChar   = "* //";

      $inlineCommChar = "//";
   }
   else
   {
      print("WARNING: Spice Flavor: $spice_flavor was not detected.\n");
   }

} # sub set_defaults

###############################################################################
#
# Create a hash of ADS reserved words. The return values are set to "TRUE".
#
###############################################################################
sub ADS_ReservedWords
{
   while (@ADSReservedWords)
   {
      $ADSReservedWord{@ADSReservedWords[0]} = "TRUE";
      shift(@ADSReservedWords);
   } # while
} # sub ADS_ReservedWords

###############################################################################
#
# Create a hash of illegal ADS subcircuit names. 
# The return values are set to "TRUE" for illegal ADS subcircuit names.
#
###############################################################################
sub ADS_IllegalSubcktNames
{
   while (@ADSIllegalSubcktNames)
   {
      $ADSIllegalSubcktName{@ADSIllegalSubcktNames[0]} = "TRUE";
      shift(@ADSIllegalSubcktNames);
   } # while
} # sub ADS_IllegalSubcktNames

###############################################################################
#
# This routine finishes off some of the details for the 
# end of a subcircuit reference.
#
###############################################################################
sub FinishSubckt
{
   my $status = TRUE;
   # Have have reached the end of a subcircuit.
   # We pop the circuit stack to get back to the
   # previous circuit.
   $CUR_CKT = pop(@CKT_STACK);

   # Restore the counter that contains the number of circuit parameters.
   $CKT_ValueCount = pop(@CKT_ValueCount_STACK);

   if ($CUR_CKT eq "")
   {
      # This should never happen - but just in case...
      WriteToLog("*** ERROR! Unable to end subcircuit:  Circuit stack empty.");
      WriteToLog(" Likely cause: ends found outside of subcircuit.");
      WriteToLog(" Try using the option \"First line is not a comment\" (-l).");
      print("*** ERROR! Unable to end subcircuit:  Circuit stack empty. \n");
      print(" Likely cause: ends found outside of subcircuit. \n");
      print(" Try using the option \"First line is not a comment\" (-l).\n");
#      print("*** ERROR! Circuit stack is empty.\n");
#      print("    Setting current circuit to 0\n");
      $CUR_CKT = 0;
      $status = FALSE;
   } # if

   # Restore the Param Count to where we left off...
   $PC = $SpiceCktT[$CUR_CKT]{numElements};
   return($status);

} # sub FinishSubckt

###############################################################################
#
# This routine finishes off some of the details for the 
# end of an AHDL module reference.
#
###############################################################################
sub FinishAhdlModule
{
   my $status = TRUE;
   # Have have reached the end of a subcircuit.
   # We pop the circuit stack to get back to the
   # previous circuit.
   $CUR_CKT = pop(@CKT_STACK);

   # Restore the counter that contains the number of circuit parameters.
   $CKT_ValueCount = pop(@CKT_ValueCount_STACK);

   if ($CUR_CKT eq "")
   {
      # This should never happen - but just in case...
      WriteToLog("*** ERROR! Unable to end ahdl module:  Circuit stack empty.");
      WriteToLog(" Likely cause: endmodule found outside of module.");
      print("*** ERROR! Unable to end ahdl module:  Circuit stack empty. \n");
      print(" Likely cause: endmodule found outside of module. \n");
#      print("*** ERROR! Circuit stack is empty.\n");
#      print("    Setting current circuit to 0\n");
      $CUR_CKT = 0;
      $status = FALSE;
   } # if

   # Restore the Param Count to where we left off...
   $PC = $SpiceCktT[$CUR_CKT]{numElements};
   return($status);

} # sub FinishAhdlModule

###############################################################################
#
# This routines handles some of the overhead associated with Sections.
# This only gets called if we are generating gemini netlist output.
#
###############################################################################
sub HandleSection
{

   my (@L) = @_;

   # Record the Param Count ($PC) for the current subcircuit
   $SpiceCktT[$CUR_CKT]{numElements}=$PC;

   $CKT++;  # Bump up the global ckt counter

   # Reset the number of parameters for this circuit to zero.
   push(@CKT_ValueCount_STACK, $CKT_ValueCount);
   $CKT_ValueCount = 0;
 
   # Push onto the list the previous circuit
   # We will pop this list when we leave this
   # new subcircuit.
   push(@CKT_STACK, $CUR_CKT);

   $CUR_CKT = $CKT;
   $PC = 0;

   # Go and record the new subcircuit parameters.
   &StoreSection($ItemType{lib_section_def},@L);

} # sub HandleSection

###############################################################################
#
# This routines handles some of the overhead associated with endsection
# This only gets called if we are generating gemini netlist output.
#
###############################################################################
sub HandleEndSection
{
   # We have have reached the end of a section.
   #
   # NOTE: We treat sections just like subcircuits
   #       except that on ckt 0 we record the "section
   #       circuit" as type "lib_section_def".
   #       For schematic import (IFF) we don't bother
   #       with this and just read the entire netlist
   #       as if it were just an include.
   #
   # We pop the circuit stack to get back to the
   # previous circuit.
   $CUR_CKT = pop(@CKT_STACK);

   # Restore the counter that contains the number of circuit parameters.
   $CKT_ValueCount = pop(@CKT_ValueCount_STACK);

   if ($CUR_CKT eq "")
   {
      # This should never happen - but just in case...
      # (can happen if netlist has bad syntax)
      print("*** WARNING! Circuit stack is empty.\n");
      print("    Setting current circuit to 0\n");
      $CUR_CKT = 0;
   } # if

   # Restore the Param Count to where we left off...
   $PC = $SpiceCktT[$CUR_CKT]{numElements};

} # sub HandleEndSection

###############################################################################
#
# Dump the contents of the subcircuits
#
###############################################################################
sub dumper 
{
   (my $k) = @_;

   $x = 0;
   $y = 0;

   print("\nCKT name:         ($SpiceCktT[$k]{name})\n");
   print("CKT num pins:     ($SpiceCktT[$k]{numPins})\n");
   print("CKT num params:   ($SpiceCktT[$k]{numParams})\n");
   print("CKT num elements: ($SpiceCktT[$k]{numElements})\n");
   if ($x < $SpiceCktT[$k]{numParams})
   {
      print("Name/Value pairs:\n");
      while ($x < $SpiceCktT[$k]{numParams})
      {
         print("   $SpiceCktT[$k]->{paramArray}[$x]{name} =");
         print(" $SpiceCktT[$k]->{paramArray}[$x]{value}\n");
         $x++;
      } # while 
   } # if 
   $x = 0;
   if ($x < $SpiceCktT[$k]{numPins})
   {
      print("Pin names:\n");
      while ($x < $SpiceCktT[$k]{numPins})
      {
         print("   pin $x: ($SpiceCktT[$k]->{pinArray}[$x]{name})\n");
         $x++;
      } # while
   } # if 
   $x = 0;
   
   while ($x < $SpiceCktT[$k]{numElements})
   {
      print("\n");
      print(" SpectreType: ($SpiceCktT[$k]->{elementArray}[$x]->{tmpType})\n");
      print(" Item Type:   ($SpiceCktT[$k]->{elementArray}[$x]->{ItemType})\n");
      print(" Type:        ($SpiceCktT[$k]->{elementArray}[$x]->{outputType})\n");
      print(" Name:        ($SpiceCktT[$k]->{elementArray}[$x]->{tagName})\n");
      print(" tmpType      ($SpiceCktT[$k]->{elementArray}[$x]->{tmpType})\n");
      print(" bsimName:    ($SpiceCktT[$k]->{elementArray}[$x]->{bsimName})\n");
      print(" subckt Name: ($SpiceCktT[$k]->{elementArray}[$x]->{subcktName})\n");
      print(" num pins:    ($SpiceCktT[$k]->{elementArray}[$x]->{numPins})\n");
      print(" num params:  ($SpiceCktT[$k]->{elementArray}[$x]->{numParams})\n");
      print(" Used:        ($SpiceCktT[$k]->{elementArray}[$x]->{used})\n");
      print(" Dup ckt:     ($SpiceCktT[$k]->{elementArray}[$x]->{cktDuplicate})\n");
      print(" Pin names:\n");
      while ($y < $SpiceCktT[$k]->{elementArray}[$x]->{numPins})
      {
         print("    pin $y: ($SpiceCktT[$k]->{elementArray}[$x]->{pinArray}[$y]{name})\n");
         $y++;
      } # while 
      $y = 0;
      print(" Name/Value pairs:\n");

      while ($y < $SpiceCktT[$k]->{elementArray}[$x]->{numParams})
      {
         if ($SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{used})
         {
            print(" ($SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{name}) = ");
            print(" ($SpiceCktT[$k]->{elementArray}[$x]->{paramArray}[$y]{value})\n");
         } # if
         $y++;
      } # while 
      $y = 0;
      $x++;
   } # while 
} # dumper() 

###############################################################################
#
# ReadAhdlFile : called from cmain()
#
###############################################################################
sub ReadAhdlFile
{
   my ($FileName) = @_;

   my ($line, $contline, $nextline) = "";
   my ($EverFail, $FileDone) = 0;
   my $status = TRUE;
   my $FirstTime = 1;

   # Generate a unique file handle. This is needed
   # because "nested includes" will recursively call
   # this routine. The package "symbol" helps us here...
   my $FH = gensym();

   #if ($Section) { print("IN SECTION: file=($FileName), Section=($Section)\n"); exit(0); }

   #print("main.pl: file name is ($FileName)\n");

   unless (open($FH, "<$FileName"))
   {
      &WriteToLog("Failed to open filename $FileName\n");
      die("cannot open $FileName\n"); 
   }

   $line = <$FH>;

   while (! $FileDone)
   {
      # CleanupLine() returns the $line (all continuation lines
      # are accounted for), the next line in the file, and whether
      # or not we have reached the end of file.
      ($line, $nextline, $FileDone) = &CleanupLine($line, $FH);

      #print("\nProcessing: ($line)");

      if ($line ne "")
      {
         # AHDL is not included in the final netlist.  Just ignore comment lines.
         if (! &CheckForCommentLine($line))
         {
            $status = &read_ahdl_element($line);
         } # else
      } #elsif

      if    ($status eq "FALSE") { $EverFail = 1; }

      #print "status=$status EverFail=$EverFail\n";

      $PrevFile=0;
      $line = $nextline;

   } # while

   #if ($IncludeCount > 0) { $IncludeCount--; }

   # This is a kludge until I fix the main parser. If we are
   # supressing the output of include file components, then
   # we look at this flag to indicate that the previous component
   # belonged to an include file.
   #$PrevFile=1;

   close($FH);
   return(!$EverFail);

} # ReadAhdlFile


#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

require("data.pl");

###############################################################################
#
# We will generate a hash with the following form where {$T} is
# either an "element" or a "model" type.
#
# $SpecMap{$T}{$comp}                : ADS equivalent component name.
# $SpecMap{$T}{$comp}{pin}[0]        : ADS pin number mapping.
# $SpecMap{$T}{$comp}{pin}[1]        : ADS pin number mapping etc..
# $SpecMap{$T}{$comp}{$param1..n}    : Equivalent ADS parameter name for Xspice
#                                      param1..n and default value. Name and
#                                      value are separated with a comma.
# $SpecMap{$T}{$comp}{NumPins}       : Contains the number of pins for this comp.
# $SpecMap{$T}{$comp}{CB}{$file}     : Given the Call Back file the Perl function
#                                      is returned
# NOTE: $SpecMap{$T}{$comp} and $SpecMap{$T}{$comp}{$param1..n} can have
#       multiple names going to the one hash key. In the first case these
#       names are separated with a comma, the later case with a tilde.
#       A check will have to be made on these two values to see if there is
#       more than one mapping. The reason for this is that, for example, ADS 
#       can have one name for a netlist element and another name for a schematic
#       (IFF) component.
#
###############################################################################

my $Type                = 0;
my $XspiceNameIndex     = 1;
my $OutputNameIndex     = 2;
my $pinIndex            = 3;
my $paramIndex          = 4;
my $CallBackIndex       = 5;

my $FileName = "spectre.rul";
my $CompName = "";
my $Etype = "";
my @L = "";
my $contline = "";

sub ReadRulesFile
{
   # The index format is determined from the top level mapping rule:
   # ---------------------------------------------------------------
   # Type | Xspice Name | Output Name | Pin Rule | Param Rule | PerlFilel,CallBack
   #   0        1              2           3           4                 5
   #
   
   my $found = 0;
   my $x = 0;
   
   while ( ($x < @INC) && (!$found) )
   {
      if (-f "@INC[$x]/$FileName")
      {
         $FileName = "@INC[$x]/$FileName";
         $found = 1;
      } # if
      $x++;
   } # while

   unless (open(INFILE, "<$FileName"))
   {
      print("ERROR: Cannot open $FileName - be sure your HPEESOF_DIR is set properly.\n");
      if ($PrintErrors) {
         &WriteToLog("ERROR: ERROR: Cannot open $FileName - be sure your HPEESOF_DIR is set properly."); }
      exit(1);
   } # unless

   while ($line = <INFILE>)
   {
      chop($line);

      # Check for whitespace after the possible continuation character "\"
      while ($line =~ /\\[\s]*$/)
      {
         $contline = <INFILE>;
         chomp($contline);
         if ( ($contline !~ /^\s$/) &&  ($contline !~ /^[\s]*#/) )
         {
            $line =~ s/\\[\s]*$//;  # Get rid of the trailing \
            $line = $line . " " . $contline;
         } # if
      } # while

      if ($line && ($line !~ /^#/) && ($line !~ /^\*/) && ($line !~ /^\/\//))
      {
         $line =~ s/\s//g;        # Get rid of any white space in the line.
         @L = split(/\|/, $line); # Split on the "|" symbol.

         $Etype = &GetElementType(@L);
         $CompName = &GetCompName($Etype,@L);
	 #  These components will be read in spectre syntax, therefore don't do any mapping . 
	 unless( !$backwardCompatible && ($CompName  eq "cccs"||$CompName  eq "ccvs"||$CompName eq "vccs"||$CompName eq "vcvs" ||
    		$CompName eq "pcccs"||$CompName eq "pccvs"||$CompName eq "pvccs"|| $CompName eq "pvcvs" || $CompName eq "bsource" )) 
	 {
		&GetPinMapping($Etype,$CompName,@L);
		&GetParamMapping($Etype,$CompName, @L);
		&GetPerlCallbacks($Etype,$CompName, @L);
	 }
     } # if
   } # while

   close(INFILE);

#   &DumpHash();

} # sub ReadRulesFile

###############################################################################
#
# GetElementType() : Return the type of line we are looking at. It could be
#                    an "element" or a "model".
#                  
###############################################################################
sub GetElementType
{
   my (@L) = @_;
   
   return($L[0]);

} # sub GetElementType


###############################################################################
#
# GetCompName() : Hash the ADS component name(s) to the Xspice component name.
#                  
###############################################################################
sub GetCompName
{
   my ($T,@L) = @_;
   
   my @params = "";
   my $x=0;

   #print("Entering GetCompName ($L[$OutputNameIndex])\n");

   @params = split(/,/,$L[$OutputNameIndex]);

   if (@params)
   {
      while (($x+1) <= @params)
      {
         if ( ($SpecMap{$T}{$L[$XspiceNameIndex]} eq "") && $params[$x])
         {
            $SpecMap{$T}{$L[$XspiceNameIndex]} = $params[$x];
         } # if
         elsif ($params[$x])
         { 
            $SpecMap{$T}{$L[$XspiceNameIndex]} = $SpecMap{$T}{$L[$XspiceNameIndex]} .
                                              "," . $params[$x];
         } # elsif
         $x++;
      } # while
      return($L[$XspiceNameIndex]);
   } # if
   else
   {
      if (@L)
      {
         print("WARNING: PROBLEM READING COMPONENT MAPPING NAME.\n");
         print("         PROBABLY MISSING A CONTINUATION CHARACTER.\n");
         print("   (@L)\n");
      } # if
   } # else

} # sub GetCompName

###############################################################################
#
# GetInputSymbolName() : Get ADS IFF symbol name
#
###############################################################################
sub GetInputSymbolName
{
   my ($T, $comp, @L) = @_;

   my @params = "";
   my $x=0;

   @params = split(/,/, $L[$IFFSymbolNameIndex]);

   $SpecMap{$T}{$comp}{NumIFFNames} = @params;

   while (($x+1) <= @params)
   {
      $SpecMap{$T}{$comp}{IFF}[$x] = $params[$x];
      $x++;
   } # while

} # sub GetInputSymbolName

###############################################################################
#
# GetPinMapping() : Get Xspice and ADS pins mappings
#
###############################################################################
sub GetPinMapping
{
   my ($T, $comp, @L) = @_;

   my @pins = "", @pMap = "";
   my $x=0, $numPins=0;
   @pins = split(/;/, $L[$pinIndex]);

   $numPins = @pins;
   $SpecMap{$T}{$comp}{NumPins} = $numPins;

   while ($x < $numPins)
   {
      # @pMap will only be a list with two elements.
      # The Xspice pin is: $x
      # The ADS    pin is: $pMap[1]

      @pMap = split(/,/,$pins[$x]);
      
      # The rule files use pin 1, pin 2 etc...we index 
      # starting at 0, hence the $pMap[1]-1 logic below.
      $SpecMap{$T}{$comp}{pin}[$x] = $pMap[1]-1;
      $x++;
   } # while

#   print("For $comp: Xspice pin 1 maps to ADS pin: $SpecMap{$T}{$comp}{pin}[1]\n");
#   print("For $comp: Xspice pin 2 maps to ADS pin: $SpecMap{$T}{$comp}{pin}[2]\n");
#   print("For $comp: Xspice pin 3 maps to ADS pin: $SpecMap{$T}{$comp}{pin}[3]\n");
#   print("For $comp: Xspice pin 4 maps to ADS pin: $SpecMap{$T}{$comp}{pin}[4]\n");

} # sub GetPinMapping

###############################################################################
#
# GetParamMapping() : Get Xspice and ADS parameter mappings
#
#   Here's the format we are looking at:
#
#      |
#
###############################################################################
sub GetParamMapping
{
   my ($T, $comp, @L) = @_;

   my @params = "", @pMap = "";
   my $x=0, $y=0, $numParams=0;

   @params = split(/;/, $L[$paramIndex]);
   $numParams = @params;
   $SpecMap{$T}{$comp}{NumParams} = $numParams;

   while ($x < $numParams)
   {
      # @pMap will be a list with possibly many elements.
      #   The first element can be a list of Xspice parameters
      #   The succeeding element is an ADS name.

      @pMap = split(/,/,$params[$x]);

      @multParams = split(/~/,$pMap[0]);
      if (@multParams > 1)
      {
         while ($y < @multParams)
         { 
            $SpecMap{$T}{$comp}{@multParams[$y]} = $pMap[1] . "," . $pMap[2];
            $y++;
         } # while
      } # if
      else
      {
         if ($pMap[1] eq "")  # Both map to same name
         {
            $SpecMap{$T}{$comp}{$pMap[0]} = $pMap[0] . "," . $pMap[2];
         } # if
         else 
         { 
            $SpecMap{$T}{$comp}{$pMap[0]} = $pMap[1] . "," . $pMap[2];
         } # else
      } # else
      $x++;
      $y=0;
   } # while
} # sub GetParamMapping

###############################################################################
#
# GetPerlCallbacks() : Save the default value for this parameter.
#
# Note: The index "$x" is later referenced from the callback
#       indexing parameters set in data.pl
#
###############################################################################
sub GetPerlCallbacks
{
   my ($T, $comp, @L) = @_;

   my @CB = "", @cbMap = "";
   my $x=0, $numCBs=0;
   @CB = split(/;/, $L[$CallBackIndex]);

   $numCBs = @CB;

   while ($x < $numCBs)
   {
      # @cbMap will only be a list with two elements.
      @cbMap = split(/,/,$CB[$x]);
      $SpecMap{$T}{$comp}{CB}[$x] = $cbMap[0] . "," . $cbMap[1];
      $x++;
   } # while

} # sub GetDefaultValue

###############################################################################
#
# DumpHash() : Dump the HashTable
#
###############################################################################
sub DumpHash
{
   my $x=1;
   for $comp (keys %SpecMap)
   {
      print "key: $comp\n";
      for $role (sort (keys %{ $SpecMap{$T}{$comp} }) )
      {
         if ($role eq "pin")
         {
            while ($x < $SpecMap{$T}{$comp}{NumPins}+1)
            {
               print("   ADS pin $x maps to Sectre pin $SpecMap{$T}{$comp}{$role}[$x]\n");
               $x++;
            } # while
            $x = 1;
         } # if
         else { print "   ($role)=($SpecMap{$T}{$comp}{$role})\n"; }
      } # for
   } #for 
} # sub DumpHash

return(1);

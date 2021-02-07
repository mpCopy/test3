#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

require("data.pl");

###############################################################################
#
# We will generate a hash with the following form:
#
# $FunctionMap{$fun} - ADS equivalent function name.
#
###############################################################################

sub ReadFunctionRulesFile
{

   my $XspiceName    = 0;
   my $ADSName       = 1;
   my $CallBackIndex = 2;

   my $FileName="spectrefunc.rul";
   my $line="";
   my $contline="";

   my $found = 0;
   my $x = 0;


   # The index format is determined from the top level mapping rule:
   # ---------------------------------------------------------------
   # Xspice Function | ADS Function
   #       0                1

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
         $line =~ s/\\[\s]*$//;
         $contline = <INFILE>;
         chop($contline);
         $line = $line . " " . $contline;
      } # while

      if ($line && ($line !~ /^#/) && ($line !~ /^\*/) && ($line !~ /^\/\//))
      {
         $line =~ s/\s//g;        # Get rid of any white space in the line.
         @L = split(/\|/, $line); # Split on the "|" symbol.

         $FunctionMap{@L[0]} = @L[1];
      } # if
   } # while

   close(INFILE);

   #my $tmp;
   #for $tmp (keys %FunctionMap)
   #{
   #   print("key: $tmp, returns ($FunctionMap{$tmp})\n");
   #} # for

} # sub ReadFunctionRulesFile


#!/usr/local/bin/perl -w
# Copyright Keysight Technologies 2001 - 2017  

#BEGIN { push(@INC,"/hped/builds/sr/dev170/rday/opt/prod/tools/lib/perl5/5.6.0"); }
#use strict;
#use diagnostics;

# Original work done by Richard Clark 6/1/01
# Add specified prefix to appropriate variables, model names,
# and subcircuit names in an ADS netlist.

###############################################################################
#
# prefixNet() : called from C
#
# IN: Name of the output file
#     The string we are to prefix the names with
#
###############################################################################
sub prefixNet()
{

   ($inputFileName, $prefix) = @_;

   BEGIN
   {
      # We need to setup the @INC array before doing anything...

      my $tmp="";
      if ($ENV{"NETTRANS_DIR"}) 
      {
         $tmp = $ENV{"NETTRANS_DIR"} . "/links/spice/perl";
         push(@INC,$tmp);
      } # if
      if ($ENV{"HOME"})
      {
         $tmp = $ENV{"HOME"} . "/hpeesof/links/spice/perl"; 
         push(@INC,$tmp);
      } # if
      if ($ENV{"HPEESOF_DIR"})
      {
         $tmp = $ENV{"HPEESOF_DIR"} . "/links/spice/perl";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/lib/perl5/5.6.0";
         push(@INC,$tmp);
         $tmp = $ENV{"HPEESOF_DIR"} . "/tools/perl/lib";
         push(@INC,$tmp);
      } # if
   } # BEGIN
   use Symbol;

print("Perl: inputFileName=($inputFileName)\n");
print("Perl: PREFIX=($prefix)\n");

   # Read input file into in-memory buffer for multi-pass processing

   open (INFILE,$inputFileName) || die "Cannot open input file: $!";
   #open (OUTFILE, ">$outputFileName") || die "Cannot open output file: $!";
   open (OUTFILE, ">./tmp_pref_file.nl") || die "Cannot open output file: $!";

   @inFile = <INFILE>;

   @outFile = @inFile;
   $lastLine = $#outFile;

   # Create list of global vars, models, and subcircuits

   $insideSubcircuit = 0;
   $insideContinue = 0;
   foreach (@inFile)
   {
      if (!$insideContinue && !$insideSubcircuit && /^\s*(\w+)\s*=/)
        { $globalVars{$1} = $1; }

     if (!$insideContinue && /^\s*model\s+(\w+)/)
        { $models{$1} = $1; }

     if (!$insideContinue && /^\s*define\s+(\w+)/)
        { $subcircuits{$1} = $1; $insideSubcircuit = 1; }

     if (!$insideContinue && $insideSubcircuit && /^\s*end\s+\w+/)
        { $insideSubcircuit = 0; }

     $insideContinue = /\\$/;
   }

   @globalVars = keys %globalVars;
   @models = keys %models;
   @subcircuits = keys %subcircuits;

   print OUTFILE ";Global Variables:\n";
   foreach $i (@globalVars)
      { print OUTFILE ";  $i\n"; }

   print OUTFILE "\n;Models:\n";
   foreach $i (@models)
      { print OUTFILE ";  $i\n"; }

   print OUTFILE "\n;Subcircuits:\n";
   foreach $i (@subcircuits)
      { print OUTFILE ";  $i\n"; }

   # Scan through the output file, prefixing things as necessary

   $insideSubcircuit = 0;
   $insideContinue = 0;
   $line = 0;
   while ($line <= $lastLine)
   {
      # Is it the start of a global variable definition?
      if ($outFile[$line] =~ /^\s*(\w+)\s*=/) # if yes, prefix line
      {
         foreach $var (@globalVars)
         {
           $outFile[$line] =~ s/\b$var\b/$prefix$var/g;
         } # foreach
         while ($insideContinue = $outFile[$line] =~ /\\$/)  # if continued, prefix next line
         {
            $line += 1;
            foreach $var (@globalVars)
            {
               $outFile[$line] =~ s/\b$var\b/$prefix$var/g;
            } # foreach
         } # while
      } # if

      # Is it the start of a model card definition?
      if ($outFile[$line] =~ /^\s*model\s+(\w+)/)
      {
         # It's a model, fix model name
         $model = $1;
         $outFile[$line] =~ s/\b$model\b/$prefix$model/g;
    
         # Is it a BinModel?
         if ($outFile[$line] =~ /\bBinModel\b/) # yep, sub models and vars on all lines
         {
            foreach $model (@models)
               { $outFile[$line] =~ s/\b$model\b/$prefix$model/g; }
            foreach $var (@globalVars)
               { $outFile[$line] =~ s/\b$var\b/$prefix$var/g; }
            while ($outFile[$line] =~ /\\$/) # if continued, prefix next line
            {
               $line += 1;
               foreach $model (@models)
                  { $outFile[$line] =~ s/\b$model\b/$prefix$model/g; }
               foreach $var (@globalVars)
                  { $outFile[$line] =~ s/\b$var\b/$prefix$var/g; }
            } # while
         } # if
         else  # no, it is an ordinary model card, sub for vars
         {
            foreach $var (@globalVars)
              { $outFile[$line] =~ s/\b$var\b/$prefix$var/g; }
            while ($outFile[$line] =~ /\\$/) # if continued, prefix next line
            {
               $line += 1;
               foreach $var (@globalVars)
                  { $outFile[$line] =~ s/\b$var\b/$prefix$var/g; }
            } # while
         } # else
      } # if

      # starting a subcircuit here
      # should exclude local vars and parameters, but that's work
      # just sub vars, models, and subcircuits on each line until end
      if ($outFile[$line] =~ /^\s*define\s+(\w+)/)
      {
         do 
         {
            foreach $subcircuit (@subcircuits)
               { $outFile[$line] =~ s/\b$subcircuit\b/$prefix$subcircuit/g; }
            foreach $model (@models)
               { $outFile[$line] =~ s/\b$model\b/$prefix$model/g; }
            foreach $var (@globalVars)
               { $outFile[$line] =~ s/\b$var\b/$prefix$var/g; }
         } until ($outFile[$line++] =~ /^\s*end\s+\w+/);
         $line--; # back up line counter to point at end of subcircuit
      } # if
 
      $line += 1;
      #print STDOUT "next line is $line\n";
   } # while

   foreach (@outFile)
      { print OUTFILE;}

unlink($inputFileName);
   rename("tmp_pref_file.nl", $inputFileName);

   return(1);

} # sub prefixNet

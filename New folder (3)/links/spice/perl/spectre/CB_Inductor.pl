#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# For mutual inductor elements we need to quote the inductor names.
#
###############################################################################

sub cb_inductor
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $tmpName="";

   $y = 0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      # We look for Inductor1 and Inductor2 and quote their values.
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Inductor1")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         $tmpName = "\"" .  $tmpName . "\"";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
      } # elsif
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Inductor2")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         $tmpName = "\"" .  $tmpName . "\"";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
      } # elsif
      $y++;
   } # while
} # sub cb_inductor


###############################################################################
#
# For inductor models we need to map the coeffs vector to ADS list syntax:
#
#   Spectre: coeffs=[c1 c2 c3]
#   ADS:     Coeffs=list(c1,c2,c3)
#
#   Note that Spectre can delimit on commas and can include expressions if
#    enclosed in parenthesis.  Space delimitor not necessary if parenthesis
#    used.  It's not very pretty to parse.
#
###############################################################################

sub cb_inductor_model
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $tmpName="";
   my @tmpList=();

   $y = 0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      # mapping coeffs to ADS syntax
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Coeffs")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         $tmpName = vector2List($tmpName);
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
      } # elsif
      $y++;
   } # while
} # sub cb_inductor_model


return(1);

#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# This call back inserts the proper gemini #uselib statement.
#
###############################################################################

sub cb_PVCVS_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $tmp="";

   # We need to insert a "#uselib" statement in the form:
   #    #uselib "ckt" , "NonlinVCVS"

   if ($WantGeminiOutput)
   {
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType} =
         "#uselib \"ckt\" , \"NonlinVCVS\"\n" .
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType};

      $y = 0;
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Coeff")
         {
            $tmp = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
            $tmp =~ s/\[\s*/list\(/;
            $tmp =~ s/\s*\]/\)/;
            $tmp =~ s/\s/,/g;
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmp;
         } # if
         $y++;
      } # while
   } # if
} # sub cb_PVCCS_element


return(1);

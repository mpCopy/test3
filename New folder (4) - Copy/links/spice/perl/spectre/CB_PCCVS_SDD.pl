#!/usr/local/bin/perl
# Copyright Keysight Technologies 2005 - 2017  

###############################################################################
#
#   This callback inserts the proper gemini #uselib statement.
#
###############################################################################

sub cb_PCCVS_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $tmp="";
   
   if ($WantGeminiOutput)
   {
      $y = 0;
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType}="SDD";
      
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
      { 
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Coeff")
         { 
	 
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = I."\[1,0\]";
	   $tmp = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
           $tmp =~ s/\[\s*/list\(/;
           $tmp =~ s/\s*\]/\)/;
           $tmp =~ s/\s/,/g;
	   
	   $tmp = "eval_poly\(".$tmp.",_c1,0\)";
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmp;
           	   
	 } # if
	 if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "C")
         { 
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}=C."\[1\]";
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} 
	                                  = "\"".$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value}."\""; 
	   
	 } #if
	 
	 $y++;
      } # while
      
   } # if

} # sub cb_PCCVS_element


return(1);

#!/usr/local/bin/perl
# Copyright Keysight Technologies 2005 - 2017  

###############################################################################
#
#   This call back will convert pcccs to SDD
#   This will be the only file for all the processing 
#   Only Single input node pair Supported
###############################################################################

sub cb_PCCCS_element
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
	   
           $tmp = "-1"."*"."eval_poly\(".$tmp.",_c1,0\)";
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmp;
	   #print("CB_PCCCS_SDD.pl:Coeff= $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value}\n");
	 
	 } # elsif
	 if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "C")
         { 
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}=C."\[1\]";
	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} 
	                                  = "\"".$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value}."\""; 
	   
	 } # if
	 	 
	 $y++;
      } # while
   } # if

} # sub cb_PCCCS_element

return(1);

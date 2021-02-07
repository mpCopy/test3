#!/usr/local/bin/perl
# Copyright Keysight Technologies 2005 - 2017  

###############################################################################
#
# This call back will convert ccvs to SDD
# This will be the only file for all the processing 
#
###############################################################################

sub cb_CCCS_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $tmpName="";
   my $tmpVal="";
   
   if ($WantGeminiOutput)
   {
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType}="SDD";
      $y = 0;
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "I")
         {
            $tmpName=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name};
	    $tmpName=$tmpName."\[1,"."0\]" ; 
	    
	    $tmpVal = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
            $tmpVal = "-1"."*".$tmpVal."*"._c1;
	    
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}=$tmpName;
	    $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpVal;
         } # if
	 if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "C")
         {
            $tmpName=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name};
	    $tmpName=$tmpName."\[1"."\]" ;
	     
	    $tmpVal = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
            $tmpVal = "\"".$tmpVal."\"";
	    
	    $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}=$tmpName;
	    $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpVal;
         } # if
         $y++;
      } # while
   } # if
} # sub cb_CCCS_element


return(1);

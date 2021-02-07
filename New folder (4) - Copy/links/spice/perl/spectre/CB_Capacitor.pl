#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# For capacitor models we need to map the coeffs vector to ADS list syntax:
#
#   Spectre: coeffs=[c1 c2 c3]
#   ADS:     Coeffs=list(c1,c2,c3)
#
#   Note that Spectre can delimit on commas and can include expressions if
#    enclosed in parenthesis.  Space delimitor not necessary if parenthesis
#    used.  It's not very pretty to parse.
#
###############################################################################

sub cb_capacitor
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $tmpName="";
   my @tmpList=();
   my $tempCount=0;
   my $aliasIndex = -1;

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
          elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "cap")
    { 
     $tempCount=0;
     $aliasIndex = -1;
       while ($tempCount < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
     {
       if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "C" )
       { 
	 # note the array index if C is encountered
	  $aliasIndex=$tempCount; last;
	}
	      $tempCount++;
     }#while
     if ($aliasIndex != -1)
     {
	 # Since C is encountered make cap->" "
	 # print ("Model capacitor: Parameter cap is not translated to C because c is translated to C.\n");
	 if($PrintWarnings)
	 {  &WriteToLog("WARNING:Model capacitor: Parameter cap is not translated to C because c is translated to C."); }
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
      }
      elsif($aliasIndex == -1)
      {#Since c is not encountered Make cap-> C
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="C";
      }
   }#elsif
   elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "capsw")
   { 
     $tempCount=0;
     $aliasIndex = -1;
       while ($tempCount < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
     {
       if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Cjsw" )
       { 
	 # note the array index if Cjsw is encountered
	  $aliasIndex=$tempCount; last;
	}
	      $tempCount++;
     }#while
     if ($aliasIndex != -1)
     {
	 # Since Cjsw is encountered make capsw->" "
	 # print ("Model capacitor: Parameter capsw is not translated to Cjsw because cjsw is translated to Cjsw.\n");
	 if($PrintWarnings)
	 { &WriteToLog("WARNING:Model capacitor: Parameter capsw is not translated to Cjsw because cjsw is translated to Cjsw.");  }
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
      }
      elsif($aliasIndex == -1)
      {#Since capsw is not encountered Make capsw-> Cjsw
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Cjsw";
      }
   }#elsif
   elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "cox")
   { 
     $tempCount=0;
     $aliasIndex = -1;
       while ($tempCount < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
     {
       if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Cj" )
       { 
	 # note the array index if Cj is encountered
	  $aliasIndex=$tempCount; last;
	}
	      $tempCount++;
     }#while
     if ($aliasIndex != -1)
     {
	 # Since Cj is encountered make capsw->" "
	 # print ("Model capacitor: Parameter cox is not translated to Cj because cj is translated to Cj.\n");
	 if($PrintWarnings)
	 {  &WriteToLog("WARNING:Model capacitor: Parameter cox is not translated to Cj because cj is translated to Cj."); }
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
      }
      elsif($aliasIndex == -1)
      {#Since cj is not encountered Make cox-> Cj
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Cj";
      }
   }#elsif 
   $y++;
   } # while
} # sub cb_capacitor

return(1);

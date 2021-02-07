#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# This callback adjusts diode model "region" values as follows:
#
#    off -> 0
#    on  -> 1
#    breakdown  (ignore, don't output the parameter)
#
###############################################################################

sub cb_diode_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $region="";
   my $tmpName="";

   # We cycle through the elements parameters and adjusting them where necessary.
   $y = 0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off") { $region = 0; }
         elsif ($region eq "on")  { $region = 1; }
         elsif ($region eq "breakdown")
         {
            # We don't output the param if region is
            # set to "breakdown". Set the name to ""
            # so it wont be output.
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
         }
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # if
 
      $y++;
   } # while
} # sub cb_diode_element


###############################################################################
#
# This callback adjusts diode model "region" values as follows:
#
#    off -> 0
#    on  -> 1
#    breakdown  (ignore, don't output the parameter)
#
# We also need to map "fc" to the ADS parameter "Fc". The rule
# file does the mapping of "fc" to "Fcsw" - here we need to
# map it to "Fc" as well.
#
# Map level 1 spectre into Level 11 in Gemini
#
# Added a warning about the Eg parameter
#
###############################################################################

sub cb_diode_model
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $numP=0;
   my $region="";
   my $tmpName="";
   my $tlev=0;
   my $eg="UNDEF";
   my $tempCount=0;
   my $Ikf_Condition=0;
   my $Level_condition=0;
   my $tempCount=0;
   my $aliasIndex= -1;
   my $alias_cjo= -1;
   my $alias_cj= -1;
   
   # We cycle through the elements parameters and adjusting them where necessary.
   $y = 0;
   $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
   while ($y < $numP)
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off") { $region = 0; }
         elsif ($region eq "on")  { $region = 1; }
         elsif ($region eq "breakdown")
         {
            # We don't output the param if region is
            # set to "breakdown". Set the name to ""
            # so it wont be output.
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
         }
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # if
      # We need to check for the value of Fcsw and map the ADS "Fc" parameter 
      # to the same value used for Fcsw.
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Fc")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};

         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "Fcsw";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = $tmpName;
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
      } # elsif
      # map level 1 spectre to Level 11 in Gemini
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Level")
      {
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} eq 1)
         {
             $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = 11;
         }
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
      } # elsif
      # When 'level' is not specified in spectre diode model and ik is not zero,
      # "Level=11 IkModel=2" should be added to translated ADS Diode model
      # so that DC IV test would match that of spectre's.    Spectre_Tran.206, Ramesh Dec.10,2004
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Ikf")
      { 
        if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} != 0)
	{
        $Ikf_Condition=1;
	while ($tempCount < $numP)
	   {
	   if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Level")
	    {   $Level_Condition=-1; last;   }
           $tempCount++;
	   }#while
	 }#if
	}#elsif

      # We need to issue a warning when Tlev=0 or 1 and Eg is not specified.
      # Under these circumstances the simulation results can vary due to 
      # a Spectre specific implementation of the diode model.
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Tlev")
      {
         $tlev = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
      }
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Eg")
      {
         $eg = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
      }#elsif 
      #cj,cj0, cjo ->Cjo
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "cj")
      {  
         $tempCount=0;
	 $aliasIndex= -1;
         while ($tempCount < $numP)
	 {
	    if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Cjo" )#&& $tempCount != $y)
	    { 
	       #note the array index if Cjo is encountered
	       $aliasIndex=$tempCount; last;
	    }
       	    $tempCount++;
	 }#while
	 if ($aliasIndex != -1)
	 {
	     # Since Cjo is encountered make cj->" "
	     if($PrintWarnings)
	     { &WriteToLog("WARNING:Model Diode: Parameter cj is not translated to Cjo because cjo is translated to Cjo."); }
	     $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	     $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
	 }
	 elsif($aliasIndex == -1)
	 {   #Since Cjo is not encountered Make cj-> Cjo
	     $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Cjo";
	 }
      }#elsif
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "cj0")
      {
         $tempCount=0;
	 $alias_cjo= -1;
	 $alias_cj= -1;
	 while ($tempCount < $numP)
	 {
	    if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Cjo" ) #&& $tempCount != $y)
	    { 
	      # note the array index if cjo is encountered
	      $alias_cjo=$tempCount; 
	    }
	    elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "cj")# && $tempCount != $y)
	    { 
	      # note the array index if cj is encountered
	      $alias_cj=$tempCount; 
	    }
       	    $tempCount++;
	 }#while
	 if(($alias_cjo == -1) &&($alias_cj == -1) )
	 {    #Since cjo  and cj are not encountered Make cj0-> Cjo
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Cjo";
	 }
	 else
	 {
	      # Since Cjo is encountered make cj0->" "
	      #&WriteToLog("WARNING:Model Diode: Parameter cj0 is not translated to Cjo because either cjo or cj is translated to Cjo.");
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
	 }
	 
      }#elsif
           
      $y++;
   } # while
   if($Level_Condition!=-1&& $Ikf_Condition==1)
  { 
   #print ("This satisfies the condiotion of Ikf!=0 and Level not present in parameter list.\n");  
   if($PrintWarnings)
   { &WriteToLog("WARNING:Model Diode: Parameters Level=11 and IkModel=2 added to match spectre DC IV test results"); }
   $numP++;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Level";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="11";
   $numP++;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="IkModel";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="2"; 
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}+=3;     
   } 
   if ( (($tlev == 0) || ($tlev == 1)) && ($eg eq "UNDEF") )
   {
       &WriteToLog("WARNING: Diode $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName} may have different ");
       &WriteToLog("	     simulation results when the simulation temperature does not equal Tnom. ");  
       &WriteToLog("	     This is due to Spectre-specific diode implementation when tlev=0 or 1, or not ");
       &WriteToLog("	     specified, and eg is not specified.  Please verify simulation results.");
   }
} # sub cb_diode_model


return(1);

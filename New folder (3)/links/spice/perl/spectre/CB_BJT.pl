#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# If we are processing IFF output then we need to check
# for the proper ADS symbol to use. The options are:
#
#   For three pin symbols:
#      - BJT_NPN
#      - BJT_PNP
#
#   For four pin symbols:
#      - BJT4_NPN
#      - BJT4_PNP
#
# This callback is called from the element level (models don't call this
# routine). We check which model the instance is tied to and then set
# the proper ADS BJT symbol to use.
#
#
###############################################################################

sub cb_bjt_symbol
{
   my ($tmpCKT, $x) = @_;

   my $i=0;
   my $y=0;
   my $param="";
   my $region="";
   my $ModelTiedTo="";
   my $numPins=0;
   my @Type=();
   my @tmpList=();

   if (!$WantGeminiOutput)
   {
      # We are processing IFF output - we now look for
      # the model this is tied to and determine if it
      # is pnp or npn and also if it needs a three or
      # four pin symbol. Note that vbic always uses a
      # four pin symbol. In cases where only three pins
      # are defined in the netlist, the translator is 
      # creating a fourth one and setting that to ground.

      # Record the number of pins.
      $numPins = $SpiceCktT[$tmpCKT]->{elementArray}[$x]{numPins};

      # We now determine what model this instance is tied to.
      # We search through the params and look for the "Model" reference.
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->
                {elementArray}[$x]->
                   {paramArray}[$y]{name} eq "Model")
         {
            $ModelTiedTo = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
            # We got what we needed - jump out of here.
            last;
         } # if
         $y++;
      } # while

      # We now look for that model...
      while ($i < $SpiceCktT[$tmpCKT]{numElements})
      {
         if ( ($ModelTiedTo eq $SpiceCktT[$tmpCKT]->{elementArray}[$i]{tagName}) &&
              (&Get_ItemType($tmpCKT,$i) eq "model") )
         {
            # We search through the params to see if we are dealing with
            # either an NPN or PNP device. Note that PNP or NPN will be one 
            # of the first params found so the search should take a minimal
            # amount of time.
            $y = 0;
            while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$i]{numParams})
            {
               if ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "NPN")
               {
                  # Save this and we'll check it below...
                  push(@Type, "NPN");
                  push(@Type, $SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{value});
                  last;
               } # if
               elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "PNP")
               {
                  # Save this and we'll check it below...
                  push(@Type, "PNP");
                  push(@Type, $SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{value});
                  last;
               } # if
               $y++;
            } # while
            # We found what we were looking for - jump out of here.
            last;
         } # if
         $i++;
      } # while
      if (@Type == 0) # Then we didn't find the symbol! Look in ckt 0
      {
         # We now look for that model in the top level circuit.
         while ($i < $SpiceCktT[0]{numElements})
         {
            if ( ($ModelTiedTo eq $SpiceCktT[0]->{elementArray}[$i]{tagName}) &&
                 (&Get_ItemType(0,$i) eq "model") )
            {
               # We search through the params to see if we are dealing with
               # either an NPN or PNP device. Note that PNP or NPN will be one 
               # of the first params found so the search should take a minimal
               # amount of time.
               $y = 0;
               while ($y < $SpiceCktT[0]->{elementArray}[$i]{numParams})
               {
                  if ($SpiceCktT[0]->{elementArray}[$i]->{paramArray}[$y]{name} eq "NPN")
                  {
                     # Save this and we'll check it below...
                     push(@Type, "NPN");
                     push(@Type, $SpiceCktT[0]->{elementArray}[$i]->{paramArray}[$y]{value});
                     last;
                  } # if
                  elsif ($SpiceCktT[0]->{elementArray}[$i]->{paramArray}[$y]{name} eq "PNP")
                  {
                     # Save this and we'll check it below...
                     push(@Type, "PNP");
                     push(@Type, $SpiceCktT[0]->{elementArray}[$i]->{paramArray}[$y]{value});
                    last;
                  } # if
                  $y++;
               } # while
               # We found what we were looking for - jump out of here.
               last;
            } # if
            $i++;
         } # while
      } # if

      # Now we check what we found and set the proper 
      # BJT symbol to be used.

      if ((@Type[0] eq "NPN") && (@Type[1] eq "yes"))
      {
         if ($numPins eq 3)
         {
	    #3 pin Mextram504
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT_NPN"; }
	    else   
	    	{ $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT_NPN"; }
         }
         else
         {
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "vbic")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "VBIC_NPN"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bht")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "HICUM_NPN"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT4_NPN"; }
	    else
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT4_NPN"; }
         }
      } # if
      elsif ((@Type[0] eq "NPN") && (@Type[1] eq "no"))
      {
         if ($numPins eq 3)
         {
	    #3 pin Mextram504
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT_PNP"; }
	    else   
	    	{ $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT_PNP"; }
          }
	 else
         {
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "vbic")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "VBIC_PNP"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bht")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "HICUM_PNP"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT4_PNP"; }
	    else
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT4_PNP"; }
         } # else
      } # elsif
      elsif ((@Type[0] eq "PNP") && (@Type[1] eq "yes"))
      {
         if ($numPins eq 3)
         {
	    #3 pin Mextram504
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT_PNP"; }
	    else
	    { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT_PNP"; }
          }
         else
         {
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "vbic")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "VBIC_PNP"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bht")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "HICUM_PNP"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT4_PNP"; }
	    else
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT4_PNP"; }
         } # else
      } # elsif
      elsif ((@Type[0] eq "PNP") && (@Type[1] eq "no"))
      {
         if ($numPins eq 3)
            {  #3 pin Mextram504
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT_NPN"; }
	    else 
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT_NPN"; }
          }
         else
         {
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "vbic")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "VBIC_NPN"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bht")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "HICUM_NPN"; }
             elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} eq "bjt504")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "M504_BJT4_NPN"; }
	 
	    else
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BJT4_NPN"; }
         } # else
      } # elsif

   } # if
} # sub cb_bjt_symbol

###############################################################################
#
# This callback adjusts bjt model "region" values as follows:
#
#    off -> 0
#    on  -> 1
#    breakdown  (ignore, don't output the parameter)
#
###############################################################################

sub cb_bjt_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $region="";
   my $tmpName="";
   my @tmpList=();

   # We cycle through the elements parameters and adjusting them where necessary.
   $y = 0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off") { $region = 0; }
         elsif ($region eq "fwd") { $region = 1; }
         elsif ($region eq "on")  { $region = 1; } # Not sure if this is really needed...
         elsif ($region eq "rev") { $region = 2; }
         elsif ($region eq "sat") { $region = 3; }
         else
         {
            &WriteToLog("WARNING: Parameter region on instance $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName} has an invalid value $region.");
            &WriteToLog("         The value will be ignored, and the default region of 1 (fwd) will be used.");
            $region=1;
         }
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # if
 
      $y++;
   } # while
} # sub cb_bjt_element

###############################################################################
#
# special callback for "type" as follows:
#    type=npn        -> NPN=yes and PNP=no
#    type=pnp        -> NPN=no  and PNP=yes
#
#    The BJT_TYPE parameter below is processed
#    in the callback to set the ADS NPN and PNP
#    references.
#
#    The STRUCT parameter below is processed
#    in the callback to set the proper ADS Lateral
#    value.
#
# special callback for "struct" as follows:
#    struct=vertical  ->Lateral=no
#    struct=lateral   ->Lateral=yes
#    DEFAULT: vertical IF "type=npn" 
#    DEFAULT: lateral  IF "type=pnp" 
#
###############################################################################
sub cb_bjt_model
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $struct="";
   my $tmpName="";
   my @tmpList=();
   my $numP=0;
   my $HavePNP=0;
   my $LateralSet=0;
   my $RbModelSet=0;
   my $BjtTypeSet=0;
   
   # We cycle through the elements parameters and adjusting them where necessary.
   $y = 0;
   $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
   while ($y < $numP)
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "BJT_TYPE")
      {
         $BjtTypeSet=1;
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if ($tmpName eq "npn")
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NPN";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = "yes";
            # We need to add the "PNP" parameter and set it to "no"

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PNP";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "no";
         } # if
         else # We have a pnp
         {
            $HavePNP = 1;
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NPN";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = "no";
            # We need to add the "NPN" parameter and set it to "no"

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PNP";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "yes";
         } # else
      } # if
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "NPN")
      {
         $BjtTypeSet=1;
      }
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "PNP")
      {
         $BjtTypeSet=1;
      }
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "STRUCT")
      {
         $LateralSet=1;
         $struct = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if ($struct eq "vertical" || $struct eq "-1")
              { $struct = "no"; }
         else { $struct = "yes"; }
         # Save the new struct value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "Lateral";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $struct;
      } # if
 
      elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Temp")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         $tmpName = "temp + $tmpName";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
      } # elsif

     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off") { $region = 0; }
         elsif ($region eq "fwd") { $region = 1; }
         elsif ($region eq "on")  { $region = 1; } # Not sure if this is really needed...
         elsif ($region eq "rev") { $region = 2; }
         elsif ($region eq "sat") { $region = 3; }
         elsif ($region eq "breakdown")
         {
            # We don't output the param if region is
            # set to "breakdown". Set the name to ""
            # so it wont be output.
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
         }
         else
         {
            &WriteToLog("WARNING: Parameter region on instance $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName} has an invalid value $region.  The value");
            &WriteToLog("         The value will be ignored, and the default region of 1 (fwd) will be used.");
            $region=1;
         }
         
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # elsif

     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "RbModel")
      {
         $RbModelSet=1;
         my $RbModel = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($RbModel eq "spectre") { $RbModel = 0; }
         elsif ($RbModel eq "spice") { $RbModel = 1; }
         else
         {
            $RbModel=1;
         }
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $RbModel;
      } # elsif

      $y++;
   } # while

   # Spectre's default for BJT_Type is NPN.  If the parameter was not found, 
   # make sure to explicitly set it now to a value of 1.
   unless ($BjtTypeSet)
   {
      # We need to add the new parameter "NPN" and set it to "yes"
      $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "NPN";
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "yes";
      # Add the "PNP" parameter and set it to "no"
      $numP++;
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PNP";
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "no";
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
   } # if

   # Spectre's default for PNP is "Lateral" which would map to
   # ADS's parameter "Lateral=yes". Since the ADS default is "no"
   # we set the new default here.
   if ($HavePNP && !($LateralSet))
   {
      # We need to add the new parameter "Lateral" and set it to "yes"
      $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "Lateral";
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "yes";

      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
      
   } # if

   # Spectre's default for RbModel is spice mode (i.e. RbModel=1).  If the parameter was not found, 
   # make sure to explicitly set it now to a value of 1.
   #  RbModel is added explicitly for BJT model only.-Ramesh Dec13,2004, Spectre.Tran.186
   if (!$RbModelSet && ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{SpectreType} eq "bjt"))
   {
      # We need to add the new parameter "RbModel" and set it to "yes"
      $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "RbModel";
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = 1;
   
      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
   } # if

} # sub cb_bjt_model


return(1);

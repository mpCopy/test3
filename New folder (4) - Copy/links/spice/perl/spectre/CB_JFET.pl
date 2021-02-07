#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# If we are processing IFF output then we need to check
# for the proper ADS symbol to use. The options are:
#
# JFET_NFET and JFET_PFET
#
# This callback is called from the element level (models don't call this
# routine). We check which model the instance is tied to and then set
# the proper ADS BJT symbol to use.
#
#
###############################################################################

sub cb_jfet_symbol
{
   my ($tmpCKT, $x) = @_;

   my $i=0;
   my $y=0;
   my $param="";
   my $region="";
   my $ModelTiedTo="";
   my @Type=();
   my @tmpList=();

   if (!$WantGeminiOutput)
   {
      # We are processing IFF output - we now look for
      # the model this is tied to and determine if it
      # is pnp or npn.

      # We now determine what model this instance is tied to.
      # We search through the params and look for the "Model" reference.
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]{numParams})
      {
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Model")
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
               if ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "NFET")
               {
                  # Save this and we'll check it below...
                  push(@Type, "NFET");
                  push(@Type, $SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{value});
                  last;
               } # if
               elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "PFET")
               {
                  # Save this and we'll check it below...
                  push(@Type, "PFET");
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

      # Now we check what we found and set the proper 
      # JFET symbol to be used.

      if ((@Type[0] eq "NFET") && (@Type[1] eq "yes"))
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET_NFET";
      } # if
      elsif ((@Type[0] eq "NFET") && (@Type[1] eq "no"))
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET_PFET";
      }
      elsif ((@Type[0] eq "PFET") && (@Type[1] eq "yes"))
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET_PFET";
      } # elsif
      elsif ((@Type[0] eq "PFET") && (@Type[1] eq "no"))
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET_NFET";
      } # elsif

   } # if
} # sub cb_nfet_symbol

###############################################################################
#
# This callback adjusts jfet model "region" values as follows:
#
#    off -> 0
#    on  -> 1
#    breakdown  (ignore, don't output the parameter)
#
###############################################################################

sub cb_jfet_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $region="";
   my $tmpName="";
   my @tmpList=();

   # We cycle through the elements parameters and adjust them where necessary.
   $y = 0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off")    { $region = 0; }
         elsif ($region eq "triode") { $region = 1; }
         elsif ($region eq "on")     { $region = 1; } # Not sure if this is really needed...
         elsif ($region eq "subth")  { $region = 2; }
         elsif ($region eq "sat")    { $region = 3; }
         else
         {
            # We don't output the param if region is
            # set to anything else including "breakdown". Set 
            # the name to "" so it wont be output.
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
         } # else
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # if
      $y++;
   } # while
} # sub cb_jfet_element


###############################################################################
#
# special callback for "type" as follows:
#    type=npn        -> NFET=yes and PFET=no
#    type=pnp        -> NFET=no  and PFET=yes
#
#    The JFET_TYPE parameter below is processed
#    in the callback to set the ADS NFET and PFET
#    references.
#
###############################################################################
sub cb_jfet_model
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $struct="";
   my $tmpName="";
   my @tmpList=();
   my $numP=0;

   if ($WantGeminiOutput)
      { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET"; }
   else
      { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "JFET_Model"; }

   # We cycle through the elements parameters and adjusting them where necessary.
   $y = 0;
   $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
   while ($y < $numP)
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "JFET_TYPE")
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if ($tmpName eq "n")
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NFET";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = "yes";
            # We need to add the "PFET" parameter and set it to "no"

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PFET";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "no";
         } # if
         else # We have a pfet
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NFET";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = "no";
            # We need to add the "NFET" parameter and set it to "no"

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;

            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PFET";
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "yes";
         } # else
      } # if
 
      $y++;

   } # while
} # sub cb_jfet_model


return(1);

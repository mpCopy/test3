#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

# Here we need to create a new BinModel and attach
# the appropriate mosfet models.
#
# We look at "bsimName" from the @SpiceElement
# list. Anything that has the value of "bsimName"
# with _1, _2 etc is a candidate to be put into the
# model list.
#
# Below is a netlist data structure output and an IFF data
# structure output for an ADS BinModel. This model, named
# "nchan", ties together models "nchan_1" and "nchan_2"
# with the appropriate length and width values.
#
#   Netlist Data Structure
#   ----------------------
# 
# Item Type:   (1)
# Type:        (BinModel)
# Name:        (nchan)
# subckt Name: ()
# num pins:    (0)
# num params(9):  (12)
# Pin names:
# Name/Value pairs:
#    Model[1] = "nchan_1"
#    Model[2] = "nchan_2"
#    Param[1] = "Length"
#    Param[2] = "Width"
#    Min[1,1] = 1
#    Max[1,1] = 2.5
#    Min[1,2] = 2
#    Max[1,2] = 15
#    Min[2,1] = 2.5
#    Max[2,1] = 3.5
#    Min[2,2] = 2
#    Max[2,2] = 15
#
#   IFF Data Structure
#   ------------------
#
# Item Type:   (1)
# Type:        (BinModel)
# Name:        (nchan)
# subckt Name: ()
# num pins:    (0)
# num params(6):  (4)
# Pin names:
# Name/Value pairs:
#    Model = list(prm("BinModelModel",1,nchanx2),prm("BinModelModel",2,nchanx3))
#    Param = list(prm("BinModelParam",1,Length),prm("BinModelParam",2,Width))
#    Min = list(prm("BinModelMin",1,1,1),prm("BinModelMin",1,2,2),prm("BinModelMin",2,1,2.5),prm("BinModelMin",2,2,2))
#    Max = list(prm("BinModelMax",1,1,2.5),prm("BinModelMax",1,2,15),prm("BinModelMax",2,1,3.5),prm("BinModelMax",2,2,15))
#


$SetParamLength = 1;
@IFF_Models = ();
@IFF_Min = ();
@IFF_Max = ();
@BSIM_Params = ();

# We only need to cycle this once. All model
# and subcircuit stuff is taken care of on the
# same pass...
$Binning_AlreadyProcessed = 0;

###############################################################################
#
# cb_bin: CallBack that creates an ADS BinModel.
#
###############################################################################
sub cb_bin
{
   my ($dont_need_cktnum, $dont_need_elem_ref) = @_;

   my $tmpCKT=0;
   my $elemCount=0;
   my $x=0;
   my $y=0;
   my $mod="";
   my $param="";
   my $ModelCount=0;
   my $value=0;
   my $tagName="";

   if ($Binning_AlreadyProcessed) { return(1); }
   $Binning_AlreadyProcessed = 1;   

   while (@BinList)
   {
      $mod = shift(@BinList);
      $tmpCKT = shift(@BinList);
      $SetParamLength = 1;
      $ModelCount = 0;

      &Setup_BinModel($mod, $tmpCKT);

      # We need to find the models associated with this
      # and store their names, wmax, wmin, lmax, and
      # lmin values.

      $elemCount = $SpiceCktT[$tmpCKT]{numElements};
      $x = 0;
      while ($x < $elemCount)
      {
         if ( $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{bsimName} eq $mod)
         {
            # We have a new model that needs to be added to our BinModel!
            $ModelCount++;

            $tagName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName};
            if ($WantGeminiOutput)
               { &Record_Netlist_Defaults($tmpCKT,$ModelCount,$tagName); }
            else
               { &Record_IFF_Defaults($ModelCount,$tagName); }

            $SetParamLength=0;
        
            # We now override the defaults if we have length/width values
            $y = 0;
            while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
            {
               $param = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name};
               $value  = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
                  
               if ( ($param eq "Wmax") || ($param eq "Wmin") ||
                    ($param eq "Lmax") || ($param eq "Lmin") )
               {
                  # Save this data so we can add it to our
                  # new model later.
                  push(@BSIM_Params,$tmpCKT);
                  push(@BSIM_Params,$param);
                  push(@BSIM_Params,$value);
                  push(@BSIM_Params,$ModelCount);
               } # if
               $y++;
            } # while
         } # if
         $x++;
      } # while

      if (@BSIM_Params)
      {
         if ($WantGeminiOutput)
              { &Record_Netlist_LengthWidth; }
         else { &Record_IFF_LengthWidth }
      } # if
      
   } # while

   # Start on a new Bin Model
   $ModelCount = 0;

} # sub cb_bin

###############################################################################
#
# Setup_BinModel : Do initial configuration of new BinModel card.
#
###############################################################################
sub Setup_BinModel
{
   my ($mod,$tmpCKT) = @_;

   my $x=0;
   my $ItemType="";

   $ItemType = $ItemType{model};

   $x = $SpiceCktT[$tmpCKT]{numElements};

   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType} = "BinModel";

   &Record_Usage($tmpCKT,$x,1);

   # The components that reference this model name have already
   # been matched up in post processing. 
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{tagName} = $mod;

   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams} = 0;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numPins} = 0;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{ItemType} = $ItemType;
   
   # Bump up the number of elements.
   $SpiceCktT[$tmpCKT]{numElements}++;

} # sub Setup_BinModel 

###############################################################################
#
# Record_Netlist_Defaults
#
###############################################################################
sub Record_Netlist_Defaults
{
   my ($x,$ModelCount,$mod) = @_;

   # We are the last element for this CKT...
   # Indexing starts at zero so we subtract one from the total.
   my $y = $SpiceCktT[$x]{numElements} - 1; 

   my $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};

   my $Max1="";
   my $Min1="";
   my $Max2="";
   my $Min2="";
   my $ModName="";
   my $ModVal="";

   $ModName = "Model[$ModelCount]";
   $ModVal  = "\"$mod\"";

   $Max1 = "Max[$ModelCount,1]";
   $Min1 = "Min[$ModelCount,1]";
   $Max2 = "Max[$ModelCount,2]";
   $Min2 = "Min[$ModelCount,2]";

   # We check if this is the first time in here.
   # If it is then we record "Length" and "Width"
   # as parameters.
   if ($SetParamLength == 1)
   {
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = "Param[1]";
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "\"Length\"";
      $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

      $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
      &Record_NumberOfParams($x, $y, $z);
      
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = "Param[2]";
      $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "\"Width\"";
      $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

      $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
      &Record_NumberOfParams($x, $y, $z);
   } # if

   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = $ModName;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = $ModVal;
   $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

   $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
   &Record_NumberOfParams($x, $y, $z);

   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = $Max1;
   # Use an "x"
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "x";
   $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

   $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
   &Record_NumberOfParams($x, $y, $z);

   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = $Min1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "x";
   $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

   $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
   &Record_NumberOfParams($x, $y, $z);

   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = $Max2;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "x";
   $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

   $z = $SpiceCktT[$x]->{elementArray}[$y]->{numParams};
   &Record_NumberOfParams($x, $y, $z);

   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{used} = 1;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{name} = $Min2;
   $SpiceCktT[$x]->{elementArray}[$y]->{paramArray}[$z]{value} = "x";

   $SpiceCktT[$x]->{elementArray}[$y]->{numParams}++;

} # sub Record_Netlist_Defaults

###############################################################################
#
# Record_Netlist_LengthWidth
#
#  NOTE: We are dealing with a newly created BinModel here.
#
###############################################################################
sub Record_Netlist_LengthWidth
{
   my $x=0;
   my $y=0;
   my $param="";
   my $value="";
   my $tmpName="";
   my $ModelCount=0;
 
   while (@BSIM_Params)
   {
      $tmpCKT = shift(@BSIM_Params);
      $param  = shift(@BSIM_Params);
      $value  = shift(@BSIM_Params);
      $ModelCount = shift(@BSIM_Params);

      # Our new BinModel is the last element on the circuit.
      # Indexing starts at zero so we subtract one from the total.
      $x = $SpiceCktT[$tmpCKT]{numElements} - 1;

      # We cycle the parameters for our BinModel and look for the
      # proper match so we can override the default value.
      $y=0;
      while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
      {
         $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name};
         if ( ($param eq "Lmax") && ($tmpName eq "Max[$ModelCount,1]") )
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $value;
         } # if
         elsif ( ($param eq "Wmin") && ($tmpName eq "Min[$ModelCount,2]") )
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $value;
         } # elsif
         elsif ( ($param eq "Wmax") && ($tmpName eq "Max[$ModelCount,2]") )
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $value;
         } # elsif
         elsif ( ($param eq "Lmin") && ($tmpName eq "Min[$ModelCount,1]") )
         {
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $value;
         } # elsif
         $y++;
      } # while
   } # while

   $y=0;
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      # If a min/max value was not set (hence the "x" place holder
      # still exists) then null out the name so it's not output.
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} eq "x")
      {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
      } # elsif
      $y++;
   } # while

} # sub Record_Netlist_LengthWidth

###############################################################################
#
# Record_IFF_Defaults
#
###############################################################################
sub Record_IFF_Defaults
{
   my ($ModelCount,$mod) = @_;

   push(@IFF_Models, "prm(\"BinModelModel\",$ModelCount,$mod\)"); 
   push(@IFF_Min1, "prm(\"BinModelMin\",$ModelCount,1,x)");
   push(@IFF_Max1, "prm(\"BinModelMax\",$ModelCount,1,x)");
   push(@IFF_Min2, "prm(\"BinModelMin\",$ModelCount,2,x)");
   push(@IFF_Max2, "prm(\"BinModelMax\",$ModelCount,2,x)");

} # sub Record_IFF_Defaults


###############################################################################
#
# Record_IFF_LengthWidth
#
#  NOTE: We are dealing with a newly created BinModel here.
#
###############################################################################
sub Record_IFF_LengthWidth
{
   my $x=0;
   my $y=0;
   my $param="";
   my $value="";
   my $ModelCount=0;
   my $pName   = "";
   my $mName   = "";
   my $minName = "";
   my $maxName = "";

   # We override the default values...
   while (@BSIM_Params)
   {
      $tmpCKT = shift(@BSIM_Params);
      $param  = shift(@BSIM_Params);
      $value  = shift(@BSIM_Params);
      $ModelCount = shift(@BSIM_Params);

      # Accessing IFF_Min or IFF_Max by $ModelCount-1
      # will have us looking at the correct parameters.

         # In the comments below, "z" refers to $ModelCount

         # Substitute : "BinModelMin",z,1,x 
         # With       : "BinModelMin",z,1,$value
      if ($param eq "Lmin")
         { @IFF_Min1[$ModelCount-1] =~ s/x\)/$value\)/; }

         # Substitute : "BinModelMin",z,2,x 
         # With       : "BinModelMin",z,2,$value
      elsif ($param eq "Wmin")
         { @IFF_Min2[$ModelCount-1] =~ s/x\)/$value\)/; }

         # Substitute : "BinModelMax",z,1,x
         # With       : "BinModelMax",z,1,$value
      elsif ($param eq "Lmax")
         { @IFF_Max1[$ModelCount-1] =~ s/x\)/$value\)/; }

         # Substitute : "BinModelMax",z,2,x 
         # With       : "BinModelMax",z,2,$value
      elsif ($param eq "Wmax")
         { @IFF_Max2[$ModelCount-1] =~ s/x\)$/$value\)/; }

   } # while


   # Our new BinModel is the last element on the circuit.
   # Indexing starts at zero so we subtract one from the total.
   $x = $SpiceCktT[$tmpCKT]{numElements} - 1;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams} = 4;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[0]{name} = "Model";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[0]{used} = 1;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[1]{name} = "Param";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[1]{value} = "list(prm(\"BinModelParam\",1,Length),prm(\"BinModelParam\",2,Width))";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[1]{used} = 1;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[2]{name} = "Min";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[2]{used} = 1;
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[3]{name} = "Max";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[3]{used} = 1;

   $mName   = "list(";
   $minName = "list(";
   $maxName = "list(";

   $x = 0;

   while (@IFF_Models)
   {
      # Note: If we have a $value with "x)" on the end it means that
      #       there was no value supplied from the netlist. We strip
      #       off the "x" portion and leave it blank.

      $value = shift(@IFF_Models);
      $mName = $mName . $value . ",";
 
      $value = shift(@IFF_Min1);
      $value =~ s/x\)$/\)/;
      $minName = $minName . $value . ",";

      $value = shift(@IFF_Max1);
      $value =~ s/x\)$/\)/;
      $maxName = $maxName . $value . ",";

      $value = shift(@IFF_Min2);
      $value =~ s/x\)$/\)/;
      $minName = $minName . $value . ",";

      $value = shift(@IFF_Max2);
      $value =~ s/x\)$/\)/;
      $maxName = $maxName . $value . ",";

      $x++;

   } # while

   # Substitute the last "," with a ")"
   $mName =~ s/\,$/)/;
   $minName =~ s/\,$/)/;
   $maxName =~ s/\,$/)/;

   $x = $SpiceCktT[$tmpCKT]{numElements} - 1;

   # Name has already been set - so just set the value
   # $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[0]{name} = "Model";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[0]{value} = $mName;

   # Name has already been set - so just set the value
   # $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[2]{name} = "Min";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[2]{value} = $minName;

   # Name has already been set - so just set the value
   # $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[3]{name} = "Max";
   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[3]{value} = $maxName;

} # sub Record_IFF_LengthWidth

###############################################################################
#
#    For the models we search for MOS_TYPE and set the ADS parameters
#    PMOS and NMOS to either "yes" or "no" depending upon
#    if MOS_TYPE returns "n" or "p". Notice that we have to
#    create a new parameter. (we actually check elements for MOS_TYPE
#    even though they wont have the param - no big deal.)
#
###############################################################################

sub cb_bsim_params
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $tmpName="";
   my @tmpList=();
   my $numP=0;
   my $k1Defined=0;
   my $k2Defined=0;
   my $tempCount=0;
   my $aliasIndex= -1;
   my $AcmEqThree=-1;
   
   # We could have "mos1", "mos2", "bsim3v3, or "bsim4"....we 
   # figure out which one.

   # This callback is listed for all of them...
   my $MOS_Type = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{SpectreType};

   # We could just hard code the ADS name here - but we
   # get it from the hash using the Spectre "bsim3v3" key.
   my $mos_elemType = $SpecMap{element}{$MOS_Type};
   my $mos_modType  = $SpecMap{model}{$MOS_Type};

   # We need to get either the netlist or the IFF reference...
   @tmpList = split(",", $mos_elemType);
   if ($WantGeminiOutput) { $mos_elemType = @tmpList[0]; }
   else { $mos_elemType = @tmpList[1]; }

   @tmpList = split(",", $mos_modType);
   if ($WantGeminiOutput) { $mos_modType = @tmpList[0]; }
   else { $mos_modType = @tmpList[1]; }

   if ( ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType} eq $mos_elemType) ||
        ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{outputType} eq $mos_modType) )
   {
      $y = 0;
      $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
      while ($y < $numP)
      {
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "MOS_TYPE")
         {
            $tmpName = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
            #Supporting  type=n or type=(n)  , Spectre_Tran.102, Ramesh
	    if ($tmpName eq "n" or $tmpName eq "\(n\)")
            {
               $tmpName = "yes";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NMOS";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
               # We need to add the "PMOS" parameter and set it to "no"
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PMOS";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "no";
            }
            else
            {
               $tmpName = "no";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "NMOS";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $tmpName;
               # We need to add the "PMOS" parameter and set it to "no"
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "PMOS";
               $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = "yes";
            } # else
         } # if
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "K1")
         {
            $k1Defined=1;
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "K2")
         {
            $k2Defined=1;
         }
	 # resolving 'n' and 'nj' .   Spectre_Trans.188 Ramesh  Dec.14,04
	 # when users specify both 'n' and 'nj', n -> Nj
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Njtemp")
         { 
	   $tempCount=0;
           while ($tempCount < $numP)
	   {
	     if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Nj" && $tempCount != $y)
	      { 
	      # note the array index if Nj is encountered
	       $aliasIndex=$tempCount;
	       last;
	      }
       	    $tempCount++;
	   }#while
	   if ($aliasIndex != -1)
	     {
	      # Since Nj is encountered make Njtemp->" "
	      # print ("Model bsim3v3: Parameter nj is not translated to Nj because n is translated to Nj.\n");
 	      if ($PrintWarnings)
	      {  &WriteToLog("WARNING:Model bsim3v3: Parameter nj is not translated to Nj because n is translated to Nj.");  }
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
	     }
	   elsif($aliasIndex == -1)
	     {#Since Nj is not encountered Make Njtemp-> Nj
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Nj";
	     }
	 }#elsif
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Cjgate")
         { #Spectre_Tran.209
	   $tempCount=0;
           while ($tempCount < $numP)
	   {
	     if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Cjswg" && $tempCount != $y)
	      { 
	      # note the array index if Cjswg is encountered
	       $aliasIndex=$tempCount;
	       last;
	      }
	      
       	    $tempCount++;
	   }#while
	   if ($aliasIndex != -1)
	   {
	      # Since cjswg is encountered make cjgate->" "
	      #print ("Model bsim3v3: Parameter cjgate is not translated to Cjswg because cjswg is translated to Cjswg.\n");
 	      if ($PrintWarnings)
	      {  &WriteToLog("WARNING:Model bsim3v3: Parameter cjgate is not translated to Cjswg because cjswg is translated to Cjswg."); }
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} =" ";
	      $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
	   }
	   elsif($aliasIndex == -1)
	   {  #Since cjswg is not encountered check for Acm=3. If true cjgate->Cjswg else cjgate->"" and generate warning
	      $tempCount=0;
	      while ($tempCount < $numP)
	      {
	        if(($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{name} eq "Acm") && 
	          ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$tempCount]{value} eq "3"))
	        {   $AcmEqThree=$tempCount; last;  }
	        $tempCount++;
	      }#while
	      if($AcmEqThree != -1)
	      {  $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="Cjswg";  }
	      elsif($AcmEqThree == -1)
	      { 
	         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} ="";
		 $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} =" ";
		 #&WriteToLog("WARNING:Model bsim3v3: Parameter cjgate not translated.");
	      }
	   }#elsif($aliasIndex == -1)
	 }#elsif
	 
         # We need to check for aliased parameters that are not
         # supported by the UI. This is only an issue for schematic
         # import.
         if ( (! $WantGeminiOutput) && ($MOS_Type eq "bsim4") )
         {
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Pta")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "Tpb"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Cta")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "Tcj"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Ptp")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "Tpbsw"; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Ctp")
               { $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "Tcjsw"; }
         } # if
         $y++;
      } # while
      
      # Check to see if K1 is not defined, but K2 is defined, and that the model is not a bsim4.  
      # There is a discrepency in spectre where K1 defaults to .50, but defaults to .53 in ADS.  
      # This leads to a mismatch in simulation results.  As a workaround, K1 will be defined to 
      # .50 if K2 is specified, but K1 is not.
      if( $k2Defined && ! $k1Defined && !($MOS_Type eq "bsim4") )
      {
         # Add the "K1" parameter and set it to .50
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}++;
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} = "K1";
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} = .50;
      }
      
   } # if
} # sub cb_bsim_params

###############################################################################
#
# This callback adjusts mos element "region" values as follows:
#
#    off           -> 0
#    fwd,triode,on -> 1
#    rev,subth     -> 2
#    sat           -> 3
#    breakdown,other  (ignore, don't output the parameter)
#
###############################################################################

sub cb_mos_element
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $param="";
   my $region="";
   my $tmpName="";
   my @tmpList=();
   my $MM9_Found=0;

   # We cycle through the elements parameters and adjust them where necessary.
   $y = 0;

   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
      if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Region")
      {
         $region = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         if    ($region eq "off")                            { $region = 0; }
         elsif (($region eq "fwd") || ($region eq "triode")) { $region = 1; }
         elsif ($region eq "on")                             { $region = 1; } # Not sure if this is really needed...
         elsif (($region eq "rev") || ($region eq "subth"))  { $region = 2; }
         elsif ($region eq "sat")                            { $region = 3; }
         else
         {
            # We don't output the param if region is
            # set to anything else - including "breakdown". 
            # Set the name to "" so it wont be output.
            $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
         }
         # Save the new region value...
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = $region;
      } # if

      $y++;
   } # while
} # sub cb_mos_element



###############################################################################
#
# If we are processing IFF output then we need to check
# for the proper ADS symbol to use. The options are:
#
# MOSFET_PMOS and MOSFET_NMOS
#
# This callback is called from the element level (models don't call this
# routine). We check which model the instance is tied to and then set
# the proper ADS MOS symbol to use.
#
###############################################################################

sub cb_mos_symbol
{
   my ($tmpCKT, $x) = @_;

   my $i=0;
   my $y=0;
   my $param="";
   my $region="";
   my $ModelTiedTo="";
   my @Type=();
   my @tmpList=();

   my ($BSIM4_Found, $MOS902_Found,$B3SOI_Found) = 0;

   if (!$WantGeminiOutput)
   {

      # We are processing IFF output - we now look for
      # the model this is tied to and determine if it
      # is pmos or nmos.

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
            if ($SpiceCktT[$tmpCKT]->{elementArray}[$i]{outputType} eq "BSIM4_Model")
               { $BSIM4_Found = 1; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$i]{outputType} eq "MOS_Model9_Process")
               { $MOS902_Found = 1; }
            elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$i]{outputType} eq "BSIM3SOI_Model")
               { $B3SOI_Found = 1; }
	    # We search through the params to find out what we are dealing with.
            $y = 0;
            while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$i]{numParams})
            {
               if ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "NMOS")
               {
                  # Save this and we'll check it below...
                  push(@Type, "NMOS");
                  push(@Type, $SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{value});
                  last;
               } # if
               elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$i]->{paramArray}[$y]{name} eq "PMOS")
               {
                  # Save this and we'll check it below...
                  push(@Type, "PMOS");
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
      # MOSFET symbol to be used.

      if ((@Type[0] eq "NMOS") && (@Type[1] eq "yes"))
      {
         if ($BSIM4_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM4_NMOS"; }
         elsif ($MOS902_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MM9_NMOS"; }
         elsif ($B3SOI_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM3SOI_NMOS"; }
	 else
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MOSFET_NMOS"; }
      } # if
      elsif ((@Type[0] eq "NMOS") && (@Type[1] eq "no"))
      {
         if ($BSIM4_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM4_PMOS"; }
         elsif ($MOS902_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MM9_PMOS"; }
         elsif ($B3SOI_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM3SOI_PMOS"; }
	 else
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MOSFET_PMOS"; }
      }
      elsif ((@Type[0] eq "PMOS") && (@Type[1] eq "yes"))
      {
         if ($BSIM4_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM4_PMOS"; }
         elsif ($MOS902_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MM9_PMOS"; }
         elsif ($B3SOI_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM3SOI_PMOS"; }
	 else
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MOSFET_PMOS"; }
      } # elsif
      elsif ((@Type[0] eq "PMOS") && (@Type[1] eq "no"))
      {
         if ($BSIM4_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM4_NMOS"; }
         elsif ($MOS902_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MM9_NMOS"; }
         elsif ($B3SOI_Found)
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "BSIM3SOI_NMOS"; }
	 else
            { $SpiceCktT[$tmpCKT]->{elementArray}[$x]{outputType} = "MOSFET_NMOS"; }
      } # elsif

   } # if
} # sub cb_mos_symbol

return(1);

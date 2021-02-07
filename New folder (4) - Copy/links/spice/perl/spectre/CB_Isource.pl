#!/usr/local/bin/perl
# Copyright Keysight Technologies 2005 - 2017  

###############################################################################
#
# This callback will resolve the isource type(dc,sine,pulse,pwl,exp)
#
#    isource, type=dc -> I_Source,  Idc
#    isource, type=sine ->I_Source, I_Tone=damped_sin(time,offset,amplitude,freq,delay,damping)
#    isource, type=pulse ->I_Source, I_Tone=pulse(time, low, high, delay, rise, fall, width, period)
#    isource, type=exp ->I_Source, I_Tran=exp_pulse(time,low, high, tdelay1,tau1, tdelay2, tau2)
#    isource, type=pwl ->I_Source, I_Tran=pwl(time,t1,v1,t2,v2...tn,vn)
#  
###############################################################################

sub cb_isource_type
{
   my ($tmpCKT, $x) = @_;

   my $y=0;
   my $numP=0;
   my $typeVal="";
   my $paramMagVal="";
   my $paramPhaseVal="";
   my $DelayVal=0;
   #Variables for sine isource
   my $AmpVal=1;   my $FreqVal="";    my $DampVal=0;
   
   #Variables for pulse isource
   # Spectre default:$widthVal= infinity;$periodVal = infinity; 
   my $val0=0;   my $val1=1;   my $riseVal="";  my $fallVal=""; my $widthVal= ""; my $periodVal = "";
   my $tDelay1=0; my $tau1=0; my $tDelay2=0; my $tau2=0;
   my $waveVal=""; my $pwlperiod=1;
   
   $y = 0;
   $numP = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams};
   while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
   {
     if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Type")
     {
         $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} = "";
	 $typeVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     } # if
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Mag")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
	$paramMagVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Phase")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
	$paramPhaseVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Delay")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
        $DelayVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Val0")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
        $val0=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Val1")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
        $val1=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Pwlperiod")
     {
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
        $pwlperiod=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
     }
     $y++;
   } # while
   

   if($typeVal eq "sine")
   {
       $y = 0;
       while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
       {	
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Ampl")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $AmpVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} ;
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "SinePhase")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
	   $paramPhaseVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Freq")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $FreqVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} ;
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Damp")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $DampVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} ;
         }
         $y++;
        } # while
	
	
	#Processing Iac
	if($paramMagVal ne "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,$paramPhaseVal)"; 
	}   
	if($paramMagVal ne "" && $paramPhaseVal eq "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,0)"; 
	}
	if($paramMagVal eq "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar(1,$paramPhaseVal)"; 
	}
	#Processing I_Tran=damped_sin(time,offset,amplitude,freq,delay,damping)
	$numP++;
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="I_Tran";
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="damped_sin(time,0,$AmpVal,$FreqVal,$DelayVal,$DampVal)";
        
	$numP++;
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}=$numP;
    }
    elsif($typeVal eq "pulse")
    {   
       $y = 0;
       while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
       {	
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Rise")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $riseVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} ;
         }
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Fall")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $fallVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} ;
         }
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Width")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $widthVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Period")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $periodVal=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
         $y++;
        } # while
	         
        #Processing Iac
	if($paramMagVal ne "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,$paramPhaseVal)"; 
	}   
	if($paramMagVal ne "" && $paramPhaseVal eq "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,0)"; 
	}
	if($paramMagVal eq "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar(1,$paramPhaseVal)"; 
	}
	
	#Processing I_Tran=pulse(time, low, high, delay, rise, fall, width, period) 
	#$val0, $val1=1,$riseVal=0, $fallVal=0, $widthVal= 0, $periodVal = 0
	$numP++;
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="I_Tran";
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="pulse(time,$val0,$val1,$DelayVal,$riseVal,$fallVal,$widthVal,$periodVal)";
        
	$numP++;
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}=$numP;	
    }
    elsif($typeVal eq "exp")
    {
       $y = 0;
       while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
       {	
         if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Td1")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $tDelay1=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Tau1")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $tau1=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
         elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Td2")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $tDelay2=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
	 elsif ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Tau2")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="";
           $tau2=$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
         }
         $y++;
        } # while
	
	
	#Processing Iac
	if($paramMagVal ne "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,$paramPhaseVal)"; 
	}   
	if($paramMagVal ne "" && $paramPhaseVal eq "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,0)"; 
	}
	if($paramMagVal eq "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar(1,$paramPhaseVal)"; 
	}
	#Processing I_Tran=exp_pulse(time,low, high, tdelay1,tau1, tdelay2, tau2)
	$numP++;
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="I_Tran";
	$SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="exp_pulse\(time,$val0,$val1,$tDelay1,$tau1,$tDelay2,$tau2\)";
        
	$numP++;
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}=$numP;
    }
    elsif($typeVal eq "pwl")
    {  
        $y = 0;
       while ($y < $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams})
       {	
         
	 if ($SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name} eq "Wave")
         {
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{name}="I_Tran";

           $waveVal = $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value};
	   
           $waveVal =~ s/\[\s*//;
	   $waveVal =~ s/\s*\]/\)/;
           $waveVal =~ s/\s/,/g;
           $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$y]{value} = "pwl\("."$pwlperiod,".$waveVal;
         }
	$y++;
      } # while
      
      #Processing Iac
	if($paramMagVal ne "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,$paramPhaseVal)"; 
	}   
	if($paramMagVal ne "" && $paramPhaseVal eq "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar($paramMagVal,0)"; 
	}
	if($paramMagVal eq "" && $paramPhaseVal ne "")
	{  
	   $numP++;
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{name} ="Iac";
    	   $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{paramArray}[$numP]{value} ="polar(1,$paramPhaseVal)"; 
	}
        $numP++;
        $SpiceCktT[$tmpCKT]->{elementArray}[$x]->{numParams}=$numP;
   }
} # sub cb_isource_type

return(1);

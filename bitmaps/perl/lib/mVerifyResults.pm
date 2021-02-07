package mVerifyResults;

use strict;
use Carp;

use dKitResults;
#use Data::Dumper;
############################################################################
####
##    Versioning stuff
#
my $VERSION = 2.1;

sub version
{
    return $VERSION;
}

##################################################
#### Debugging
#

################################################
# class method : debug
# purpose : set5 debugging level for class
# call vocabulary
#
# dKitTemplate->debug(level);
#   0 : debugging off.
#

my $Debugging = 0;

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : mVerifyResults->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
        carp ("dKitResult debugging turned on\n");
    } else
    {
        carp ("dKitResult debugging turned off\n");
    }
}

sub numerically { 
    my @aIVKeys = split /,/, $a;
    my @bIVKeys = split /,/, $b;
    $aIVKeys[0] <=> $bIVKeys[0] 
     ||
    $aIVKeys[1] <=> $bIVKeys[1] 
     ||
    $aIVKeys[2] <=> $bIVKeys[2] 
     ||
    $aIVKeys[3] <=> $bIVKeys[4] 
    }

#############################################################################
# Compare the results of 2 simulators. Only for use with mverify.  The htmlFilename 
# is the name of the file generated for this run through mverify.  prjectName will be used to find the 
# results files and name the log file generated.  testName, modelName, and testType are values displayed
# on the html results file, and can be any value. 
#
# usage 
# my $statisticaldata = $handle->compareResults(projectName, testName, modelName, testType, htmlfilename, simulators, abs_tol, Parameter1, tolerance1, ...);

sub compareResults
{
    my $package = shift;
    my $projectName = shift;
    my $testName = shift;
    my $modelName = shift;
    my $testType = shift;
    my $resultHtmlFile = shift;
    my $simulators = shift;
    my $abs_tol = shift;
    my %tolerance = ();
    my $warnings = "";
    while (@_) {
       my $paramName = shift;
       my $nextTolerance = shift;
       if ($nextTolerance) 
       {
          $tolerance{$paramName}=$nextTolerance;
       }
    }
    my $statistics = "";
    my $log = "";
    my $output_to_file = "";
    my @testedParams = ();
    my @availableParams = ();
    my %passFail= ();
    my $failedStatus='SIM_FAIL';

    my @simulators = split /\s*,\s*/,$simulators;
    my %comparisonResults = ();
    print "\nComparing simulation results...\n";
    while ($simulators[1])
    {

    my $ref_simulator = shift @simulators;
    my $REF_SIM_RESULTS=dKitResults->getResults($projectName,$ref_simulator);

    foreach my $test_simulator (@simulators)
    { 
    my $TEST_SIM_RESULTS=dKitResults->getResults($projectName,$test_simulator);
    if ((! ref $REF_SIM_RESULTS) || (! ref $TEST_SIM_RESULTS))
    {
        # If ads failed, the first thing to check is if the other simulator failed.
        if (!(${ref_simulator} eq 'ads') && (! ref $REF_SIM_RESULTS)) 
        {
          $failedStatus=${ref_simulator} . '_FAIL';
        } elsif (!(${test_simulator} eq 'ads') && (! ref $TEST_SIM_RESULTS))
        {
          $failedStatus=${test_simulator} . '_FAIL';
        } elsif (!(${ref_simulator} eq 'spectre') && (! ref $REF_SIM_RESULTS)) 
        {
          $failedStatus=${ref_simulator} . '_FAIL';
        } elsif (!(${test_simulator} eq 'spectre') && (! ref $TEST_SIM_RESULTS))
        {
          $failedStatus=${test_simulator} . '_FAIL';
        } elsif (! ref $REF_SIM_RESULTS)
        {
          $failedStatus=${ref_simulator} . '_FAIL';
        } elsif (! ref $TEST_SIM_RESULTS) 
        {
          $failedStatus=${test_simulator} . '_FAIL';
        }

        $passFail{"$ref_simulator|$test_simulator"} = $failedStatus;
        $output_to_file .= "\n------------------------------------------------------------------------------------\n$modelName status for $test_simulator vs. $ref_simulator:" . $passFail{"$ref_simulator|$test_simulator"} . "\n\n" . "SIMULATION ERROR:  Results not available for comparison between $ref_simulator and $test_simulator!\n\n------------------------------------------------------------------------------------\n";
        next;
    }
    print "reference= $ref_simulator   test=$test_simulator\n";
    my $self=dKitResults->compareDataRelative($REF_SIM_RESULTS,$TEST_SIM_RESULTS);
    foreach my $deviceName (keys %{$self->{"depVars"}})
    {
        foreach my $depVarName (keys %{$self->{"depVars"}{$deviceName}})
        { 
            my $paramName = "$deviceName.$depVarName";
            unshift @availableParams,$paramName;
            my $activeCompare = "";
            foreach my $checkParam (keys %tolerance)
            {
                if ($checkParam eq $paramName) {
                    $activeCompare = $checkParam;
                    push @testedParams,$activeCompare;
                    $log .= "|$paramName|: Verifying $paramName with relative tolerance $tolerance{$activeCompare}% and absolute tolerance $abs_tol.\n"
                }
            }
            if (! $activeCompare)
            {
               $log .= "|$paramName|: Not verified\n";
            }
            my $sum = 0;
            my $maximum = -1e38;
            my $minimum = 1e38;
            my $nrOfValues = 0;
            my $fail = 0;
            my %indVarKeys;
            foreach my $indVarKey (sort numerically keys %{$self->{"depVars"}{$deviceName}{$depVarName}})
            {
            my $value;
            if (ref $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey})
            {  ## complex use magnitude...  ...and phase (Isaac 8 Aug 2002)
                $value = $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0] * $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0];
                $value += $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1] * $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1];
                $value = sqrt($value);
            } else
            {
                $value =  abs($self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey});
            }
            $sum += $value;
            if ($activeCompare)
            {
                if ($value > $tolerance{$activeCompare})
                {
                    ##### ----- FAILURE, relative tolerance exceeded. ----- 
                    my $indVarIdxIdx=0;
                    my @indVarIdx=split(',',$indVarKey);
                    my $location='';
                    my @refIndVarKeyArray;
                    foreach my $REFindVar (@{$REF_SIM_RESULTS->{"indVarCreateOrder"}})
                    {
                        push @refIndVarKeyArray,"0"; 
                    }
                    foreach my $indVar (@{$self->{"indVarCreateOrder"}})
                    {
                        my $REFindx=0;
                        $location .= "$indVar = " . sprintf("%-8.5g",$self->{"indVars"}{$indVar}{"values"}[$indVarIdx[$indVarIdxIdx]]) . ", ";
                        foreach my $REFindVar (@{$REF_SIM_RESULTS->{"indVarCreateOrder"}})
                        { 
                            if ($indVar eq $REFindVar) { $refIndVarKeyArray[$REFindx]=$indVarIdx[$indVarIdxIdx]; }
                            $REFindx++;
                        } 
                        $indVarIdxIdx++;
                    }
                    chop $location; chop $location;                     #remove last commma
                    my $refIndVarKey=join ",",@refIndVarKeyArray;
#                    chop $refIndVarKey; chop $refIndVarKey;
                    my $refValue="";
                    my $refRe=0;
                    my $refIm=0;
                    if (ref $REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey})
                    {
                        $refValue="" . sprintf("%8.3g", $REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[0]) . "+" . sprintf("%8.3g", $REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[1]) . "j";
                        $refRe=$REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[0];
                        $refIm=$REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[1];
                    }
                    else
                    { 
                        $refValue=sprintf("%8.3g", $REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey});
                        $refRe=$REF_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey};
                    }

                    my $testValue="";
                    my $testRe=0;
                    my $testIm=0;
                    if (ref $TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$indVarKey})
                    {
                        $testValue= "" . sprintf("%8.3g", $TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0]) . "+" . sprintf("%8.3g", $TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1]) . "j";
                        $testRe=$TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[0];
                        $testIm=$TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey}[1];
                    }
                    else
                    { 
                        sprintf("%8.3g", $testValue=$TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$indVarKey});
                        $testRe=$TEST_SIM_RESULTS->{"depVars"}{$deviceName}{$depVarName}{$refIndVarKey};
                    }

                    my $comparisonResult=" FAIL";
                    # The test fails if the absolute tolerance is also exceeded.
                    if( abs(eval($testRe) - eval($refRe)) > $abs_tol ||  abs(eval($testIm) - eval($refIm)) > $abs_tol)
                    {
                        $fail=1;
                        $passFail{"$ref_simulator|$test_simulator"}="FAIL";
                    }
                    else
                    {
                        $comparisonResult="WATCH";
                    }
                    $log = $log . "          ${comparisonResult}: Reference($ref_simulator)=$refValue Test($test_simulator)=$testValue   Diff: " . sprintf("%8.3g", $value) . "% exceeds tolerance at $location\n";

                } # if ($value > $tolerance{$activeCompare})
            } # if ($activeCompare)

            if ($value  > $maximum)
            {
                $maximum = $value;
            }
            if ($value  < $minimum)
            {
                $minimum = $value;
            }
            $nrOfValues += 1;

            } # foreach my $indVarKey

            if (($fail == 0) && ($activeCompare)) 
            {
                $log = $log . "           pass!  Variable $paramName within tolerance\n";
                if ($passFail{"$ref_simulator|$test_simulator"} ne "FAIL") 
                    {$passFail{"$ref_simulator|$test_simulator"} = "PASS";}
            }
            $statistics = $statistics . "$log";
            $statistics = $statistics . "           maximum relative difference($paramName) = " . sprintf("%8.3g", $maximum) . " %\n";
            $statistics = $statistics . "           mean relative difference($paramName)    = " . sprintf("%8.3g", $sum/$nrOfValues) . " %\n";
            $statistics = $statistics . "           minimum relative difference($paramName) = " . sprintf("%8.3g", $minimum) . " %\n\n";
            $log = "";

        } # foreach my $depVarName
    } # foreach my $deviceName

    foreach my $checkParam (keys %tolerance)
    {
        my $paramUsed=0;
        foreach my $testedParam (@testedParams)
        {
           if ($testedParam eq $checkParam) {$paramUsed=1}
        }
        if (! $paramUsed)
        {
           $statistics = $statistics . "Parameter $checkParam not tested! Parameter unavailable.\nAvailable parameters: " . join(", ", @availableParams) . "\n";
           $warnings .= "WARNING: Parameter $checkParam not tested!\n";
           if ($passFail{"$ref_simulator|$test_simulator"} eq 'PASS') {$passFail{"$ref_simulator|$test_simulator"} = 'WARN';}
        }
    }

    if (! $passFail{"$ref_simulator|$test_simulator"})
    {
        $passFail{"$ref_simulator|$test_simulator"} = 'no test';
        $warnings .= "WARNING:  No tests were performed.  All tolerance parameters undefined or set to zero.\nAvailable parameters: " . join(", ", @availableParams) . "\n";
    }
    $output_to_file .= "\n------------------------------------------------------------------------------------\n$modelName status for $test_simulator vs. $ref_simulator:" . $passFail{"$ref_simulator|$test_simulator"} . "\n\n" . $warnings . $statistics . "\n\n------------------------------------------------------------------------------------\n";
    $statistics = "";
    $warnings = "";

    } # foreach my $test_simulator (@simulators)
    } # while ($simulators[1])

    my $outputFileName = "$projectName.stat"; 
    if (open(OUTPUT,">$outputFileName"))
    {
        print OUTPUT $output_to_file;
        close OUTPUT;
    } else
    {
        warn  "ERROR: Cannot create $outputFileName!\n";
    } 

    if (open (OUTFILE, ">> $resultHtmlFile"))
    {
        print OUTFILE "<tr>\n<td>$testName</td><td>$modelName</td><td>$testType</td>";
        if (($passFail{"ads|hspice"}) || ($passFail{"hspice|ads"}))
        {
            if (($passFail{"ads|hspice"}) && ($passFail{"hspice|ads"})) 
            {
            warn "ERROR: simulation results verified twice! \$passFail{\"ads|hspice\"}=" . $passFail{"ads|hspice"}. "  \$passFail{\"hspice|ads\"}=" . $passFail{"hspice|ads"}. "\n\n";
            print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"ads|hspice"}) && (! $passFail{"hspice|ads"})) { $simulatorTest="ads|hspice";}
                else {$simulatorTest="hspice|ads";}

                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest}</font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
            print OUTFILE "<td>n/a</td>\n";
        }

        if (($passFail{"ads|spectre"}) || ($passFail{"spectre|ads"}))
        {
            if (($passFail{"ads|spectre"}) && ($passFail{"spectre|ads"})) 
            {   
                warn "ERROR: simulation results verified twice! \$passFail{\"ads|spectre\"}=" . $passFail{"ads|spectre"}. "  \$passFail{\"spectre|ads\"}=" . $passFail{"spectre|ads"}. "\n\n";
                print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"ads|spectre"}) && (! $passFail{"spectre|ads"})) { $simulatorTest="ads|spectre";}
                else {$simulatorTest="spectre|ads";}
                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest}</font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
            print OUTFILE "<td>n/a</td>\n";
        }

        if (($passFail{"spectre|hspice"}) || ($passFail{"hspice|spectre"}))
        {
            if (($passFail{"spectre|hspice"}) && ($passFail{"hspice|spectre"})) 
            {   
                warn "ERROR: simulation results verified twice! \$passFail{\"spectre|hspice\"}=" . $passFail{"spectre|hspice"}. "  \$passFail{\"hspice|spectre\"}=" . $passFail{"hspice|spectre"}. "\n\n";
                print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"spectre|hspice"}) && (! $passFail{"hspice|spectre"})) { $simulatorTest="spectre|hspice";}
                else {$simulatorTest="hspice|spectre";}
                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest} </font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
            print OUTFILE "<td>n/a</td>\n";
        }
        print OUTFILE "<td><A HREF=\"$projectName.ds\">$projectName.ds</a></td>\n</tr>\n";
        close OUTFILE;
    } else
    {
        warn "ERROR: Cannot append $resultHtmlFile!\n";
    }

    my $returnVal="";
    foreach my $simulatorTest (reverse keys %passFail)
    {
        $returnVal .= "$simulatorTest:$passFail{$simulatorTest}  ";
    }
    return "$returnVal\n";

} # sub compareResults


#############################################################################
# delete files specified.
#
# usage
# deleteFiles(filePrefix, deleteList, status);
#
# where deleteList is a string containing one or more of the following 
#  l = all log files (.log) generated
#  n = all netlist files (.ckt .hsp .scs) generated
#  r = all results files (.rad .rhs .rsp/) generated
#  c = all citifiles (.cti) generated
#  o = other files (.st0 .ic .ic0) generated
#  d = all datasets (.ds) generated
#  s = all stat files (.stat) generated
#  p = apply deletions only to tests that all pass

sub deleteFiles
{
#    my $self=shift;
    my $fileName=shift;
    my $deleteList=shift;
    my $status=shift;
    if ( ($deleteList =~ /p/) && (($status =~ "FAIL") || ($status =~ "no test") || ($status =~ "WARN"))  )
    { 
        # save files!
    }
    else
    {
        if ($deleteList =~ /n/) 
        {
           unlink "$fileName\.ckt", "$fileName\.hsp", "$fileName\.scs";
    }
        if ($deleteList =~ /r/) 
        {
           unlink "$fileName\.rad", "$fileName\.rhs";
           if (-e "$fileName\.rsp") {`rm -r $fileName\.rsp`;}
           if (-e "$fileName\.rsp.prev") {`rm -r $fileName\.rsp.prev`;}
    }
        if ($deleteList =~ /l/) 
        {
           unlink glob("$fileName*.log");
    }
        if ($deleteList =~ /c/) 
        {
           unlink "$fileName\.cti", glob("$fileName*.cti");
    }
        if ($deleteList =~ /o/) 
        {
           unlink "$fileName\.ic", "$fileName\.st0", "$fileName\.ic0";
    }
        if ($deleteList =~ /d/) 
        {
           unlink "$fileName\.ds";
    }
        if ($deleteList =~ /s/) 
        {
           unlink "$fileName\.stat";
    }
    }
}



#############################################################################
# print frequency information.  Calculates the gate delay and fundamental frequency
#   of a node voltage by clocking each time the signal crosses the trigger voltage.  For
#   use with Transient analysis only.  Designed for use with digital signals. 
#   Start is the time to start the measurements;
#
# usage 
# my $datastring = $handle->ringOscResults(projectName, testName, htmlfilename, simulators, node, triggerVoltage, edge, triggerSkip, numberGates, abs_tol, periodTolerence);
#
#  for edge use 0 = neg, 1 = pos for the triggering
#  triggerSkip is the number of edges to ignore from first time point.

sub ringOscResults
{
    my $self = shift;
    my $projectName = shift;
    my $testName = shift;
    my $resultHtmlFile = shift;
    my $simulators = shift;
    my $node = shift;
    my $trigger = shift;
    my $triggerEdge = shift;
    my $triggerSkip = shift;
    my $numGates = shift;
    my $abs_tol = shift;
    my $tolerance = shift;
    my $statistics = "";
    my $log = "";
    my $output_to_file = "";
    my @posEdge=();
    my @negEdge=();
    my %passFail= ();
    my %gateDelay= ();

    if ($Debugging) {print "...comparing Ring oscillator results\n"};
    my @indVarNames=();

    my $depVarName='v';
    my $timeIndex=-1;
    my $periodSum=0;
    my $periodCount=0;
    my $widthSum=0;
    my $numEdges=0;


    my @simulators = split /\s*,\s*/,$simulators;
    my %comparisonResults = ();
    my $TEST_SIM_RESULTS;
    my @voltages=();
 
    foreach my $test_simulator (@simulators)
    {
    $log = "";
        $TEST_SIM_RESULTS=dKitResults->getResults($projectName,$test_simulator);
        if (! ref $TEST_SIM_RESULTS)
        {
        $output_to_file .= "\n------------------------------------------------------------------------------------\nstatus for $test_simulator\n\n" . "SIMULATION ERROR:  Results not available for $test_simulator!\n\n------------------------------------------------------------------------------------\n";
                next;
        }

        foreach my $indVariable (keys %{$TEST_SIM_RESULTS->{"indVars"}})
        {
            @indVarNames = (@indVarNames, $indVariable);
        if ($indVariable eq "time") {$timeIndex = $#indVarNames;}
        }
$timeIndex = 0;
        if ($timeIndex == -1)
    {
        print "Unable to find time variable for $test_simulator!";
        $output_to_file .= "\n------------------------------------------------------------------------------------\nstatus for $test_simulator\n\n" . "ERROR:  Unable to find the independent variable time for $test_simulator!\n\n------------------------------------------------------------------------------------\n";
        next;
    }
    @voltages=();
        foreach my $indVarKey (keys %{$TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}})
        {
            my @sweeps=split ",", $indVarKey;
        if (ref $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey})
            {  ## complex use magnitude...
            $voltages[$indVarKey] = $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey}[0] * $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey}[0];
            $voltages[$indVarKey] += $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey}[1] * $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey}[1];
            $voltages[$indVarKey] = sqrt($voltages[$indVarKey]);
            } else
        {
                $voltages[$sweeps[$timeIndex]] =  $TEST_SIM_RESULTS->{"depVars"}{$node}{$depVarName}{$indVarKey};
 #       $log .=  "$test_simulator key=$indVarKey timePT=$sweeps[$timeIndex] volts=$voltages[$sweeps[$timeIndex]] \n";
        }
        }
        if ($Debugging) {print "index = $timeIndex   Number of points=$#voltages\n";}
        foreach my $timePtIndex (0..$#voltages-1)
        {
        if (($voltages[$timePtIndex] > $trigger) && ($voltages[$timePtIndex+1] < $trigger))
            {
                @negEdge=(@negEdge,$timePtIndex);
                my $tpt=$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[$timePtIndex];
                $log .= "negative edge at time $tpt index $timePtIndex  before = $voltages[$timePtIndex]    after = $voltages[$timePtIndex+1]\n";
            } elsif (($voltages[$timePtIndex] < $trigger) && ($voltages[$timePtIndex+1] > $trigger))
            {
                @posEdge=(@posEdge,$timePtIndex);
                my $tpt=$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[$timePtIndex];
                $log .= "positive edge at time $tpt index $timePtIndex   before = $voltages[$timePtIndex]    after = $voltages[$timePtIndex+1]\n";
            }
        }
    
        $periodSum=0;
        $periodCount=0;
        $widthSum=0;
        $numEdges=0;
        if ($triggerEdge)
        {
           $numEdges = $#posEdge + 1 - $triggerSkip;
           foreach my $posEdgePtIdx ($triggerSkip..($#posEdge-1))
           {
                my $period=$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@posEdge[$posEdgePtIdx+1]]-$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@posEdge[$posEdgePtIdx]];
                if ($Debugging) {print "Positive edge period #" . $posEdgePtIdx . ":  $period\n";}
                $periodSum+=$period;
                $periodCount++;
           }
        } else
        {
           $numEdges = $#negEdge + 1 - $triggerSkip;
           foreach my $negEdgePtIdx ($triggerSkip..($#negEdge-1))
           {
                my $period=$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@negEdge[$negEdgePtIdx+1]]-$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@negEdge[$negEdgePtIdx]];
                if ($Debugging) {print "Negative edge period #" . $negEdgePtIdx . ":  $period\n";}
                $periodSum+=$period;
                $periodCount++;
           }
        }
    
        if ($periodCount > 0) {
            foreach my $edgePtIdx (0..($numEdges-1))
            {
               $widthSum+=$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@negEdge[$edgePtIdx]]-$TEST_SIM_RESULTS->{"indVars"}{'time'}{'values'}[@posEdge[$edgePtIdx]];
            }
        if (! $numGates) {$numGates = 1;}
        my $avgPeriod=$periodSum/($periodCount);
        $gateDelay{"$test_simulator"} = $avgPeriod/$numGates;
        $statistics = $statistics . " Average Period = " . $avgPeriod . "\n";
        $statistics = $statistics . " Average Gate Delay = " . $gateDelay{"$test_simulator"} . "\n";
            $statistics = $statistics . " Average Width = " . abs($widthSum)/($numEdges) . "\n";
        }  else
        { 
        $gateDelay{"$test_simulator"} = "n/a";
        $statistics = $statistics . "Not enough periods to calculate frequency information\n  Possible causes:  Transient stop time too short\n                    Trigger voltage not found in the waveform\n                    Parameter sweep used.\n\n";
        }
    $output_to_file .= "\n------------------------------------------------------------------------------------\nResult details for $test_simulator \n\n" . $statistics . "\n\n" . $log . "\n\n------------------------------------------------------------------------------------\n";
        $statistics = "";
    $log = "";
        @posEdge=();
        @negEdge=();
    }

#  PASS/FAIL comparison
    my $comparisonResults = "";
    while ($simulators[1])
    {

       my $ref_simulator = shift @simulators;
       my $REF_SIM_RESULTS = $gateDelay{"$ref_simulator"};

       foreach my $test_simulator (@simulators)
       {
           my $TEST_SIM_RESULTS = $gateDelay{"$test_simulator"};
       if ((! defined $REF_SIM_RESULTS) || (! defined $TEST_SIM_RESULTS))
           {
                $passFail{"$ref_simulator|$test_simulator"} = 'SIM_FAIL';
                $comparisonResults .= "\n------------------------------------------------------------------------------------\nRing Oscillator status for $test_simulator vs. $ref_simulator:" . $passFail{"$ref_simulator|$test_simulator"} . "\n\n" . "SIMULATION ERROR:  Results not available for comparison between $ref_simulator and $test_simulator!\n\n------------------------------------------------------------------------------------\n";
                next;

           }
    
           if (($REF_SIM_RESULTS eq "n/a") || ($TEST_SIM_RESULTS eq "n/a"))
           {
                $passFail{"$ref_simulator|$test_simulator"} = 'no test';
                $comparisonResults .= "\n------------------------------------------------------------------------------------\nRing Oscillator status for $test_simulator vs. $ref_simulator:" . $passFail{"$ref_simulator|$test_simulator"} . "\n\n" . "ERROR:  Results not available for comparison between $ref_simulator and $test_simulator due to insufficient results!\n  Pleae increase the time for the analysis so that at least two periods of the oscillation occur.\n\n------------------------------------------------------------------------------------\n";
                next;

           }
        

 
           print "reference= $ref_simulator   test=$test_simulator\n";
       my $delta = 0;
       if ($REF_SIM_RESULTS != 0)
       {
          $delta = 100 * abs(($REF_SIM_RESULTS - $TEST_SIM_RESULTS) / $REF_SIM_RESULTS);
       } elsif ($TEST_SIM_RESULTS != 0) 
       {
          $delta = 100 * abs(($REF_SIM_RESULTS - $TEST_SIM_RESULTS) / $TEST_SIM_RESULTS);
       }
       if ($delta < $tolerance)
       {
        # PASS!
           $passFail{"$ref_simulator|$test_simulator"}="PASS";
       } else
       {
           if (abs($REF_SIM_RESULTS - $TEST_SIM_RESULTS) > $abs_tol)
           {
               # FAIL!
               $passFail{"$ref_simulator|$test_simulator"}="FAIL";
           } else
           {
               # Relative tolerance exceeded, but within absolute toerance.
               $passFail{"$ref_simulator|$test_simulator"}="OK";
           }
       }
           $comparisonResults .= "\n------------------------------------------------------------------------------------\nRing oscillator status for $test_simulator vs. $ref_simulator:" . $passFail{"$ref_simulator|$test_simulator"} . "\n\n Relative difference of $delta % compared with relative tolerance of ${tolerance}% and absolute tolerance of $abs_tol.\n Average gate dalay for $ref_simulator = $REF_SIM_RESULTS\n Average gate dalay for $test_simulator = $TEST_SIM_RESULTS\n" . $statistics . "\n\n------------------------------------------------------------------------------------\n";
       }

    }

    my $outputFileName = "$projectName.stat";
    if (open(OUTPUT,">$outputFileName"))
    {
        print OUTPUT $comparisonResults . $output_to_file;
        close OUTPUT;
    } else
    {
        warn  "ERROR: Cannot create $outputFileName!\n";
    }
    if (open (OUTFILE, ">> $resultHtmlFile"))
    {
        print OUTFILE "<tr>\n<td>$testName</td><td>$testName</td><td>Ring Oscillator</td>";
        if (($passFail{"ads|hspice"}) || ($passFail{"hspice|ads"}))
        {
            if (($passFail{"ads|hspice"}) && ($passFail{"hspice|ads"}))
            {
                warn "ERROR: simulation results verified twice! \$passFail{\"ads|hspice\"}=" . $passFail{"ads|hspice"}. "  \$passFail{\"hspice|ads\"}=" . $passFail{"hspice|ads"}. "\n\n";
                print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"ads|hspice"}) && (! $passFail{"hspice|ads"})) { $simulatorTest="ads|hspice";}
                else {$simulatorTest="hspice|ads";}
                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest}</font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
                print OUTFILE "<td>n/a</td>\n";
        }

        if (($passFail{"ads|spectre"}) || ($passFail{"spectre|ads"}))
        {
            if (($passFail{"ads|spectre"}) && ($passFail{"spectre|ads"}))
            {
                warn "ERROR: simulation results verified twice! \$passFail{\"ads|spectre\"}=" . $passFail{"ads|spectre"}. "  \$passFail{\"spectre|ads\"}=" . $passFail{"spectre|ads"}. "\n\n";
                print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"ads|spectre"}) && (! $passFail{"spectre|ads"})) { $simulatorTest="ads|spectre";}
                else {$simulatorTest="spectre|ads";}
                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest}</font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
                print OUTFILE "<td>n/a</td>\n";
        }

        if (($passFail{"spectre|hspice"}) || ($passFail{"hspice|spectre"}))
        {
            if (($passFail{"spectre|hspice"}) && ($passFail{"hspice|spectre"}))
            {  
                warn "ERROR: simulation results verified twice! \$passFail{\"spectre|hspice\"}=" . $passFail{"spectre|hspice"}. "  \$passFail{\"hspice|spectre\"}=" . $passFail{"hspice|spectre"}. "\n\n";
                print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>Internal ERROR</font></A></td>\n";
            } else
            {
                my $simulatorTest="";
                if (($passFail{"spectre|hspice"}) && (! $passFail{"hspice|spectre"})) { $simulatorTest="spectre|hspice";}
                else {$simulatorTest="hspice|spectre";}
                if ($passFail{$simulatorTest} eq "PASS") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=green>$passFail{$simulatorTest} </font></A></td>";}
                elsif ($passFail{$simulatorTest} eq "WARN") {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=yellow>$passFail{$simulatorTest}</font></A></td>\n";}
                elsif ($passFail{$simulatorTest} eq "no test") {print OUTFILE "<td><A HREF=\"$projectName.stat\">$passFail{$simulatorTest}</A></td>\n";}
                elsif ($passFail{$simulatorTest}) {print OUTFILE "<td><A HREF=\"$projectName.stat\"><font color=red>$passFail{$simulatorTest}</font></A></td>\n";}
                else {print OUTFILE "<td>Internal ERROR/a</td>\n";}
            }
        } else
        {
                print OUTFILE "<td>n/a</td>\n";
        }
        print OUTFILE "<td><A HREF=\"$projectName.ds\">$projectName.ds</a></td>\n</tr>\n";
        close OUTFILE;
    } else
    {
        warn "ERROR: Cannot append $resultHtmlFile!\n";
    }


    my $returnVal="";
    foreach my $simulatorTest (reverse keys %passFail)
    {
        $returnVal .= "$simulatorTest:$passFail{$simulatorTest} ";
    }
    print "Hi!!! $returnVal";
    return "$returnVal\n";

}

1

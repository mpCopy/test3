package dKitResults;

use strict;
use Carp;

use dKitGemx;
use dKitParameter;
#use Data::Dumper;
############################################################################
####
##    Versioning stuff
#
my $VERSION = 2.0;

sub version
{
    return $VERSION;
}
#to be able to use perl versioning
$dKitResults::VERSION = $VERSION;

############################################################################
####
##    some macro definitions
#

# real $1 has real number, up to $5 hold subdata
my $real = "([+-]?)(?=\\d|\\.\\d)\\d*(\\.\\d*)?([Ee]([+-]?\\d+))?";

# complex $1 has complex number, $2 has real part, $7 has imag part
my $complex = "\\(\\s*($real)\\s*,\\s*($real)\\s*\\)";

my $scaleFactors = 'fpnumkxg';
my %convertScale = (
      'f' => 'e-15', 
      'p' => 'e-12',
      'n' => 'e-9',
      'u' => 'e-6',
      'm' => 'e-3',
      'k' => 'e3',
      'x' => 'e6',
      'g' => 'e9'
      );

my %resultsDatabase = ();

my $Debugging = 0;


##### resultsuffixes ....

my %resultSuffix =
(
    'spectre' => ".rsp",
    'ads' => ".rad",
    'hspice' => ".rhs",
    'citi' => ".rct",
    'dataset' => ".ds"
);

###########################################################################
#
# class method : resultSuffix
# purpose : set/get resultsuffix for dialects
# call vocabulary
#
# dKitResult->resultSuffix("dialect" [,"suffix"]);
#

sub resultSuffix($$)
{

    my $self = shift;
    my $dialect = shift;

    unless (@_ < 2) { confess "usage : dKitResults->resultSuffix(dialect, [suffix]" }

    if (@_ == 1)
    {
        my $suffix = shift;
	$resultSuffix{$dialect} = $suffix
    }
    return $resultSuffix{$dialect};
}

my %sweepVariableNormalizationTable = ();

###############################################################################
#
# sweepVariableOffset
# sets the offset of indirect variables (swept variable)
#
###############################################################################

sub sweepVariableOffset
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "sweepVariableOffset: class method called as object method";
    }
    if ($self ne "dKitResults" || ! @_)
    {
	confess "Usage: [offset =] dKitResults->sweepVariableOffset('sweepVariable', 'dialect' [, 'value']);";
    }
    my $varName = shift;
    if (! @_)
    {
	confess "Usage: [offset =] dKitResults->sweepVariableOffset('sweepVariable', 'dialect' [, 'offsetValue']);";
    }
    my $dialect = shift;
    if (@_) 
    {
        my $offset = shift;
	$sweepVariableNormalizationTable{$varName}{$dialect}{'offset'} = $offset;
	return $offset;
    }
    if (! defined($sweepVariableNormalizationTable{$varName}{$dialect}{'offset'}))
    {
	return 0;
    }
    return $sweepVariableNormalizationTable{$varName}{$dialect}{'offset'};
}

###############################################################################
#
# sweepVariableScale
# sets the scale of an indirect variable (swept variable)
#
###############################################################################

sub sweepVariableScale
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "sweepVariableScale: class method called as object method";
    }
    if ($self ne "dKitResults" || ! @_)
    {
	confess "Usage: [scale =] dKitResults->sweepVariableScale('sweepVariable', 'dialect' [, 'scaleValue']);";
    }
    my $varName = shift;
    if (! @_)
    {
	confess "Usage: scale = dKitResults->sweepVariableScale('sweepVariable', 'dialect' [, 'scaleValue']);";
    }
    my $dialect = shift;
    if (@_) 
    {
	my $scale = shift;
	$sweepVariableNormalizationTable{$dialect}{$varName}{'scale'} = $scale;
	return $scale;
    }
    if (! defined($sweepVariableNormalizationTable{$varName}{$dialect}{'scale'}))
    {
	return 1.0;
    }
    return $sweepVariableNormalizationTable{$dialect}{$varName}{'scale'};
}

###############################################################################
#
# normalize
# normalizes the variables
#
###############################################################################

sub normalizeSweepVariables
{
    my $self = shift;
    my $dialect = shift;

    if (defined $sweepVariableNormalizationTable{$dialect})
    {
	foreach my $indVarName ( keys %{ $self->{"indVars"} })
	{
	    if (defined $sweepVariableNormalizationTable{$dialect}{$indVarName})
	    {
		my $scale = 1.0;
                my $offset = 0;
		if (defined $sweepVariableNormalizationTable{$dialect}{$indVarName}{'offset'})
		{
		    $offset = $sweepVariableNormalizationTable{$dialect}{$indVarName}{'offset'};
		}
		if (defined $sweepVariableNormalizationTable{$dialect}{$indVarName}{'scale'})
		{
		    $scale = $sweepVariableNormalizationTable{$dialect}{$indVarName}{'scale'};
		}
		my @newValues =();
		foreach my $value (@{$self->{"indVars"}{$indVarName}{"values"}})
		{
		    push(@newValues, $value * $scale + $offset);
		}
		@{$self->{"indVars"}{$indVarName}{"values"}} = @newValues;
	    }
	}
    }
    return $self;
}



###############################################################################
#
# getResults
# get the results of a simulation / first look whether they are in the database
#
###############################################################################

sub getResults
{
    my $self = shift;
    my $projectName = shift;
    my $dialect = shift;

    if (!$resultsDatabase{$projectName}{$dialect})
    {
        if (! dKitResults->readData($projectName, $dialect)) 
        {
            print "ERROR: Unable to read $dialect data for $projectName\n";
            return;
        }
    }
    return ($resultsDatabase{$projectName}{$dialect});
}

###############################################################################
#
# freeMemory
# get the results of a simulation / first look whether they are in the databasf# free the memory occupied by the results
#
###############################################################################

sub freeMemory
{
    my $self = shift;
    my $projectName = shift;
    if (! $projectName)
    {
	croak("usage : \$dKitResults->freeMemory(projectName[, dialect]);");
	return;
    }
    if ($_)
    {
	my $dialect = shift;

	if ($resultsDatabase{$projectName}{$dialect})
	{
	    delete ($resultsDatabase{$projectName}{$dialect});
	}
    } else
    {
	if ($resultsDatabase{$projectName})
	{
	    foreach my $dialect (keys %{$resultsDatabase{$projectName}})
	    {
		delete ($resultsDatabase{$projectName}{$dialect});
	    }
	}
    }
}

###############################################################################
#
# convertCitifile2Dataset
# create a dataset - with flattened path - from the given citifile
#
###############################################################################

sub convertCitifile2Dataset($;$)
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "class method called as object method";
    }

    if (@_)
    {
	my $citiFile = shift;
	my $dialect = shift;
        my $intermediateFile;
        if (! $dialect)
        {
	    $intermediateFile = "sim.cti"
	} else
        {
	    $intermediateFile = $dialect . ".cti"
	} 

 	my $dataset = $citiFile;

        $dataset =~ s/\//_/g;
        $dataset =~ s/^\._//g;

### remove .cti extension
        $dataset =~ s/\.cti$//g;

        $dataset = $dataset . $resultSuffix{'dataset'};

	print "creating dataset $dataset\n";

    # strip blank spaces
    for($citiFile) {
      s/^\s+//;
      s/\s+$//;
    }
	if (rename($citiFile, $intermediateFile))
        {
	    dKitGemx->cti2ds($intermediateFile, $dataset);
	    rename($intermediateFile, $citiFile);
	} else
        {
	    print "Warning : rename failed, dataset will have $citiFile as set name instead of $intermediateFile\n";
	    dKitGemx->cti2ds($citiFile, $dataset);
	}

    # If DKIT_DATASET_DIR is set in the environment, create symbolic link to the .ds file.
    if ($ENV{'DKIT_DATASET_DIR'})
    {
        my $targetDir=$ENV{'DKIT_DATASET_DIR'};
        chomp(my $sourceDir=`pwd`);
        if( !(-d ${targetDir} && -w ${targetDir}) ) 
        {
            print "Warning: DKIT_DATASET_DIR (${targetDir}) is not a writable directory\n";

        }
        elsif( ${sourceDir} ne ${targetDir} ) 
        {
            my $linkOfDataset="${targetDir}/${dataset}";
            if( -f $linkOfDataset ) 
            { 
                unlink("$linkOfDataset");
            }
            symlink("${sourceDir}/${dataset}", $linkOfDataset);
        }
    }

    }
##### OK
    return 0; 
}


###############################################################################
#
# mergeProjectCitifiles
# the project citi result files to one citi file
#
###############################################################################

sub mergeProjectCitifiles($@)
{
    my $self = shift;
    if (ref $self) { confess "class method called as object method";}
    if (@_)
    {
	my $projectName = shift;
 	my @dialects = @_;
	my $citiFileName = $projectName . ".cti";

	#--- open the results data file ---
	if (!open(CITI_OUTFILE, ">$citiFileName"))
	{
	    print "ERROR: Cannot open results CITI file $citiFileName!\n"; return;
	}

	foreach my $dialect (@dialects)
	{
	    my $inputFileName = $projectName . "_" . $dialect . ".cti";
	    if (!open(CITI_INFILE, "<$inputFileName"))
	    {
		print "WARNING: file $inputFileName will be skipped in citifile merge because it cannot be openend!\n";
	    } else
            {
		print "reading file $inputFileName\n";
		my @myLines = <CITI_INFILE>;
		close(CITI_INFILE);
		print CITI_OUTFILE @myLines;
		if (! $Debugging)
                {
		    unlink($inputFileName);
		}
	    }
	}
	close(CITI_OUTFILE);
    }
##### error
    return 1; 
}

###############################################################################
#
# mergeCitifiles
# merge citifiles to one file
#
# call vocabulary
#    dKitResults->mergeCitiFiles(resultFileName, inputFileNames)
#
###############################################################################

sub mergeCitifiles($@)
{
    my $self = shift;
    if (ref $self) { confess "class method called as object method";}
    if (@_)
    {
	my $citiFileName = shift;
 	my @inputFiles = @_;

	#--- open the results data file ---
	if (!open(CITI_OUTFILE, ">$citiFileName"))
	{
	    print "ERROR: Cannot open results CITI file $citiFileName!\n"; return;
	}

	foreach my $inputFileName (@inputFiles)
	{
	    if (!open(CITI_INFILE, "<$inputFileName"))
	    {
		print "WARNING: file $inputFileName will be skipped in citifile merge because it cannot be openend!\n";
	    } else
            {
#		print "reading file $inputFileName\n";
		my @myLines = <CITI_INFILE>;
		close(CITI_INFILE);
		print CITI_OUTFILE @myLines;
	    }
	}
	close(CITI_OUTFILE);
    }
##### error
    return 1; 
}

###############################################################################
#
# data2citi
# convert the simulation results to citi file
#
###############################################################################

sub data2citi($$;$)
{
    my $self = shift;
    if (ref $self) { confess "class method called as object method";}
    if (@_)
    {
	my $projectName = shift;
 	my $dialect = shift;
 	my $citiFileName = shift;
	if (! $citiFileName)
        {
	    $citiFileName = $projectName . "_" . $dialect . ".cti";
	}

	my $result = dKitResults->readData($projectName, $dialect);
	if ($result)
	{
	    return $result->writeCitifile($citiFileName, $dialect);
	}
    }
##### error
    return 1; 
}


###############################################################################
#
# readData
# read the simulation data
#
###############################################################################

sub readData($$)
{
    my $self = shift;
    my $projectName = shift;
    my $dialect = shift;
    my $resultDataP = 0;

    my $results = $projectName . $resultSuffix{$dialect};
    if ($dialect eq "spectre")
    {
	$resultDataP = readSpectreData($results);
        if (!$resultDataP)
        {
           print "ERROR:  Spectre data not available\n"; return;
        }
	$resultDataP->markUniformData($dialect);
    } elsif ($dialect eq "ads")
    {
	$resultDataP = readAdsData($results);
        if (!$resultDataP)
        {
           print "ERROR:  ADS data not available\n"; return;
        }
	$resultDataP->markUniformData($dialect);
    } elsif ($dialect eq "hspice")
    {
	$resultDataP = readHspiceData($results); 
        if (!$resultDataP)
        {
           print "ERROR:  HSpice data not available\n"; return;
        }
	$resultDataP->markUniformData($dialect);
    } elsif ($dialect eq "citi")
    {
	$resultDataP = readCitiData($results);
        if (!$resultDataP)
        {
           print "ERROR:  Citi data not available\n"; return;
        }
	$resultDataP->markUniformData($dialect);
    } else
    {
	print "Dialect $dialect not implemented in dKitResults->readData()";
        return;
    }

    $resultDataP->normalizeSweepVariables($dialect);

    # save data for further reference
    $resultsDatabase{$projectName}{$dialect} = $resultDataP;

    return $resultDataP;
}

###############################################################################
#
# writeCitifile
#
###############################################################################

sub writeCitifile($;$)
{
    my $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }

    (my $citiFileName, my $citiName) = @_;

    if (!$citiName)
    {
	($citiName) = ($citiFileName =~ /(.*)\.cti$/);
    }
    
    my $date;
    my $index;

    my (@indVarNames, $indVarName, @indVarValues, $nrOfSweepVariableValues);
    my ($deviceName, $depVarName, $depVarValuesP);

 
    if ($Debugging)
    {
	print "...writing CITI file $citiFileName\n";
    }
    #--- open the results data file ---
    if (!open(CITI_FILE, ">$citiFileName"))
    {
	print "ERROR: Cannot open results CITI file $citiFileName!\n"; return;
    }

    my $errorOccured = 0;
    $resultDataP->{OPEN_FILE_WRITE} = \*CITI_FILE;

    #--- write header ---
    $date = gmtime;
    printf CITI_FILE "\n\nCITIFILE A.01.00\n";
    printf CITI_FILE "NAME %s\n", $citiName;
    
    #--- write independent variable header ---
    # just write them the way they were created  ....
    
    if (! defined $resultDataP->{"indVarWriteOrder"})
    {
	if (! defined $resultDataP->{"indVarCreateOrder"})
	{
	    $resultDataP->{OPEN_FILE_WRITE} = 0;
	    close(CITI_FILE);
	    unlink($citiFileName);
	    print "ERROR: empty CITI file $citiFileName. Deleted!\n";
	    return 1;
	}
	@indVarNames = @{$resultDataP->{"indVarCreateOrder"}};
    } elsif ($#{$resultDataP->{"indVarWriteOrder"}} < 0)
    {
	@indVarNames = @{$resultDataP->{"indVarCreateOrder"}};
    } else 
    {
	@indVarNames = @{$resultDataP->{"indVarWriteOrder"}}
    }

    $errorOccured = 1;
    foreach $indVarName (@indVarNames)
    {
	$nrOfSweepVariableValues = $#{$resultDataP->{"indVars"}{$indVarName}{"values"}}+1;
	if ($nrOfSweepVariableValues > 1)
	{
	    printf CITI_FILE "VAR %s MAG %d\n", $indVarName, $nrOfSweepVariableValues;
	    $errorOccured = 0;
	}
    }
    
    if ($errorOccured)
    {
	$resultDataP->{OPEN_FILE_WRITE} = 0;
	close(CITI_FILE);
	unlink($citiFileName);
	print "ERROR: empty CITI file $citiFileName. Deleted!\n";
	return 1;
    }
	
    #--- write dependent variable header ---

    $errorOccured = 1;
    foreach $deviceName (sort keys %{$resultDataP->{"depVars"}})
    {
	foreach $depVarName (sort keys %{$resultDataP->{"depVars"}{$deviceName}})
	{
	    if ($Debugging > 9)
	    {
		print "depVarName = $depVarName\n";
	    }
            my $dataName;
	    if ($deviceName eq "sParams")
	    {
		$dataName = $depVarName;
	    } else
            {
		$dataName = $deviceName . "." . $depVarName;
	    }

	    if ( defined ($resultDataP->testForUniformData($deviceName, $depVarName)))
	    {
		

		$depVarValuesP = $resultDataP->{"depVars"}{$deviceName}{$depVarName};
		my @tempArray = %{$depVarValuesP};
		if ($#tempArray > -1)
		{
		    $errorOccured = 0;
		}

		if (ref $tempArray[1])
		{
		    printf CITI_FILE "DATA %s RI\n", $dataName;
		} else
		{
		    printf CITI_FILE "DATA %s%s MAG\n", $dataName;
		}
	    }
	}
    }

    if ($errorOccured)
    {
	$resultDataP->{OPEN_FILE_WRITE} = 0;
	close(CITI_FILE);
	unlink($citiFileName);
	print "ERROR: empty CITI file $citiFileName. Deleted!\n";
	return 1;
    }

    #--- write independent variable values ---
    foreach $indVarName (@indVarNames)
    {
	$nrOfSweepVariableValues = $#{$resultDataP->{"indVars"}{$indVarName}{"values"}}+1;
	if ($nrOfSweepVariableValues > 1)
	{
	    print CITI_FILE "VAR_LIST_BEGIN\n";
	    @indVarValues = @{$resultDataP->{"indVars"}{$indVarName}{"values"}};
	    for ($index = 0; $index < $nrOfSweepVariableValues; $index++)
	    {
		if ($Debugging > 9)
		{
		    print "VAR_value = $indVarValues[$index] \n";
		}
		printf CITI_FILE "  %g\n", $indVarValues[$index];
	    }
	    print CITI_FILE "VAR_LIST_END\n";
	}
    }

    ### write dependent variables 

    foreach $deviceName (sort keys %{$resultDataP->{"depVars"}})
    {
	foreach $depVarName (sort keys %{$resultDataP->{"depVars"}{$deviceName}})
	{
	    if ($Debugging) 
	    {
		print "writing $deviceName\.$depVarName\n";
	    }

	    if ( defined ($resultDataP->testForUniformData($deviceName, $depVarName)))
	    {
		$depVarValuesP = $resultDataP->{"depVars"}{$deviceName}{$depVarName};
		print CITI_FILE "BEGIN\n";
		$resultDataP->writeCitiDataValue($depVarValuesP, \@indVarNames);
		print CITI_FILE "END\n";
	    }
	}
    }

    $resultDataP->writeMonteCitifile($citiName);

    $resultDataP->{OPEN_FILE_WRITE} = 0;
    close(CITI_FILE);

#--- return to calling function --- 
    return 0;
}

###############################################################################
#
# writeMonteCitifile
#
###############################################################################

sub writeMonteCitifile($;$)
{
    my $resultDataP = shift;
    my $citiName = @_[0];
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }
    if (! defined $resultDataP->{"monte"})
    {
	return;
    }

    my ($date, $index, $errorOccured);

    my (@indVarNames, $indVarName, @indVarValues, $nrOfSweepVariableValues);
    my ($deviceName, $depVarName, $depVarValuesP);

    if ($Debugging)
    {
	print "...writing Monte Carlo CITI file\n";
    }


#--- write header ---
    $date = gmtime;
    printf CITI_FILE "\n\nCITIFILE A.01.00\n";
    printf CITI_FILE "NAME %s\n", $citiName . "-monte";


#--- write independent variable header ---
# just write them the way they were created  ....
    if (! defined $resultDataP->{"indVarWriteOrder"})
    {
	if (! defined $resultDataP->{"indVarCreateOrder"})
	{
	    return 1;
	}
	@indVarNames = @{$resultDataP->{"indVarCreateOrder"}};
    } elsif ($#{$resultDataP->{"indVarWriteOrder"}} < 0)
    {
	@indVarNames = @{$resultDataP->{"indVarCreateOrder"}};
    } else 
    {
	@indVarNames = @{$resultDataP->{"indVarWriteOrder"}}
    }

    $errorOccured = 1;
    $indVarName = $indVarNames[0];
    $nrOfSweepVariableValues = $#{$resultDataP->{"indVars"}{$indVarName}{"values"}}+1;
    if ($nrOfSweepVariableValues > 1)
    {
        printf CITI_FILE "VAR %s MAG %d\n", $indVarName, $nrOfSweepVariableValues;
        $errorOccured = 0;
    }
    
    if ($errorOccured)
    {
	return 1;
    }


#--- write dependent variable header ---

    $errorOccured = 1;
    foreach $deviceName (sort keys %{$resultDataP->{"depVars"}})
    {
	foreach $depVarName (sort keys %{$resultDataP->{"depVars"}{$deviceName}})
	{
	    if ($Debugging > 9) 
	    {
		print "depVarName = $depVarName\n";
	    }
            my $dataName; 
	    if ($deviceName eq "sParams")
	    {
		$dataName = $depVarName;
	    } else
            {
		$dataName = $deviceName . "." . $depVarName;
	    }

	    if ( defined ($resultDataP->testForMonteData($deviceName, $depVarName)))
	    {
		$depVarValuesP = $resultDataP->{"depVars"}{$deviceName}{$depVarName};
		my @tempArray = %{$depVarValuesP};
		if ($#tempArray > -1)
		{
		    $errorOccured = 0;
		}

		if (ref $tempArray[1])
		{
		    printf CITI_FILE "DATA %s RI\n", $dataName;
		} else
		{
		    printf CITI_FILE "DATA %s%s MAG\n", $dataName;
		}
	    }
	}
    }

    if ($errorOccured)
    {
	return 1;
    }


#--- write independent variable values ---
    $indVarName = $indVarNames[0];
	$nrOfSweepVariableValues = $#{$resultDataP->{"indVars"}{$indVarName}{"values"}}+1;
	if ($nrOfSweepVariableValues > 1)
	{
	    print CITI_FILE "VAR_LIST_BEGIN\n";
	    @indVarValues = @{$resultDataP->{"indVars"}{$indVarName}{"values"}};
	    for ($index = 0; $index < $nrOfSweepVariableValues; $index++)
	    {
		if ($Debugging > 9)
		{
		    print "VAR_value = $indVarValues[$index] \n";
		}
		printf CITI_FILE "  %g\n", $indVarValues[$index];
	    }
	    print CITI_FILE "VAR_LIST_END\n";
	}


# write dependent variables 

    my @indVarNames2 = ( $indVarName );
    foreach $deviceName (sort keys %{$resultDataP->{"depVars"}})
    {
	foreach $depVarName (sort keys %{$resultDataP->{"depVars"}{$deviceName}})
	{

	    if ( defined ($resultDataP->testForMonteData($deviceName, $depVarName)))
	    {
		if ($Debugging) 
		{
		    print "writing $deviceName\.$depVarName\n";
		}
		$depVarValuesP = $resultDataP->{"depVars"}{$deviceName}{$depVarName};
		print CITI_FILE "BEGIN\n";
		$resultDataP->writeMonteDataValue($depVarValuesP, \@indVarNames2);
		print CITI_FILE "END\n";
	    }
	}
    }
  #--- return to calling function --- 
    return 0;
}


###############################################################################
#
# testForMonteData
#
###############################################################################

sub testForMonteData
{
    my ($resultDataP, @montelist, $deviceName, $depVarName, $deviceName2, $depVarName2);
    $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }
#    printf(" - testForMonteData\n");
    $deviceName = shift;
    $depVarName = shift;

    @montelist = @{$resultDataP->{"monte"}};

    while ( $#montelist > 0 )
    {
	$deviceName2 = shift @montelist;
	$depVarName2 = shift @montelist;
	if ( $deviceName eq $deviceName2 && $depVarName eq $depVarName2 )
	{
	    return 0;
	}
    }

#    printf("TEST %s  %s\n", $deviceName, $depVarName);
#    print Dumper(@montelist);
    return ;
}




###############################################################################
#
# testForUniformData
#
###############################################################################

sub testForUniformData
{
    my ($resultDataP, @uniformlist, $deviceName, $depVarName, $deviceName2, $depVarName2);
    $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }

    $deviceName = shift;
    $depVarName = shift;
    if ( ($resultDataP->{"uniform"} == undef) || ($#{$resultDataP->{"uniform"}} == 0) )
    {
	return 0;
    }

    @uniformlist = @{$resultDataP->{"uniform"}};

    while ( $#uniformlist > 0 )
    {
	$deviceName2 = shift @uniformlist;
	$depVarName2 = shift @uniformlist;
	if ( $deviceName eq $deviceName2 && $depVarName eq $depVarName2 )
	{
	    return 0;
	}
    }
    return ;
}


###############################################################################
#
# markUniformData
#
###############################################################################

sub markUniformData
{
    my($resultDataP, $indVarWriteOrderP, $depVarsP, $depVarNames, $depVarValuesP, $deviceName); 
    my (@indVarNames, $indVarName, $index, $maxIndex, $size, $outersize, $depVarName, @uniformlist, @montelist);

    $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }
    $indVarWriteOrderP = $resultDataP->{"indVarCreateOrder"};
    $depVarsP = $resultDataP->{"depVars"};

    @indVarNames = @{$indVarWriteOrderP};
# Compute size of outer loop of data
    $indVarName = $indVarNames[0];
    my $tempP = $resultDataP->{"indVars"}->{$indVarName}{"values"};
    $outersize = $#{$tempP} +1;

# Compute number of data entries for uniform variables
    if (scalar @indVarNames >=0)
    {
	$size = 1;
	for ($index = 0; $index < scalar @indVarNames; $index++)
	{
	    $indVarName = $indVarNames[$index];
	    $tempP = $resultDataP->{"indVars"}->{$indVarName}{"values"};
	    $maxIndex = $#{$tempP} + 1;
	    $size = $size * ($maxIndex);
	}
    }

# Check dependent data

    @uniformlist = ();
    @montelist = ();

    foreach $deviceName (sort keys %{$resultDataP->{"depVars"}})
    {
#        print "devices = $deviceName \n";
	NAME: foreach $depVarName (sort keys %{$resultDataP->{"depVars"}{$deviceName}})
	{
	    $depVarValuesP = $resultDataP->{"depVars"}{$deviceName}{$depVarName};
#	    print Dumper($depVarValuesP);

#	    if ( $deviceName eq "dummy" && ( $depVarName eq "yield" ||$depVarName eq "npass" ||$depVarName eq "nfail" ) )
#	    {
#		delete($resultDataP->{"depVars"}{$deviceName}{$depVarName});
#		printf("Deleting %s.%s\n", $deviceName, $depVarName);
#		next NAME;
#	    }

	    if ( $outersize == scalar keys %$depVarValuesP )
	    {
		push @montelist, $deviceName;
		push @montelist, $depVarName;
#		printf("Monte DATA %d %s %s\n", $outersize, $deviceName, $depVarName);
	    } 
#	    printf("indVarNames = %s\n", Dumper(@indVarNames));


	    if ( $size == scalar keys %$depVarValuesP )
	    {
		push @uniformlist, $deviceName;
		push @uniformlist, $depVarName;
#		printf("Uniform DATA %d %s %s\n", $outersize, $deviceName, $depVarName);
	    }
#	    print "Keeping $deviceName\.$depVarName\n";

	}
    }
    if ( ($#montelist > 0) && (${$indVarWriteOrderP}[0] eq 'iteration') )
    {
	$resultDataP->{"monte"} = \@montelist;
    }
    $resultDataP->{"uniform"} = \@uniformlist;
}


###############################################################################
#
# verifyCitiData
#
###############################################################################

sub verifyCitiData
{
    my $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }
    my $depVarValuesP = shift;
    my $indVarWriteOrderP = shift;
    my @indVarNames = @{$indVarWriteOrderP};
    my $indVarDataP = $resultDataP->{"indVars"};
    my $indVarName;
    my $index;
    my $maxIndex;
    my $size;
    my $outersize;

    $indVarName = shift(@indVarNames);
    @indVarNames = @{$indVarWriteOrderP};
    $outersize = $#{@{$indVarDataP->{$indVarName}{"values"}}} +1;

    if (scalar @indVarNames >=0)
    {
	$size = 1;
	for ($index = 0; $index <= scalar @indVarNames; $index++)
	{
	    $indVarName = shift(@indVarNames);
	    $maxIndex = $#{@{$indVarDataP->{$indVarName}{"values"}}};
	    $size = $size * ($maxIndex +1);
	}
	if ( $size == scalar keys %$depVarValuesP )
	{
	    return 0;
	}
	if ( $outersize == scalar keys %$depVarValuesP )
	{
	    return 1;
	}
    }
    printf("DO NOT OUTPUT DATA %d  %d \n", $size, scalar keys %$depVarValuesP);
    return 2;
}


###############################################################################
#
# writeCitiDataValue
#
###############################################################################

sub writeCitiDataValue
{
    my $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }

    my $depVarValuesP = shift;
    my $indVarWriteOrderP = shift;

    my @indVarNames = @{$indVarWriteOrderP};
    my $indVarDataP = $resultDataP->{"indVars"};

    my $indVarName;
    my $index;
    my $maxIndex;

    if ($#indVarNames >=0)
    {
	$indVarName = shift(@indVarNames);
	my $tempP = $indVarDataP->{$indVarName}{"values"};
	$maxIndex = $#{$tempP};
	for ($index = 0; $index <= $maxIndex; $index++)
	{
	    $indVarDataP->{$indVarName}{"index"} = $index;
	    $resultDataP->writeCitiDataValue($depVarValuesP, \@indVarNames);
	}
    }
    else
    {
	my $indVarKey = "";
	foreach $indVarName (@{$resultDataP->{"indVarCreateOrder"}})
	{
	    $index = $indVarDataP->{$indVarName}{"index"};
	    if ($indVarKey ne "") 
	    {
		$indVarKey = $indVarKey . ",";
	    }
	    $indVarKey = $indVarKey . "$index";
	}
#        print "indVarKey = $indVarKey\n";

	if (ref $depVarValuesP->{$indVarKey})
        {  ## complex
	    printf { $resultDataP->{OPEN_FILE_WRITE} } "%9.6e,\t%9.6e\n", 
	                                  $depVarValuesP->{$indVarKey}[0],
	                                  $depVarValuesP->{$indVarKey}[1];
         } else
        {  ## real
	    printf { $resultDataP->{OPEN_FILE_WRITE} } "%9.6e\n", $depVarValuesP->{$indVarKey};
	}
    }
    #--- return to calling function --- 
    return;
}

###############################################################################
#
# writeMonteDataValue
#
###############################################################################

sub writeMonteDataValue
{
    my $resultDataP = shift;
    if (! ref $resultDataP) 
    { 
	confess "Object method called as class method";
    }

    my $depVarValuesP = shift;
    my @keys = keys %{$depVarValuesP};
    my $akey = shift @keys;
    my @keylist = split(',', $akey);
    shift @keylist; # throw away first key
    my $secondKey = join(",",@keylist); # put remaining keys together
    for (my $index = 0; $index <= $#keys+1; $index++ )
    {
	my $key = "$index" . "," . "$secondKey";
	printf { $resultDataP->{OPEN_FILE_WRITE} } "%9.6e\n", $depVarValuesP->{$key};

    }
    return;
}

#############################################################################
#
# compare 2 resultdataP structures, and put differences in 3rd structure
#
# do Comparisons and return relative differences
#

sub compareDataRelative
{
    my $self = shift;
    (my $res1DataP, my $res2DataP) = @_;

    my %cmpData = {};

    my $cmpDataP = \%cmpData;
    bless($cmpDataP, "dKitResults");

    my @res2_indVarNames;
    my $res2_indVarName;
    my %res1_indVarName;
    my $res1_indVarName;
    my @res1_indVarNames;
    my $res2_deviceName;
    my %res1_deviceName;
    my $res1_deviceName;
    my @res1_deviceNames;
    my $res2_depVarName;
    my %res1_depVarName;
    my $res1_depVarName;
    my @res1_depVarNames;
    my $res2_indVarKey;
    my @res2_indVarKeys;
    my $res1_indVarKey;
    my @res1_indVarKeys;
    my $index;
    
    if ($Debugging) {print "...comparing data\n";}

    #--- check if independent variables match ---
    for my $indVarName (keys %{$res1DataP->{"indVars"}})
    {
	if ($#{$res1DataP->{"indVars"}{$indVarName}{"values"}} > 0)
	{
	    @res1_indVarNames = (@res1_indVarNames, $indVarName);
	}
    }

    for my $indVarName (keys %{$res2DataP->{"indVars"}})
    {
	if ($#{$res2DataP->{"indVars"}{$indVarName}{"values"}} > 0)
	{
	    @res2_indVarNames = (@res2_indVarNames, $indVarName);
	}
    }
    
    if ($#res2_indVarNames != $#res1_indVarNames)
    {
	print "ERROR: number of independent variables doesn't match!\n   RES2: @res2_indVarNames\n   RES1: @res1_indVarNames\n";
	return;
    }


    foreach $res2_indVarName (@res2_indVarNames)
    {
	if ($Debugging > 10) 
	{
	    print "indVar : res2.$res2_indVarName <-> ";
	}
	
	# find matching res1_indVarName;
	$res1_indVarName = "";
	for ($index = 0; $index <= $#res1_indVarNames; $index++)
	{
	    if (lc($res1_indVarNames[$index]) eq lc($res2_indVarName))
	    {
		$res1_indVarName = $res1_indVarNames[$index];
		last;
	    }
	}
	$res1_indVarName{$res2_indVarName} = $res1_indVarName;
	if ($res1_indVarName eq "")
	{
	    print "ERROR: couldn't find a matching independent variable\n"; return;
	}
	if ($Debugging) {print "res1.$res1_indVarName : OK\n";}
	
	#--- should check order of values now --- to be implemented.
    }
    if ($Debugging) {print "\n";}


    #--- check if device and dependent variables match ---
    foreach $res2_deviceName (keys %{$res2DataP->{"depVars"}})
    {
	if ($Debugging) {print "device : res2.$res2_deviceName <-> ";}
	
	# find matching res1_deviceName;
	$res1_deviceName = "";
	@res1_deviceNames = keys %{$res1DataP->{"depVars"}};
	for ($index = 0; $index <= $#res1_deviceNames; $index++)
	{
	    if (lc($res1_deviceNames[$index]) eq lc($res2_deviceName))
	    {
		$res1_deviceName = $res1_deviceNames[$index];
		last;
	    }
	}
	$res1_deviceName{$res2_deviceName} = $res1_deviceName;
	if ($res1_deviceName eq "")
	{
	    if ($Debugging) {print "couldn't find a matching device : SKIP\n"};
	    next;
	}
	if ($Debugging) {print "res1.$res1_deviceName : OK\n";}
	
	foreach $res2_depVarName (keys %{$res2DataP->{"depVars"}{$res2_deviceName}})
	{ 
	    if ($Debugging) {print "depVar : res2.$res2_deviceName.$res2_depVarName <-> ";}
	    
	    # find matching res1_deviceName;
	    $res1_depVarName = "";
	    @res1_depVarNames = keys %{$res1DataP->{"depVars"}{$res1_deviceName}};
	    for ($index = 0; $index <= $#res1_depVarNames; $index++)
	    {
		if (lc($res1_depVarNames[$index]) eq lc($res2_depVarName))
		{
		    $res1_depVarName = $res1_depVarNames[$index];
		    last;
		}
	    }
	    $res1_depVarName{$res2_deviceName}{$res2_depVarName} = $res1_depVarName;
	    if ($res1_depVarName eq "")
	    {
		if ($Debugging) {print "Couldn't find a matching depVar : SKIP\n";}
		next;
	    }
	    if ($Debugging) {print "res1.$res1_deviceName.$res1_depVarName : OK\n";}
	}
    }
    if ($Debugging) {print "\n";}
    
    #--- compare for those dependent variables that match ---
    @res1_indVarKeys = ();

    if (defined $res1DataP->{"indVarCreateOrder"})
    {
	@res1_indVarNames = @{$res1DataP->{"indVarCreateOrder"}};
    } else
    {
        @res1_indVarNames = @{$res1DataP->{"indVars"}};
    }
#    print join(",", @res1_indVarNames) . "\n";

    if (defined $res2DataP->{"indVarCreateOrder"})
    {
	@res2_indVarNames = @{$res2DataP->{"indVarCreateOrder"}};
    } else
    {
        @res2_indVarNames = @{$res2DataP->{"indVars"}};
    }

#    print join(",",@res2_indVarNames) . "\n";

    foreach (keys %{$res1DataP->{"indVars"}})
    {
	push(@res1_indVarKeys, 0);
    }
    foreach $res2_deviceName (keys %{$res2DataP->{"depVars"}})
    {
	$res1_deviceName = $res1_deviceName{$res2_deviceName};
	if ($res1_deviceName eq "")
	{
	    next;
	}
	if ($Debugging) {print "$res2_deviceName --- $res1_deviceName\n";}
	foreach $res2_depVarName (keys %{$res2DataP->{"depVars"}{$res2_deviceName}})
	{ 
	    $res1_depVarName = $res1_depVarName{$res2_deviceName}{$res2_depVarName};
	    if ($res1_depVarName eq "")
	    {
		next;
	    }
	    if ($Debugging) {print "$res2_depVarName --- $res1_depVarName\n";}
	    foreach $res2_indVarKey (keys %{$res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}})
	    {
		#print "res2_indVarKeys = ($res2_indVarKey) <-> ";
		@res2_indVarKeys = split(/,/, $res2_indVarKey);
		for (my $index2 = 0; $index2 <= $#res2_indVarNames; $index2++)
		{
		    $res2_indVarName = $res2_indVarNames[$index2];
		    $res1_indVarName = $res1_indVarName{$res2_indVarName};
		    for (my $index1 = 0; $index1 <= $#res1_indVarNames; $index1++)
		    {
			if ($res1_indVarName eq $res1_indVarNames[$index1])
			{
			    $res1_indVarKeys[$index1] = $res2_indVarKeys[$index2];
			} 
		    }
		}
		$res1_indVarKey = "";
		foreach $index (@res1_indVarKeys)
		{
		    if ($res1_indVarKey ne "") { $res1_indVarKey = $res1_indVarKey . ","; }
		    $res1_indVarKey = $res1_indVarKey . "$index";
		}
		#print "res1_indVarKey = ($res1_indVarKey)\n";
		#print "res2_indVarKey = ($res2_indVarKey)\n";
		
		if (! ref $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey})
		{
		    my $res2_value = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey};
		    my $res1_value = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey};
		    #printf "r2 = %12.9g  r1 = %12.9g\n", $res2_value, $res1_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"ads"} = $res2_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"hsp"} = $res1_value;
		    my $res_relError;
		    if ($res2_value != 0.0)
		    {
			$res_relError = 100*abs(($res2_value - $res1_value)/($res2_value));
		    }
		    elsif ($res1_value != 0.0)
		    {
			$res_relError = 100*abs(($res1_value - $res2_value)/($res1_value));
		    }
		    else
		    {
			$res_relError = 0;
		    }
		    #print "cmpData{depVars}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey} =  $res_relError\n";
		    $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey} = $res_relError;
		}
		else
		{
		    #--- real part ---
		    my $res2_value_real = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[0];
		    my $res1_value_real = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey}[0];
		    my $res2_value_imag = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[1];
		    my $res1_value_imag = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey}[1];
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"ads"}[0] = $res2_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"hsp"}[0] = $res1_value;
		    #printf "ads = %12.9g  hsp = %12.9g\n", $res2_value, $res1_value;
		    my $res_relError;
		    my $res_refMag;
                    $res_relError = ($res2_value_real - $res1_value_real) * ($res2_value_real - $res1_value_real);
                    $res_relError += ($res2_value_imag - $res1_value_imag) * ($res2_value_imag - $res1_value_imag);
                    $res_relError = 100 * sqrt($res_relError);
		    $res_refMag = sqrt($res2_value_real * $res2_value_real + $res2_value_imag * $res2_value_imag);
                    if ($res_refMag == 0.0)
                    {
			$res_refMag = sqrt($res1_value_real * $res1_value_real + $res1_value_imag * $res1_value_imag);   
		    } 
                    if ($res_refMag == 0.0)
                    {
			$res_relError = 0;
                    }
                    else
		    {
			$res_relError /= $res_refMag;
		    }
		    
		    $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey} = $res_relError;
		    
		}
	    }
	}
    }
    
    #--- build complete cmpData structure using references to adsData! ---
    if (defined $res2DataP->{"indVarWriteOrder"})
    {
	$cmpData{"indVarWriteOrder"} = $res2DataP->{"indVarWriteOrder"};
    } 
    if (defined $res2DataP->{"indVarCreateOrder"})
    {
	$cmpData{"indVarCreateOrder"} = $res2DataP->{"indVarCreateOrder"};
    } 
    $cmpData{"indVars"} = $res2DataP->{"indVars"};
    
    #--- return to calling function --- 
    return $cmpDataP;
}

#############################################################################
#
# compare 2 resultdataP structures, and put differences in 3rd structure
#
# do Comparisons and return absolute differences
#

sub compareDataAbsolute
{
    my $self = shift;
    (my $res1DataP, my $res2DataP) = @_;

    my %cmpData = {};

    my $cmpDataP = \%cmpData;
    bless($cmpDataP, "dKitResults");

    my @res2_indVarNames;
    my $res2_indVarName;
    my %res1_indVarName;
    my $res1_indVarName;
    my @res1_indVarNames;
    my $res2_deviceName;
    my %res1_deviceName;
    my $res1_deviceName;
    my @res1_deviceNames;
    my $res2_depVarName;
    my %res1_depVarName;
    my $res1_depVarName;
    my @res1_depVarNames;
    my $res2_indVarKey;
    my @res2_indVarKeys;
    my $res1_indVarKey;
    my @res1_indVarKeys;
    my $index;
    
    if ($Debugging) {print "...comparing data\n";}

    #--- check if independent variables match ---
    for my $indVarName (keys %{$res1DataP->{"indVars"}})
    {
	if ($#{$res1DataP->{"indVars"}{$indVarName}{"values"}} > 0)
	{
	    @res1_indVarNames = (@res1_indVarNames, $indVarName);
	}
    }

    for my $indVarName (keys %{$res2DataP->{"indVars"}})
    {
	if ($#{$res2DataP->{"indVars"}{$indVarName}{"values"}} > 0)
	{
	    @res2_indVarNames = (@res2_indVarNames, $indVarName);
	}
    }
    
    if ($#res2_indVarNames != $#res1_indVarNames)
    {
	print "ERROR: number of independent variables doesn't match!\n   RES2: @res2_indVarNames\n   RES1: @res1_indVarNames\n";
	return;
    }



    foreach $res2_indVarName (@res2_indVarNames)
    {
	if ($Debugging > 10) 
	{
	    print "indVar : res2.$res2_indVarName <-> ";
	}
	
	# find matching res1_indVarName;
	$res1_indVarName = "";
	for ($index = 0; $index <= $#res1_indVarNames; $index++)
	{
	    if (lc($res1_indVarNames[$index]) eq lc($res2_indVarName))
	    {
		$res1_indVarName = $res1_indVarNames[$index];
		last;
	    }
	}
	$res1_indVarName{$res2_indVarName} = $res1_indVarName;
	if ($res1_indVarName eq "")
	{
	    print "ERROR: couldn't find a matching independent variable\n"; return;
	}
	if ($Debugging) {print "res1.$res1_indVarName : OK\n";}
	
	#--- should check order of values now --- to be implemented.
    }

    if ($Debugging) {print "\n";}


    #--- check if device and dependent variables match ---
    foreach $res2_deviceName (keys %{$res2DataP->{"depVars"}})
    {
	if ($Debugging) {print "device : res2.$res2_deviceName <-> ";}
	
	# find matching res1_deviceName;
	$res1_deviceName = "";
	@res1_deviceNames = keys %{$res1DataP->{"depVars"}};
	for ($index = 0; $index <= $#res1_deviceNames; $index++)
	{
	    if (lc($res1_deviceNames[$index]) eq lc($res2_deviceName))
	    {
		$res1_deviceName = $res1_deviceNames[$index];
		last;
	    }
	}
	$res1_deviceName{$res2_deviceName} = $res1_deviceName;
	if ($res1_deviceName eq "")
	{
	    if ($Debugging) {print "couldn't find a matching device : SKIP\n"};
	    next;
	}
	if ($Debugging) {print "res1.$res1_deviceName : OK\n";}
	
	foreach $res2_depVarName (keys %{$res2DataP->{"depVars"}{$res2_deviceName}})
	{ 
	    if ($Debugging) {print "depVar : res2.$res2_deviceName.$res2_depVarName <-> ";}
	    
	    # find matching res1_deviceName;
	    $res1_depVarName = "";
	    @res1_depVarNames = keys %{$res1DataP->{"depVars"}{$res1_deviceName}};
	    for ($index = 0; $index <= $#res1_depVarNames; $index++)
	    {
		if (lc($res1_depVarNames[$index]) eq lc($res2_depVarName))
		{
		    $res1_depVarName = $res1_depVarNames[$index];
		    last;
		}
	    }
	    $res1_depVarName{$res2_deviceName}{$res2_depVarName} = $res1_depVarName;
	    if ($res1_depVarName eq "")
	    {
		if ($Debugging) {print "Couldn't find a matching depVar : SKIP\n";}
		next;
	    }
	    if ($Debugging) {print "res1.$res1_deviceName.$res1_depVarName : OK\n";}
	}
    }
    if ($Debugging) {print "\n";}
    
    #--- compare for those dependent variables that match ---
    @res1_indVarKeys = ();

    if (defined $res1DataP->{"indVarCreateOrder"})
    {
	@res1_indVarNames = @{$res1DataP->{"indVarCreateOrder"}};
    } else
    {
        @res1_indVarNames = @{$res1DataP->{"indVars"}};
    }
#    print join(",", @res1_indVarNames) . "\n";

    if (defined $res2DataP->{"indVarCreateOrder"})
    {
	@res2_indVarNames = @{$res2DataP->{"indVarCreateOrder"}};
    } else
    {
        @res2_indVarNames = @{$res2DataP->{"indVars"}};
    }

#    print join(",",@res2_indVarNames) . "\n";


    foreach (keys %{$res1DataP->{"indVars"}})
    {
	push(@res1_indVarKeys, 0);
    }
    foreach $res2_deviceName (keys %{$res2DataP->{"depVars"}})
    {
	$res1_deviceName = $res1_deviceName{$res2_deviceName};
	if ($res1_deviceName eq "")
	{
	    next;
	}
	if ($Debugging) 
	{
	    print "$res2_deviceName --- $res1_deviceName\n";
	}
	foreach $res2_depVarName (keys %{$res2DataP->{"depVars"}{$res2_deviceName}})
	{ 
	    $res1_depVarName = $res1_depVarName{$res2_deviceName}{$res2_depVarName};
	    if ($res1_depVarName eq "")
	    {
		next;
	    }
	    if ($Debugging) 
	    {
		print "$res2_depVarName --- $res1_depVarName\n";
	    }
	    foreach $res2_indVarKey (keys %{$res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}})
	    {
#		print "res2_indVarKeys = ($res2_indVarKey) <-> ";
		@res2_indVarKeys = split(/,/, $res2_indVarKey);
		for (my $index2 = 0; $index2 <= $#res2_indVarNames; $index2++)
		{
		    $res2_indVarName = $res2_indVarNames[$index2];
		    $res1_indVarName = $res1_indVarName{$res2_indVarName};
		    for (my $index1 = 0; $index1 <= $#res1_indVarNames; $index1++)
		    {
			if ($res1_indVarName eq $res1_indVarNames[$index1])
			{
#			    print "\nres1match  $res1_indVarName <-> $res1_indVarNames[$index1] ($index1 $index2)\n";
			    $res1_indVarKeys[$index1] = $res2_indVarKeys[$index2];
			    last;
			} 
		    }
		}
		$res1_indVarKey = "";
		foreach $index (@res1_indVarKeys)
		{
		    if ($res1_indVarKey ne "") 
		    { 
			$res1_indVarKey = $res1_indVarKey . ","; 
		    }
		    $res1_indVarKey = $res1_indVarKey . "$index";
		}
#		print "res1_indVarKey = ($res1_indVarKey)\n";
#		print "res2_indVarKey = ($res2_indVarKey)\n";
		
		if (! ref $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey})
		{
		    my $res2_value = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey};
		    my $res1_value = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey};
		    #printf "r2 = %12.9g  r1 = %12.9g\n", $res2_value, $res1_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"ads"} = $res2_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"hsp"} = $res1_value;
		    my $res_absError;
		    $res_absError = ($res2_value - $res1_value);
		    #print "cmpData{depVars}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey} =  $res_absError\n";
		    $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey} = $res_absError;
		}
		else
		{
		    #--- real part ---
		    my $res2_value = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[0];
		    my $res1_value = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey}[0];
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"ads"}[0] = $res2_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"hsp"}[0] = $res1_value;
#		    printf "ads = %12.9g  hsp = %12.9g\n", $res2_value, $res1_value;
		    my $res_absError;
		    $res_absError = ($res2_value - $res1_value);
		    $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[0] = $res_absError;
		    
		    #--- imag value ---
		    $res2_value = $res2DataP->{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[1];
		    $res1_value = $res1DataP->{"depVars"}{$res1_deviceName}{$res1_depVarName}{$res1_indVarKey}[1];
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"ads"}[1] = $res2_value;
#	  $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}{"hsp"}[1] = $res1_value;
#		    printf "ads = %12.9g  hsp = %12.9g\n", $res2_value, $res1_value;
		    $res_absError = ($res2_value - $res1_value);
		    $cmpData{"depVars"}{$res2_deviceName}{$res2_depVarName}{$res2_indVarKey}[1] = $res_absError;
		}
	    }
	}
    }
    
    #--- build complete cmpData structure using references to adsData! ---
    if (defined $res2DataP->{"indVarWriteOrder"})
    {
	$cmpData{"indVarWriteOrder"} = $res2DataP->{"indVarWriteOrder"};
    } 
    if (defined $res2DataP->{"indVarCreateOrder"})
    {
	$cmpData{"indVarCreateOrder"} = $res2DataP->{"indVarCreateOrder"};
    } 
    $cmpData{"indVars"} = $res2DataP->{"indVars"};
    
    #--- return to calling function --- 
    return $cmpDataP;
}


#############################################################################
# print statistical output 
#
# usage 
# my $statisticaldata = $handle->calculateStatistics([outputfilename]);

sub calculateStatistics
{
    my $self = shift;
    my $outputFileName = shift;
    my $statistics = "";

    if ($Debugging) {print "...calculating statistics\n"};

    foreach my $deviceName (keys %{$self->{"depVars"}})
    {
	foreach my $depVarName (keys %{$self->{"depVars"}{$deviceName}})
	{ 
	    $statistics = $statistics . "|$deviceName.$depVarName|: ";
            my $sum = 0;
            my $maximum = -1e38;
            my $minimum = 1e38;
            my $nrOfValues = 0;
	    foreach my $indVarKey (keys %{$self->{"depVars"}{$deviceName}{$depVarName}})
	    {
		my $value;
		if (ref $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey})
                {  ## complex use magnitude...
		    $value = $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0] * $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0];
		    $value += $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1] * $self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1];
		    $value = sqrt($value);
                } else
		{
                    $value =  abs($self->{"depVars"}{$deviceName}{$depVarName}{$indVarKey});
		}
		$sum += $value;
		if ($value  > $maximum)
		{
		    $maximum = $value;
		}
		if ($value  < $minimum)
		{
		    $minimum = $value;
		}
		$nrOfValues += 1;
	    }
	    $statistics = $statistics . "mean = " . sprintf("%8.2g", $sum/$nrOfValues);
	    $statistics = $statistics . ", max = " . sprintf("%8.2g", $maximum);
	    $statistics = $statistics . ", min = " . sprintf("%8.2g", $minimum) . "\n";
	}
    }
    if ($outputFileName)
    {
	if ($outputFileName eq "STDOUT")
	{
	    print STDOUT $statistics;
	} elsif ($outputFileName eq "STDERR")
	{
	    print STDERR $statistics;
	} else
	{
	    open(OUTPUT,">$outputFileName");
	    print OUTPUT $statistics;
	    close OUTPUT;
	}
    }
    return $statistics;
}


#############################################################################
# functions to deal with spectre result files
#


sub spectreAddDepVarName($@)
{
    my $spectreDataP = shift;
    my @content = @_;

    if ($Debugging > 9)
    {
	print "adding depVarName = $content[0]\n";
    }
    my $tempValueRef = undef;

    if ($content[2] eq "S-Param")
    {
	if ($content[0] =~ /^S(\d)(\d)/i)
	{
	    my $depVarName = "S[" . $1 . "," . $2 . "]";
	    if (!exists($spectreDataP->{"depVars"}{"sParams"}{$depVarName}))
	    {
		$spectreDataP->{"depVars"}{"sParams"}{$depVarName} = {};
	    }
#			print "depvarName = $depVarName\n";
	    $tempValueRef = $spectreDataP->{"depVars"}{"sParams"}{$depVarName};
	} else
	{
	    print "unable to resolve s-parameters for $content[0]\n";
	}
    } elsif ($content[2] eq "V/sqrt(Hz)")
    {
	my $depVarName;
	if ($content[0] eq "out")
	{
	    $depVarName = "onoise";
	} else
	{
	    $depVarName = $content[0];
	}
	if (!exists($spectreDataP->{"depVars"}{"noise"}{$depVarName}))
	{
	    $spectreDataP->{"depVars"}{"noise"}{$depVarName} = {};
	}
#		    print "depvarName = $depVarName\n";
	$tempValueRef = $spectreDataP->{"depVars"}{"noise"}{$depVarName};
	
    } elsif ($content[0] =~ /(.*)\:(.*)/)
    {
	my $param = $2;
	if ($content[2] eq "I")
	{
	    if ($param eq "p")
	    {
		$param = "i1";
	    } elsif ($param =~ /^\d/)
	    {
		$param = "i$param";
	    }
	} else
	{
	    #### device parameter Xref backsubstitution here
	    $param = dKitParameter->dialect2result($param, "spectre");
	}
	
	if (!exists($spectreDataP->{"depVars"}{$1}{$param}))
	{
	    $spectreDataP->{"depVars"}{$1}{$param} = {};
	}
	$tempValueRef = $spectreDataP->{"depVars"}{$1}{$param};
    } elsif ($content[2] eq "V")
    {
	if (!exists($spectreDataP->{"depVars"}{$content[0]}{"v"}))
	{
	    $spectreDataP->{"depVars"}{$content[0]}{"v"} = {};
	}
	$tempValueRef = $spectreDataP->{"depVars"}{$content[0]}{"v"};
    } elsif ($content[2] eq "I")
    {
	if (!exists($spectreDataP->{"depVars"}{$content[0]}{"i1"}))
	{
	    $spectreDataP->{"depVars"}{$content[0]}{"i1"} = {};
	}
	$tempValueRef = $spectreDataP->{"depVars"}{$content[0]}{"i1"};
    } else
    {
	if (!exists($spectreDataP->{"depVars"}{$content[0]}{"dummy"}))
	{
	    $spectreDataP->{"depVars"}{$content[0]}{"dummy"} = {};
	}
	$tempValueRef = $spectreDataP->{"depVars"}{$content[0]}{"dummy"};
    }
    return $tempValueRef;
}

#############################################################################
#
# readSpectreDataFile
#  read one spectre data file
#
# call vocabulary 
#  readSpectreDataFile($spectreFileName, $spectreDataP);

sub readSpectreDataFile
{
    my ($spectreFileName, $spectreDataP) = @_;

    my $tempValueRefName;
    my @tempValuesOld = ();
    my $sweepVar;

    my @section;
    my $section_NOTSTARTED = -1;
    my $section_HEADER = 0;
    my $section_TYPE = 1;
    my $section_SWEEP = 2;
    my $section_TRACE = 3;
    my $section_VALUE = 4;
    my $section_PROP = 5;
    my $section_STRUCT = 6;
    my $section_ARRAY = 7;
    if ($Debugging > 1)
    {
        print "...reading spectre data file $spectreFileName\n";
    }
    #--- open the spectre data file ---
    if (!open(SPECTRE_FILE, "<$spectreFileName"))
    {
	print "ERROR: Cannot open spectre  data file $spectreFileName!\n"; return;
    }

    my $sweepName = "";
    my $processedTraces = 0;
    #--- parse the spectre  data file ---
    while (<SPECTRE_FILE>)
    {
	no strict 'refs';
#	print "processing  $_";
        my @content = ($_ =~ /\"(.+?)\"|([\S]+)/gsx);
# this structure creates 2n fragments [2*n] contains string 
# [2n+1] contains no string value
#        print join (' -,- ',  @content) . "\n";
####
##   @section istreated as a stack of lists,
#    each list contains the type of definition which will follow,
#    and a ptr to the structure where to store the definition
#    this ptr is 0 for the major definitions
#
        if ($#content == 1)
	{
	    if ($content[1] =~ /^\s*HEADER/i)
	    {
		$section[0] = ([$section_HEADER, 0]);
	    } elsif ($content[1] =~ /^\s*TYPE/i)
	    {
		$section[0] = ([$section_TYPE, 0]);
	    } elsif ($content[1] =~ /^\s*SWEEP/i)
            {
		$section[0] = ([$section_SWEEP, 0]);
	    } elsif ($content[1] =~ /^\s*TRACE/i)
	    {
		$section[0] = ([$section_TRACE, 0]);
		$processedTraces = 1;
	    } elsif ($content[1] =~ /^\s*VALUE/i)
	    {
		$section[0] = ([$section_VALUE, 0]);
	    } elsif ($content[1] =~ /^\s*END/i)
	    {
		$section[0] = ([$section_NOTSTARTED, 0]);
	    } elsif ($content[1] =~ /^\s*\)/i)
	    {
		pop @section;
	    } else
            {
		if ($section[$#section][0] eq $section_ARRAY)
                {

		} else
		{
		    print "unknown content type: \"$content[0]\",$content[1]\n";
		}
	    }
        } else
        {
	    if ($content[1] =~ /^\s*\)/i)
	    {
		pop @section;
            }
	    if ($section[$#section][0] eq $section_SWEEP)
            {
#		print "sweep $content[0]\n";
#add sweep value which resides in $content[0]
                if ($sweepName eq "")
                {
		    $sweepName=$content[0];
                }

		#### device parameter Xref backsubstitution here
		my @fragments = split('\:', $sweepName);
		if ($#fragments == 1)
		{
		    $fragments[1] = dKitParameter->dialect2result($fragments[1], "spectre");
		}
		$sweepName = join('.', @fragments);

		$sweepName =~ s/:/./g;
#		print "$sweepName\n";
		if (!exists($spectreDataP->{"indVars"}{$sweepName}{"index"}))
		{
		    push(@{$spectreDataP->{'indVarCreateOrder'}}, $sweepName);
        # currently no values are stored yet  
		    $spectreDataP->{"indVars"}{$sweepName}{"index"} = -1;
		    if ($Debugging > 9)
		    {
			print "adding indVarName = $sweepName\n";
		    }
		} else
                {
		    @tempValuesOld = @{$spectreDataP->{"indVars"}{$sweepName}{"values"}};
		    @{$spectreDataP->{"indVars"}{$sweepName}{"values"}} = ();
		    $sweepVar = $sweepName;
		}
		$tempValueRefName = "value_" . $content[0];
		$$tempValueRefName = \@{$spectreDataP->{"indVars"}{$sweepName}{"values"}};
	    } elsif ($section[$#section][0] eq $section_TRACE)
            {
#		print "trace $content[0]\n";
		$tempValueRefName = "value_" . $content[0];
		$$tempValueRefName = spectreAddDepVarName($spectreDataP, @content);
	    } elsif ($section[$#section][0] eq $section_VALUE)
            {
#                print "value $content[0]\n";
		$tempValueRefName = "value_" . $content[0];
		if (!$processedTraces)
		{
		    $$tempValueRefName = spectreAddDepVarName($spectreDataP, @content);
		}

		while ($content[0])
		{
		    shift @content;
		    shift @content;
		}

		my $value = "";
                my @array = ();
		if ($#content == 1)
		{
#		    print "3 " . $content[1] . "\n";
		    if ($content[1] eq '(')
                    {
#			print "found bracket\n";
			push @section, [$section_ARRAY, 0];
		    } elsif ($content[1] eq 'PROP(')
		    {
#			print "found property\n";
			push @section, [$section_PROP, 0];
		    } else
		    {
		        $value = $content[1];
		    }
		} elsif ($#content == 3)
                {
		    $content[1] =~ /\(+(.*)/;
		    $array[0] = $1;
		    $content[3] =~ /(.*)\)+/;
		    $array[1] = $1;
		    $value = \@array;
		}
		if (ref ($$tempValueRefName) eq "ARRAY")
		{
#		    print $$tempValueRefName . "\n";
		    push (@{$$tempValueRefName}, $value);
		    if ($Debugging > 9)
		    {
			(my $name) = ($tempValueRefName =~ /value_(.*)/);
#			print "adding to $name .. value $value\n";
		    }
#		    print "$tempValueRefName " . join(" ", @{$$tempValueRefName}) . "\n";
		} elsif  (ref ($$tempValueRefName) eq "HASH")
		{
		    # create key
		    my @indVarCreateOrder =
			@{$spectreDataP->{'indVarCreateOrder'}};
		    my $key = "";
		    foreach my $indvar (@indVarCreateOrder)
		    {
			if ($spectreDataP->{"indVars"}{$indvar}{"index"} < 0)
			{
			    if ($key eq "")
			    {
				$key = $#{$spectreDataP->{"indVars"}{$indvar}{"values"}};
			    } else
                            {
				$key = $key . "," . $#{$spectreDataP->{"indVars"}{$indvar}{"values"}};
			    }
                        } else
                        {
			    if ($key eq "")
			    {
				$key = $spectreDataP->{"indVars"}{$indvar}{"index"};
			    } else
                            {
				$key = $key . "," . $spectreDataP->{"indVars"}{$indvar}{"index"};
			    }
			}
		    }
		    if ($Debugging > 9)
		    {
			(my $name) = ($tempValueRefName =~ /value_(.*)/);
			if (! ref  $value)
			{
			    print "$name: key = $key, value = $value\n";
		        } else
			{
			    print "$name: key = $key, value = $$value[0],$$value[1]\n";
			}
		    }
		    $$tempValueRefName->{$key} = $value;
#                    print hash2str(%{$$tempValueRefName});
		}
	    } elsif ($section[$#section][0] eq $section_HEADER)
            {
		if ($content[0] eq "analysis description")
                {
		    if ($content[2] =~ /\':\s*(\S+)\s*=/)
                    {
			$sweepName=$1;
#			print "sweepName=$sweepName\n";
		    }
                }
            }

# ignore all other sections for now

	    if ( $content[$#content] eq "PROP(" )
	    {
		push @section, [$section_PROP, 0];
	    } elsif ( $content[$#content] eq "STRUCT(" )
	    {
		push @section, [$section_STRUCT, 0];
	    } 
         }
#        print join (' -:- ',  @section) . "\n";
    }

    close(SPECTRE_FILE);

    if ($#tempValuesOld >= 0)
    {  #check whether we have the same values
#        print "oldValues = $#tempValuesOld, newValues = $#{$spectreDataP->{indVars}{$sweepVar}{values}}\n";
	if ($#tempValuesOld != $#{$spectreDataP->{"indVars"}{$sweepVar}{"values"}})
	{
	    print "ERROR: Spectre Results sweeps for $sweepVar not correctly defined"; return;
	}
        my $cnt = 0;
	foreach my $value (@tempValuesOld)
        {
	    my $newValue = $spectreDataP->{"indVars"}{$sweepVar}{"values"}[$cnt];
#            print "value = $value, newValue = $newValue\n";
	    if (abs($newValue - $value) > 1.0e-12)
            {
		print "ERROR: Spectre Results sweeps for $sweepVar not correctly defined in file $spectreFileName"; return;
	    }
	    if (abs($newValue - $value) > 1.0e-8 * (1 + abs($newValue + $value)))
            {
		print "ERROR: Spectre Results sweeps for $sweepVar not correctly defined in file $spectreFileName"; return;
	    }
	    $cnt++;
	}
    }
#    print hash2str(%{$spectreDataP});
#    print Dumper($spectreDataP);
}


###########################################################################
#### read the spectre result directory 
####
#### call vocabulary
####    readSpectreData("resultDirName")
####

use Cwd;

sub readSpectreData
{
    my $spectreDirName = shift;
    my %spectreData = ();
    my $spectreDataP = \%spectreData;
    bless($spectreDataP, "dKitResults");

    # strip blank spaces
    for($spectreDirName) {
      s/^\s+//;
      s/\s+$//;
    }
    if (!opendir(SPECTRE_DIR, $spectreDirName))
    { 
       print "ERROR: Cannot open directory $spectreDirName\n";
       return;
    }
    my @spectreFiles = grep { !/^logFile$/ && !/.*\.info$/ && -f "$spectreDirName/$_" } readdir(SPECTRE_DIR);
    closedir(SPECTRE_DIR);
    my $curDir = cwd;
    if (! chdir($spectreDirName))
    {
       print "can't change directory to $spectreDirName";
       return;
    }

# If Monte Carlo files exist read it in as the first independent sweep variable

    my $monteFlag = 0;
    my @monteFiles = grep(/\.montecarlo$/, @spectreFiles);
    if ( $#monteFiles == 0 )
    {
	$monteFlag = 1;
	readSpectreDataFile($monteFiles[0], $spectreDataP);
    }

# Get Names of sweep files 

    my $suffix = ".sweep";
    my @sweepFiles = grep(/\.sweep$/, @spectreFiles);

    if (! (($#sweepFiles == -1) && ($#monteFiles == -1)) )
    {

    my @tmpDataFiles = grep(!/\.sweep$|\.montecarlo$/, @spectreFiles);
    my @dataFiles = grep(/_/, @tmpDataFiles);

    my (@analysis, @sweeps, @sweepsInfo);
    @sweeps = ($dataFiles[0] =~ /(\w+)\-\d+_/g);
    @sweepsInfo = ($dataFiles[0] =~ /\w+\-(\d+)_/g);
    if ( $#sweeps == -1 )
    {
        @sweeps = ($dataFiles[0]   =~ /([0-9a-zA-Z]+)_/g);
        @analysis = ($dataFiles[0] =~ /[0-9a-zA-Z]*_(\w+)\.(\w+)/g);
    } else
    {
        @analysis = ($dataFiles[0] =~ /(?:\w+\-\d+_)*(\w+)\.(\w+)/g);
    }
    my $postfix = "_" . $analysis[0] . $suffix;
    my $prefix = "";


#  read in independent sweep variables
    if ($#sweepFiles != -1)
    {
	my ($sweepInfo,$dFile);
	foreach my $sweep (@sweeps)
        {
	    if ($prefix eq "")
            {
		$prefix = $sweep;
	    } else
            {
		$prefix = $prefix . "-" . $sweepInfo . "_" . $sweep;
            }
	$sweepInfo = shift @sweepsInfo;
	readSpectreDataFile($prefix . $postfix, $spectreDataP);
	}

    }


# reading dependent data information
        my $dataRE = "";
	foreach my $sweep (@sweeps)
        {
	    if ($dataRE eq "")
            {
		$dataRE = $sweep . '-0*(\d+)_' ;
	    } else
            {
		$dataRE = $dataRE . $sweep . '-0*(\d+)_';
            }
	}
	$dataRE = $dataRE . $analysis[0] . "." . $analysis[1];
	foreach my $dataFile (@dataFiles)
        {
	    my @indices = ($dataFile =~ /$dataRE/);
	    my @indVars = @{$spectreDataP->{'indVarCreateOrder'}};
	    foreach my $index (@indices)
	    {
		my $indvar = shift @indVars;
		if ( $monteFlag )  # if Monte Carlo, sweeps start at "1", but arrays at "0".
		{
		    $spectreDataP->{"indVars"}{$indvar}{"index"} = $index-1;
		}
		else
		{
		    $spectreDataP->{"indVars"}{$indvar}{"index"} = $index;
		}
	    }
	    readSpectreDataFile($dataFile, $spectreDataP);
        }

    } else
    { # we just should have one analysis file
        if ($#spectreFiles != 0)
        {
	    if ($#spectreFiles < 0)
            {
		print "ERROR: Could not find simulation data\n";
                return;
	    }
	    print "ERROR: Spectre translation implemented for single analysis only\n";
            return;
	}
	readSpectreDataFile($spectreFiles[0], $spectreDataP); 
    }



# Read Monte Carlo parameters if needed
    if ( $monteFlag )
    {
	my $numIndVars = $#{$spectreDataP->{indVarCreateOrder}}+1;
	my $keySuffix = "";
	
	my $ivar = 1; 
	while ($ivar < $numIndVars)
	{
	    $keySuffix .= ",1";
	    $ivar++;
	}

       # Get Dependent Data Names
	my @depVarList = ();
	if (!exists($spectreDataP->{"depVars"}{"dummy"}))
	{
	    $spectreDataP->{"depVars"}{"dummy"} = {};
	}
	my $tempRef = $spectreDataP->{"depVars"}{"dummy"};
	if (!open(SPECTRE_FILE, "monteCarloParam"))
	{
	    print "ERROR: Cannot open spectre Monte Carlo  data file!\n"; return;
	}
	while (<SPECTRE_FILE>)
	{
	    my $line = $_;
	    if ( ($line =~ /^\s*\#/ ) || ( $line eq "\n"  ) )
	    {
		next;
	    }
	    my @content = ($line =~ /\"(.+?)\"|([\S]+)/gsx);
	    my $depVar = pop @content;
	    push @depVarList, ($depVar);
	    $tempRef->{$depVar} = {};
	}
	close(SPECTRE_FILE);

	# There can be redundent data in the montecarloData file when other
	# independent sweep variables are used. This eliminates it.
	my $numDepVars = ( scalar keys %{$tempRef} );
	my $entriesThisFile = $#depVarList+1;
	my $repeatFactorInDataFile = $entriesThisFile/$numDepVars;

        # Read Dependent Data Values
	if (!open(SPECTRE_FILE, "monteCarloData"))
	{
	    print "ERROR: Cannot open spectre Monte Carlo  data file!\n"; return;
	}
	my $count = 0;
	my $dataIndex = 0;
	while (<SPECTRE_FILE>)
	{
	    my $line = $_;
	    if ( ($line =~ /^\s*\#/ ) || ( $line eq "\n"  ) )
	    {
		next;
	    }
	    if (     (int($count/$repeatFactorInDataFile) * $repeatFactorInDataFile) == $count )
	    {
		my @content = ($line =~ /[\S]+/gsx);
		my $key = $dataIndex . $keySuffix;
		$tempRef->{npass}{$key} = $dataIndex+1; # Monte Carlo number of pass

		for (my $dindex = 0; $dindex < $numDepVars; $dindex++)
		{
		    $tempRef->{$depVarList[$dindex]}{$key} = $content[$dindex];
		}
		$dataIndex++;
	    }
	    $count++;
	}
	close(SPECTRE_FILE);

    } # end if montecarlo
    chdir($curDir);
    return $spectreDataP;
}


###############################################################################
#
# readADSData
# call vocabulary 
#     readAdsData("resultfile")
#
###############################################################################

sub readAdsData($)
{
  my $adsFileName = shift;

  my %adsData = ();
  my @myKeys = ();

  if ($Debugging)
  {
      print "...reading ADS Simulation data $adsFileName\n";
  }
  #--- open the Ads simulation data file ---
  if (!open(ADS_FILE, "<$adsFileName"))
  {
      print "ERROR: Cannot open Ads simulation data file $adsFileName!\n"; return;
  }

  my $section = "init";
  my $sweepDef = "";
  my $varDef = "";
  my $valDef = "";
  my $noOfVariables = 0;
  my $noOfSweepVariables = 0;
  my $deviceParameters = "no";
  my $deviceParametersIndex = "no";
  my @varList = ();
  my @indVarCreateOrder = ();

  #--- parse the Adsice data file ---
  while (<ADS_FILE>)
  {
      no strict 'refs';
#      print "parsing $_";
      if ($_ eq "\n")
      {
	  next;
      }
      if ($section eq "init")
      {
	  if (/No. Sweep Variables:\s*(\d+)/)
          {
	      $noOfSweepVariables = $1;
          } elsif (/^Sweep Variables:\s*(.*)/s)
          {
	      $sweepDef = $1;
	      $section = "sweepdef";
          } elsif (/^Variables:\s*(.*)/s)
          {
	      $varDef = $1;
	      $section = "vardef";
          }
      }
      elsif ($section eq "sweepdef")
      {
	  if (/No. Variables:\s*(\d+)/)
          {
	      $noOfVariables = $1;
	      $section = "init";
              if (my @sweeps = ($sweepDef =~ /(.*?)\n/gs))
              {
		  for my $sweep (@sweeps)
		  {
#		      print "sweep = $sweep\n";
		      my $var;
                      my $value;
		      my $typeName;
		      

		      if ($sweep =~ /\s*(\S+)\s+($complex)/)
                      {
                          $var = $1;
                          $value = $2;
#			  print "var=$1, complex = $2\n";
			  $typeName="typeOf" . $var;
			  $$typeName = "complex";
                      } elsif ($sweep =~ /\s*(\S+)\s+($real)/)
		      {
                          $var = $1;
                          $value = $2;
#			  print "var=$1, real = $2\n";
			  $typeName = "typeOf" . $var ;
			  $$typeName = "real";
                      }

		      my @fragments = split('\.', $var);

		      my $parameter = pop(@fragments); 
		      $parameter = dKitParameter->dialect2result($parameter, "ads");
		      push(@fragments, $parameter);

		      $var = join('.', @fragments);

#		      print "var = $var\n";

	              if (!exists($adsData{"indVars"}{$var}{"index"}))
		      {
			  push(@indVarCreateOrder, $var);
			  $adsData{"indVars"}{$var}{"index"} = $#indVarCreateOrder;
			  if ($Debugging > 9)
			  {
			      print "adding indVarName = $var, value = $value\n";
			  }
			  @{$adsData{'indVarCreateOrder'}} = @indVarCreateOrder;
			  push (@{$adsData{"indVars"}{$var}{"values"}}, "$value");
			  $myKeys[$adsData{"indVars"}{$var}{"index"}] = 0;	      
		      } else
		      {
			  if ($$typeName eq "real")
                          {
			      my $i_cnt = 0;
			      for ($i_cnt = 0; 
				       $i_cnt <= $#{$adsData{"indVars"}{$var}{"values"}};
					      $i_cnt++)
			      {
				  if ($value == ${$adsData{"indVars"}{$var}{"values"}}[$i_cnt])
			          {
				      last;
			          }
			      }
#			      print "i_cnt = $i_cnt\n";
			      if ($i_cnt > $#{$adsData{"indVars"}{$var}{"values"}})
			      {
				  push (@{$adsData{"indVars"}{$var}{"values"}}, "$value");
				  if ($Debugging > 9)
				  {
				      print "adding value = $value to indVarName = $var\n";
				  } 
			      } else
			      {  
				  if ($Debugging > 9)
				  {
				      print "found value = $value for indVarName = $var\n";
				  } 
			      }
#		              print "index = $adsData{indVars}{$var}{index}\n";
			      $myKeys[$adsData{"indVars"}{$var}{"index"}] = $i_cnt;	      
                          } else
                          {
			      croak ("complex variables not implemeted in readAdsData (dKitResults.pm)");
                          }
		      }
		  }
	      }
          } else
          {
	      $sweepDef = $sweepDef . $_;
	  }
      } elsif ($section eq "vardef")
      {
	  if (/Values:/)
          {
	      $section = "valuedef";
	      $valDef = "";
	      $deviceParameters = "no";
	      $deviceParametersIndex = "no";
              if (my @variables = ($varDef =~ /(.*?)\n/gs))
              {
                  @varList = ();

		  # Need to ignore "index" parameter for Device Operating Point
		  # "index" is new for ADS2003C
		  #
		  my @frag0 = split(' ', $variables[0]);
		  my @frag1 = split(' ', $variables[1]);
		  if ( $frag0[1] eq "index" && $frag1[1] eq "DeviceId" )
		  {
	          $deviceParametersIndex = "yes";
		  }

		  for my $variableDef (@variables)
		  {
		      if ($Debugging > 5)
                      {
			  print "variable = $variableDef\n";
		      }
		      (my $var, my $units, my $type, my $independent) = 
			  ($variableDef =~ /\s*\d+\s+(\S+)\s+(\S+)\s+type=(\S+)\s+indep=(\S+)/);

		      my @fragments = split('\.', $var);
		      my $parameter = pop(@fragments); 
		      if ($units eq "v-noise")
                      {
			  $parameter = "onoise";
#	  we need to hide the output node, 
#         because other simulators do not output it
			  @fragments = ("noise");
		      }
		      elsif ($units eq "current")
		      {
			  my $tDevice = pop(@fragments);
			  if ($tDevice)
			  {
			      if ($parameter eq "i" && ($tDevice =~ /^V/))
			      {  ## current of volatge source i->i1
				  $parameter = "i1";
			      } else
			      {
				  $parameter = dKitParameter->dialect2result($parameter, "ads");
			      }
			      push(@fragments, $tDevice);
			  }
		      }
		      elsif ($parameter ne "index" && $parameter ne "DeviceId" && $units ne "voltage" && $units ne "s-param" && $units ne "port-impedance")
		      {
			  ### DeviceID's and voltages should not be translated
			  $parameter = dKitParameter->dialect2result($parameter, "ads");
		      }
		      push (@fragments, $parameter);
		      $var = join('.', @fragments);

#		      print "val $var, $units, $type, $independent\n";

		      if ($independent eq "yes" && $deviceParametersIndex eq "no" )
		      {
			  if (!exists($adsData{"indVars"}{$var}{"index"}))
			  {
			      push(@indVarCreateOrder, $var);
			      $adsData{"indVars"}{$var}{"index"} = $#indVarCreateOrder;
			      if ($Debugging > 9)
			      {
				  print "adding indVarName = $var\n";
			      }
			      @{$adsData{'indVarCreateOrder'}} = @indVarCreateOrder;
			  }
		      } else
                      {
			  if ($var eq "DeviceId")
			  {
			      $deviceParameters = "yes";
			  } 
			  if ($deviceParameters eq "no")
                          {
			      my @fragments = split('\.', $var);
			      if ($#fragments != 1)
			      {
				  if ($units eq "voltage")
				  {
				      $var = $var . ".v";
				  } elsif ($units eq "current")
				  {
				      $var = $var . ".i1";
				  }
 			      }
			  }
		      }
		      
		      push @varList, $var;
		      my $typeName = "typeOf" . $var;
		      $$typeName = $type;

		      my $indepName = "indepVar" . $var;
		      $$indepName = $independent;
		  }
	      }
          } else
          {
	      $varDef = $varDef . $_;
	  }
      } elsif ($section eq "valuedef")
      {
	  if (/#/)
          {
	      $section="init";
	      $valDef =~ s/\n\s/ /g;
              if (my @values = ($valDef =~ /(.*?)\n/gs))
              {
		  for my $valueDef (@values)
		  {
#		      print "value = $valueDef\n";
		      my $deviceName;
		      my $iCnt;

		      (my @numValues) = 
			  ($valueDef =~ /(\S+)\s*/g);
                      my $ndx = shift @numValues;
#		      print "ndx = $ndx\n";
                      if ($#numValues != $noOfVariables - 1)
                      {
			  croak("Unable to process file");
                      }
		      

#		      print "deviceParameters = $deviceParameters\n";


		      if ($deviceParameters eq "yes")
		      {
				if ( $deviceParametersIndex eq "yes" )
				{
				  $deviceName = $numValues[1];
				  $deviceName =~ s/\"//g;
				  $iCnt = 2;
				} else
				{
				  $deviceName = $numValues[0];
				  $deviceName =~ s/\"//g;
				  $iCnt = 1;
				}
		      } else
                      {
			  $deviceName="";
			  $iCnt = 0;
		      }

		      for (; $iCnt < $noOfVariables; $iCnt++)
                      {
#			  print "$varList[$iCnt] = $numValues[$iCnt]\n";
			  if ($numValues[$iCnt] =~ /($real),$real/)
			  {
			      my $myType = "typeOf" . $varList[$iCnt];
#			      print "mytype = $myType, $$myType\n";
			      if (!($$myType eq "complex"))
			      {
#				  print "switch to real $varList[$iCnt] -> $1\n";
				  $numValues[$iCnt] = $1;
			      }
			  }
			  my $indepName = "indepVar" . $varList[$iCnt];
			  if ($$indepName eq "yes" && $deviceParametersIndex eq "no")
                          {
#			      print "independent $varList[$iCnt]\n";
			      my $myType = "typeOf" . $varList[$iCnt];
#			      print "mytype = $myType, $$myType\n";
			      my $var = $varList[$iCnt];
			      my $value = $numValues[$iCnt];
# 			      print "$varList[$iCnt] = $numValues[$iCnt]\n";
	 		      if ($$myType eq "real")
			      {
				  my $i_cnt;
				  for ($i_cnt = 0; 
				       $i_cnt <= $#{$adsData{"indVars"}{$var}{"values"}};
					      $i_cnt++)
				  {
				      if ($value == ${$adsData{"indVars"}{$var}{"values"}}[$i_cnt])
			              {
				          last;
			              }
			          }
#			          print "i_cnt = $i_cnt\n";
				  if ($i_cnt > $#{$adsData{"indVars"}{$var}{"values"}})
				  {
				      push (@{$adsData{"indVars"}{$var}{"values"}}, "$value");
				      if ($Debugging > 9)
				      {
					  print "adding value = $value to indVarName = $var\n";
				      } 
				  } else
				  {
				      if ($Debugging > 9)
				      {
					  print "found value = $value for indVarName = $var\n";
				      } 
				  }
#				  print "index = $adsData{indVars}{$var}{index}\n";
				  $myKeys[$adsData{"indVars"}{$var}{"index"}] = $i_cnt;	      
			      }
			  } else
			  {
			      # dependent variable stuff...
			      my $varValue = $numValues[$iCnt];
			      my $name;

			      if ($deviceName eq "")
			      {
				  $name = $varList[$iCnt];
			      } else
			      {
				  $name = $deviceName. "." . $varList[$iCnt];
			      }
			      my $key = join(",", @myKeys);

#			      print "varName = $name, value = $varValue\n";
#			      print "keys = $key\n";
			      my @fragments = split('\.', $name);

			      if ($#fragments == 1)
			      {
				  my $myType = "typeOf" . $varList[$iCnt];
				  if ($varValue =~/\s*($real)\s*,\s*($real)\s*/)
				  {
				      $adsData{"depVars"}{$fragments[0]}{$fragments[1]}{$key}[0] = $1;
				      $adsData{"depVars"}{$fragments[0]}{$fragments[1]}{$key}[1] = $6;
				  } else
				  {
				      $adsData{"depVars"}{$fragments[0]}{$fragments[1]}{$key} = $varValue;
				  }
			      } else
			      {
				  my $myType = "typeOf" . $varList[$iCnt];
				  if ($varValue =~/\s*($real)\s*,\s*($real)\s*/)
				  {
				      $adsData{"depVars"}{"sParams"}{$name}{$key}[0] = $1;
				      $adsData{"depVars"}{"sParams"}{$name}{$key}[1] = $6;
				  } else
				  {
				      $adsData{"depVars"}{"dummy"}{$name}{$key} = $varValue;
				  }
			      }
			  }
		      }
		  }
	      }

          } else
          {
	      $valDef = $valDef . $_;
	  }
      }


  }
  close(ADS_FILE);
  bless(\%adsData, "dKitResults");
  return \%adsData;
}

###############################################################################
#
# readHspiceData
# call vocabulary 
#     readHspiceData("resultfile")
#
###############################################################################

sub readHspiceData($)
{
    my $hspFileName = shift;
    my %hspData = {};
    my $nrOfIndVars;
    my @indVarIndex;
    my @indVarOrder = ();
    my $indVarKey;
    my $indVarName;
    my $indVarHP;
    my $innerLoopVarName = "";
    my $dataBlock;
    my $nrOfDepVars;
    my @depVarNames;
    my $depVarName;
    my $depVar;
    my @deviceNames;
    my $deviceName;
    my $index;
    my @temps;
    my $temp;
    my @polarValue;
    my @values;
    my $dataBlockName;
    my $dataBlockSweep;
    my $section;
    my @indVarNames;
    my $dataBlockIndex;
    my $dataBlockValue;
    my @types;
    my @devicesWithComplexResults = ();
    my $resetBlockSweep = 0;
    my $MonteFlag = 0;
    my @MonteDepVarNames = ();
    my @MonteDeviceNames = ();
    my @MonteValues = ();
    my $warned = 0;

    my $INIT  = 0;
    my $DDEP  = 1;
    my $DDAT  = 2;

    my $writeOrderGiven = 0;

    if ($Debugging)
    {
	print "...reading Hspice data\n";
    }
    #--- open the Hspice data file ---
    if (!open(HSP_FILE, "<$hspFileName"))
    {
	print "ERROR: Cannot open Hspice data file $hspFileName!\n"; return;
    }

    #--- parse the Hspice data file ---
    $section = $INIT;

    while (<HSP_FILE>)
    {
	no strict 'refs';
#	print "processing ($section) $_ ";
	if (/^\s*$/)
	{
	    next;
	}
	elsif (($section==$INIT) && /^\s*\*\*\*\s+sweep\s+variables\s+list\s+/i)
	{
	    if (! $writeOrderGiven)
	    {
		my $iline;
                if ( $MonteFlag )
                {
                  $iline = "iteration " . $';
	        }
                else
                {
                  $iline = $';
                }
		my @thisIndVarOrder = split(" ", $iline);
		for my $indVarName (@thisIndVarOrder)
		{
		    if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
		    {
			if ($Debugging > 9)
			{
			    print "adding indVarName = $indVarName\n";
			}
			@{$hspData{"indVars"}{$indVarName}{"values"}} = ();
			$index = $#{$hspData{"indVars"}{$indVarName}{"values"}};
			$hspData{"indVars"}{$indVarName}{"index"} = $index;
		    } else
		    {
			@indVarOrder = grep(!($indVarName eq $_), @indVarOrder);
		    }
		}
		push (@thisIndVarOrder, @indVarOrder);
		@indVarOrder = @thisIndVarOrder;
		$writeOrderGiven = 1;
	    }
	}
	elsif (($section==$INIT) && /^\s*(V|I)(\S+)\s+(\S+)\s+(\S+)\s+/i)
	{
	    if (!($2 =~ /[=\.]/) && !($3 =~ /[=\.]/) && !($4 =~ /[=\.]/))
	    {
		$deviceName = $1 . $2 ;
		my $parameter = uc($1);
		if ($' =~ /^(DC\s*=\s*)?($real)\s+/i)
		{
		    $parameter = "dc";
#		    print "1: parameter = $parameter\n";
		    #### device parameter Xref backsubstitution here
		    $parameter = dKitParameter->dialect2result($parameter, "hspice");
		    $indVarName = $deviceName . "." . $parameter;
		    if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
		    {
			# indVar is not swept (up to now)
			$hspData{"indVars"}{$indVarName}{"values"}[0] = $2;
			$hspData{"indVars"}{$indVarName}{"index"} = 0;
			push(@indVarOrder, $indVarName);
			if ($Debugging > 9)
			{
			    print "adding indVarName = $indVarName\n";
			}
		    }
		    else
		    {
			@values = @{$hspData{"indVars"}{$indVarName}{"values"}};
			for ($index = 0; $index <= $#values; $index++)
			{
			    if ($2 == $values[$index]) 
			    {
				$hspData{"indVars"}{$indVarName}{"index"} = $index;
				last; 
			    }
			}
			if ($index > $#values)
			{
			    push(@{$hspData{"indVars"}{$indVarName}{"values"}}, $2);
			    $hspData{"indVars"}{$indVarName}{"index"} = 
				$#{$hspData{"indVars"}{$indVarName}{"values"}};
			}
		    }
		}
	    }
	}
	elsif (($section==$INIT) && /^\s*\.DC\s+/i)
	{
            my $tail =$';
	    if ($' =~ /^([VI]\S+)\s+($real)\s+($real)\s+($real)\s+/i)
	    {
		my $parameter;
		if (substr($1, 0, 1) eq "i")
		{
		    my $parameter = "dc";
		}
		else
		{
		    $parameter = "dc";
		}
 

		#### device parameter Xref backsubstitution here
#		print "2: parameter = $parameter\n";

		$parameter = dKitParameter->dialect2result($parameter, "hspice");
		$indVarName = $1 . "." . $parameter;
		if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
		{
		    push(@indVarOrder, $indVarName);
		    if ($Debugging > 9)
		    {
			print "adding indVarName = $indVarName\n";
		    }
		}
		
		@{$hspData{"indVars"}{$indVarName}{"values"}} = ();
		$index = $#{$hspData{"indVars"}{$indVarName}{"values"}};
		$hspData{"indVars"}{$indVarName}{"index"} = $index;
		# this is the innerloop variable
		$innerLoopVarName = $indVarName;
	    }
	    elsif ($' =~ /^TEMP\s+/i)
	    {
		my $parameter = dKitParameter->dialect2result('temp', "hspice");
		$indVarName = $parameter;
		if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
		{
		    push(@indVarOrder, $indVarName);
		    if ($Debugging > 9)
		    {
			print "adding indVarName = $indVarName\n";
		    }
		}
		@{$hspData{"indVars"}{$indVarName}{"values"}} = ();
		$index = $#{$hspData{"indVars"}{$indVarName}{"values"}};
		$hspData{"indVars"}{$indVarName}{"index"} = $index;
		# this is the innerloop variable
		$innerLoopVarName = $indVarName;		
	    }
	    elsif ($' =~ /^(?:SWEEP\s+)?DATA\s*=\s*(\S+)\s+/i)
	    {
		$dataBlock = $1;
	    }
            if ( $tail =~ /monte/ )
            {
                $MonteFlag = 1;
            }
	}
	elsif (($section==$INIT) && /^\s*\.AC\s+/i)
	{
	    my $parameter = "freq";
            my $tail = $';
            if ( $tail =~ /monte/ )
            {
              $MonteFlag = 1;
            }
	    $indVarName = $parameter;
	    if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
	    {  
		push(@indVarOrder, $indVarName);
		if ($Debugging > 9)
		{
		    print "adding indVarName = $indVarName\n";
		}
	    }
	    $hspData{"indVars"}{$indVarName}{"values"} = ();
	    $index = $#{$hspData{"indVars"}{$indVarName}{"values"}};
	    $hspData{"indVars"}{$indVarName}{"index"} = $index;
#		print "indVar: $indVarName($index) = undef\n";
	    
	    # this is the innerloop variable
	    $innerLoopVarName = $indVarName;

	    if ($' =~ /(?:SWEEP\s+)?DATA\s*=\s*(\S+)/i)
	    {
#		print "' = $'\n";
		$dataBlock = $1;
#		print "setting datablockName = $dataBlock\n";
	    }
	}
	elsif (($section==$INIT) && /^\s*\.TRAN\s+/i)
	{
            if ( $' =~ /monte/ )
            {
              $MonteFlag = 1;
            }

            my $parameter = "time";
	    $indVarName = $parameter;
	    if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
	    {
		push(@indVarOrder, $indVarName);
		if ($Debugging > 9)
		{
		    print "adding indVarName = $indVarName\n";
		}
	    }
	    $hspData{"indVars"}{$indVarName}{"values"} = ();
	    $index = $#{$hspData{"indVars"}{$indVarName}{"values"}};
	    $hspData{"indVars"}{$indVarName}{"index"} = $index;
#	    print "indVar: $indVarName($index) = undef\n";
	    
	    # this is the innerloop variable
	    $innerLoopVarName = $indVarName;
	}
	elsif (($section==$INIT) && /^\s*\.DATA\s+(\S+)\s+/i)
	{
	    $dataBlockName = $1;
	    $hspData{"dataBlocks"}{$dataBlockName} = {};
	    while ($' =~ /^(\S+)\s*/)
	    {
		#### device parameter Xref backsubstitution here
		my @fragments = split('\.', $1);
#		print "3: ($1) parameter = $fragments[1]\n";
		if ($#fragments == 1)
		{
		    $fragments[1] = dKitParameter->dialect2result($fragments[1], "hspice");
		}
		$indVarName = join('.', @fragments);
	  
		push(@{$hspData{"dataBlocks"}{$dataBlockName}{"indVarNames"}}, $indVarName);
		if (!exists($hspData{"indVars"}{$indVarName}{"values"}))
		{
		    push(@indVarOrder, $indVarName);
		    if ($Debugging > 9)
		    {
			print "adding indVarName = $indVarName\n";
		    }
		}
		@{$hspData{"indVars"}{$indVarName}{"values"}} = ();
		$hspData{"indVars"}{$indVarName}{"index"} = -1;
#		print "indVar: $indVarName(-1) = undef\n";
	    }
	    # this is the innerloop variable
	    $index = 0;
	    while (<HSP_FILE>)
	    {
#		print " processing $_\n";
		if (/^\s*\.ENDDATA/i)
		{
		    last;
		}
		elsif (/^\s*\+\s+/)
		{
		    $_ = $';
		    while (s/([$scaleFactors])/$convertScale{$1}/){};
		    @values = split;
#		    print "@values\n";
		    @{$hspData{"dataBlocks"}{$dataBlockName}{"values"}[$index]} = @values;
#		    print "@{$hspData{dataBlocks}{$dataBlockName}{values}[$index]}" . "\n";
		    $index++;
		}
	    }
#	    print "dataBlock: $dataBlockName{\"indVarNames\"} = @{$hspData{\"dataBlocks\"}{$dataBlockName}{\"indVarNames\"}}\n";
	}
	elsif (($section==$INIT) && /^\s*\.TEMP\s+/i)
	{
	    if (!exists($hspData{"indVars"}{"temp"}{"values"}))
	    {
		push(@indVarOrder, "temp");
		if ($Debugging > 9)
		{
		    print "adding indVarName = temp\n";
		}
	    }
	    $_ = $';
	    while (s/([$scaleFactors])/$convertScale{$1}/){};
	    @{$hspData{"indVars"}{"temp"}{"values"}} = split;
	    $hspData{"indVars"}{"temp"}{"index"} = -1;
#	    print "indVar: temp($hspData{\"indVars\"}{\"temp\"}{\"index\"})\n";
	}
	elsif (($section==$INIT) && /^\s*\.PRINT\s+((AC|DC|TRAN)\s+)?/i)
	{
	    @depVarNames = split(/[ \b\t\n]+/, $');
#	    print "Dependent variables = list(@depVarNames)\n";
	    foreach $depVarName (@depVarNames)
	    {
		if ($depVarName =~ /^I\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$1}{"i1"} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^I(\d+)\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$2}{"i$1"} = {};
#		    print "device: $2\n"
		}
		elsif ($depVarName =~ /^IR\((\S+)\)/i)
		{
		    push (@devicesWithComplexResults, $1 . ":i1");
		    $hspData{"depVars"}{$1}{"i1_real"} = {};

#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^II\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$1}{"i1_imag"} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^IR(\d+)\((\S+)\)/i)
		{
		    push (@devicesWithComplexResults, $2 . ":i" . $1);
		    $hspData{"depVars"}{$2}{"i$1_real"} = {};
#		    print "device: $2\n"
		}
		elsif ($depVarName =~ /^II(\d+)\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$2}{"i$1_imag"} = {};
#		    print "device: $2\n"
		}
		elsif ($depVarName =~ /^V\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$1}{"v"} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^VR\((\S+)\)/i)
		{
		    push (@devicesWithComplexResults, $1 . ":v");
		    $hspData{"depVars"}{$1}{"v_real"} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^VI\((\S+)\)/i)
		{
		    $hspData{"depVars"}{$1}{"v_imag"} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^(\S+):(\S+)/i)
		{
		    #### device parameter Xref backsubstitution here
#		print "4: parameter = $2\n";
		    my $parameter = dKitParameter->dialect2result($2, "hspice");
		    $hspData{"depVars"}{$1}{$parameter} = {};
#		    print "device: $1\n"
		}
		elsif ($depVarName =~ /^(\S+)=PAR\('\S+'\)/i)
		{
		    if ($1 =~ /^(\S+)_(\S+)/i)
		    {
#			print "5: parameter = $2\n";
			#### device parameter Xref backsubstitution here
#			my $parameter = dKitParameter->dialect2result($2, "hspice");
#  we do not do backsubstitution here, because it should be done while creating the parametername
			my $parameter = $2;
			$hspData{"depVars"}{$1}{$parameter} = {};
#			print "device = $1, variable = $parameter\n";
		    }
		    else
		    {
			$hspData{"depVars"}{"equations"}{$1} = {};
#			print "device: equations\n"
		    }
		}
		elsif ($depVarName =~ /^S(\d)(\d)\((R|I)\)/i)
		{
		    $depVarName = "S[" . $1 . "," . $2 . "]";
		    if (!defined($hspData{"depVars"}{"sParams"}{$depVarName}))
		    {
			$hspData{"depVars"}{"sParams"}{$depVarName} = {};
#			print "device = SParam, variable = $depVarName\n"
		    }
		}
		elsif ($depVarName =~ /^ONOISE/i)
		{
		    $hspData{"depVars"}{"noise"}{"onoise"} = {};
#		    $hspData{"depVars"}{"noise"}{"rx"} = {};
#		    print "device = noise, variables = onoise, rx\n";
		    last;
		}
		else
		{
		    print "ERROR: Didn't recognize independent parameter $depVarName\n"; return;
		}
	    }
	}
	elsif (($section==$INIT) && /\s*dc\s+transfer\s+curves\s+.*?temp\s*=\s*($real)\s*$/i)
	{
	    $temp = $1;
	    if (exists $hspData{"indVars"}{"temp"})
            {
		@temps = @{$hspData{"indVars"}{"temp"}{"values"}};
		for ($index = 0; $index <= $#temps; $index++)
		{
		    if ($temp == $temps[$index]) { last; }
		}
		if ($index > $#temps)
		{
#		    push(@{$hspData{"indVars"}{"temp"}{"values"}}, $temp);
#		      $index = $#{$hspData{"indVars"}{"temp"}{"values"}};
#### do not add value
		    $index = -1;
		}
		$hspData{"indVars"}{"temp"}{"index"} = $index;
	    }
#	    $dataBlockSweep = 0;
#	    print "resetting datablocsweep\n";
	}


	elsif (($section==$INIT) && /\s*\*\*\*\s*monte\s*carlo\s*index\s*=\s*($real)\s*/i)
	{
	    my $MonteIndex;
	    $temp = $1;
	    if (exists $hspData{"indVars"}{"iteration"})
            {
 		@temps = @{$hspData{"indVars"}{"iteration"}{"values"}};
		for ($index = 0; $index <= $#temps; $index++)
		{
#	             print "temps[$index] = $temps[$index]\n";
		    if ($temp == $temps[$index]) { last; }
		}
		if ($index > $#temps)
		{
		    push(@{$hspData{"indVars"}{"iteration"}{"values"}}, $temp);
		    $MonteIndex = $#{$hspData{"indVars"}{"iteration"}{"values"}};
		}
		$hspData{"indVars"}{"iteration"}{"index"} = $MonteIndex;
	    }

	    # Now look for Monte Carlo Parameters, save them until
	    #  innerLoopVarName is read
	    my ($value);
	    @MonteDepVarNames = ();
	    @MonteDeviceNames = ();
	    @MonteValues = ();
	    do
	    {
		$_ = <HSP_FILE>;
	    }  until ( /^\s*\d+:(\w+)/ );

	    do
	    {
		push @MonteDepVarNames, ($1);
		$_ = <HSP_FILE>;
		if ( ! /\s*\d+:(\w+)\s+=\s+($real)/ )
		{
		    croak ("Monte Carlo Parameters not parsable, readHspiceData (dKitResults.pm)");
		}
		push @MonteDeviceNames, ($1);
		push @MonteValues, ($2);
		$_ = <HSP_FILE>;
	    }  while ( /^\s*\d+:(\w+)/ );
	}

	elsif (($section==$INIT) && /\s*ac\s+analysis\s+.*temp\s*=\s*($real)\s*$/i)
	{
	    $temp = $1;
	    if (exists $hspData{"indVars"}{"temp"})
            {
		@temps = @{$hspData{"indVars"}{"temp"}{"values"}};
		for ($index = 0; $index <= $#temps; $index++)
		{
		    if ($temp == $temps[$index]) { last; }
		}
		if ($index > $#temps)
		{
#		    push(@{$hspData{"indVars"}{"temp"}{"values"}}, $temp);
#		    $index = $#{$hspData{"indVars"}{"temp"}{"values"}};
#### do not add value
		    $index = -1;
		}
		$hspData{"indVars"}{"temp"}{"index"} = $index;
	    }
#	    $dataBlockSweep = 0;
#	    print "resetting datablocsweep\n";
	}
	elsif (($section==$INIT) && /\s*transient\s+analysis\s+.*temp\s*=\s*($real)\s*$/i)
	{
	    $temp = $1;
	    if (exists $hspData{"indVars"}{"temp"})
            {
		@temps = @{$hspData{"indVars"}{"temp"}{"values"}};
		for ($index = 0; $index <= $#temps; $index++)
		{
		    if ($temp == $temps[$index]) { last; }
		}
		if ($index > $#temps)
		{
#		    push(@{$hspData{"indVars"}{"temp"}{"values"}}, $temp);
#		    $index = $#{$hspData{"indVars"}{"temp"}{"values"}};
###### index not found
		    $index = -1;
		}
		$hspData{"indVars"}{"temp"}{"index"} = $index;
	    }
#	    $dataBlockSweep = 0;
#	    print "resetting datablocsweep\n";
	}
	elsif (($section==$INIT) && /data\s+name\s+=\s+(\S+)\s+/i)
	{
	    $dataBlockName = $1;
	    $dataBlockSweep = 1;
#	    print "ending $'\n";
	    if ($' =~ /index\s+=\s+(\d+)/)
            {
#		print "found index = $1\n";
		$hspData{"dataBlocks"}{$dataBlockName}{"index"} = $1 - 1;
		$resetBlockSweep = 0;
	    } else
	    {
#		print "setting index = -1\n";
		$hspData{"dataBlocks"}{$dataBlockName}{"index"} = -1;
		$resetBlockSweep = 1;
	    }
#	    print "datablockindex = $hspData{dataBlocks}{$dataBlockName}{index}\n";
#	    $innerLoopVarName = $hspData{"dataBlocks"}{$dataBlockName}{"indVarNames"}[0];
#	    print "dataBlockName = $dataBlockName\n";
#	    print "innerLoopVarName = $innerLoopVarName\n";
#	    print "dataBlockSweep = $dataBlockSweep\n";
	}
	elsif (($section==$INIT) && /^\s*x\s*$/i)
	{
	    $section = $DDEP;
	}
	elsif (($section == $DDEP) && /^\s*(\S+)\s+/i)
	{
	    # read dependent variable names
            my $indVarName = $1;
#	    print "Independent variable $indVarName\n";

	    my @tempDepVarNames = split(/[ \b\t\n]+/, $');
            @depVarNames = ();
	    @deviceNames = ();
#	    print "Dependent variables = list(" . join(" ", @tempDepVarNames) . ")\n";
	    foreach $depVarName (@tempDepVarNames)
	    {
#	        print "Dependent variable = $depVarName\n";
		if ($depVarName =~ /^S(\d)(\d)$/i)
		{
		    $depVarName = "S[" . $1 . "," . $2 . "]";
		    push(@depVarNames, $depVarName);
		    push(@deviceNames, "sParams");
		}
		elsif ($depVarName eq "current")
		{
		    push(@depVarNames, "i1");
		    push(@deviceNames, "dummy");
		}
		elsif ($depVarName eq "i")
		{
		    push(@depVarNames, "i1");
		    push(@deviceNames, "dummy");
		} 
		elsif ($depVarName eq "voltage")
		{
		    push(@depVarNames, "v");
		    push(@deviceNames, "dummy");
		} 
		elsif ($depVarName eq "volt")
		{
		    push(@depVarNames, "v");
		    push(@deviceNames, "dummy");
		} 
		elsif ($depVarName eq "real")
		{
		    my $token = pop (@depVarNames);
		    push(@depVarNames, $token . "_real");
		}
		elsif ($depVarName eq "imag")
		{
		    my $token = pop (@depVarNames);
		    push(@depVarNames, $token . "_imag");
		}
		elsif ($depVarName =~ /^\d+$/)
		{
		    my $token = pop (@depVarNames);
		    if ($token =~ /^i1/)
                    {
                        my $replacement = "i$depVarName";
			$token =~ s/i1/$replacement/i;
		    } else
                    {
			print "No current found to substitute for\n";
		    }
		    push(@depVarNames, $token);
		}
		elsif ($depVarName =~ /^(\S+)_(\S+)$/)
		{
		    #### device parameter Xref backsubstitution here
#		print "6: parameter = $2\n";
#
# we should not do back substitution here, because it should have been done while creating the name
#		    my $parameter = dKitParameter->dialect2result($2, "hspice");
		    my $parameter = $2;
		    push(@depVarNames, $parameter);
		    push(@deviceNames, $1);
		}
		elsif ($depVarName eq "onoise")
		{
		    $depVarName = "onoise";
		    @depVarNames = ($depVarName);
		    push(@deviceNames, "noise");
#		    print "@deviceNames\n";
		    last;
		}
		else
		{
		    push(@depVarNames, $depVarName);
		    push(@deviceNames, "equations");
		}
	    }
	    if ($Debugging > 9)
	    {
		print "dependent variables = (@depVarNames)\n";
	    }
	    # read device names
	    $_ = <HSP_FILE>;
	    @types = ();
	    if (/^\s*/)
	    {
		@types = split(/[ \b\t\n]+/, $');
	    }
	    my $i = 0;
	    foreach $deviceName (@deviceNames)
	    {
		if ($deviceName eq "dummy")
		{
		    $deviceName = $types[$i];
		}
		$i = $i + 1;
	    }
	    if ($Debugging > 9)
	    {
		print "devices = list(@deviceNames)\n";
	    }
	    $section = $DDAT;
	}
	elsif (($section == $DDAT) && /^\s*y\s*$/i)
	{
	    if ($resetBlockSweep)
	    {
		$hspData{"dataBlocks"}{$dataBlockName}{"index"} = -1;
	    }
	    if ($innerLoopVarName)
	    {
		$hspData{"indVars"}{$innerLoopVarName}{"index"} = -1;
	    }
	    $section = $INIT;
	}
	elsif (($section == $DDAT) && /^\s*($real)[$scaleFactors]?\s+/i)
	{
	    # set innerloop values
#	    print "innerLoopVarName = $innerLoopVarName\n";
#	    print "dataBlockSweep = $dataBlockSweep\n";
	    if ($innerLoopVarName)
	    {
		$index = ++$hspData{"indVars"}{$innerLoopVarName}{"index"};
		if (!defined($hspData{"indVars"}{$innerLoopVarName}{"values"}[$index]))
		{
		    push(@{$hspData{"indVars"}{$innerLoopVarName}{"values"}}, $1);
		}
#		print "dataBlockIndex = $dataBlockIndex\n";
		$dataBlockIndex = $hspData{"dataBlocks"}{$dataBlockName}{"index"};
            } elsif ($dataBlockSweep)
	    {
		$dataBlockIndex = ++$hspData{"dataBlocks"}{$dataBlockName}{"index"};
	    }
	    if ($dataBlockSweep)
	    {
#		print "dataBlockName = $dataBlockName\n";
		my @dataBlockValues = @{$hspData{"dataBlocks"}{$dataBlockName}{"values"}[$dataBlockIndex]};
		@indVarNames = @{$hspData{"dataBlocks"}{$dataBlockName}{"indVarNames"}};
#		print "dataBlockIndex=$dataBlockIndex, @dataBlockValues , @indVarNames\n";
		for (my $tmpdataBlockndx = 0; $tmpdataBlockndx <= $#dataBlockValues; $tmpdataBlockndx++)
		{
		    $dataBlockValue = $dataBlockValues[$tmpdataBlockndx];
		    $indVarName = @indVarNames[$tmpdataBlockndx];
#		    print "indVarName = $indVarName\n";
		    @values = @{$hspData{"indVars"}{$indVarName}{"values"}};
		    for ($index = 0; $index <= $#values; $index++)
		    {
			if ($dataBlockValue == $values[$index])
			{
			    $hspData{"indVars"}{$indVarName}{"index"} = $index;
			    last;
			}
		    }
		    $hspData{"indVars"}{$indVarName}{"values"}[$index] = $dataBlockValue;
		    $hspData{"indVars"}{$indVarName}{"index"} = $index;
		    if ($Debugging > 9)
		    {
			print "indVar: $indVarName($index) = $dataBlockValue\n";
		    }
		}
	    }


        # create independent variable key
        $indVarKey = "";
        foreach $indVarName (keys %{$hspData{"indVars"}})
        {
            if ($indVarKey ne "")
            {
                $indVarKey = $indVarKey . ",";
            }
            $index = $hspData{"indVars"}{$indVarName}{"index"};
            if ($index < 0)
            {
                # /hped/apps/hspice/A-2008.03-SP1/hspice or newer HSPICE, index of temp becomes -1!.
                if ($indVarName eq "temp")
                {
                    if ($warned == 0)
                    {
                        warn("Index of $indVarName is negative! Changed to zero.\n");
                        $warned = 1;
                    }
                    $index=0;
                }
                else
                {
                    croak("can't process hspice result file\n  $indVarName 's index is negative");
                }
            }
            $indVarKey = $indVarKey . "$index";
        }

#        print "indVarkey = $indVarKey\n";

            # Store previously saved Monte Carlo Parameters
            if ( $#MonteValues > -1 )
            {
 
	        for ( my $i=0; $i <= $#MonteValues; $i++)
  	        {
                    my $value      = $MonteValues[$i];
		    $deviceName = $MonteDeviceNames[$i];
		    $depVarName = $MonteDepVarNames[$i];
		    $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey} = $value;
		}
            }
            @MonteValues = ();
            @MonteDeviceNames = ();
            @MonteDepVarNames = ();

	    my $i = 0;
	    $_ = $';
	    while (s/([$scaleFactors])/$convertScale{$1}/){};
	    my @depVarValues = split;

	    if ($Debugging > 9)
	    {
		print "list(@deviceNames), list(@depVarNames), list(@depVarValues)\n";
	    }
	    foreach my $value (@depVarValues)
	    {
#		print "value = $value\n";
		$deviceName = $deviceNames[$i];
		$depVarName = $depVarNames[$i];
		if ($deviceName eq "sParams" && $types[$i] eq "real")
		{
		    $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0] = $value;
		    if ($Debugging > 9)
		    {
			printf "depVar: %s\.%s.re = %12.9g\n", $deviceName, $depVarName, $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[0];
		    }
		}
		elsif ($deviceName eq "sParams" && $types[$i] eq "imag")
		{
		    $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1] = $value;
		    if ($Debugging > 9)
		    {
			printf "depVar: %s\.%s.im = %12.9g\n", $deviceName, $depVarName, $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey}[1];
		    }
		}
		elsif ($deviceName eq "noise")
		{
		    $depVarName = "onoise";
		    $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey} = $value;
#		    printf "depVar: %s\.%s(%d:%s) = %12.9g\n", $deviceName, $depVarName, $i, $indVarKey, $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey};
		    if ($#depVarValues >= 2)
		    {
			$depVarName = "rx";
			$hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey} = $depVarValues[1]/
			    $depVarValues[2];
#			printf "depVar: %s\.%s(%d:%s) = %12.9g\n", $deviceName, $depVarName, $i, $indVarKey, 
			$hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey};
		    }
		    else
		    {
#			print "ERROR: Can't find noise transfer function data v(1) and i(vdd)\n"; return;
		    }
		    last;
		}
		else
		{
		    $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey} = $value;
#		    printf "depVar: %s\.%s(%d:%s) = %12.9g\n", $deviceName, $depVarName, $i, $indVarKey, $hspData{"depVars"}{$deviceName}{$depVarName}{$indVarKey};
		}
		$i++;
	    }
	}
    }

    close(HSP_FILE);
    if ( $writeOrderGiven == 0)
    {
	my $havefreq = 0;
	foreach my $var (@indVarOrder)
	{
	    if ($var eq "freq")
	    {
		$havefreq = 1;
	    } else
	    {
		push(@{ $hspData{'indVarWriteOrder'} }, $var);
	    }
	}
	if ($havefreq)
	{
	    push(@{ $hspData{'indVarWriteOrder'} }, "freq");
	}
    } else
    {    
	@ {$hspData{'indVarWriteOrder'}} = @indVarOrder;
    }
    # merge complex stuff
    foreach my $item (@devicesWithComplexResults)
    {
	($deviceName, $depVarName) = split(":", $item);
#	print "item = $item, deviceName = $deviceName, depVarName = $depVarName\n";
	my $tmpDataP = $hspData{"depVars"}{$deviceName}{$depVarName . "_real"};
	foreach my $key (keys %{$tmpDataP})
	{
	    $hspData{"depVars"}{$deviceName}{$depVarName}->{$key}[0] = $tmpDataP->{$key};
	}
	delete($hspData{"depVars"}{$deviceName}{$depVarName . "_real"});
	$tmpDataP = $hspData{"depVars"}{$deviceName}{$depVarName . "_imag"};
	foreach my $key (keys %{$tmpDataP})
	{
	    $hspData{"depVars"}{$deviceName}{$depVarName}->{$key}[1] = $tmpDataP->{$key};
	}
	delete($hspData{"depVars"}{$deviceName}{$depVarName . "_imag"});
    }


    #--- check the results ---
    if ($Debugging)
    {
	print "### BEGIN HSP DATA ###\n";
	    #--- write independent variables + values
	    foreach $indVarName (keys %{$hspData{"indVars"}})
	    {
		print "indVar: $indVarName = list(@{$hspData{\"indVars\"}{$indVarName}{\"values\"}})\n";
	    }
	
	#--- write dependent variable names
	foreach $deviceName (keys %{$hspData{"depVars"}})
	{
	    foreach $depVarName (keys %{$hspData{"depVars"}{$deviceName}})
	    {
		print "depVar: $deviceName.$depVarName\n";
	    }
	}
	print "### END HSP DATA ###\n";
    }
    
    my @indVarCreateOrder = keys %{$hspData{"indVars"}};
    $hspData{"indVarCreateOrder"} = \@indVarCreateOrder;
    
    bless(\%hspData, "dKitResults");
#    print Dumper \%hspData;
    return \%hspData;
}

###############################################################################
#
# readCitiData
#
###############################################################################

sub readCitiData
{
    my $citiFileName = shift;

    my %citiData = ();
    my $citiFile;
    my @indVarCreateOrder = ();
    my $nrOfIndVars;
    my $indVarName;
    my @depVarNames;
    my $depVarName;

    my $deviceName;
    my $index;

    my @maxCounts = ();
    my @indices = ();

    if ($Debugging > 9)
    {
	print "...reading Citi data\n";
    }

    #--- open the Hspice data file ---
    if (!open(CITI_FILE, "<$citiFileName"))
    {
	print "ERROR: Cannot open Citi data file $citiFileName!\n"; return;
    }

    #--- parse the Hspice data file ---
    while (<CITI_FILE>)
    {
#        print "processing  $_ ";
	if (/^\s\#/)
	{
	    next;
	}
	elsif (/^\s*VAR\s+(\S+)\s+(\S+)\s+(\d+)/i)
	{
	    $indVarName = $1;
	    if (!exists($citiData{"indVars"}{$indVarName}{"index"}))
	    {
		push(@indVarCreateOrder, $indVarName);
		$citiData{"indVars"}{$indVarName}{"index"} = $#indVarCreateOrder;
		if ($Debugging > 9)
		{
		    print "adding indVarName = $indVarName\n";
		}
		@{$citiData{'indVarCreateOrder'}} = @indVarCreateOrder;
	    }
	}
	elsif (/^\s*DATA\s+(\S+)\s+(\w+)/i)
	{
	    my $name = $1;
	    push(@depVarNames, $name);
	    if ($name =~ /\s*S\s*\[\s*\d+\s*\,\s*\d+\s*\]/)
	    {
		$citiData{"depVars"}{"sParams"}{$name} = {};
	    } else
	    {
		my @fragments = split('\.', $name);
		if ($#fragments == 1)
                {
		    $citiData{"depVars"}{$fragments[0]}{$fragments[1]} = {};
		} else
		{
		    $citiData{"depVars"}{"citi"}{$name} = {};
		}
	    }
	    if ($Debugging > 9)
	    {
		print "adding depVarName = $name\n";
	    }
	}
	elsif (/\s*VAR_LIST_BEGIN\s*/i)
	{
	    $indVarName = shift @indVarCreateOrder;
	    if ($Debugging > 9)
	    {
		print "loading indVarName $indVarName\n";
	    }
	    while (<CITI_FILE>)
	    {
		if (/\s*VAR_LIST_END\s*/i)
		{
		    last;
		} elsif (/\s*($real)\s*,\s*($real)\s*$/)
		{
		    push (@{$citiData{"indVars"}{$indVarName}{"values"}}, "$1, $2");
#		     print "complex = $1 + j $2\n"
		} elsif (/\s*($real)\s*$/)
		{
		    push (@{$citiData{"indVars"}{$indVarName}{"values"}}, $1);
#                    print "real = $1\n"
		}
	    }
	}
	elsif (/\s*BEGIN\s*/i)
	{
	    my $i_cnt = 0;
	    $depVarName = shift @depVarNames;
	    if ($Debugging > 9)
	    {
		print "loading depVarName $depVarName\n";
	    }
# initialize index array
	    @indVarCreateOrder = @{$citiData{'indVarCreateOrder'}};
	    if ($#maxCounts == -1)
	    {
		for ($i_cnt = 0; $i_cnt <= $#indVarCreateOrder; $i_cnt++)
		{
		    $indVarName = $indVarCreateOrder[$i_cnt];
		    $citiData{"indVars"}{$indVarName}{"index"} = $i_cnt;
		    $maxCounts[$i_cnt] = $#{$citiData{"indVars"}{$indVarName}{"values"}};
#		     print "max Counts ($i_cnt) ($indVarName) = $maxCounts[$i_cnt]\n";
		}
#	         @indVarCreateOrder = keys %{$citiData{'indVars'}};
#                @{$citiData{'indVarCreateOrder'}} = @indVarCreateOrder;
		@indVarCreateOrder = @{$citiData{'indVarCreateOrder'}};
		for ($i_cnt = 0; $i_cnt <= $#indVarCreateOrder; $i_cnt++)
		{
		    $indVarName = $indVarCreateOrder[$i_cnt];
		}
	    }
	    for ($i_cnt = 0; $i_cnt <= $#indVarCreateOrder; $i_cnt++)
	    {
		$indices[$i_cnt] = 0;
#	         print "indices[$i_cnt] = $indices[$i_cnt]\n"
	    }

	    my $depVarValuesP;
	    if ($depVarName =~ /\s*S\s*\[\s*\d+\s*\,\s*\d+\s*\]/)
	    {
		$depVarValuesP = $citiData{"depVars"}{"sParams"}{$depVarName};
	    } else
	    {
		my @fragments = split('\.', $depVarName);
		if ($#fragments == 1)
                {
		    $depVarValuesP = $citiData{"depVars"}{$fragments[0]}{$fragments[1]};
		} else
		{
		    $depVarValuesP =$citiData{"depVars"}{"citi"}{$depVarName};
		}
	    }
	    my $key;
	    while (<CITI_FILE>)
	    {
		$key = join(",", @indices);
#                print "key $key\n";
		if (/\s*END\s*/i)
		{
		    last;
		} elsif (/\s*($real)\s*,\s*($real)\s*$/)
		{
		    $depVarValuesP->{$key}[0] = $1;
		    $depVarValuesP->{$key}[1] = $6;
		} elsif (/\s*($real)\s*$/)
		{
		    $depVarValuesP->{$key} = "$1";
		}
		#recalculate indices
		for ($i_cnt = $#indVarCreateOrder; $i_cnt >= 0; $i_cnt--)
		{
		    $indices[$i_cnt]++;
#                    print "set indices $i_cnt to $indices[$i_cnt]\n";
#                    print "($indices[$i_cnt] <= $maxCounts[$i_cnt])\n";
		    if ($indices[$i_cnt] <= $maxCounts[$i_cnt])
		    {
			last;
		    }
		    $indices[$i_cnt] = 0;
		}
	    }
	}
    }
    close(CITI_FILE);

  #--- check the results ---
    if ($Debugging)
    {
	print "### BEGIN HSP DATA ###\n";
  #--- write independent variables + values
	foreach $indVarName (keys %{$citiData{"indVars"}})
	{
	    print "indVar: $indVarName = list(@{$citiData{\"indVars\"}{$indVarName}{\"values\"}})\n";
	}
	
	#--- write dependent variable names
	foreach $deviceName (keys %{$citiData{"depVars"}})
	{
	    foreach $depVarName (keys %{$citiData{"depVars"}{$deviceName}})
	    {
		print "depVar: $deviceName.$depVarName\n";
	    }
	}
	print "### END CITI DATA ###\n";
    }
    bless(\%citiData, "dKitResults");
    return \%citiData;
}

######################### utility debug functions


sub list2str
{
    my @myList = @_;
    my $string = "";
    my $value;
    foreach $value (@myList)
    {
        while (ref($value) eq "REF")
        {
	    $value = ${$value};
	}
        if (ref($value) eq "SCALAR")
        {
	    $value = "(->S:" . ${$value} . ")";
        } elsif (ref($value) eq "ARRAY")
        {
	    $value = "(->L:" . list2str (@{$value}) . ")";
        } elsif (ref($value) eq "HASH")
        {
 	    $value = "(->H:" . hash2str (%{$value}) . ")";
        } else
        {
	    $value = "raw $value\n";
        }
	$string = $string . "$value, " ;
     }
     return $string;
}

sub hash2str
{
    my %myHash = @_;
    my $string = "";
    my $key;
    my $value;

    foreach $key (keys(%myHash))
    {
        $value = $myHash{$key};
        while (ref($value) eq "REF")
        {
	    $value = ${$value};
	}
        if (ref($value) eq "SCALAR")
        {
	    $value = "(->S:" . ${$value} . ")";
        } elsif (ref($value) eq "ARRAY")
        {
	    $value = "(->L:" . list2str (@{$value}) . ")";
        } elsif (ref($value) eq "HASH")
        {
 	    $value = "(->H:" . hash2str (%{$value}) . ")";
        } else
        {
	    $value = "raw $value";
        }
	$string = $string . "\n  $key=$myHash{$key} $value" ;
    }
    return $string
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

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : dKitTemplate->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
        carp ("dKitResult debugging turned on\n");
    } else
    {
        carp ("dKitResult debugging turned off\n");
    }
}

#####################################################################
# object method : dump2str
# purpose : dump the result content to string
# call vocabulary
#
# $Result->dump2str;
#

sub dump2str {
    my $self = shift;
    my $string = "Results:\n";
    $string = $string . hash2str(%{$self}) . "\n";
    return $string;
}

1

package dKitCircuit;

use strict;
use dKitAnalysis;
use dKitInstance;
use dKitParameter;
use dKitResults;
use dKitTemplate;



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
$dKitCircuit::VERSION = $VERSION;

#####################################################
# temporary version checking....
# 

use Cwd;
my $workDirectory = cwd;

if ($VERSION == 2)
{   ### move old legacy version 1 code out of the way if it still is there ....
    my $doexit = 0;

    if (-f "./dKitTemplate.pm")
    {
	if (! -f "./dKitCircuit.pm")
	{
	    print "This newer version of the design kit model verification tool uses\n";
	    print "an improved database model for supporting templates. Therefore the\n";
	    print "file $workDirectory/dKitTemplate.pm will be\n";
	    print "moved to $workDirectory/dKitTemplate.pm.old\n";
	    print "and you will have to reinstall the template database by running\n";
	    print "the initialization script (dKitSetupWork.pl) and your custom\n";
	    print "template creation scripts\n";
	    $doexit = 1;
	} else
	{ ### we are in the myLibPath directory !!!
	}
    }
    
    if (-f "./dKitParameter.pm")
    {
	if (! -f "./dKitCircuit.pm")
	{
	    print "This newer version of the design kit model verification tool uses\n";
	    print "an improved database model for supporting parameters. Therefore the\n";
	    print "file $workDirectory/dKitParameter.pm will be\n";
	    print "moved to $workDirectory/dKitParameter.pm.old\n";
	    print "and you will have to reinstall the parameter database by running\n";
	    print "the initialization script (dKitSetupWork.pl) and your custom\n";
	    print "parameter creation scripts\n";
	    $doexit = 1;
	} else
	{ ### we are in the myLibPath directory !!!
	}
    }    

    if ($doexit)
    {
	exit(0);
    }
}

if (! defined $dKitTemplate::{version})
{
    print "do not have versioning.\n";
}


#############################################################################
####
## include predefined subcircuits
#
# code that deals with subcircuits is at the end of this file
#


my $nameSpaceDelimitor = "_";  ### global, used when inlining subcircuits ...
$dKitCircuit::nameSpaceDelimitor = $nameSpaceDelimitor;
my %Subcircuits;

if ( -f "$workDirectory/dKitSubcircuitDB.pl")
{
    require "$workDirectory/dKitSubcircuitDB.pl";
} else
{
    %Subcircuits = ();
}


#############################################################################
#### Debugging

use Carp;
my $Debugging = 0;

################################################
# class method : debug
# purpose : set debugging level for class
# call vocabulary
#
# dKitCircuit->debug(level);
#   0 : debugging off.
#

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : dKitCircuit->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
	carp ("Circuit debugging turned on\n");
    } else
    {
	carp ("Circuit debugging turned off\n");
    }
}

##### global variables, keeps all circuits currently defined

my %Circuits = ();


######################################
# class method : new
# purpose : create new circuit definition
# call vocabulary
#
# dKitCircuit->new([circuitName]);
#
# e.g
#
#  $Mix = dKitCircuit->new();

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self;

    $self = +{};
    bless($self, $class);
    if (@_)
    {
	$self->circuitName(@_);
    } else
    {
	my $circuitName = "";
	$self->{CIRCUITNAME} = $circuitName;
    }
    $self->{_GlobalCircuits} = \%Circuits;

    $self->{SIMULATOROPTIONS} = [];
    $self->{MODELLIBRARY} = [];
    $self->{ANALYSIS} = [];
    $self->{INSTANCES} = [];

# used when defining subcircuits...
    $self->{NODES} = undef;
    $self->{PARAMETERS} = undef;
    $self->{HEADERTEMPLATES} = undef;
    $self->{FOOTERTEMPLATES} = undef;

# circuits are build when doing a netlist only
    $self->{CIRCUITS} = undef;
    $self->{FLATTENEDINSTANCES} = undef;
    $self->{FLATTENEDANALYSES} = undef;

    if ($Debugging > 100)
    {
	carp("creating new circuit\n");
    }
    return $self;
}

######################################
# object method : DESTROY
# purpose : destoy circuit
# call vocabulary
#
# $Circuit->DESTROY;
#
 
sub DESTROY 
{
    my $self = shift;
    if ($self->circuitName)
    {
	delete ${$self->{_GlobalCircuits}}{$self->circuitName};
    }
}

######################################
# object method : remove
# purpose : remove all global definitions links to a circuit.
# call vocabulary
#
# $Circuit->remove;
# dKitCircuit->remove(circuitName);
 
sub remove
{
    my $self = shift;
    if (! ref $self) 
    { 
	my $circuitName = shift;
	if ($circuitName)
	{
	    delete ${Circuits}{$circuitName};
	    delete ${Subcircuits}{$circuitName};
	} else
	{
	    croak("Usage: dKitCircuit->delete(circuitName);");
	}
    } else
    {
	if ($self->circuitName)
	{
	    delete ${$self->{_GlobalCircuits}}{$self->circuitName};
            delete ${Subcircuits}{$self->circuitName};
        }
    }
}

#####################################################################
# object method : blessContent
# purpose : add the necessary class definitions to each value
# call vocabulary
#
# $Circuit->blessInstances
#
# e.g.
#    $Circuit->blessContent;

sub blessContent
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    foreach my $analysis (@ {$self->{ANALYSIS} })
    {
       bless($analysis, "dKitAnalysis");
       $analysis->blessContent;
    }

    foreach my $instance (@ {$self->{SIMULATOROPTIONS} })
    {
       bless($instance, "dKitInstance");
       $instance->init;
    }

    foreach my $instance (@ {$self->{MODELLIBRARY} })
    {
       bless($instance, "dKitInstance");
       $instance->init;
    }
 
    foreach my $instance (@ {$self->{INSTANCES} })
    {
       bless($instance, "dKitInstance");
       $instance->init;
    }
    return;
}

#####################################################################
# object method : circuitName
# purpose : get the circuitName for a circuit
# call vocabulary
#
# $Circuit->circuitName([CircuitName]);
#

sub circuitName {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_) 
    {
	my $oldName = $self->{CIRCUITNAME};
	my $newName = shift;
	my $overwrite = shift;
	### deactivate overwrite....
	$overwrite = 0;

	if (! $newName)
        {
	    carp ("Cannot set circuitName to \"\"\n");
	    return "";
	}

	my $myNewSubcircuit = dKitCircuit->getSubcircuit($newName);
	my $myOldSubcircuit = 0;
	if ($oldName)
        {
	   $myOldSubcircuit = dKitCircuit->getSubcircuit($oldName);
	   ### $myOldSubcircuit, should be equal to $self if not zero.
	}

	if ($myNewSubcircuit || $myOldSubcircuit)
	{
	    if (!$overwrite)
	    {   ### do not do anything as operations are prohibited on subcircuits
		if ($myNewSubcircuit && $myOldSubcircuit)
		{
		    if ($myNewSubcircuit != $myOldSubcircuit)
		    {
			croak("\n\nCannot rename circuit.\nBoth subcircuits $newName and $oldName exist.\nUse the overwrite option to force the renaming.\n");
		    } else
		    {
			croak("\n\nCannot create circuit $newName.\nA subcircuit with that name already exists.\nUse the overwrite option to force the renaming.\n");
		    }
		} elsif ($myNewSubcircuit)
		{
		    croak("\n\nCannot create circuit $newName.\nA subcircuit with that name already exists.\nUse the overwrite option to force the renaming.\n");
		} else
		{
		    croak("\n\nCannot rename circuit $oldName, it is a subcircuit.\nUse the overwrite option to force the renaming.\n");
		}
	    } else
	    {
		if ($myNewSubcircuit && $myOldSubcircuit)
		{
		    if ($myNewSubcircuit != $myOldSubcircuit)
		    {
			delete $Subcircuits{$newName};
			carp("subcircuit $newName forced to be deleted.\n");
			delete $Subcircuits{$oldName};
			$Subcircuits{$newName} = $self;
			$self->{CIRCUITNAME} = $newName;
			$self->createSubcircuitHeaderAndFooters(1);
			carp("subcircuit $oldName renamed to $newName.\n");
		    } 
		} elsif ($myNewSubcircuit)
		{   ### move 
		    if ($self != $myNewSubcircuit)
		    {
			delete $Subcircuits{$newName};
			carp("Creation of the new circuit $newName forced the deletion\nof the existing subcircuit with the same name.\n");
		    }
		} else
		{   ### rename an existing subcircuit....
		    delete $Subcircuits{$oldName};
		    $Subcircuits{$newName} = $self;
		    $self->{CIRCUITNAME} = $newName;
		    $self->createSubcircuitHeaderAndFooters(1);
		    carp("subcircuit $oldName renamed to $newName.\n");
		}
		if ($self->{CIRCUITNAME})
		{
		    delete $Circuits{$self->{CIRCUITNAME}};
		}
		$self->{CIRCUITNAME} = $newName;
		$Circuits{$self->{CIRCUITNAME}} = $self;
	    }
	} else
	{
	    if ($self->{CIRCUITNAME})
	    {
		delete $Circuits{$self->{CIRCUITNAME}};
	    }
	    $self->{CIRCUITNAME} = $newName;
	    $Circuits{$self->{CIRCUITNAME}} = $self;
	}
    }
    return $self->{CIRCUITNAME};
}

#####################################################################
# object method : addInstance
# purpose : add to the circuit the reference to an Instance
# call vocabulary
#
# $Circuit->addInstance(instanceReference);
#
# e.g.
#    $Circuit->addInstance($C);

sub addInstance
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $instance = shift;
        if (! $instance)
        {
	    croak("addInstance: adding undefined instance to circuit;\n");
        } elsif (ref $instance ne "dKitInstance")
        {
	    my $type = ref $instance;
	    croak("addInstance: reference to $type given instead of reference to dKitInstance;\n");
        }
        @ {$self->{INSTANCES} } = (@ {$self->{INSTANCES}}, $instance);
### reset circuits;
	$self->{CIRCUITS} = undef;
    }
    return;
}

#####################################################################
# object method : removeInstance
# purpose : remove the reference to an Instance from the circuit
# call vocabulary
#
# $Circuit->removeInstance(instanceReference);
#
# e.g.
#    $Circuit->removeInstance($C | "all");

sub removeInstance
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $instance = shift;
        if (! $instance)
        {
	    carp("removeInstance: undefined instance given;\n   Remove Ignored\n");
        } elsif ($instance eq "all")
        {
	    @ {$self->{INSTANCES} } = ();
        } elsif (ref $instance ne "dKitInstance")
        {
	    my $type = ref $instance;
	    carp("removeInstance: reference to $type given instead of reference to dKitInstance;\n   Remove ignored\n");
        } else
        {
	    if (grep($instance == $_, @ {$self->{INSTANCES} }))
	    {
		@ {$self->{INSTANCES} } = grep($instance != $_, @ {$self->{INSTANCES} });
	### reset circuits;
		$self->{CIRCUITS} = undef;
	    } else
	    {
		carp("removeInstance: reference to remove not found;\n   Remove ignored\n");
	    }
	}
    }
    return;
}

#####################################################################
# object method : addAnalysis
# purpose : add to the circuit the reference to an Analysis
# call vocabulary
#
# $Circuit->addAnalysis(analysisReference);
#
# e.g.
#    $Circuit->addAnalysis(C);

sub addAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $instance = shift;
        if (! $instance)
        {
	    croak("addAnalysis: adding undefined analysis to circuit;\n");
        } elsif (ref $instance ne "dKitAnalysis")
        {
	    my $type = ref $instance;
	    croak("addAnalysis: reference to $type given instead of reference to dKitAnalysis;\n");
        }
        @ {$self->{ANALYSIS} } = (@ {$self->{ANALYSIS}}, $instance);
    }
    return;
}

#####################################################################
# object method : removeAnalysis
# purpose : remove from the circuit the reference to an Analysis
# call vocabulary
#
# $Circuit->removeAnalysis(analysisReference);
#
# e.g.
#    $Circuit->removeAnalysis($DC);

sub removeAnalysis
{
    my $self = shift;
    if (! ref $self) 
    { 
	confess "Object method called as class method";
    }
    if (@_)
    {
 	my $instance = shift;
        if (! $instance)
        {
	    carp("removeAnalysis: undefined analysis given.\n   Remove ignored;\n");
        } elsif ($instance eq "all")
        {
	    @ {$self->{ANALYSIS} } = ();
        } elsif (ref $instance ne "dKitAnalysis")
        {
	    my $type = ref $instance;
	    carp("removeAnalysis: reference to $type given instead of reference to dKitAnalysis;\n   Remove ignored\n");
        } else
        {
	    if (grep($instance == $_, @ {$self->{ANALYSIS} }))
	    {
		@ {$self->{ANALYSIS} } = grep($instance != $_, @ {$self->{ANALYSIS} });
	    } else
	    {
		carp("removeAnalysis: reference to remove not found;\n   Remove ignored\n");
	    }
	}
    }
    return;
}

#####################################################################
# object method : addSimulatorOption
# purpose : add the simulation options for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->addSimulatorOption(optionInstance);
#

sub addSimulatorOption
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $optionInstance = shift;	    
        if (! $optionInstance)
        {
	    croak("addSimulatorOption: adding undefined option to circuit;\n");
        } elsif (ref $optionInstance ne "dKitInstance")
        {
	    my $type = ref $optionInstance;
	    croak("addInstance: reference to $type given instead of reference to dKitInstance;\n");
        }
	@{$self->{SIMULATOROPTIONS}} = (@{$self->{SIMULATOROPTIONS}}, $optionInstance);
    } else
    {
	croak("usage : \$Circuit->addSimulatorOption(optionInstance);\n");
	return;
    }
}

#####################################################################
# object method : removeSimulatorOption
# purpose : remove the simulation options for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->removeSimulatorOption(optionInstance | "all");
#

sub removeSimulatorOption
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $instance = shift;
        
        if (! $instance)
        {
	    carp("removeSimulatorOption: undefined instance given;\n   Remove Ignored\n");
        } elsif ( $instance eq "all")
        {
	    @ {$self->{SIMULATOROPTIONS} } = ();
	} elsif (ref $instance ne "dKitInstance")
        {
	    my $type = ref $instance;
	    carp("removeSimulatorOption: reference to $type given instead of reference to dKitInstance;\n   Remove ignored\n");
        } else
        {
	    if (grep($instance == $_, @ {$self->{SIMULATOROPTIONS} }))
	    {
		@ {$self->{SIMULATOROPTIONS} } = grep($instance != $_, @ {$self->{SIMULATOROPTIONS} });
	    } else
	    {
		carp("removeSimulatorOption: reference to remove not found;\n   Remove ignored\n");
	    }
	}	
    } else
    {
	croak("usage : \$Circuit->removeSimulatorOption(optionInstance);\n");
	return;
    }
}

#####################################################################
# object method : simulatorOptions
# purpose : set/get the simulation options for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->simulatorOptions(dialect [, options]);
# the use to define simulatorOptions this way is discouraged...
#

my $hiddenDirectlyDefinedOption = 0;

sub simulatorOptions
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
	my $options;
	if (@_)
	{
	    $options = shift;

	    ### overwrite previous options
	    
	    my $optionInstance;
	    if (! $hiddenDirectlyDefinedOption)
            {
		$hiddenDirectlyDefinedOption = dKitInstance->new("SIMULATOROPTION");
		@{$self->{SIMULATOROPTIONS}} = ($hiddenDirectlyDefinedOption, @{$self->{SIMULATOROPTIONS}});
	    }
	    if ($hiddenDirectlyDefinedOption)
	    {
		$hiddenDirectlyDefinedOption->parameterValue($dialect . "Options" , $options);
	    }
	} elsif ($#{$self->{SIMULATOROPTIONS}} > -1)
	{
	    $options = "";
	    foreach my $optionInstance (@{$self->{SIMULATOROPTIONS}})
	    {
		$options = $options . $optionInstance->netlist($dialect);
	    }
	} else
	{
	    $options = "\n";
	}
#	print "options = $options, length = " . length($options) . "\n";
	if ($options eq "\n")
        {      #### try to get the default options
	    my $optionInstance = dKitInstance->new("CIRCUITDEFAULTSIMULATOROPTIONS");
	    if ($optionInstance)
	    {
		$options = $optionInstance->netlist($dialect);
	    }
	} else
        { ### add the required options
	    my $optionInstance = dKitInstance->new("CIRCUITREQUIREDSIMULATOROPTIONS");
	    if ($optionInstance)
	    {
		$options = $options . $optionInstance->netlist($dialect);
	    }
	}
	return $options;
    } else
    {
	croak("usage : \$Circuit->simulatorOptions(dialect);\n");
	return;
    }
}

#####################################################################
# object method : addModelLibrary
# purpose : add the modelLibrary for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->addModelLibrary(modelLibraryInstance);
#

sub addModelLibrary
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $libraryInstance = shift;	    
        if (! $libraryInstance)
        {
	    croak("addInstance: adding undefined modelLibrary to circuit;\n");
        } elsif (ref $libraryInstance ne "dKitInstance")
        {
	    my $type = ref $libraryInstance;
	    croak("addModelLibrary: reference to $type given instead of reference to dKitInstance;\n");
        }
	@{$self->{MODELLIBRARY}} = (@{$self->{MODELLIBRARY}}, $libraryInstance);
    } else
    {
	croak("usage : \$Circuit->addModelLibrary(\"modelLibrary\");\n");
	return;
    }
}

#####################################################################
# object method : removeModelLibrary
# purpose : remove the ModelLibrary
# (instances only)
# call vocabulary
#
# $Circuit->removeModelLibrary(modelLibraryInstance | "all");
#

sub removeModelLibrary
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $instance = shift;
        
        if (! $instance)
        {
	    carp("removeModelLibrary: undefined instance given;\n   Remove Ignored\n");
        } elsif ( $instance eq "all")
        {
	    @ {$self->{MODELLIBRARY} } = ();
	} elsif (ref $instance ne "dKitInstance")
        {
	    my $type = ref $instance;
	    carp("removeModelLibrary: reference to $type given instead of reference to dKitInstance;\n   Remove ignored\n");
        } else
        {
	    if (grep($instance == $_, @ {$self->{MODELLIBRARY} }))
	    {
		@ {$self->{MODELLIBRARY} } = grep($instance != $_, @ {$self->{MODELLIBRARY} });
	    } else
	    {
		carp("removeModelLibrary: reference to remove not found;\n   Remove ignored\n");
	    }
	}	
    } else
    {
	croak("usage : \$Circuit->removeModelLibrary(modelLibraryInstance);\n");
	return;
    }
}

#####################################################################
# object method : modelLibrary
# purpose : set/get the simulation options for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->modelLibrary(dialect [,modelLibrary]);
# the use to define modelLibraries this way is discouraged...
#

my $hiddenDirectlyDefinedModelLibrary = 0;

sub modelLibrary
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
	my $modelLibraries;
	if (@_)
	{
	    $modelLibraries = shift;

	    ### overwrite previous modelLibraries
	    
	    my $modelLibraryInstance;
	    if (! $hiddenDirectlyDefinedModelLibrary)
            {
		$hiddenDirectlyDefinedModelLibrary = dKitInstance->new("MODELLIBRARY");
		@{$self->{MODELLIBRARY}} = ($hiddenDirectlyDefinedModelLibrary, @{$self->{MODELLIBRARY}});
	    }
	    if ($hiddenDirectlyDefinedModelLibrary)
	    {
		$hiddenDirectlyDefinedModelLibrary->parameterValue($dialect . "ModelLibrary" , $modelLibraries);
	    }
	} elsif ($#{$self->{MODELLIBRARY}} > -1)
	{
	    $modelLibraries = "";
	    foreach my $modelLibraryInstance (@{$self->{MODELLIBRARY}})
	    {
		$modelLibraries = $modelLibraries . $modelLibraryInstance->netlist($dialect);
	    }
	} else
	{
	    $modelLibraries = "\n";
	}
	return $modelLibraries;
    } else
    {
	croak("usage : \$Circuit->modelLibrary(dialect);\n");
	return;
    }
}

#####################################################################
# object method : startDeckCard
# purpose : get the startDeckCard syntax for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->startDeckCard(dialect);
#

sub startDeckCard
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
	my $line = "";
	if (@_)
        {
	    croak("Error: startdeckcard syntax cannot be modified\nUse CIRCUITSTARTDECKCARD template to modify startdeckcard syntax\n");
	}

	if ($dialect eq "hspice")
        {
	    my @sweptVariables = $self->doForeachAnalysis("getHspiceSweptVariables");
            $line = "*** sweep variables list";
	    foreach my $variable (@sweptVariables)
	    {
		my @fragments = split('\:', $variable);
		if ($#fragments == 1)
		{
		    (my $newParam, my $newDevice) = $self->getTranslatedParameterDevicePair("result4hspice", $fragments[1], $fragments[0]);
		    if ($newDevice)
		    {
			$variable = "$newDevice" . "." . "$newParam";		    
		    } else
		    {
			$variable = "$newParam";
		    }
#		    $variable = "$fragments[0]" . ".";
#		    my $newParam = dKitParameter->dKit2result($fragments[1]$fragments[1]);
#		    $variable = $variable . $newParam;
		} 
		$line = $line . " " . $variable;
	    }
        } else
	{
	    $line = "";
	}

   #### get the default startdeckcard
	my $instance = dKitInstance->new("CIRCUITSTARTDECKCARD");
	if ($instance)
	{
	    $line = $line . $instance->netlist($dialect);
	}
	return $line;
    } else
    {
	croak("usage : \$Circuit->startDeckCard(dialect);\n");
	return;
    }
}

#####################################################################
# object method : endDeckCard
# purpose : get the endDeckCard syntax for the simulator
# (instances only)
# call vocabulary
#
# $Circuit->endDeckCard(dialect);
#

sub endDeckCard
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
	my $line = "";
	if (@_)
        {
	    croak("Error: enddeckcard syntax cannot be modified\nUse CIRCUITENDDECKCARD template to modify enddeckcard syntax\n");
	}
   #### get the default enddeckcard
	my $instance = dKitInstance->new("CIRCUITENDDECKCARD");
	if ($instance)
	{
	    $line = $instance->netlist($dialect);
	}
	return $line;
    } else
    {
	croak("usage : \$Circuit->endDeckCard(dialect);\n");
	return;
    }
}


#####################################################################
# object method : getInstanceHierarchy
# purpose : get all the instances of the specified type
#           return array including subcircuit traversal ...
#
# call vocabulary
#
# $CIRCUIT->getInstanceHierarchy(Name, dialect);
#

sub getInstanceHierarchy($$)
{
    my $circuit = shift;
    if (! ref $circuit) { confess "Object method called as class method";}
    if (! @_)
    {
	croak("usage : \$Circuit->getInstanceHierarchy(instanceName, dialect);\n");
	return;
    }

    my $deviceName = shift;

    if (! @_)
    {
	croak("usage : \$Circuit->getInstanceHierarchy('Name', dialect);\n");
	return;
    }
    my $dialect = shift;

    my @instanceHierarchy = ();

    my $curCircuit = 0;
    my $localInstance = 0;

    #### split subcircuits/devices ...
    my @fragments = split('\.', $deviceName);

    for (my $ndx = 0; $ndx <= $#fragments; $ndx++)
    {
# print "ndx = $ndx out of $#fragments, checking fragment $fragments[$ndx]\n";
	if ($ndx)
	{   ### these instances from the previous round should be subcircuits ....
# print $localInstance->template->dKitSubcircuitName($dialect) . "\n";
	    $curCircuit = dKitCircuit->getSubcircuit($localInstance->template->dKitSubcircuitName($dialect));
	} else
	{   ### initialize ...
	    $curCircuit = $circuit;
	}

# print $curCircuit->dump2str . "\n";
	
	$localInstance = $curCircuit->getFlattenedInstance($fragments[$ndx]);
	if (! $localInstance)
	{
	    ### search for inlined instances...
	    my $inlinedName = $fragments[$ndx];
# print "look for inlined... starting with $inlinedName\n";
	    my $inlined_ndx = $ndx + 1;
	    for (; (!($localInstance)) && ($inlined_ndx <= $#fragments); $inlined_ndx += 1)
	    {
		$inlinedName = $fragments[$inlined_ndx] . $nameSpaceDelimitor . $inlinedName;
# print "look for inlined...  $inlinedName\n";
		$localInstance = $curCircuit->getFlattenedInstance($inlinedName);
	    }
	    if ($localInstance)
	    {   ### we added 1 too many 
		$ndx = $inlined_ndx - 1;
	    }
	}

        if (!($localInstance))
	{
	    ### we might ask for an instance and a parameter that were removed
            ## because they were inlined
	    $localInstance = $curCircuit->getLocalInstance($fragments[$ndx]);
	} 

        if (!($localInstance))
	{
	    ### maybe we are given an inlined name ...
	    my @inlinedfragments = split($nameSpaceDelimitor, $fragments[$ndx]);
	    my $inlinedName = "";
	    for (my $inlined_ndx = $#inlinedfragments; $inlined_ndx > -1 ; $inlined_ndx--)
	    {
# print "inlined_ndx = $inlined_ndx out of $#inlinedfragments, checking fragment $inlinedfragments[$inlined_ndx]\n";
		if ($inlined_ndx != $#inlinedfragments)
		{   ### these instances from the previous round should be subcircuits ....
		    $curCircuit = dKitCircuit->getSubcircuit($localInstance->template->dKitSubcircuitName($dialect));
		} 
                $localInstance = $curCircuit->getLocalInstance($inlinedfragments[$inlined_ndx]);
                if (! $localInstance)
		{
		    last;
		}
                if ($inlinedfragments[$inlined_ndx] . $inlinedName eq $fragments[$ndx])
		{   ## recreate in namespace ....
		    my $newLocalInstance = $localInstance->copyToNamespace($inlinedName);
		    $localInstance = $newLocalInstance;
		    last;
		}
		$inlinedName = $nameSpaceDelimitor . $inlinedfragments[$inlined_ndx] . $inlinedName;
	    }
	    if (!($localInstance))
	    {
		croak($curCircuit->dump2str . "\n" . "Could not find instance $fragments[$ndx]\n");
	    }
        }

# print $localInstance->dump2str . "\n";

	if (! $localInstance->isSubcircuit($dialect))
	{
	    if ($ndx != $#fragments)
	    {
		croak "Error: could not traverse hierarchy beyond $fragments[$ndx] within circuit " . $curCircuit->circuitName . " \n";
	    }
	    push(@instanceHierarchy, $localInstance);
	    return @instanceHierarchy;
	}
	push(@instanceHierarchy, $localInstance);
    }
    return @instanceHierarchy;
}

#####################################################################
# object method : getLocalSimulatorOption
# purpose : get all the simulatoroptions of the specified name
#           does not do subcircuit traversal...
#           so their should not be any dots in the name ....
#
# call vocabulary
#
# $CIRCUIT->getLocalSimulatorOption("Name");
#

sub getLocalSimulatorOption
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @simulatoroptions = grep($_->instanceName eq $name, @{ $self->{SIMULATOROPTIONS}});
	if ($#simulatoroptions > 0)
        {
	    my $cnt = $#simulatoroptions + 1;
	    carp("Circuit->getLocalSimulatorOption: found $cnt simulatoroptions with name $name\nReturning first occurence\n")
	}
	return $simulatoroptions[0];
    } else
    {
	croak("usage : \$Circuit->getLocalSimulatorOption(\"name\");\n");
	return;
    }
}

#####################################################################
# object method : getSimulatorOptions
# purpose : get all the simulatoroptions 
#           does not do subcircuit traversal...
#           so their should not be any dots in the name ....
#
# call vocabulary
#
# $CIRCUIT->getSimulatorOptions();
#

sub getSimulatorOptions
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @{ $self->{SIMULATOROPTIONS}};
}

#####################################################################
# object method : getLocalModellibrary
# purpose : get all the modellibrarys of the specified name
#           does not do subcircuit traversal...
#           so their should not be any dots in the name ....
#
# call vocabulary
#
# $CIRCUIT->getLocalModellibrary("Name");
#

sub getLocalModelLibrary
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @modellibraries = grep($_->instanceName eq $name, @{ $self->{MODELLIBRARY}});
	if ($#modellibraries > 0)
        {
	    my $cnt = $#modellibraries + 1;
	    carp("Circuit->getLocalModelLibrary: found $cnt modellibraries with name $name\nReturning first occurence\n")
	}
	return $modellibraries[0];
    } else
    {
	croak("usage : \$Circuit->getLocalModelLibrary(\"name\");\n");
	return undef;
    }
}

#####################################################################
# object method : getModellibraries
# purpose : get all the modellibrarys 
#
# call vocabulary
#
# $CIRCUIT->getModellibraries();
#

sub getModelLibraries
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @{ $self->{MODELLIBRARY}};
}

#####################################################################
# object method : getLocalInstance
# purpose : get all the instances of the specified name
#           does not do subcircuit traversal...
#           so their should not be any dots in the name ....
#
# call vocabulary
#
# $CIRCUIT->getLocalInstance("Name");
#

sub getLocalInstance
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @instances = grep($_->instanceName eq $name, @{ $self->{INSTANCES}});
	if ($#instances > 0)
        {
	    my $cnt = $#instances + 1;
	    carp("Circuit->getLocalInstance: found $cnt instances with name $name\nReturning first occurence\n")
	}
	return $instances[0];
    } else
    {
	croak("usage : \$Circuit->getLocalInstance(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getInstances
# purpose : get all the instances 
#
# call vocabulary
#
# $CIRCUIT->getLocalInstances();
#

sub getInstances
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @{ $self->{INSTANCES}};
}

#####################################################################
# object method : getLocalAnalysis
# purpose : get all the analysis of the specified name
#           does not do analysis traversal...
#
# call vocabulary
#
# $CIRCUIT->getLocalAnalysis("Name");
#

sub getLocalAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @analyses = grep($_->analysisName eq $name, @{ $self->{ANALYSIS}});
	if ($#analyses > 0)
        {
	    my $cnt = $#analyses + 1;
	    carp("Circuit->getLocalAnalysis: found $cnt analyses with name $name\nReturning first occurence\n")
	}
	return $analyses[0];
    } else
    {
	croak("usage : \$Circuit->getLocalAnalysis(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getLocalAnalyses
# purpose : get all the analyses 
#
# call vocabulary
#
# $CIRCUIT->getAnalyses;
#

sub getAnalyses
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @{ $self->{ANALYSIS}};
}

#####################################################################
# object method : getFlattenedAnalysis
# purpose : get all the analysis of the specified name
#           do subanalysis traversal...
#
# call vocabulary
#
# $CIRCUIT->getFlattenedAnalysis("Name");
#

sub getFlattenedAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @analyses = @{ $self->{ANALYSIS}};
	my @list = ();
        foreach my $handle (@analyses)
	{
	    push (@list, $handle->getFlattenedAnalysis($name));
        }
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Circuit->getFlattenedAnalysis: found $cnt analyses with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Circuit->getLocalAnalysis(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getFlattenedSweepPlan
# purpose : get all the sweep plans of the specified name
#           do subanalysis traversal...
#
# call vocabulary
#
# $CIRCUIT->getFlattenedSweepPlan("Name");
#

sub getFlattenedSweepPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @analyses = @{ $self->{ANALYSIS}};
	my @list = ();
        foreach my $handle (@analyses)
	{
	    push (@list, $handle->getFlattenedSweepPlan($name));
        }
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Circuit->getFlattenedSweepPlan: found $cnt sweep plans with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Circuit->getFlattenedSweepPlan(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getFlattenedOutputPlan
# purpose : get all the output plans of the specified name
#           do subanalysis traversal...
#
# call vocabulary
#
# $CIRCUIT->getFlattenedOutputPlan("Name");
#

sub getFlattenedOutputPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @analyses = @{ $self->{ANALYSIS}};
	my @list = ();
        foreach my $handle (@analyses)
	{
	    push (@list, $handle->getFlattenedOutputPlan($name));
        }
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Circuit->getFlattenedOutputPlan: found $cnt output plans with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Circuit->getFlattenedOutputPlan(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getFlattenedInstance
# purpose : get all the flattened instances of the specified name
#
# call vocabulary
#
# $CIRCUIT->getFlattenedInstance("Name");
#

sub getFlattenedInstance
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @instances = grep($_->instanceName eq $name, @{ $self->{FLATTENEDINSTANCES}});
	if ($#instances > 0)
        {
	    carp("Circuit->getFlattenedInstance: found $#instances instances with name $name\nReturning first occurence\n")
	}
	return $instances[0];
    } else
    {
	croak("usage : \$Circuit->getFlatennedInstance(\"name\");\n");
	return;
    }
}

#####################################################################
# object method : getLocalInstancesOfType
# purpose : get all the instances of the specified type
#           does not do subcircuit traversal...
#
# call vocabulary
#
# $Circuit->getLocalInstancesOfType("Type");
#

sub getLocalInstancesOfType
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $type = shift;
        my @instances = grep($_->template->templateName eq $type, @{ $self->{INSTANCES}});

	return @instances;
    } else
    {
	croak("usage : \$Circuit->getLocalInstancesOfType(\"type\");\n");
	return;
    }
}

#####################################################################
# object method : getFlattenedInstancesOfType
# purpose : get all the instances of the specified type
#           does not do subcircuit traversal...
#
# call vocabulary
#
# $Circuit->getFlattenedInstancesOfType("Type");
#

sub getFlattenedInstancesOfType
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $type = shift;
        my @instances = grep($_->template->templateName eq $type, @{ $self->{FLATTENEDINSTANCES}});

	return @instances;
    } else
    {
	croak("usage : \$Circuit->getFlattenedInstancesOfType(\"type\");\n");
	return;
    }
}

#####################################################################
# object method : getProcessedPorts
# purpose : get all the Ports and do some processing on them
#
# call vocabulary
#
# $Circuit->getProcessedPorts();
#

sub getProcessedPorts
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my @ports = $self->getFlattenedInstancesOfType("PORT");
    my @orderedPorts = ();
    foreach  my $port (@ports)
    {
	$port->parameterValue('i_portName', $port->instanceName);	

	my $portNr = $port->parameterValue('portNr');
	if ($portNr =~ /~eval\(/ )
	{ ### try evaluating the expression
	    $portNr = dKitTemplate::nt_evaluateExpressions($portNr, $port, 0);
	}
	if ( !($portNr =~ /^\s*[0-9]+$/ ) )
	{   #### try to get the parameter value
	    my $instance = $self->getFlattenedInstance($portNr);
	    if ($instance && ($instance->template->templateName eq "PARAMETER"))
	    {   ### should be of type PARAMETER
		$portNr = $instance->parameterValue('value');
	    }
	}
	if ( !($portNr =~ /^\s*([0-9]+)$/ ) )
	{
	    croak("portNumber `$portNr` is not a numerical value\n");
	}
	$portNr = $1;
	$port->parameterValue('i_portNr', $portNr);

	my $referenceImpedance = $port->parameterValue('referenceImpedance');
	if ($referenceImpedance eq "")
        {   # reference impedance not defined ... default to 50
	    $referenceImpedance = 50;
	}

	if ($referenceImpedance =~ /~eval\(/ )
	{ ### try evaluating the expression
	    $referenceImpedance = dKitTemplate::nt_evaluateExpressions($referenceImpedance, $port, 0);
	}
	if ( !($referenceImpedance =~ /^\s*[0-9]+$/ ) )
	{   #### try to get the parameter value
	    my $instance = $self->getFlattenedInstance($referenceImpedance);
	    if ($instance && ($instance->template->templateName eq "PARAMETER"))
	    {   ### should be of type PARAMETER
		$referenceImpedance = $instance->parameterValue('value');
	    }
	}
	if ( !($referenceImpedance =~ /^\s*([0-9]+)$/ ) )
	{
	    croak("referenceImpedance `$referenceImpedance` is not a numerical value\n");
	}
	$referenceImpedance = $1;
	$port->parameterValue('i_referenceImpedance', $referenceImpedance);
	$orderedPorts[$portNr-1] = $port;
    }

    my @biasedPorts = $self->getFlattenedInstancesOfType("PORT_BIN");
    foreach  my $port (@biasedPorts)
    {
	my $portNr = $port->parameterValue('pbin_portnr');
	my $referenceImpedance = $port->parameterValue('pbin_referenceimpedance');
	if ($portNr)
	{
	    $port->parameterValue('i_portNr', $portNr);
	} else
        {
	    # need to assign a port number or fail here
	    croak("portNumber `$portNr` is not a numerical value\n");
	}
	if ($referenceImpedance)
	{
	    $port->parameterValue('i_referenceImpedance', $referenceImpedance);
	}
	$port->parameterValue('i_portName', $port->instanceName);
	$orderedPorts[$portNr-1] = $port;
    }
    push (@ports, @biasedPorts);

    my @biasedPorts = $self->getFlattenedInstancesOfType("PORT_BN");
    foreach  my $port (@biasedPorts)
    {
	my $portNr = $port->parameterValue('pbn_portnr');
	my $referenceImpedance = $port->parameterValue('pbn_referenceimpedance');
	if ($portNr)
	{
	    $port->parameterValue('i_portNr', $portNr);
	} else
        {
	    # need to assign a port number or fail here
	    croak("portNumber `$portNr` is not a numerical value\n");
	}
	if ($referenceImpedance)
	{
	    $port->parameterValue('i_referenceImpedance', $referenceImpedance);
	}
	########## inlined subcircuit
        ####    vport3 should be changed whenever 
        ##      port subcircuit definition changes
	$port->parameterValue('i_portName', "vport3" .  $nameSpaceDelimitor . $port->instanceName);
	$orderedPorts[$portNr-1] = $port;
    }
    push (@ports, @biasedPorts);

    return @orderedPorts;
}


#####################################################################
# object method : doForeachAnalysis
#
# purpose : perform a function on each analysis
# call vocabulary
#
# $Circuit->doForeachAnalysis(function, arguments);
#

sub doForeachAnalysis
{
    my $self = shift;
    if (! @_)
    {
	croak("usage : \$Circuit->doForeachAnalysis(function, arguments);\n");
	return;
    }
    my $function = shift;

    my @results = ();
    foreach my $analysis (@ {$self->{FLATTENEDANALYSIS}} )
    {
	@results = (@results , $analysis->$function(@_));
    }
    return @results;
}

#####################################################################
# object method : prepareForNetlisting
#
# purpose : insure the netlist of the circuit will be created correctly
# call vocabulary
#
# $Circuit->prepareForNetlisting(dialect);
#

sub prepareForNetlisting
{
    my $self = shift;
    if (! ref $self) 
    { 
	confess "Object method called as class method";
    }

    if (@_)
    {
	my $dialect = shift;

## modify instances depending on the analysis definition,
## e.g adapt variablesnames to sweep parameter for hspice
## e.g add ac source to input port for hspice
## e.g add ac source to noiseReference for hspice 

	my @modifiedParameterList = ();
	if ($dialect eq "hspice")
        {
            ## adapt variablesnames to sweep parameter for hspice
	    my @sweptVariables = $self->doForeachAnalysis("getHspiceSweptVariables");
	    foreach my $variable (@sweptVariables)
	    {
		my @fragments = split('\:', $variable);
		if ($#fragments == 1)
		{
		    (my $newParam, my $newDevice) = $self->getTranslatedParameterDevicePair("hspice", $fragments[1], $fragments[0]);
		    if ($newDevice)
		    {
			$variable = "$newDevice" . "." . "$newParam";

			my @instanceHierarchy = $self->getInstanceHierarchy($newDevice, $dialect);
			if ($#instanceHierarchy)
			{
			    croak ("hierarchy level $#instanceHierarchy not implemented yet\n");
			}
			my $instance = $instanceHierarchy[0];
			if (! $instance)
			{
			    croak "Unable to find instance named $newDevice used by device sweep\n  Device = $newDevice ($fragments[0]), Parameter = $fragments[1]\n";
			}
			(my $newParam, my $newDevice) = $self->getTranslatedParameterDevicePair("dKit4hspice", $fragments[1], $fragments[0]);
			my $value = $instance->parameterValue($newParam);
			$instance->parameterValue($newParam, $variable);

			my @resetCommand = ($instance, $newParam, $value);
			@modifiedParameterList = (@modifiedParameterList, \@resetCommand);
		    } else
		    {
			$variable = "$newParam";
		    }
		}
	    }

            ## add ac source to input port for hspice 
	    my @instances = $self->getProcessedPorts;
	    foreach my $instance (@instances)
	    {
		my $portNr = $instance->parameterValue('i_portNr');
#		print "portNr=$portNr\n";
		if ($portNr == 1)
		{
		    my $portType = $instance->template->templateName;
                    my $acMagName = "";
		    if ($portType eq "PORT")
                    {
			$acMagName = 'Vac_Mag';
		    } elsif ($portType eq "PORT_BN")
		    {
			$acMagName = 'pbn_vac_mag';
		    } elsif ($portType eq "PORT_BIN")
		    {
			$acMagName = 'pbin_vac_mag';
		    } elsif ($portType eq "PORT_BD")
		    {
			$acMagName = 'pbd_vac_mag';
		    }
		    if ($acMagName)
		    {
			my $value = $instance->parameterValue($acMagName);
			$instance->parameterValue($acMagName, '1m');
			my @resetCommand = ($instance, $acMagName, $value);
			@modifiedParameterList = (@modifiedParameterList, \@resetCommand);
		    } else
		    {
			croak("Error: unable to set-up AC analysis for S-Parameter Analysis\n");
		    }
		    last;
		} 
	    }

	    my @noiseReferences = $self->doForeachAnalysis("getHspiceNoiseReferences");

#	    print "noisesources = " . join(" ", @noiseReferences) . "\n";

	    foreach my $instanceName (@noiseReferences)
	    {
		my @instanceHierarchy = $self->getInstanceHierarchy($instanceName, $dialect);
		if ($#instanceHierarchy)
		{
		    croak ("hierarchy level $#instanceHierarchy not implemented yet\n");
		}
		my $instance = $instanceHierarchy[0];
		if ($instance)
		{
		    my $parmName;
		    if  (exists( $instance->{PARAMETERS}->{Vac_Mag} ))
		    {
			$parmName = "Vac_Mag";
		    }
		    elsif  (exists( $instance->{PARAMETERS}->{Iac_Mag} ))
		    {
			$parmName = "Iac_Mag";
		    }
		    else
		    {
			croak("Error: Noise analysis requires an independent Voltage or Current Source\n");
		    }	
		    my $value = $instance->parameterValue($parmName);
		    $instance->parameterValue($parmName, '1m');
		    my @resetCommand = ($instance, $parmName, $value);
		    @modifiedParameterList = (@modifiedParameterList, \@resetCommand);
		}
	    }
        }
	return @modifiedParameterList;
    } else
    {
	croak("usage : \$Circuit->prepareForNetlisting(dialect);\n");
	return;
    }
}


#####################################################################
# object method : copyToNamespace
# purpose : 
# call vocabulary
#
# $newCircuit = $Circuit->copyToNamespace(namespace);
#
# currently only deals with analysis and instances ....


sub copyToNamespace($)
{
    my $circuit = shift;
    if (! ref $circuit) { confess "Object method called as class method";}
    if ($#_ != 0)
    {
	croak('Error usage :$newCircuit = $Circuit->copyToNamespace(namespace)');
    }

    my $namespace = shift;

    my @instances = @{$circuit->{INSTANCES}};
    my @analyses = @{$circuit->{ANALYSIS}};
    my @simulatorOptions = @{$circuit->{SIMULATOROPTIONS}};
    my @modelLibraries = @{$circuit->{MODELLIBRARY}};

    my $newCircuit = dKitCircuit->new();

    $newCircuit->{NODES} = +{};
    foreach my $param (keys %{$circuit->{NODES}})
    {
	$newCircuit->{NODES}->{$param} = $ {$circuit->{NODES}}{$param};
    }

    $newCircuit->{PARAMETERS} = +{};
    foreach my $param (keys %{$circuit->{PARAMETERS}})
    {
	$newCircuit->{PARAMETERS}->{$param} = $ {$circuit->{PARAMETERS}}{$param};
    }

# carp "recreating instances for namespace $namespace\n";
    my @newSimulatorOptions = ();
    my @newModelLibraries = ();
    my @newInstances = ();
    my @newAnalyses = ();

    foreach my $option (@simulatorOptions)
    {
	push(@newSimulatorOptions, $option->copyToNamespace($namespace));
    }

    foreach my $modelLibrary (@modelLibraries)
    {
	push(@newModelLibraries, $modelLibrary->copyToNamespace($namespace));
    }
  
    foreach my $instance (@instances)
    {
	push(@newInstances, $instance->copyToNamespace($namespace));
    }
	
    foreach my $analysis (@analyses)
    {
	push(@newAnalyses, $analysis->copyToNamespace($namespace));
    }
	
    @{$newCircuit->{SIMULATOROPTIONS}} = @newSimulatorOptions;
    @{$newCircuit->{MODELLIBRARY}} = @newModelLibraries;
    @{$newCircuit->{INSTANCES}} = @newInstances;
    @{$newCircuit->{ANALYSIS}} = @newAnalyses;

    return $newCircuit;
}


#####################################################################
# object method : adjustInterfaceToParent
# purpose : forward parent Characteristics to the newly created inlined circuit
# call vocabulary
#
# $Circuit->adjustInterfaceToParent(originalInstance);
#
# currently only deals with analysis and instances ....

sub adjustInterfaceToParent($)
{
    my $circuit = shift;
    if (! ref $circuit) { confess "Object method called as class method";}
    if ($#_ != 0)
    {
	croak('Error usage :$newCircuit = $Circuit->adjustInterfaceToParent(origInstance)');
    }
    my $parent = shift;

    #### copy nodehash and parameterhash data from parent ....

    my $parameterHashRef = $circuit->{PARAMETERS};
    foreach my $parameter (keys %{ $parameterHashRef})
    {
	my $paramvalue = $parent->parameterValue($parameter);
	if (defined $paramvalue)
	{
# print "setting I parameter $parameter to $paramvalue\n";
	    $ {parameterHashRef}->{$parameter} = $paramvalue;
	}
    }

    my $nodeHashRef = $circuit->{NODES};
    foreach my $node (keys %{$nodeHashRef})
    {
	my $nodeName = $parent->nodeName($node);
	if (defined $nodeName)
	{
	    $ {nodeHashRef}->{$node} = $nodeName;
	}
    }
    return;
}



#####################################################################
# object method : createExternalParameterList
# purpose : get the external parameters into the game
# call vocabulary
#
# @externalParmameterInstanceList = $Circuit->createInterfaceParameterInstanceList(namespace);
#
# 

sub createInterfaceParameterInstanceList
{
    my $circuit = shift;
    if (! ref $circuit) { confess "Object method called as class method";}
    if ($#_ != 0)
    {
	croak('Error usage :$Circuit->createInterfaceParameterInstanceLis(namespace)');
    }
    my $namespace = shift;
    my @newParameters = ();

    ### create netlist parameters in namespace
    my %parameterHash = $circuit->parameterHash;
    foreach my $parameter (keys %parameterHash)
    {
	my $newParameter = $parameter . $namespace;
	my $paramInstance = dKitInstance->getInstance($newParameter);
	if (! $paramInstance)
	{
	    $paramInstance = dKitInstance->new('PARAMETER', $newParameter);
	}
	my $paramvalue = $ {parameterHash}{$parameter};
	$paramInstance->parameterValue('value', $paramvalue);

	push(@newParameters, $paramInstance);
    }

    return @newParameters;
}



#####################################################################
# object method : adjustContentToInterface
# purpose : forward parent Characteristics to the newly created inlined circuit
# call vocabulary
#
# $Circuit->adjustContentToInterface(namespace);
#
# currently only deals with analysis and instances ....


sub adjustContentToInterface($)
{
    my $circuit = shift;
    if (! ref $circuit) { confess "Object method called as class method";}
    if ($#_ != 0)
    {
	croak('Error usage :$Circuit->adjustContentToInterface(namespace)');
    }
    my $namespace = shift;
    
    my @instances = @{$circuit->{INSTANCES}};
    my @analyses = @{$circuit->{ANALYSIS}};

    my @newParameters = $circuit->createInterfaceParameterInstanceList($namespace);

    ### rename all nodes
    my %nodeHash = $circuit->nodeHash;
    foreach my $instance (@instances)
    {
	$instance->fixConnectivityForNamespace($namespace, \%nodeHash);
    }
    
    ### rename all parameters ....
    ### this can be tricky ... 
    my %parameterHash = $circuit->parameterHash;
    foreach my $instance (@instances)
    {
	$instance->fixParametersForNamespace($namespace, \%parameterHash);
    }

    @{$circuit->{INSTANCES}} = (@newParameters, @instances);
    ### rename all parameters ....
    ### this can be tricky ... 
    foreach my $analysis (@analyses)
    {
	$analysis->fixParametersForNamespace($namespace, $circuit);
    }

    @{$circuit->{INSTANCES}} = (@newParameters, @instances);
    @{$circuit->{ANALYSIS}} = @analyses;

    return;
}

#####################################################################
# object method : inlineWhereNeeded
# purpose : inline circuits who need to be inlined
# call vocabulary
#
# $Circuit->inlineWhereNeeded(dialect);
#

sub inlineWhereNeeded($)
{
    my $self = shift;

    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
        my $namespace = shift;

	my @instances = @{$self->{INSTANCES}};
	my @analyses = @{$self->{ANALYSIS}};

	my @newInstances = ();
	my @newAnalyses = ();
	my @newOptions = @{$self->{SIMULATOROPTIONS}};
        my @newModelLibraries = @{$self->{MODELLIBRARY}};

	foreach my $instance (@instances)
	{
	    if ($instance->inline($dialect))
	    {
		my $subcircuit = $self->createInlinedSubcircuit($instance, $dialect);
		if ($subcircuit)
		{
		    $subcircuit->inlineWhereNeeded($dialect);
		    push (@newInstances, @{$subcircuit->{FLATTENEDINSTANCES}});
		    push (@newAnalyses, @{$subcircuit->{FLATTENEDANALYSIS}});
		    push (@newOptions, @{$subcircuit->{SIMULATOROPTIONS}});
		    push (@newModelLibraries, @{$subcircuit->{MODELLIBRARY}});
		} else
		{
		    croak("inlineWhereNeeded cannot create inlined subcircuit needed by\n" . $instance->dump2str);
		}
	    } else
	    {
		push (@newInstances, $instance);
	    }
	}
	
# add analysis netlists
# anaysis needs to know some characteristics of the circuit...
# e.g. portnames for spectre

	foreach my $analysis (@analyses)
	{
	    if ($analysis->inline($dialect))
	    {
		my $subcircuit = $self->createInlinedSubcircuit($analysis, $dialect);
		if ($subcircuit)
		{
		    $subcircuit->inlineWhereNeeded($dialect);
		    push (@newInstances, @{$subcircuit->{FLATTENEDINSTANCES}});
		    push (@newAnalyses, @{$subcircuit->{FLATTENEDANALYSIS}});
		    push (@newOptions, @{$subcircuit->{SIMULATOROPTIONS}});
		    push (@newModelLibraries, @{$subcircuit->{MODELLIBRARY}});
		} else
		{
		    croak("inlineWhereNeeded cannot create inlined subcircuit needed by\n" . $analysis->dump2str);
		}
	    } else
	    {
		push (@newAnalyses, $analysis);
	    }	
	}
	@{$self->{FLATTENEDINSTANCES}} = @newInstances;
	@{$self->{FLATTENEDANALYSIS}} = @newAnalyses;


### do not add duplicate modellibaries and options...

	foreach my $option (@newOptions)
	{
	    if (! grep($_->name eq $option->name, @{$self->{SIMULATOROPTIONS}}))
	    {
		push (@{$self->{SIMULATOROPTIONS}}, $option)
	    }
	}

	foreach my $modelLibrary (@newModelLibraries)
	{
	    if (! grep($_->name eq $modelLibrary->name, @{$self->{MODELLIBRARY}}))
	    {
		push (@{$self->{MODELLIBRARY}}, $modelLibrary)
	    }
	}

	return undef;
    } else
    {
	croak("usage : \$Circuit->inlineWhereNeeded(dialect);\n");
	return undef;
    }
    return undef;
}

####################################################################
###
# class method current.
# purpose : returns pointer to circuit currently being netlisted

my @circuitNetlistStack = ();

sub current
{
    return ($circuitNetlistStack[0]);
}

#####################################################################
# object method : netlist
# purpose : return a string with the netlist
# call vocabulary
#
# $Circuit->netlist(dialect, [fileName]);
#


sub netlist
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    if (@_)
    { 
 	my $dialect = shift;
        my $outputFileName = shift;
	if ($outputFileName)
        {
            ### ensure the directorie to write the file to exists
	    fileUtil_createDirectoryPart($outputFileName ,0755);
	}

# save circuit ptr of current circuit being netlisted ...
	unshift (@circuitNetlistStack, $self);

# look for all subcircuits ....

	$self->identifySubcircuits($dialect);

# get the correct subcircuits inlined ...
	
	$self->inlineWhereNeeded($dialect);


# get the interface parameters ... put them first...
	my @newParameters = $self->createInterfaceParameterInstanceList("");
	unshift (@{$self->{FLATTENEDINSTANCES}}, @newParameters);

#	print "\n\n result \n\n";
#	print $self->dump2str;

# modify the certain parameters for analysis 

	my @modifiedParameterList = $self->prepareForNetlisting($dialect);

# mark the start of the circuitdefinition

	my $netlist = $self->startDeckCard($dialect) . "\n";

# only write out simulation options of top level circuit

	$netlist = $netlist . $self->simulatorOptions($dialect) . "\n";

# only write out modellibraryinclude of top level circuit

	$netlist = $netlist . $self->modelLibrary($dialect) . "\n";

# write out definitions of subcircuits

	foreach my $circuit (values %{ $self->{CIRCUITS}->{$dialect}} )
        {
	    $netlist = $netlist . $circuit->netlistAsSubcircuit($dialect) . "\n";    
	}

	foreach my $instance (@{$self->{FLATTENEDINSTANCES}})
	{
	    $netlist = $netlist . $instance->netlist($dialect);
	}
	
# add analysis netlists
# anaysis needs to know some characteristics of the circuit...
# e.g. portnames for spectre

	foreach my $analysis (@{$self->{FLATTENEDANALYSIS}})
	{
	    $netlist = $netlist . $analysis->netlist($dialect, $self);
	}

#### because circuits were inlined befor we should not do 
###  any namespace stuff any more when netlisting
##	$netlist = $netlist . $self->netlistInNamespace($dialect);

# mark the end of the circuitdefinition

	$netlist = $netlist . $self->endDeckCard($dialect) . "\n";


# restore circuit to original state

#    print "modifiedParameterList = @modifiedParameterList\n";
	foreach my $reference (@modifiedParameterList)
        {
	    my $instance = $ {$reference}[0];
	    my $parameter = $ {$reference}[1];
	    my $value = $ {$reference}[2];
	    $instance->parameterValue($parameter, $value);
        }

# reset temporary variables

	@{$self->{FLATTENEDINSTANCES}} = ();
	@{$self->{FLATTENEDANALYSES}} = ();

# remove from list of circuits being netlisted ...
	shift @circuitNetlistStack;

# save to file if requested
	if ($outputFileName)
        {
	    if ($outputFileName eq "STDOUT")
            {
		print STDOUT $netlist;
	    } elsif ($outputFileName eq "STDERR")
            {
		print STDERR $netlist;
	    } else
            {
		open(OUTPUT,">$outputFileName");
		print OUTPUT $netlist;
		close OUTPUT;
	    }
	}
	return $netlist;
    } else
    {
	croak("usage : \$Circuit->netlist(dialect);\n");
	return;
    }
}

#####################################################################
# object method : simulate
# purpose : simulate the circuit
# call vocabulary
#
# $Circuit->simulate($dialect1, $dialect2);
# dKitCircuit->simulate(netlist1, netlist2);
#

sub simulate (@)
{
    my $self = shift;

    if (!@_)
    {
	croak("usage : \$Circuit->simulate(dialect1[, dialect2]...);\n       or dKitCircuit->simulate(netlistfile1, netlistfile2);");
	return 0;
    }

    my $netlistInstance = dKitInstance->new("CIRCUITNETLISTNAME");
    my @arguments = @_;
    my $returnValue = 0;
    if (! ref $self) 
    { 
	#### actually arguments are filenames
        my %parameterHash = $netlistInstance->parameterHash;
	my @dialects = ();
	foreach my $fileName (@arguments)
        {
	    my ($project, $suffix) = ($fileName =~ /(.*)(\.\S+)$/);
	    print "project = $project; suffix = $suffix\n";
            my $dialect = "";
	    foreach my $key (keys %parameterHash)
	    {
#	        print "parameterHash{$key} = $parameterHash{$key}\n";
		if ($parameterHash{$key} eq $suffix)
		{
		    ($dialect) = ($key =~ /(\S*)NetlistSuffix$/);
	            print "dialect = $dialect\n";
		    last;
		}
	    }
	    if ($dialect)
            {
		my $previuosProject = $netlistInstance->parameterValue("projectName");
		if ($previuosProject)
		{
		    if ($previuosProject ne $project)
		    {
			### simulate what we previuosly had;
			$returnValue += simulateNetlistInstance($netlistInstance, @dialects);
			@dialects = ();
		    }
		}
		$netlistInstance->parameterValue("projectName", $project);
		@dialects = (@dialects, $dialect);
	    } else
            {
		print("unable to simulate file $fileName\n");
	    }
	}
	$returnValue = simulateNetlistInstance($netlistInstance, @dialects);
    } else
    {
	if (! $self->{CIRCUITNAME})
	{
	    $self->circuitName("tmp$$");
	}
	$netlistInstance->parameterValue("projectName", $self->{CIRCUITNAME});
	foreach my $dialect (@arguments)
	{
	    my $netlistName = $netlistInstance->netlist($dialect);
	    chomp($netlistName);
	    $self->netlist($dialect, $netlistName);
	}
	$returnValue = simulateNetlistInstance($netlistInstance, @arguments);
    }
    return $returnValue;
}


############################################################################
###
### simulate one project ...
###
### simulateNetlistInstance
### 
###

#local
sub simulateNetlistInstance($@)
{
    my $netlistInstance = shift;
    my @dialects = @_;

    my $returnValue = 0;
    my $projectName = $netlistInstance->parameterValue("projectName");
    my $invokeInstance = dKitInstance->new("CIRCUITINVOKECOMMAND");
    foreach my $dialect (@dialects)
    {
	my $netlistName = $netlistInstance->netlist($dialect);
	chomp($netlistName);
	$invokeInstance->parameterValue("netlistFilename", $netlistName);
	my $myErrors = callSimulator($invokeInstance, $dialect);
	if (! $myErrors)
	{
	    if (! dKitResults->data2citi($projectName, $dialect))
	    {
		if (! $Debugging)
		{      #### cleanup
		    $invokeInstance->parameterValue("cleanup", "--cleanup");
		    callSimulator($invokeInstance, $dialect);
		    $invokeInstance->parameterValue("cleanup", "");
		}
	    } else
	    {
		$myErrors = 1;
	    }
	}
        $returnValue += $myErrors;
    }
    if (! $returnValue)
    {
	if ($#dialects > 0)
	{   #### merge all dialect citifiles to 1 citi file
	    dKitResults->mergeProjectCitifiles($projectName, @dialects);
	    dKitResults->convertCitifile2Dataset($projectName . ".cti");
	} else
	{
	    dKitResults->convertCitifile2Dataset($projectName . $nameSpaceDelimitor . $dialects[0] . ".cti", $dialects[0]);
	}
    } else
    {
	print "WARNING: dataset not created due to previously reported errors!\n";
    }
    return $returnValue;
}

############################################################################
###
### call the simulator...
###
### callSimulator($invokeInstance, $dialect)
### 
###


#local
sub callSimulator($$)
{
    my $invokeInstance = shift;
    my $dialect = shift;

    my $returnValue = 0;

    my $commandLine = $invokeInstance->netlist($dialect);
    chomp($commandLine);
    my @args = split(/\s/, $commandLine);
    print "command = $commandLine\n";

    if ( ! ($ENV{'PATH'} =~ m|$ENV{'DKITVERIFICATION'}/bin|))
    {
	if ($^O =~ /win/i)
	{
	    $ENV{'PATH'}="$ENV{'PATH'};$ENV{'DKITVERIFICATION'}/bin";
	} else
	{
	    $ENV{'PATH'}="$ENV{'PATH'}:$ENV{'DKITVERIFICATION'}/bin";
	}
    }

    if (system(@args))
    {
	print "\n\ncommand $commandLine failed !!!\n\n\n";
	return 1;
    } else
    {
	print "command $commandLine successful !!!\n";
        return 0;
    }
}

######################################################################################
###  routines to output the circuit(s) content)
#

################################################
#### class method : circuits2perl
##   dump all circuits defined by hash table to perl string
#
# call vocabulary
#
# dKitCircuit->circuits2perl($circuitHashRef)

sub circuits2perl
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    my %myCircuits;
    if (ref $self)
    { #object
	%myCircuits = % { $self->{_GlobalCircuits} };
    } else
    { # class
	if (@_)
        {
	    my $myCircuits = shift;
	    %myCircuits = %{$myCircuits};
	} else
        {
	    %myCircuits = %Circuits;
	} 
    }
    my $string = "(\n";
    my @circuits = ();
    foreach my $circuitName (sort keys %myCircuits)
    {
        @circuits = (@circuits, $circuitName . "=>\n" . $myCircuits{$circuitName}->dump2perl);
    }
    $string = $string . join( ",\n", @circuits);
    $string = $string . "\n)";
    return $string;
}

#####################################################################
# object method : dump2perl
# purpose : dump the circuit content in a string
# call vocabulary
#
# $Circuit->dump2perl;
#

sub dump2perl {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $string =           "+{\n   CIRCUITNAME => q{$self->{CIRCUITNAME}},\n";
    $string = $string . "   CIRCUITS => +{},\n";

    $string = $string . "   SIMULATOROPTIONS => [";
    my @options = ();
    foreach my $option (@{ $self->{SIMULATOROPTIONS} })
    {
        my $definition = "\n" . $option->dump2perl;
	if (!$definition)
        {
            print "Cannot save references to perl\n";
 	    print "ignoring " . $self->dump2str . "\n";
	    return "";
        }
	@options = (@options, $definition);
    }
    $string = $string . join(",", @options);
    $string = $string . "\n   ],\n";

    $string = $string . "   MODELLIBRARY => [";
    my @modelLibraries = ();
    foreach my $library (@{ $self->{MODELLIBRARY} })
    {
        my $definition = "\n" . $library->dump2perl;
	if (!$definition)
        {
            print "Cannot save references to perl\n";
 	    print "ignoring " . $self->dump2str . "\n";
	    return "";
        }
	@modelLibraries = (@modelLibraries, $definition);
    }
    $string = $string . join(",", @modelLibraries);
    $string = $string . "\n   ],\n";

    $string = $string . "   INSTANCES => [";
    my @instances = ();
    foreach my $instance (@{ $self->{INSTANCES} })
    {
        my $definition = "\n" . $instance->dump2perl;
	if (!$definition)
        {
            print "Cannot save references to perl\n";
 	    print "ignoring " . $self->dump2str . "\n";
	    return "";
        }
	@instances = (@instances, $definition);
    }
    $string = $string . join(",", @instances);
    $string = $string . "\n   ],\n";

    $string = $string . "   ANALYSIS => [";
    my @analysis = ();
    foreach my $instance (@{ $self->{ANALYSIS} })
    {
        my $definition = "\n". $instance->dump2perl;
	if (!$definition)
        {
            print "Cannot save references to perl\n";
 	    print "ignoring " . $self->dump2str . "\n";
	    return "";
        }
	@analysis = (@analysis, $definition);
    }
    $string = $string . join(",", @analysis);
    $string = $string . "\n   ]";

    if (defined $self->{NODES})
    {
	my @nodes = ();
	$string = $string . ",\n   NODES => +{\n" ;
	foreach my $key (sort keys(%{$self->{NODES}}))
	{
	    my $value = $self->{NODES}->{$key};
	    if (ref($value))
	    {
		print "Cannot save references to perl\n";
		print "ignoring $self->dump\n";
		return "";
	    }
	    @nodes = (@nodes, "    $key => q{$value}");
	}
	$string = $string . join(",\n", @nodes);
	$string = $string . "\n   }";
    }

    if (defined $self->{PARAMETERS})
    {
	my @parameters = ();
	$string = $string . ",\n   PARAMETERS => +{\n";
	foreach my $key (sort keys(%{$self->{PARAMETERS}}))
	{
	    if (!defined $self->{PARAMETERS}->{$key})
	    {
		@parameters = (@parameters, "   $key => undef");
	    } else
	    {
		my $value = $self->{PARAMETERS}->{$key};
		if (ref($value))
		{
		    print "Cannot save references to perl\n";
		    print "ignoring " . $self->dump2str . "\n";
		    return "";
		}
		@parameters = (@parameters, "    $key => q{$value}");
	    }
	}
	$string = $string . join(",\n", @parameters);
	$string = $string . "\n   }";
    }

    if (defined $self->{HEADERTEMPLATES})
    {
	my @headertemplates = ();
        $string = $string . ",\n   HEADERTEMPLATES => +{\n";
	foreach my $key (sort keys %{$self->{HEADERTEMPLATES}})
	{
	    my $value = $self->headerTemplate($key);
	    @headertemplates = (@headertemplates , "    $key => q{$value}");
	}
	$string = $string . join(",\n", @headertemplates);
	$string = $string . "\n   }";
    } 
 
    if (defined $self->{FOOTERTEMPLATES})
    {
	my @footertemplates = ();
        $string = $string . ",\n   FOOTERTEMPLATES => +{\n";
	foreach my $key (sort keys %{$self->{FOOTERTEMPLATES}})
	{
	    my $value = $self->footerTemplate($key);
	    @footertemplates = (@footertemplates , "    $key => q{$value}");
	}
	$string = $string . join(",\n", @footertemplates);
	$string = $string . "\n   }";
    } 

    $string = $string . "\n  }";

    return $string; 
}

################################################
# class method : circuits2str
# purpose : list all Circuits defined
# call vocabulary
#
# dKitCircuit->circuits2str($CircuitHashRef)
#

sub circuits2str
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    my %myCircuits;
    if (ref $self)
    { #object
	%myCircuits = % { $self->{_GlobalCircuits} };
    } else
    { # class
	if (@_)
        {
	    my $myCircuits = shift;
	    %myCircuits = %{$myCircuits};
	} else
        {
	    %myCircuits = %Circuits;
	} 
    }

    my $string = "";
    foreach my $circuit (keys %myCircuits)
    {
	$string = $string . $circuit . " ";
	$string = $string . $myCircuits{$circuit}->dump2str . "\n";
    }
    return $string;
}

#####################################################################
# object method : dump2str
# purpose : dump the circuit content in a string
# call vocabulary
#
# $Circuit->dump2str;
#

sub dump2str {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

# call instance dump2str

    my $string = "Circuit: $self->{CIRCUITNAME}\n";
    $string = $string . "SimulatorOptions\n";
    foreach my $option (@{ $self->{SIMULATOROPTIONS} })
    {
	$string = $string . $option->dump2str;
    }
    $string = $string . "ModelLibraries\n";
    foreach my $library (@{ $self->{MODELLIBRARY} })
    {
	$string = $string . $library->dump2str;
    }
    $string = $string . "Instances\n";
    foreach my $instance (@{ $self->{INSTANCES} })
    {
	$string = $string . $instance->dump2str;
    }
    $string = $string . "Analyses\n";
    foreach my $instance (@{ $self->{ANALYSIS} })
    {
	$string = $string . $instance->dump2str;
    }
    if (defined $self->{FLATTENEDINSTANCES})
    {
	$string = $string . "Flattened Instances\n";
	foreach my $instance (@{ $self->{FLATTENEDINSTANCES} })
	{
	    $string = $string . $instance->dump2str;
	}
    }
    if (defined $self->{FLATTENEDANALYSIS})
    {
	$string = $string . "Flattened Analyses\n";
	foreach my $instance (@{ $self->{FLATTENEDANALYSIS} })
	{
	    $string = $string . $instance->dump2str;
	}
    }

    if (defined $self->{NODES})
    {
	$string = $string . " Nodes:";
	foreach my $key (sort keys(%{$self->{NODES}}))
	{
	    $string = $string . "\n  $key=$self->{NODES}->{$key}" ;
	}
	$string = $string . "\n";
    }

    if (defined $self->{PARAMETERS})
    {
	$string = $string . " Parameters:";
	foreach my $key (sort keys(%{$self->{PARAMETERS}}))
	{
	    $string = $string . "\n  $key=$self->{PARAMETERS}->{$key}" ;
	}
	$string = $string . "\n";
    }

    if (defined $self->{HEADERTEMPLATES})
    {
	$string = $string . " HeaderTemplates:\n";
	foreach my $dialect (keys %{$self->{HEADERTEMPLATES}})
	{
	    $string = $string . "  $dialect=>" . $self->headerTemplate($dialect) . "\n";
	}
    }
    if (defined $self->{FOOTERTEMPLATES})
    {
	$string = $string . " FooterTemplates:\n";
	foreach my $dialect (keys %{$self->{FOOTERTEMPLATES}})
	{
	    $string = $string . "  $dialect=>" . $self->footerTemplate($dialect) . "\n";
	}
    }
    return $string;
}


################################################
# class method : printCircuits
# purpose : print all circuits defined
# call vocabulary
#
# dKitCircuit->printCircuits
#

### for backward compatibility ....
sub listCircuits
{
    print "Warning: function listCircuits renamed to printCircuits\n";
    dKitCircuit->printCircuits;
}
    
sub printCircuits
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    print "These circuits are currently globally defined:\n";
    print $self->circuits2str;
}

#####################################################################
# object method : dump
# purpose : dump the circuit content
# call vocabulary
#
# $Circuit->dump;
#

sub dump {
    if ($Debugging)
    {
	my $self = shift;
	print $self->dump2str;
    }
}

##########################################################################################
## memory related functions
#

#####################################################################
# object method : deleteResultsFromMemory()
# purpose : free the memory occupied by the circuit...
# its mainly the results memeory that matters...
#
# call vocabulary
#
# $Circuit->freeMemory
#

sub deleteResultsFromMemory()
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    return dKitResults->freeMemory($self->circuitName);
}


############################################################################
### utility functions

#local
sub list2str
{
    return join (", ", @_);
}

#local
sub hash2str
{
    my %myHash = @_;
    my $string = "";
    my $key;
    my $value;

    foreach $key (sort keys(%myHash))
    {
        $value = $myHash{$key};
        while (ref($value) eq "REF")
        {
	    $value = $ {$value};
	}
        if (ref($value) eq "SCALAR")
        {
	    $value = "(->:" . $ {$value} . ")";
        } elsif (ref($value) eq "ARRAY")
        {
	    $value = "(->L:" . list2str (@ {$value}) . ")";
        } elsif (ref($value) eq "HASH")
        {
 	    $value = "(->H:" . hash2str (% {$value}) . ")";
        } else
        {
	    $value = "";
        }
	$string = $string . "\n  $key=$myHash{$key} $value" ;
    }
    return $string
}

#local
sub fileUtil_createDirectoryPart($$)
{
    # forces the recursive creation of the directory path of 
    # a given filename
    my ($dir, $mode) = @_;
    my @a = split(/\//, $dir);
    my $i = 0;
    my @mydir;
    my $mydir;
    for ($i=0; $i < $#a; )
    {
	@mydir = @a;
	$i = $i+1;
	splice(@mydir, $i);
	$mydir = join('/', @mydir);
	if (($mydir) && (! -d $mydir))
	{
	    if (!mkdir($mydir, $mode))
	    {
		ioUtil_log("Could not create directory \$mydir");
		return 0;
	    }
	}
    }
    return 1;
}

#####################################################################
####
#
# functions to create the subcircuits ....
#

#### Define subcircuitVocabularyHash

my %subcircuitVocabularyHash = 
(
  ads => +{
    INSTANCETEMPLATE => 
      '&subcircuitName:#instanceName &nodes &requiredParameters &optionalParameters [[_M=<m>]]',
    HEADERTEMPLATE => 
      'define &subcircuitName (&nodes)
parameters &parameters',
    FOOTERTEMPLATE => 
      'end &subcircuitName'
  },
  hspice => +{
    INSTANCETEMPLATE => 
      '#instanceName &nodes &subcircuitName &requiredParameters &optionalParameters [[m=<m>]]',
    HEADERTEMPLATE => 
      '.subckt &subcircuitName &nodes &parameters' ,
    FOOTERTEMPLATE => 
      '.ends'
  },
  spectre => +{
    INSTANCETEMPLATE => 
      '#instanceName &nodes &subcircuitName &requiredParameters &optionalParameters [[m=<m>]]',
    HEADERTEMPLATE => 
      'subckt &subcircuitName (&nodes)
parameters &parameters' ,
    FOOTERTEMPLATE => 
      'ends &subcircuitName'
  }
);


################################################
# class  method : addSubcircuitHash
# purpose : add subcircuitHash table
# call vocabulary
#
# dKitCircuit->addSubcircuitHash(version, %HashTable)
#

sub addSubcircuitHash
{
    my $module = shift;
    if (!ref $module) 
    { 
	if (@_)
	{
	    my $version = shift;
	    %Subcircuits = @_;
	} else
	{
	    croak("Usage dKitCircuit->addSubcircuitHash(version, %hashTable);\n");
	}
    } else
    {
	croak("Usage dKitCircuit->addSubcircuitHash(version, %hashTable);\n");
    }
     #### initialize...
    foreach my $circuit (values %Subcircuits)
    {
	bless($circuit, "dKitCircuit");
	$circuit->blessContent;
    }
    return;
}


################################################
# object  method : addToSubcircuits
# purpose : add circuit to subcircuits list... 
#    calls prepareForSubcircuit if arguments are given
# call vocabulary
#
# $Circuit->addToSubcircuits([nodeList, parameterList [, optionalParameterList]]);
#

sub addToSubcircuits
{
    my $instance = shift;
    if (!ref $instance) 
    { 
	croak("\$Circuit->addToSubcircuits: object method called as class method;\n");    
    }
    my $overwrite = 0;
    if (! $instance)
    {
	croak("addToSubcircuits: not adding undefined Subcircuit to circuit;\n");
    } elsif (ref $instance ne "dKitCircuit")
    {
	my $type = ref $instance;
	croak("addToSubcircuits: reference to $type given instead of reference to dKitCircuit;\n");
    }
    if (@_)
    {
	$instance->prepareForSubcircuit(@_);
    }

    if (! $instance->circuitName)
    {
	croak("addToSubcircuits: Unable to add, no circuitName defined.\n");
    }

    if (${Subcircuits}{$instance->circuitName})
    {
	if ($overwrite)
	{
	    print("Info: Replacing old definition of subcircuit " . $instance->circuitName . " with new one\n");
	    delete ${Subcircuits}{$instance->circuitName};
	} else
        {
	    croak("addToSubcircuits: Unable to add " . $instance->circuitName . ": subcircuit already exists.\n");
	}
    }

#    if (! defined $instance->{NODES})
#    {
#	croak("addToSubcircuits: Unable to add " . $instance->circuitName . ": no nodes defined.\n");	
#    }

    if (!defined $instance->{HEADERTEMPLATES} || !defined $instance->{FOOTERTEMPLATES})
    {
	if ($Debugging > 0)
	{
	    print "Installing default headers and footers for " . $instance->circuitName . "\n";
	}
	$instance->createSubcircuitHeaderAndFooters;
    }

    ${Subcircuits}{$instance->circuitName} = $instance;

    return;
}

################################################
# class  method : getSubcircuit
# purpose : get the pointer to a subCircuit
# call vocabulary
#
# $SubCircuit = dKitCircuit->getSubcircuit(circuitName);
#

sub getSubcircuit
{
    my $usage = 'Usage $SubCircuit = dKitCircuit->getSubcircuit(subcircuitName);';

    my $self = shift;
    if (ref $self) 
    { 
	croak($usage);
    }

    my $searchDefinition = shift;

    if (! $searchDefinition) 
    { 
	croak($usage);
    }

    if (!defined ${Subcircuits}{$searchDefinition})
    {
	return undef;
    }
    return ${Subcircuits}{$searchDefinition};
}

################################################
# class  method : getSubcircuitDefinition
# purpose : get the pointer to a definition of a subCircuit attached to an 
# analysis or instance 
# call vocabulary
#
# $SubCircuit = $Circuit->getSubcircuitDefinition($instanceRef, $dialect)
# $SubCircuit = $Circuit->getSubcircuitDefinition($analysisRef, $dialect)
#

sub getSubcircuitDefinition
{
    my $usage = 
'Usage $SubCircuit = $Circuit->getSubcircuitDefinition($instance, $dialect);
   or $SubCircuit = $Circuit->getSubcircuitDefinition($analysis, $dialect);';

    my $self = shift;
    if (! ref $self) 
    { 
	croak($usage);
    }

    my $searchDefinition = shift;
    if (! $searchDefinition && ! ref $searchDefinition) 
    { 
	croak($usage);
    }

    ### try to find subcircuit attached to instance or analysis
    my $dialect = shift;
    if (! $dialect)
    {
	croak($usage);
    }
    if ($searchDefinition->isSubcircuit($dialect))
    {
	my $subcircuitName = $searchDefinition->template->dKitSubcircuitName($dialect);
	if ($self->{CIRCUITS}->{$dialect}->{$subcircuitName})
	{
	    return $self->{CIRCUITS}->{$dialect}->{$subcircuitName};
	}
	### $self not processed for subcircuits ?????
	## it should have been ..........
	return undef;
    }
    return undef;
}

######################################
# class method : clone
# purpose : create new circuit definition dependent on existing subcircuit
# call vocabulary
#
# dKitCircuit->clone(subcircuitName, [circuitName]);
#
# e.g
#
#  $Mix = dKitCircuit->clone('Mixer', 'mymixer');

sub clone {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    if (! @_) 
    { 
	croak("Error: usage : dKitCircuit->clone(subcircuitName, [circuitName])\n");
    }
    my $subcircuitName = shift;
    my $circuitName = shift;

    my $subcircuit = dKitCircuit->getSubcircuit($subcircuitName);
    if (!$subcircuit)
    {
	croak ("Error: clone: Unable to retrieve subcircuit definition $subcircuitName\n");
    }
    my $clone = $subcircuit->copyToNamespace("");
    if ($circuitName ne "")
    {
	$clone->circuitName($circuitName);
    }
    return $clone;
}

################################################
# class  method : createInlinedSubcircuit
# purpose : get the pointer to a subCircuit which is inlined
# call vocabulary
#
# $SubCircuit = $Circuit->createInlinedSubcircuit($instanceRef, $dialect)
# $SubCircuit = $Circuit->createInlinedSubcircuit($analysisRef, $dialect)
#

sub createInlinedSubcircuit($$)
{
    my $usage = 
'Usage $SubCircuit = $Circuit->createInlinedSubcircuit($instance, $dialect);
   or $SubCircuit = $Circuit->createInlinedSubcircuit($analysis, $dialect);';

    my $self = shift;
    if (! ref $self) 
    { 
	croak($usage);
    }

    my $parent = shift;
    if (! $parent && ! ref $parent) 
    { 
	croak($usage);
    }

    ### try to find subcircuit attached to instance or analysis
    my $dialect = shift;
    if (! $dialect)
    {
	croak($usage);
    }

    if ($parent->inline($dialect))
    {
	my $subcircuit = $self->getSubcircuitDefinition($parent, $dialect);
        if (!$subcircuit)
	{
	    croak ("Error: getSubcircuitDefinition: Unable to retrieve subcircuit definition\n");
	}
	my $inLinedSubcircuit = $subcircuit->copyToNamespace($nameSpaceDelimitor . $parent->name);
	$inLinedSubcircuit->adjustInterfaceToParent($parent);
	$inLinedSubcircuit->adjustContentToInterface($nameSpaceDelimitor . $parent->name);
	$inLinedSubcircuit->{CIRCUITS} = $self->{CIRCUITS};
	return $inLinedSubcircuit;
    }
    return undef;
}

#####################################################################
# class/object method : removeFromSubcircuits
# purpose : remove the reference to an Subcircuit from the circuit
# call vocabulary
#
# $Circuit->removeSubcircuit(instanceReference);
#
# e.g.
#    $dKitCircuit->removeFromSubcircuits($C | "all");
#    $C->removeFromSubcircuits

sub removeFromSubcircuits
{
    my $instance = shift;
    if (!ref $instance) 
    { 
	if (@_)
	{
	    $instance = shift;
	} else
	{
	    croak("Usage dKitCircuit->removeFromSubcircuits(\$Circuit);\n");
	}
    }
    if (! $instance)
    {
	carp("removeFromSubcircuits: undefined instance given;\n   Remove Ignored\n");
    } elsif ($instance eq "all")
    {
	%Subcircuits = ();
    } elsif (ref $instance ne "dKitCircuit")
    {
	my $type = ref $instance;
	carp("removeFromSubcircuits: reference to $type given instead of reference to dKitCircuit;\n   Remove ignored\n");
    } else
    {
	delete ${Subcircuits}{$instance->circuitName};
    }
    return;
}


################################################
# class method : printSubcircuits
# purpose : print all Subcircuits defined
# call vocabulary
#
# dKitCircuit->printSubcircuits
#

sub printSubcircuits
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    print "These Subcircuits are currently globally defined:\n";
    print $self->circuits2str(\%Subcircuits);
}


########################################################################################
# class method : createSubcircuitDatabaseFile
# purpose : save all Subcircuits defined in the local file 
#                                             $workDirectory/dKitSubcircuitDB.pl
#
# call vocabulary
#
# dKitCircuit->createSubcircuitDatabaseFile()
#

sub createSubcircuitDatabaseFile
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }

    my $subCircuitHashRef = shift;
    if (! $subCircuitHashRef)
    {
	$subCircuitHashRef = \%Subcircuits;
    }
    my $outFileName = shift;
    if (!$outFileName)
    {
	$outFileName = "$workDirectory/dKitSubcircuitDB.pl";
    }
    if (-f $outFileName)
    {
        rename($outFileName, $outFileName. ".old");
    }

    my $subcircuitDefinitions = dKitCircuit->circuits2perl($subCircuitHashRef);

    open(OUTPUT,">$outFileName") 
        || die "Can't open output template file $outFileName";
    print OUTPUT "dKitCircuit->addSubcircuitHash($VERSION, ";
    print OUTPUT "$subcircuitDefinitions";
    print OUTPUT ");\n";
    print OUTPUT "\n1\n";
    return;
}


#####################################################################
# object method : identifySubcircuits
# purpose : get the subcircuitdefinitions
# call vocabulary
#
# $Circuit->identifySubcircuits;
#
# e.g.
#    $Circuit->identifySubcircuits($dialect);

sub identifySubcircuits
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my @list = ();
    if (@_)
    {
	my $dialect = shift;
	if (!defined $self->{CIRCUITS}->{$dialect})
	{
	    foreach my $instance (@{$self->{INSTANCES}})
	    {
		if (my $subcircuitName = $instance->template->dKitSubcircuitName($dialect))
		{
		    if (my $circuit = dKitCircuit->getSubcircuit($subcircuitName))
		    {
			@list = (@list, $circuit->identifySubcircuits($dialect));
		    }
		    @list = (@list, $subcircuitName);
		}
	    }
	    if (@list)
	    {
		foreach  my $circuitName (@list)
		{
		    $self->{CIRCUITS}->{$dialect}->{$circuitName} = dKitCircuit->getSubcircuit($circuitName);
		}
	    } else
	    {
		$self->{CIRCUITS} = +{};
	    }
	}
	return keys %{ $self->{CIRCUITS}->{$dialect} };
    } else
    {
	croak('Usage : $Circuit->identifySubcircuits($dialect)');
    }
}


#####################################################################
# object method : netlistAsSubcircuit
# purpose : return a string with the netlist of this circuit being a
#  subcircuit
# (instances only)
# call vocabulary
#
# $Circuit->netlistAsSubcircuit(dialect);
#

sub netlistAsSubcircuit
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    if (@_)
    {
 	my $dialect = shift;

# write header
	my $netlist = $self->headerTemplate($dialect) . "\n";

# write instance netlists

	foreach my $instance (@{ $self->{INSTANCES} })
        {
	    $netlist = $netlist . $instance->netlist($dialect);
	}

# write footer
	$netlist = $netlist . $self->footerTemplate($dialect) . "\n";

	return $netlist;

    } else
    {
	croak("usage : \$Circuit->netlistAsSubcircuit(dialect);\n");
	return;
    }
}

#####################################################################
# object method : parameterHash
# purpose : set/get the parameters for a circuit
# call vocabulary
#
# $Circuit->parameterHash(%templateParameterHash);
#
# e.g.
#    $C->parameterHash(C=>"");

sub parameterHash {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_) 
    { 
        % { $self->{PARAMETERS} } = @_ ;
	if ($Debugging > 100)
	{
	    carp("setting parameterHash to " . hash2str(% { $self->{PARAMETERS} }) . "\n");
	}
    }
    if (defined $self->{PARAMETERS})
    {
	return % { $self->{PARAMETERS} } ;
    } else
    {
	return ();
    }
}

#####################################################################
# object method : addParameter
# purpose : add a parameter to the parameter list, initialize to undef
# call vocabulary
#
# $Circuit->addParameter(parameterName);
#
# e.g.
#    $Circuit->addParameter(C);

sub addParameter {
    my $self = shift;
    if (@_) 
    { 
        my $parameter = shift ;
	if (!exists $self->{PARAMETERS}->{$parameter})
        {
	    $self->{PARAMETERS}->{$parameter} = undef;
            if ($Debugging > 100)
	    {
	        carp("adding parameter $parameter, initialized as undef\n");
	    }
        }
    } else
    {
	croak("usage : \$Circuit->addParameter(parameterName);\n");
	return;
    }
}

#####################################################################
# object method : parameterValue
# purpose : set/get the value of a parameter
# call vocabulary
#
# $Template->parameterValue(name [, value]);
#
# e.g.
#  $C->parameterValue(C, "10pf");
#

sub parameterValue {
    my $self = shift;
    if (@_) 
    {
	my $param = shift;
        if (@_) 
        {
            my $paramValue = shift;
	    if (exists $self->{PARAMETERS}->{$param})
	    {
		$self->{PARAMETERS}->{$param} = $paramValue;
	    } else
	    {
		croak("\n Error: parameter $param does not exists for " .  $self->dump2str . "\n");
	    }
        }
        my $value = $self->{PARAMETERS}->{$param};
        while (ref  $value)
        {
	    $value = ${$value};
        }
	return $value;
    }
    return;
}

#####################################################################
# object method : nodeHash
# purpose : set/get the node hash for a circuit
# call vocabulary
#
# $Circuit->nodes(n1=>node1, n2=>node2);
#
# e.g.
#  $C->nodeHash(n1=>_net1, n2=>_net2);
#

sub nodeHash {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if ($self)
    {
        if (@_) 
        {
	    my %nodes = @_;
	    foreach my $node (keys %nodes)
            {
		if (exists $self->{NODES}->{$node})
                {
		    $self->{NODES}->{$node} = $nodes{$node};
		} else
                {
		    $Debugging = 1;
		    croak("\n Error: node $node does not exists for " . $self->dump2str . "\n");
		}
	    }
        }
        return % { $self->{NODES} } ;
    }
}


#####################################################################
# object method : nodeName
# purpose : set/get the external node name for a given node of an instance
# call vocabulary
#
# $Instance->nodeName(internalName[, externalName]);
#
# e.g.
#  $C->nodeName(n1, _net1);
#

sub nodeName {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_) 
    {
	my $node = shift;
	if (@_) 
	{
            my $nodeName = shift;
	    if (exists $self->{NODES}->{$node})
	    {
		$self->{NODES}->{$node} = $nodeName;
	    } else
	    {
		croak("\n Error: node $node does not exists for " .  $self->dump2str . "\n");
	    }
	} 
	if (defined $self->{NODES}->{$node})
	{
	    return $self->{NODES}->{$node};
	}
    }
    return undef;
}

#####################################################################
# object method : nodeList
# purpose : set/get the nodes for a circuit
# call vocabulary
#
# $Circuit->nodeList(@templateNodeList);
#
# e.g.
#  $C->nodeList(n1, n2);
#
#
sub nodeList {
    my $self = shift;
    my @myList;

    if (@_) 
    {
	@myList = @_;
	foreach my $node (@myList)
	{
	    ${ $self->{NODES} } { $node } = scalar keys %{$self->{NODES}};
	}
	if ($Debugging > 100)
	{
           carp("setting nodes to " . list2str(keys %{$self->{NODES}}) . "\n");
	}
    }

    foreach my $node (keys %{$self->{NODES}})
    {
        $myList[$self->{NODES}->{$node}] = $node;
    }

    return @myList ;
}

#####################################################################
# object method : addNode
# purpose : add a node for a circuit
# call vocabulary
#
# $Circuit->addNode(node);
#
# e.g.
#  $C->addNode(n1);
#
#

sub addNode {
    my $self = shift;
    if (@_) 
    {
        my $node = shift ;
	if (!exists $self->{NODES}->{$node})
        {
	    $self->{NODES}->{$node} = scalar keys %{$self->{NODES}};
        }
	if ($Debugging > 100)
	{
	    carp("setting nodes to " . list2str(keys %{$self->{NODES}}) . "\n");
	}
    }
}


#####################################################################
# object method :  headerTemplateHash
# purpose : set/get netlist template Hash for subcircuit inclusion
# call vocabulary
#
# $C->headerTemplateHash(%templateHashTable);
#

sub headerTemplateHash {
    my $self = shift;
    if (@_) 
    { 
	$self->{HEADERTEMPLATES} = @_;
	if ($Debugging > 100)
	{
	    carp("setting header template" . hash2str(%{$self->{HEADERTEMPLATES}}) . "\n");
	}
    }
    return % { $self->{HEADERTEMPLATES} } ;
}

#####################################################################
# object method :  headerTemplate
# purpose : set/get header template dialect for subcircuit inclusion
# call vocabulary
#
# $C->headerTemplate(dialect [, "template"]);
#

sub headerTemplate {
    my $self = shift;
    if (@_) 
    { 
        my $dialect = shift;
	if (@_) 
	{ 
	    my $template = shift;
	    $self->{HEADERTEMPLATES}->{$dialect} = $template;

	    if ($Debugging > 100)
	    {
		carp("setting header template for $dialect to $template\n");
	    }
	}
	return $self->{HEADERTEMPLATES}->{$dialect};
    } else
    {
	croak("usage : \$Template->headerTemplate(dialect[, template]);\n");
	return;
    }
}

#####################################################################
# object method :  footerTemplateHash
# purpose : set/get footer template Hash for subcircuit inclusion
# call vocabulary
#
# $C->footerTemplateHash(%templateHashTable);
#

sub footerTemplateHash {
    my $self = shift;
    if (@_) 
    { 
	$self->{FOOTERTEMPLATES} = @_;
	if ($Debugging > 100)
	{
	    carp("setting footer template" . hash2str(%{$self->{FOOTERTEMPLATES}}) . "\n");
	}
    }
    return % { $self->{FOOTERTEMPLATES} } ;
}

#####################################################################
# object method :  footerTemplate
# purpose : set/get footer template dialect for subcircuit inclusion 
# call vocabulary
#
# $C->footerTemplate(dialect [, "template"]);
#

sub footerTemplate {
    my $self = shift;
    if (@_) 
    { 
        my $dialect = shift;
	if (@_) 
	{ 
	    my $template = shift;
	    $self->{FOOTERTEMPLATES}->{$dialect} = $template;

	    if ($Debugging > 100)
	    {
		carp("setting footer template for $dialect to $template\n");
	    }
	}
	return $self->{FOOTERTEMPLATES}->{$dialect};
    } else
    {
	croak("usage : \$Template->headerTemplate(dialect[, template]);\n");
	return;
    }
}

#########################################################################
####
### purpose higher level function that creates the headers and the footers
##  to be used when calling this circuit as a subcircuit for all dialects
##  defined in %subcircuitVocabularyHash
#
#  call vocabulary
#  $circuit->createSubcircuitHeaderAndFooters([overwrite])
#

sub createSubcircuitHeaderAndFooters
{
    my $self = shift;
    my $overwrite = shift;

    my $type = $self->circuitName;

    my @nodes = $self->nodeList();
    my $nodes = join(" ", @nodes);
    
    my %parameterHash = $self->parameterHash();
    
    my $parameters = "";
    for my $key (keys %parameterHash)
    {
	$parameters = $parameters . $key . "=" . $ {parameterHash}{$key} . " ";
    }
    for my $dialect (keys %subcircuitVocabularyHash)
    {
	my %vocabulary = %{$subcircuitVocabularyHash{$dialect}};
	
	if ($overwrite || ! defined $self->{HEADERTEMPLATES}{$dialect})
	{
	    my $template = $vocabulary{HEADERTEMPLATE};
	    $template =~ s/\&subcircuitName/$type/g;
	    $template =~ s/\&nodes/$nodes/g;
	    $template =~ s/\&parameters/$parameters/g;
	    $self->headerTemplate($dialect, $template);
	}
	
	if ($overwrite || ! defined $self->{FOOTERTEMPLATES}{$dialect})
	{
	    my $template = $vocabulary{FOOTERTEMPLATE};
	    $template =~ s/\&subcircuitName/$type/g;
	    $template =~ s/\&nodes/$nodes/g;
	    $template =~ s/\&parameters/$parameters/g;
	    $self->footerTemplate($dialect, $template);
	}
    }
    return 1;
}
############################################################################
# class method : createTemplateANDaddToSubcircuits
# purpose : create subcircuit template and initiatate with 
# default netlist instance template
#
#     uninitialized parameters are required parameters !!!!
#
# call vocabulary
#
#
# A) using nodelist and parameterlist definitions
#
# $TemplateHandle = $Circuit->createTemplateANDaddToSubcircuits(templateName, 
#                                                  nodeList, parameterlist);
#
# B) using nodelist and required and optional parameter definitions
#
# $TemplateHandle = $Circuit->createTemplateANDaddToSubcircuits(templateName, 
#                   nodeList, requiredParameterList, optionalParameterList);
#
#e.g
#  $C->createTemplateANDaddToSubcircuits(templateName,  
#                                      [n1, n2, n3], 
#                                      ['t1=1', 't2', ],
#                                      ['t=3']);

sub createTemplateANDaddToSubcircuits
{
    ### this function subcircuitizes the circuit and creates a Template

    my $circuit = shift;
    if (@_)
    {
	my $templateName = shift;
	$circuit->addToSubcircuits(@_);
	my $template = $circuit->createSubcircuitTemplateOnly($templateName, @_);
	return $template;
    } else
    {
	croak("Usage: \$Circuit->subcircuitizeANDcreateTemplate(templateName, nodeList, parameterList)");
    }
    return undef;
}



############################################################################
# object method : createSubcircuitTemplateOnly
# purpose : create subcircuit template and initiatate with 
# default netlist instance template
#
#     uninitialized parameters are required parameters !!!!
#
# call vocabulary
#
# A) when circuit has bees setup for subcircuit use using
#                                                  prepareForSubcircuit
#
# $TemplateHandle = $Circuit->createSubcircuitTemplateOnly(templateName);
#
# B) using nodelist and parameterlist definitions
#
# $TemplateHandle = $Circuit->createSubcircuitTemplateOnly(templateName, 
#                                                  nodeList, parameterlist);
#
# C) using nodelist and required and optional parameter definitions
#
# $TemplateHandle = $Circuit->createSubcircuitTemplateOnly(templateName, 
#                   nodeList, requiredParameterList, optionalParameterList);
#
#e.g
#  $C->createSubcircuitTemplateOnly(templateName,  
#                                      [n1, n2, n3], 
#                                      ['t1=1', 't2', ],
#                                      ['t=3']);

sub createSubcircuitTemplateOnly
{
    ### this function only creates Template and does not try to 
    ### subcircuitize 

    my $circuit = shift;
    if (@_)
    {
        my $templateName = shift;   
	my @nodes = ();
	my @requiredParameterList = ();
	my @optionalParameterList = ();

	if (@_)
	{
	    my $nodeRef = shift;
	    @nodes = @{$nodeRef};
	} else
	{
	    @nodes = $circuit->nodeList();
	}
	if (@_)
	{
	    my $requiredParametersRef = shift;
	    if (@_)
	    {
		my $optionalParametersRef = shift;
		@requiredParameterList = @{$requiredParametersRef};
		@optionalParameterList = @{$optionalParametersRef};
	    } else
	    {
		my @parameterList = @{$requiredParametersRef};
		for my $key (@parameterList)
		{
		    if ($key =~ /^(.*)=(.*)$/)
		    {
			push(@optionalParameterList, $key);
		    } else 
		    {
			push(@requiredParameterList, $key);
		    }
		}
	    }
	} else
	{
	    my %parameterHash = $circuit->parameterHash();
	    for my $key (keys %parameterHash)
	    {
		if ($ {parameterHash}{$key})
		{
		    push(@optionalParameterList, $key);
		} else 
		{
		    push(@requiredParameterList, $key);
		}
	    }
	}

#	if ($#nodes == -1)
#	{
#	    croak(": Unable to create subCircuit Template: no nodes defined.\n");
#	}

	my $subCircuitTemplate = dKitTemplate->new($templateName);
	$subCircuitTemplate->requiredPrefix('x');

	for my $dialect (keys %subcircuitVocabularyHash)
	{
	    my %vocabulary = %{$subcircuitVocabularyHash{$dialect}};
	    $subCircuitTemplate->dKitSubcircuitName($dialect, $circuit->circuitName);
	    my $template = $vocabulary{INSTANCETEMPLATE};
	    my $nodes = "";
	    for my $node (@nodes)
	    {
		$nodes = $nodes . "%" . $node . " ";
	    }

	    my $requiredParameters = "";
	    for my $key (@requiredParameterList)
	    {
		if ($key =~ /^(.*)=(.*)$/)
		{
		    $requiredParameters = $requiredParameters . $1 . "=<" . $1 . "> ";
		} else 
		{
		    $requiredParameters = $requiredParameters . $key . "=<" . $key . "> ";
		}
	    }
	    my $optionalParameters = "";
	    for my $key (@optionalParameterList)
	    {
		if ($key =~ /(.*)=(.*)$/)
		{
		    $optionalParameters = $optionalParameters . "[[" . $1 . "=<" . $1 . ">]] ";
		} else 
		{
		    $optionalParameters = $optionalParameters . "[[" . $key . "=<" . $key . ">]] ";
		}
	    }
	    my $circuitName = $circuit->circuitName;
	    $template =~ s/\&subcircuitName/$circuitName/g;
	    $template =~ s/\&nodes/$nodes/g;
	    $template =~ s/\&requiredParameters/$requiredParameters/g;
	    $template =~ s/\&optionalParameters/$optionalParameters/g;
	    $subCircuitTemplate->netlistInstanceTemplate($dialect, $template);
	}
	return $subCircuitTemplate;
    }
    croak("usage :  $circuit->createSubcircuitTemplateOnly(templateName, [nodeList, [[parameterList], [requiredParameterList, optionalParameterList]]]);\n");
    return undef;
}


##########################################################################
# class method : prepareForSubcircuit
# purpose : add parameters and nodes so circuit can be used as subcircuit
# call vocabulary
#
# $Circuit->prepareForSubcircuit(nodeList, parameterList [, optionalParameterList])
#
# e.g
#  $C->prepareForSubcircuit([n1, n2, n3], ['t1=1', 't2']);

sub prepareForSubcircuit
{
    my $circuit = shift;
    if (@_)
    {
	my $nodeRef = shift;
	for my $node (@{$nodeRef})
	{
	    $circuit->addNode($node);
	}
	while ($#_ > -1)
	{
	    my $parametersRef = shift;
	    for my $key (@{$parametersRef})
	    {
		if ($key =~ /(.*)=(.*)$/)
		{
		    $circuit->addParameter($1);
		    $circuit->parameterValue($1, $2);
		} else 
		{
		    $circuit->addParameter($key);
		}
	    }
	}
	return;
    }
    croak("usage :  \$Circuit->prepareForSubcircuit(nodeList, parameterList);\n");
    return undef;
}

###########################################################################
# class method : isSubcircuit 
# purpose : determine whether a device 
# using the subcircuit . notation is a subCircuit within the given circuit
# call vocabulary
# $circuit->isSubcircuit('deviceName', 'dialect');

sub isSubcircuit
{
    my $usage = "\$circuit->isSubcircuit('deviceName', 'dialect')";
    my $circuit = shift;  ## reference to circuit
    if (!ref $circuit) { confess "Object method called as class method.\n$usage";}
    if (! @_) 
    { 
	croak "$usage";
    }
    my $deviceName = shift;
    if (! @_) 
    { 
	croak "$usage";
    }
    my $dialect = shift;

    #### split subcircuits/devices ...

# print "entering getInstanceHierarchy from isSubcircuit\n";

    my @instanceHierarchy = $circuit->getInstanceHierarchy($deviceName, $dialect);

    # check whether last one in chain is subcircuit
    my $instance = $instanceHierarchy[$#instanceHierarchy];
    if (! $instance)
    {
	warn "could not check whether instance $deviceName is subcircuit\nGuessed it is not\n";
	return 0;
    }
    if (! $instance->isSubcircuit($dialect))
    {
	return 0;
    }
    return 1;
}


############################################################################
#####
##
## functions that deal with parameters
#

###########################################################################
# object method : 
# purpose : get translated network/device parameter 
# call vocabulary
# ($parameterName, $deviceName) = $circuit->getTranslatedParameterDevicePair(dialect, parameterName [,deviceName]);

sub getTranslatedParameterDevicePair($$;$)
{
    my $usage = "(\$parameterName, \$deviceName) = \$circuit->getTranslatedParameterDevicePair('dialect', 'parameterName' [,'deviceName'])";
    my $circuit = shift;  ## reference to circuit
    if (! ref $circuit) { confess "Object method called as class method.\n$usage";}
    if (! @_) { croak "$usage"; }
    my $dialect = shift; 
    if (! @_) { croak "$usage"; }
    my $parameterName = shift;
    if (! @_) { croak "$usage"; }
    my $deviceName = shift;

    my $want = "";
    if ($dialect =~ /^(.*)4(.*)$/)
    {
	$want = $1;
	$dialect = $2;
    }

    my $newParameterName = "";
    my $newDeviceName = "";
    my $inlinedName = "";

    if ($deviceName)
    {
	my @instanceHierarchy = $circuit->getInstanceHierarchy($deviceName, $dialect);
	my $instance = ""; 
	for (my $ndx = 0; $ndx < $#instanceHierarchy; $ndx++)
	{
	    $instance = $instanceHierarchy[$ndx];
	    if ($newDeviceName)
	    {
		$newDeviceName = $newDeviceName . ".";
	    }
	    $newDeviceName = $newDeviceName . $instance->instanceName;
	}

	### check whether the last device is inlined...
	$instance = $instanceHierarchy[$#instanceHierarchy];
	if (!$instance)
	{
	    croak("Could not find instance with name $deviceName\n");
	}
	if ($instance->inline($dialect))
	{
	    $inlinedName = $nameSpaceDelimitor . $instance->instanceName;
	} else
	{
	    if ($newDeviceName)
	    {
		$newDeviceName = $newDeviceName . ".";
	    }
	    $newDeviceName = $newDeviceName . $instance->instanceName;	    
	}
    }

    if ($want eq "result")
    {
	$newParameterName = dKitParameter->dKit2result($parameterName);
    } elsif ($want eq "dKit")
    {
	$newParameterName = $parameterName;
    } else
    {
	$newParameterName = dKitParameter->dKit2dialect($parameterName, $dialect);
    }
    $newParameterName = $newParameterName . $inlinedName;

# print "dialect = $want$dialect newParameterName=$newParameterName newDeviceName=$newDeviceName\n";

    return ($newParameterName, $newDeviceName);
}


#########################################################################
#
# obsoleted functions
#

#####################################################################
# object method : parameter
# purpose : set/get a parameter 
# call vocabulary
#
# $Circuit->parameter(parameterName, value);
#
# e.g.
#    $C->parameter(C);
#    $C->parameter(C, undef);
#
#sub parameter {
#    my $self = shift;
#    if (! ref $self) { confess "Object method called as class method";}
#    if (@_) 
#    { 
#        my $parameter = shift ;
#	if (@_) 
#	{
#	    my $value = shift ;
#	    $self->{PARAMETERS}->{$parameter} = $value;
#	    if ($Debugging > 100)
#	    {
#		carp("setting parameter $parameter, initialized as $value\n");
#	    }
#        }
#        return($self->{PARAMETERS}->{$parameter});
#    } else
#    {
#	croak("usage : \$Circuit->parameter(parameterName [,value];\n");
#	return;
#    } 
#}


1







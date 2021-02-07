package dKitAnalysis;

use strict;
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
$dKitAnalysis::VERSION = $VERSION;

#### Debugging
use Carp;
my $Debugging = 0;

################################################
# class method : debug
# purpose : set debugging level for class
# call vocabulary
#
# dKitAnalysis->debug(level);
#   0 : debugging off.
#

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : dKitAnalysis->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
	carp ("dKitAnalysis debugging turned on\n");
    } else
    {
	carp ("dKitAnalysis debugging turned off\n");
    }
}

my %Analyses = ();

################################################
# class method : dumpAnalyses
# purpose : list all analysiss defined
# call vocabulary
#
# dKitAnalysis->listAnalyses;
#

sub listAnalyses
{
    my $self = shift;
    my %myAnalyses;
    if (ref $self)
    { #object
	%myAnalyses = % { $self->{_GlobalAnalyses} };
    } else
    { # class
	%myAnalyses = %Analyses;
    }

    print "These analyses are currently defined:\n";
    foreach my $analysis (keys %myAnalyses)
    {
	print $analysis . " ";
	print $myAnalyses{$analysis}->dump2str;
    }
}

######################################
# class method : new
# purpose : create analysis
# call vocabulary
#
# $dKitAnalysis->new("templateName", instanceName);
#
#e.g
#  $C = dKitAnalysis->new(DC, 1);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self;
    if (!@_)
    {
        croak("usage : dKitAnalysis->new(\"templateName\"[, \"analysisName\"]);\n");
        return;
    }
    my $templateName = shift;
    my $template = dKitTemplate->getTemplate($templateName);
    if (! $template)
    {
	croak("Could not find template definition for $templateName.\nExiting.");
    }

    my $instanceName = shift;
    if ($Analyses{$templateName . $instanceName})
    {
	croak("Analysis $templateName . $instanceName already defined\nExiting.");
    }
    $self = +{};
    $self->{TEMPLATE} = $template;
    $self->{NAME} = $instanceName;
    $self->{_GlobalAnalyses} = \%Analyses;
    $Analyses{$templateName . $instanceName} = $self;

#    instanciate the nodes from the template
#    $self->{NODES} = +{};
#    foreach my $node ($template->nodeList)
#    {
#         $self->{NODES}->{$node} = undef;
#    }

    $self->{SUBANALYSES} = [];
    $self->{OUTPUTPLANS} = [];
    $self->{SWEEPPLANS} = [];
    $self->{PARAMETERS} = +{};
    # instanciate the parameters from the template
    foreach my $param (keys % {$template->{PARAMETERS} })
    {
	$self->{PARAMETERS}->{$param} = $template->{PARAMETERS}->{$param};
    }

    #### figure out whether or not to inline
    ###  when inline is true for subcircuit... 
    ##   flatten circuit instead of using subcircuit call
    # inline is a hash table, one entry for each dialect
    $self->{INLINE} = $template->inline;

    bless($self, $class);
    if ($Debugging > 100)
    {
	carp("created new analysis instance\n");
    }
    return $self;
}


######################################
# object method : copyToNamespace
# purpose : create analysis in new namespace
# call vocabulary
#
# $analysis->copyToNamespace("namespace");
#
#e.g
#  $DC->copyToNamespace('x7');

sub copyToNamespace {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (! @_)
    {
        croak("usage : \$analysis->copyToNamespace(\"namespace\"]);\n");
        return;
    }
    my $class = ref($self) ;
    my $namespace = shift;

### we need to append namespaces because otherwise we'll get in trouble with 
##  instance prefixes ...

    my $analysisName = $self->analysisName . $namespace  ;
    if ($analysisName)
    {
	if ($Analyses{$analysisName})
	{
	    ### when copying to namespace 
	    ## we delete previous existences automatically

	    delete $Analyses{$analysisName};
	}
    }
    my $template = $self->template;
    if (my $requiredPrefix = $template->requiredPrefix)
    {
	if (!($analysisName =~ /^$requiredPrefix/i))
	{
	    croak("Analysis of type " . $template->templateName . " has wrong name $analysisName.\nName should start with $requiredPrefix.\nExiting.");
	} 
    }
    my $newAnalysis = +{};
    $newAnalysis->{TEMPLATE} = $template;
    if ($analysisName)
    {
	$newAnalysis->{NAME} = $analysisName;
	$newAnalysis->{_GlobalInstances} = \%Analyses;
	$Analyses{$analysisName} = $newAnalysis;
    }

#  instanciate the nodes from the original instance
#    $newAnalysis->{NODES} = +{};
#    foreach my $node (keys %{$self->{NODES}})
#    {
#         $newAnalysis->{NODES}->{$node} = ${$self->{NODES}}{$node};
#    }
    # instanciate the parameters from the original instance
    $newAnalysis->{PARAMETERS} = +{};
    foreach my $param (keys %{$self->{PARAMETERS}})
    {
	$newAnalysis->{PARAMETERS}->{$param} = ${$self->{PARAMETERS}}{$param};
    }

    foreach my $subanalysis (@{$self->{SUBANALYSES}})
    {
	push(@{$newAnalysis->{SUBANALYSES}}, $subanalysis->copyToNamespace($namespace));
    }
    foreach my $outputplan (@{$self->{OUTPUTPLANS}})
    {
	push(@{$newAnalysis->{OUTPUTPLANS}}, $outputplan->copyToNamespace($namespace));
    }
    foreach my $sweepplan (@{$self->{SWEEPPLANS}})
    {
	push(@{$newAnalysis->{SWEEPPLANS}}, $sweepplan->copyToNamespace($namespace));
    }

    #### figure out whether or not to inline
    ###  when inline is true for subcircuit... 
    ##   flatten circuit instead of using subcircuit call
    # inline is a hash table, one entry for each dialect

    $newAnalysis->{INLINE} = +{};
    foreach my $param (keys %{$self->{INLINE}})
    {
	$newAnalysis->{INLINE}->{$param} = ${$self->{INLINE}}{$param};
    }

    bless($newAnalysis, $class);
    if ($Debugging > 100)
    {
	carp("copyied analysis to namespace\n");
    }
    return $newAnalysis;
}

######################################
# object method : fixParametersForNamespace
# purpose : fix the parameters for this analysis when placed in the new namespace
# call vocabulary
#
# $instance->fixParametersForNamespace("namespace", $circuitRef);
#

sub fixParametersForNamespace($$) 
{
    my $analysis = shift;
    if (! @_)
    {
        croak("usage : \$analysis->fixParametersForNamespace(\"namespace\", circuitRef);\n");
        return;
    }
    my $namespace = shift;
    if (! @_)
    {
        croak("usage : \$analysis->fixParametersForNamespace(\"namespace\", circuitRef);\n");
        return;
    }

    my $circuitRef = shift;

    foreach my $subAnalysis (@{$analysis->{SUBANALYSES}})
    {
	$subAnalysis->fixParametersForNamespace($namespace, $circuitRef);
    }

    foreach my $sweepplan (@{$analysis->{SWEEPPLANS}})
    {
	$sweepplan->fixParametersForNamespace($namespace, $circuitRef);
    }

    foreach my $outputplan (@{$analysis->{OUTPUTPLANS}})
    {
	$outputplan->fixParametersForNamespace($namespace, $circuitRef);
    }

    ### build device hash, device names have namespace added already

    my %deviceHash = ();
    foreach my $device (@{$circuitRef->{INSTANCES}})
    {
#	print "defining" . $device->name. "\n";
	$deviceHash{$device->name} = 1;
    }


    foreach my $parameter (keys %{$analysis->{PARAMETERS}})
    {
	my $paramValue = $analysis->parameterValue($parameter);
	if (defined $paramValue)
	{
# print "found parameter $parameter with value $paramValue\n";
	    my $newParamValue = "";
	    my $regExp = '\b([\w]+)|([\W]+)';
	    while ($paramValue =~ /(?:$regExp)/g)
	    {
		### $1 is alphanumeric + _
		### $2 all other content
# print "found chuncks $1, $2\n";
		if ($1 ne "")
		{
		    if (defined $deviceHash{$1 . $namespace})
		    {
			$newParamValue = $newParamValue . $1 . $namespace;
		    } else
		    {
			$newParamValue = $newParamValue . $1;
		    }
		} elsif ($2)
		{
		    $newParamValue = $newParamValue . $2;
		}
	    }
	    $analysis->parameterValue($parameter, $newParamValue);
# print "parameter $parameter set to $newParamValue\n";
	}
    }

    return;
}


######################################
# object method : DESTROY
# purpose : destoy Analysis
# call vocabulary
#
# $Analysis->DESTROY;
#
 
sub DESTROY {
    my $self = shift;
    delete $ {$self->{_GlobalAnalyses} }{$self->analysisName};
}

#####################################################################
# object method : blessContent
# purpose : add the necessary class definitions to each value
# call vocabulary
#
# $Analysis->blessContent
#
# e.g.
#    $Analysis->blessConten;

sub blessContent
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    foreach my $analysis (@ {$self->{SUBANALYSES} })
    {
       bless($analysis, "dKitAnalysis");
       $analysis->blessContent;
    }

    foreach my $sweepplan (@ {$self->{SWEEPPLANS} })
    {
       bless($sweepplan, "dKitAnalysis");
    }

    foreach my $outputplan (@ {$self->{OUTPUTPLANS} })
    {
       bless($outputplan, "dKitAnalysis");
    }

    return;
}


#####################################################################
# object method : analysisName
# purpose : get the analysisName for an analysis
# call vocabulary
#
# $Analysis->analysisName;
#

sub analysisName {
    my $self = shift;
    if (@_) 
    {
	my $name = shift;
	carp("Cannot change analysisName to $name\nOld analysisName $self->{NAME} still in use\n");
#	$self->{NAME} = $name;
#	if ($Debugging > 100)
#	{
#	    carp("setting analysisName to $self->{NAME}\n");
#	}
    }
    return $self->{NAME};
}


#####################################################################
# object method : name
# purpose : get the name for an analysis
# call vocabulary
#
# $Analysis->name;
#

sub name {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return $self->{NAME};
}

#####################################################################
# object method : template
# purpose : set/get the reference to the template for an Analysis
# call vocabulary
#
# $Analysis->template;
#

sub template {
    my $self = shift;
    if (@_) 
    {
	my $template = shift;
        if (ref $template)
	{
	    $template = $template->templateName;
	}
	carp("Cannot change template to $template\nOld template $self->template->templateName still in use\n");
#        $self->{TEMPLATE} = $template;
    }
    if (! ref $self->{TEMPLATE})
    {
	my $template = dKitTemplate->getTemplate($self->{TEMPLATE});
	$self->{TEMPLATE} = $template;
    }
    return $self->{TEMPLATE};
}

#####################################################################
# object method : inline
# purpose : get/set the inline value for an instance
# call vocabulary
#
# $Analysis->inline(dialect);
#

sub inline {
    my $self = shift;
    if (@_) 
    {
	my $dialect = shift;
	if (@_)
	{
	    if (! $self->isSubcircuit($dialect))
	    {
		carp("$self->analysisName is not a subcircuit for dialect $dialect.\n \$Analysis->inline function ignored;\n");
		return undef;
	    }		    my $inline = shift;
	    $self->{INLINE}->{$dialect} = $inline;
	    if ($Debugging > 100)
	    {
		carp("setting inline for dialect $dialect to $self->{INLINE}->{$dialect}\n");
	    }
	}
	if (defined $self->{INLINE}->{$dialect})
	{
	    return $self->{INLINE}->{$dialect};
	}
	return undef;
    }
    return $self->{INLINE};
}

#####################################################################
# object method : isSubcircuit
# purpose : isSubcircuittest wheter this analysis is a subcircuit
# call vocabulary
#
# $Analysis->isSubcircuit;
#

sub isSubcircuit()
{
    my $self = shift;
    if (! ref $self) 
    { 
	if (@_)
	{
	    my $analysisName = shift;
	    $self = $Analyses{$analysisName};
	} else
        {
	    croak("usage : dKitAnalysis->isSubcircuit(analysisName, dialect);\n");
	}
    }
    if (@_)
    {
	my $dialect = shift;
	my $template = $self->template;
        my $subCircuitName = $template->dKitSubcircuitName($dialect);
	if ($subCircuitName)
	{
	    return 1;
        } else
	{
            return 0;
	}
    } else
    {
	croak("usage : \$Analysis->isSubcircuit(dialect);\n or\n        dKitAnalysis->isSubcircuit(analysisName, dialect);\n");
	return 0;
    }
    return undef;
}


#####################################################################
# object method : getAllAnalyses
# purpose : get a list including this analysis and all subanalyses
# call vocabulary
#
#  $subanalysis = $Analysis->getAllAnalyses;
#

sub getAllAnalyses
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my @list = ($self);
    foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
    {
	push (@list, $subAnalysis->getAllAnalyses);
    }
    return @list;
}


#####################################################################
# object method : getFlattenedAnalysis
# purpose : get subAnalysis given its name within analysis or its subanalyses
# call vocabulary
#
#  $subanalysis = $Analysis->getFlattenedAnalysis(name);
#

sub getFlattenedAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift;
	my @analyses = $self->getAllAnalyses;
	my @list = grep($_->analysisName eq $name, @analyses);
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Analysis->getFlattenedAnalysis: found $cnt subanalyses with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Analysis->getFlattenedAnalysis(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getFlattenedSweepPlan
# purpose : get sweepplan given its name within analysis or its subanalyses
# call vocabulary
#
#  $subanalysis = $Analysis->getFlattenedSweepPlan(name);
#

sub getFlattenedSweepPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift;
	my @analyses = $self->getAllAnalyses;
	my @list = ();
	foreach my $analysis (@analyses)
        {
	    my $item = $analysis->getLocalSweepPlan($name);
	    if ($item)
	    {
		push(@list, $item);
	    }
	}
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Analysis->getFlattenedSweepPlan: found $cnt sweep plans with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Analysis->getFlattenedSweepPlan(\"name\");\n");
	return undef;
    }
}


#####################################################################
# object method : getFlattenedOutputPlan
# purpose : get outpuplan given its name within analysis or its subanalyses
# call vocabulary
#
#  $handle = $Analysis->getFlattenedOutputPlan(name);
#

sub getFlattenedOutputPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift;
	my @analyses = $self->getAllAnalyses;
	my @list = ();
	foreach my $analysis (@analyses)
        {
	    my $item = $analysis->getLocalOutputPlan($name);
	    if ($item)
	    {
		push(@list, $item);
	    }
	}
	if ($#list > 0)
        {
	    my $cnt = $#list + 1;
	    carp("Analysis->getFlattenedOutputPlan: found $cnt outputplans with name $name\nReturning first occurence\n")
	}
	return $list[0];
    } else
    {
	croak("usage : \$Analysis->getFlattenedOutputPlan(\"name\");\n");
	return undef;
    }
}



#####################################################################
# object method : addSubAnalysis
# purpose : add to the sweep analysis the reference to a subAnalysis
# call vocabulary
#
# $Analysis->addSubAnalysis(analysisReference);
#
# e.g.
#    $Analysis->addSubAnalysis($sweep1);

sub addSubAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $instance = shift;
    if ($instance)
    {
        @ {$self->{SUBANALYSES} } = (@ {$self->{SUBANALYSES} }, $instance);
    } else
    {
	carp("addSubAnalysis: undefined analysis given.\n   Add ignored;\n");
    }
    return;
}

#####################################################################
# object method : getSubAnalyses
# purpose : get the subAnalyses
# call vocabulary
#
#  @subanalysesList = $Analysis->getSubAnalyses;
#

sub getSubAnalyses
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @ {$self->{SUBANALYSES} };
}

#####################################################################
# object method : removeSubAnalysis
# purpose : add to the sweep analysis the reference to a subAnalysis
# call vocabulary
#
# $Analysis->removeSubAnalysis(analysisReference);
#
# e.g.
#    $Analysis->removeSubAnalysis($sweep1);

sub removeSubAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    my $instance = shift;
    if (! $instance)
    {
	carp("removeSubAnalysis: undefined analysis given.\n   Remove ignored;\n");
    } elsif ($instance eq "all")
    {
	@ {$self->{SUBANALYSES} } = ();
    } elsif (ref $instance ne "dKitAnalysis")
    {
	my $type = ref $instance;
	carp("removeSubAnalysis: reference to $type given instead of reference to dKitAnalysis;\n   Remove ignored\n");
    } else
    {
	if (grep($instance == $_, @ {$self->{SUBANALYSES} }))
	{
	    @ {$self->{SUBANALYSES} } = grep($instance != $_, @ {$self->{SUBANALYSES} });
	} else
	{
	    carp("removeSubAnalysis: reference to remove not found;\n   Remove ignored\n");
	}
    }
    return;
}

#####################################################################
# object method : getLocalSubAnalysis
# purpose : get a local subAnalysis given its name
# call vocabulary
#
#  $subanalysis = $Analysis->getLocalSubAnalysis(name);
#

sub getLocalSubAnalysis
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @list = grep($_->analysisName eq $name, @ {$self->{SUBANALYSES} });
	if ($#list == 0)
	{
	    return $list[0];
        } elsif ($#list > 0)
        {
	    carp("Analysis->getLocalSubAnalysis: found $#list subanalyses with name $name\nReturning first occurence\n");
	    return $list[0];
	} 
	return undef;
    } else
    {
	croak("usage : \$Analysis->getLocalSubAnalysis(\"name\");\n");
	return undef;
    }
}

#####################################################################
# object method : addSweepPlan
# purpose : add to the sweep analysis the reference to a sweepPlan
# call vocabulary
#
# $Analysis->addSweepPlan(sweepPlanReference);
#
# e.g.
#    $Analysis->addSweepPlan($Plan1);

sub addSweepPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $instance = shift;
    if ($instance)
    {
        @ {$self->{SWEEPPLANS} } = (@ {$self->{SWEEPPLANS} }, $instance);
    } else
    {
	carp("addSweepPlan: undefined SweepPlan given.\n   Add ignored;\n");
    }
    return;
}

#####################################################################
# object method : getSweepPlans
# purpose : get all the sweepplans
# call vocabulary
#
# @sweepplanList = $Analysis->getSweepPlans();
#

sub getSweepPlans
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @ {$self->{SWEEPPLANS} };
}

#####################################################################
# object method : removeSweepPlan
# purpose : remove for the sweep analysis the reference to a sweepPlan
# call vocabulary
#
# $Analysis->removeSweepPlan(sweepPlanReference);
#
# e.g.
#    $Analysis->removeSweepPlan($Plan1);

sub removeSweepPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $instance = shift;
    if (! $instance)
    {
	carp("removeSweepPlan: undefined sweepplan given.\n   Remove ignored;\n");
    } elsif ($instance eq "all")
    {
	@ {$self->{SWEEPPLANS} } = ();
    } elsif (ref $instance ne "dKitAnalysis")
    {
	my $type = ref $instance;
	carp("removeSweepplan: reference to $type given instead of reference to dKitAnalysis;\n   Remove ignored\n");
    } else
    {
	if (grep($instance == $_, @ {$self->{SWEEPPLANS} }))
	{
	    @ {$self->{SWEEPPLANS} } = grep($instance != $_, @ {$self->{SWEEPPLANS} });
	} else
	{
	    carp("removeAnalysis: reference to remove not found;\n   Remove ignored\n");
	}
    }
    return;
}

#####################################################################
# object method : getLocalSweepPlan
# purpose : get a local sweep plan given its name
# call vocabulary
#
#  $subanalysis = $Analysis->getLocalSweepPlan(name);
#

sub getLocalSweepPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @list = grep($_->analysisName eq $name, @ {$self->{SWEEPPLANS} });
	if ($#list == 0)
	{
	    return $list[0];
        } elsif ($#list > 0)
        {
	    carp("Analysis->getLocalSweepPlan: found $#list sweep plans with name $name\nReturning first occurence\n");
	    return $list[0];
	} 
	return undef;
    } else
    {
	croak("usage : \$Analysis->getLocalSweepplan(\"name\");\n");
	return undef;
    }
}

#####################################################################
# object method : addOutputPlan
# purpose : add to the analysis the reference to an outputPlan
# call vocabulary
#
# $Analysis->addOutputPlan(outputPlanReference);
#
# e.g.
#    $Analysis->addOutputPlan($Plan1);

sub addOutputPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $instance = shift;
    if ($instance)
    {
	@ {$self->{OUTPUTPLANS} } = (@ {$self->{OUTPUTPLANS} }, $instance);
    } else
    {
	carp("addOutputPlan: undefined outputPlan given.\n   Add ignored;\n");
    }
    return;
}

#####################################################################
# object method : getOutputPlans
# purpose : get a list of outputPlan from an analysis 
# call vocabulary
#
# @outputplanList = $Analysis->getOutputPlans;

sub getOutputPlans
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return @ {$self->{OUTPUTPLANS} };
}

#####################################################################
# object method : removeOutputPlan
# purpose : remove from the analysis the reference to an outputPlan
# call vocabulary
#
# $Analysis->removeOutputPlan(outputPlanReference|all);
#
# e.g.
#    $Analysis->removeOutputPlan($Plan1);

sub removeOutputPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $instance = shift;
    if (! $instance)
    {
	carp("removeOutputPlan: undefined outputplan given.\n   Remove ignored;\n");
    } elsif ($instance eq "all")
    {
	@ {$self->{OUTPUTPLANS} } = ();
    } elsif (ref $instance ne "dKitAnalysis")
    {
	my $type = ref $instance;
	carp("removeOutputPlan: reference to $type given instead of reference to dKitAnalysis;\n   Remove ignored\n");
    } else
    {
	if (grep($instance == $_, @ {$self->{OUTPUTPLANS} }))
	{
	    @ {$self->{OUTPUTPLANS} } = grep($instance != $_, @ {$self->{OUTPUTPLANS} });
	} else
	{
	    carp("removeOutputPlan: reference to remove not found;\n   Remove ignored\n");
	}
    }
    return;
}

#####################################################################
# object method : getLocalOutputPlan
# purpose : get a local output plan given its name
# call vocabulary
#
#  $subanalysis = $Analysis->getLocalOutputPlan(name);
#

sub getLocalOutputPlan
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $name = shift; 
	my @list = grep($_->analysisName eq $name, @ {$self->{OUTPUTPLANS} });
	if ($#list == 0)
	{
	    return $list[0];
        } elsif ($#list > 0)
        {
	    carp("Analysis->getLocalOutputPlan: found $#list output plans with name $name\nReturning first occurence\n");
	    return $list[0];	    
	} 
	return undef;
    } else
    {
	croak("usage : \$Analysis->getLocalOutputPlan(\"name\");\n");
	return undef;
    }
}

#####################################################################
# object method : parameterHash
# purpose : set/get the parameters for an analysis
# call vocabulary
#
# $Analysis->parameterHash(%templateParameterHash);
#
# e.g.
#    $C->parameterHash(C=>"");

sub parameterHash {
    my $self = shift;
    if (@_) 
    { 
	my %params = @_;
	foreach my $param (keys %params)
	{
	    if (exists $self->{PARAMETERS}->{$param})
	    {
		$self->{PARAMETERS}->{$param} = $params{$param};
	    } else
	    {
		croak("\n Error: parameter $param does not exists for " . $self->dump2str . "\n");
	    }
	}
    }
    return % { $self->{PARAMETERS} } ;
}

#####################################################################
# object method : parameterValue
# purpose : set/get the value of a parameter
# call vocabulary
#
# $Analysis->parameterValue(name [, value]);
#
# e.g.
#  $DC->parameterValue(DC, "10V");
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
	    $value = $ {$value};
        }
	return $value;
    }
    return;
}

#####################################################################
# object method : netlist
# purpose : return a string with the netlist
# call vocabulary
#
# we need the circuit definition (for hspice, and to fix a bug in spectre Sparmas) !!
#   we even have to alter it for hspice sweeps and noise analysis
# $Analysis->netlist(dialect, circuit);
#

sub netlist 
{
    my $self = shift;
    if (!@_)
    {
	croak("usage : Analysis->netlist(dialect, circuit);\n");
	return;
    }
    my $dialect = shift;
    if (!@_)
    {
	croak("usage : Analysis->netlist(dialect, circuit);\n");
	return;
    }
    my $circuit = shift;

    ### use internaly stored raw representation;
    my $netlistTemplateRef = dKitTemplate->prepareNetlistTemplate($self, $dialect);

    if ($netlistTemplateRef)
    {
	dKitTemplate->nt_substituteVariables($self);
#       dKitTemplate->nt_substituteNodes($self);
	dKitTemplate->nt_substituteName($self);

	my $line = $self->{NETLIST};
	my $addedLines = "";

#### create suranalysis refs

	if ($#{$self->{SUBANALYSES} } > -1)
	{
	    foreach my $subAnalysis (@{$self->{SUBANALYSES} })
	    {
		#### SURANALYSIS only used in this context...
		$subAnalysis->{SURANALYSIS} = $self;
	    }
	}

	### hspice substitution
	if ( $line =~ /#hspiceAnalysis/ )
	{
	    ### if other sweeps are defined, there are problems with sweep defined
	    ### on dc analysis lines .... so extend to datasweeps

	    my $hspiceDefinition;
            my $template = $self->template;
            my $templateName = $template->templateName;
	    if ($templateName eq "SWEEP")
	    {
		if ($#{$self->{SUBANALYSES} } > -1)
		{
		    if ($#{$self->{SWEEPPLANS} } == 0)
		    {
			my $subAnalysis = $ {$self->{SUBANALYSES} }[0];
			return $subAnalysis->netlist($dialect, $circuit);
		    } else
		    {
			croak("Error: more than 1 sweepplan defined in " .  $self->dump2str . "\n");
		    }
		} else
		{
		    carp("subanalysis not defined\nSkipped for" . $self->dump2str . "\n");
		}
	    } elsif ($templateName eq "MONTE")
	    {
		if ($#{$self->{SUBANALYSES} } > -1)
		{
			my $subAnalysis = $ {$self->{SUBANALYSES} }[0];
   			return $subAnalysis->netlist($dialect, $circuit);
		} else
		{
		    carp("subanalysis not defined\nSkipped for" . $self->dump2str . "\n");
		}
	    } elsif (($templateName =~ /DC/)
		     || ($templateName =~ /TRAN/)
		     || ($templateName =~ /AC/)
		     || ($templateName =~ /NOISE/)
		     || ($templateName =~ /SP/))
	    {
		my @fullList = ();
		my $surAnalysis = $self->{SURANALYSIS};
		
		while ($surAnalysis)
		{
		    @fullList = ($surAnalysis, @fullList);
		    $surAnalysis = $surAnalysis->{SURANALYSIS};
		}

	### add the local definition
		if ($templateName =~ /TRAN/)
		{
		    if ($#{$self->{SWEEPPLANS} } == -1)
		    {
			@fullList = ($self, @fullList);
		    } else
		    {
			carp("Warning: Sweepplan defined for TRAN analysis.  Sweepplan ignored. \n");
		    }
		} elsif ($#{$self->{SWEEPPLANS} } > -1)
		{
		    if ($#{$self->{SWEEPPLANS} } == 0)
		    {
			@fullList = ($self, @fullList);
		    } else
		    {
			croak("Error: more than 1 sweepplan defined in " .  $self->dump2str . "\n");
		    }
		}

		my $dataName="S";
		my $dataParams="";
		my @dataList=();

                my $temperaturePlan="";
                my $frequencyPlan="";

		foreach my $sweep (@fullList)
		{
		    (my $newParam, my $newDevice) = $circuit->getTranslatedParameterDevicePair("hspice", $sweep->parameterValue('parameter'), $sweep->parameterValue('device'));

            if ( $sweep->{TEMPLATE}->{TEMPLATENAME} eq "MONTE" ) {
            $line = $line . " SWEEP MONTE=" . $sweep->{PARAMETERS}->{iterations}; 
            } elsif ( $sweep->{TEMPLATE}->{TEMPLATENAME} eq "TRAN" ) {
		  # do nothing... no sweep plans are used with the transient analysis 
	    } else
		    {
		    if ($newDevice)
		    {
			$dataParams = $dataParams . "$newDevice" . ".";
		    }

#		    $dataParams = $dataParams . "$sweep->{PARAMETERS}->{device}" . ".";
#		    my $newParam = dKitParameter->dKit2dialect($sweep->parameterValue('parameter'), 'hspice');

		    if ($newParam eq "temp")
                    {
			if ($temperaturePlan)
			{
			    croak("Too many temperature sweeps defined\n");
			} else 
			{
			    $temperaturePlan = $ {$sweep->{SWEEPPLANS} }[0];
			}
		    } elsif ($newParam eq "freq")
                    {
			if ($frequencyPlan)
			{
			    croak("Too many frequency sweeps defined.  Only one frequency sweep is allowed\n");
			} else 
			{
			    $frequencyPlan = $ {$sweep->{SWEEPPLANS} }[0];
			}
                    } else
		    {
			$dataName = $dataName . "_" . $sweep->{NAME};
			$dataParams = $dataParams . "$newParam ";
			@dataList = (@dataList, $sweep);
		    }
		    } # if MONTE
		}

		### ensure dataName is shorter then 16 chars !!!
		if (length($dataName) > 15)
		{
		    $dataName =~ s/Sweep/Swp/gs;
		    if (length($dataName) > 15)
		    {
			$dataName =~ s/Swp/S/gs;
			if (length($dataName) > 15)
			{
			    my $increment = 1 + length($dataName)/15;
			    my $cnt;
			    my $newDateName = "";
			    for ($cnt = 0; $cnt < length($dataName); $cnt += $increment)
			    {
				$newDateName = $newDateName . substr($dataName, $cnt, 1);
			    }
			    $dataName = $newDateName;
			}
		    }
		}

		if (($templateName =~ /AC/)
		     || ($templateName =~ /NOISE/)
		     || ($templateName =~ /SP/))
		{
		    if ($frequencyPlan)
		    {
			$hspiceDefinition = $frequencyPlan->netlist("hspice", $circuit);
			chomp($hspiceDefinition);
		    } else
                    {
			my $frequencyValue = $self->parameterValue("frequency");
			if (! $frequencyValue)
			{
			    croak("Error: no frequency defined for $templateName analysis\n");
			}
			$hspiceDefinition = "POI 1 $frequencyValue";
		    }
		    if ($#dataList > -1)
		    {
			$hspiceDefinition = $hspiceDefinition . " SWEEP ";
		    }
		    if ($temperaturePlan)
		    {
			my @valueList = convertSweepPlan2List($temperaturePlan);
			$addedLines = ".TEMP " . join(" ", @valueList) . "\n";
		    }
		} elsif ($templateName =~ /TRAN/)
		{
		    if ($#dataList > -1)
                    {
                        $hspiceDefinition = $hspiceDefinition . " SWEEP ";
                    }
                    if ($temperaturePlan)
                    {
                        my @valueList = convertSweepPlan2List($temperaturePlan);
                        $addedLines = ".TEMP " . join(" ", @valueList) . "\n";
                    }
		} elsif ($templateName =~ /DC/)
		{
		    if ($#dataList > -1)
		    {
			$hspiceDefinition = "";
			if ($temperaturePlan)
			{
			    my @valueList = convertSweepPlan2List($temperaturePlan);
			    $addedLines = ".TEMP " . join(" ", @valueList) . "\n";
			}
		    } else
		    {
			$hspiceDefinition = "TEMP " . $temperaturePlan->netlist("hspice", $circuit);
			chomp($hspiceDefinition);
		    }
		}


		if ($#dataList > -1)
		{
		    $hspiceDefinition = $hspiceDefinition . "DATA=$dataName ";
		    $addedLines = $addedLines . ".data $dataName $dataParams\n";
		    $addedLines = $addedLines . expandSweeps("", @dataList);
		    $addedLines = $addedLines . ".enddata\n";
		}


		if ($templateName =~ /SP/)
		{
		    my @components = $circuit->getProcessedPorts;
		    if ($#components == -1 || $#components > 1)
		    {
			my $numberOfPorts = $#components + 1;
			croak("$numberOfPorts ports were found but hspice only supports\n1- or 2- port S-paramter Analysis\n");
		    }
		    my $port1 = shift @components;
		    my $port2 = shift @components;
		    
		    ## add .net line
		    if ($port2)
		    {
			my $portNr = $port1->parameterValue('i_portNr');
			if ($portNr != 1)
			{
			    my $port3 = $port2;
			    $port2 = $port1;
			    $port1 = $port3;
			    $portNr = $port1->parameterValue('i_portNr');
			    if ($portNr != 1)
			    {
				croak("Could not find port 1. hspice only supports 2-port S-paramter\nAnalysis if ports are numbered 1 (in) and 2 (out)\n");
			    }
			}
			$portNr = $port2->parameterValue('i_portNr');
			if ($portNr != 2)
			{
			    croak("Could not find port 2. hspice only supports\n2- port S-paramter\nAnalysis if ports are numbered 1 (in) and 2 (out)\n");
			}

			$addedLines = $addedLines . ".net i(" . $port2->parameterValue('i_portName') . ") " . $port1->parameterValue('i_portName');
			my $rRef = $port1->parameterValue("i_referenceImpedance");
			if ($rRef)
			{
			    $addedLines = $addedLines . " RIN=$rRef";
			} 
			$rRef = $port2->parameterValue("i_referenceImpedance");
			if ($rRef)
			{
			    $addedLines = $addedLines . " ROUT=$rRef";
			} 
			$addedLines = $addedLines . "\n";
		    } else
		    {
			my $portNr = $port1->parameterValue('i_portNr');
# print $port1->dump2str;
			if ($portNr != 1)
			{
			    croak("Could not find port 1. hspice only supports 1-port S-paramter\nAnalysis if port is numbered 1\n");
			}
			$addedLines = $addedLines . ".net " . $port1->parameterValue('i_portName');
			my $rRef = $port1->parameterValue("i_referenceImpedance");
			if ($rRef)
			{
			    $addedLines = $addedLines . " RIN=$rRef";
			} 
			$addedLines = $addedLines . "\n";
		    }

		    #add output		    
		    if ($port2)
                    {
			$addedLines = $addedLines . ".PRINT AC S11(r) S11(i) S12(r) S12(i)\n";
			$addedLines = $addedLines . ".PRINT AC S21(r) S21(i) S22(r) S22(i)\n";
		    } else
		    {
			$addedLines = $addedLines . ".PRINT AC S11(r) S11(i)\n";
		    }
		    
		}

		if ($templateName =~ /NOISE/)
		{

		    ## add .noise line
		    if (! $self->parameterValue('noiseNode'))
		    {
			die "noiseNode parameter not specified for Noise analysis\n  Simulation will not run\n";
		    }
		    if (! $self->parameterValue('noiseReference'))
		    {
			die "noiseReference parameter not specified for Noise analysis\n  Simulation will not run\n";
		    }
		    $addedLines = $addedLines . ".NOISE V(" . $self->parameterValue('noiseNode') . ") " . $self->parameterValue('noiseReference') . "\n";

		    #add output		    
		    $addedLines = $addedLines . ".PRINT AC onoise \n";
		    
		}

		#### add outputplans
		foreach my $sweep (@fullList)
	        {
#		    print "adding outputplans\n";
		    for my $outputPlan (@ {$sweep->{OUTPUTPLANS} })
		    {
			if ($templateName eq "NOISE")
			{
			    $outputPlan->parameterValue("analysisType", "AC");
			} elsif ($templateName eq "SP")
			{
			    $outputPlan->parameterValue("analysisType", "AC");
			} else
			{
			    $outputPlan->parameterValue("analysisType", $templateName);
			}
			$addedLines = $addedLines . $outputPlan->netlist($dialect, $circuit) . "\n";
#			print "addedlines =  $addedLines"
		    }
		}

	    } else
	    {
		croak("sweeptype $templateName not supported\n");
	    }
            $line =~ s/#hspiceAnalysis/$hspiceDefinition/gs;
	}
	     
### allPortNameList substitution
	if ( $line =~ /#allPortNameList/ )
	{
	    my @components = $circuit->getProcessedPorts;
	    if ($#components > -1)
            {
	        my @portNames = ();
	        foreach my $port (@components)
                {
		    push(@portNames, $port->parameterValue('i_portName'));
                }
		my $portNames = join(" ", @portNames);
		$line =~ s/#allPortNameList/$portNames/gs;
	    } else
            {
		$line =~ s/#allPortNameList//gs;
	    }
	}

# outputplan substitution
	if ($line =~ /#outputPlanDef/ )
	{
	    my $outputPlanDef = "";
	    my $outputPlanSave = "";
	    if ($#{$self->{OUTPUTPLANS} } > -1)
	    {
		foreach my $outputPlan (@ {$self->{OUTPUTPLANS} })
		{
		    my $netlist = $outputPlan->netlist($dialect, $circuit);
		    $outputPlanSave = $outputPlanSave . $netlist;
		}
		$outputPlanDef = "save=selected";
		if ($line =~ /#outputPlanDef_optional/)
		{
		    $line =~ s/#outputPlanDef_optional/#outputPlanDef/gs;
		}
	    } else
	    {
		if ($line =~ /#outputPlanDef_optional/)
		{
		    $line =~ s/#outputPlanDef_optional/#outputPlanDef/gs;
		} else
		{
		    carp("No outputPlan found while netlisting for $dialect\nSkipped for " . $self->dump2str . "\n");
		}
	    }

	    if ($self->{SURANALYSIS})
	    {
		$self->{SURANALYSIS}->{ADDEDLINESFORTOPLEVEL} = $self->{SURANALYSIS}->{ADDEDLINESFORTOPLEVEL} . $outputPlanSave;
	    } else
	    {
		$addedLines = $addedLines . $outputPlanSave;
	    }
	    $line =~ s/#outputPlanDef/$outputPlanDef/gs;
	}

	if ($line =~ /#outputPlanName/ )
	{
	    my $outputPlanNames = "";
            my $devOpPtLevel = "";
	    if ($#{$self->{OUTPUTPLANS} } > -1)
	    {
		my $index = 1;
		foreach my $outputPlan (@ {$self->{OUTPUTPLANS} })
		{
		    my $template = $outputPlan->template;
		    if ($template->templateName eq "OUTPUTPLAN_DOPS")
		    {
			$devOpPtLevel="DevOpPtLevel=4 ";
		    } else
		    {
		        $outputPlanNames = $outputPlanNames . "OutputPlan[$index]=" . '"' . $outputPlan->analysisName . '" ';
		        $index = $index + 1;
		    }
		}
		if ($line =~ /#outputPlanName_optional/)
		{
		    $line =~ s/#outputPlanName_optional/#outputPlanName/gs;
		}
	    } else
	    {
		if ($line =~ /#outputPlanName_optional/)
		{
		    $line =~ s/#outputPlanName_optional/#outputPlanName/gs;
		} else
		{
		    carp("No outputPlan found while netlisting for $dialect\nSkipped for " . $self->dump2str . "\n");
		}
	    }
	    $outputPlanNames = $devOpPtLevel . $outputPlanNames;
	    $line =~ s/#outputPlanName/$outputPlanNames/gs;
	### add definitions of outputPlans
	    foreach my $outputPlan (@ {$self->{OUTPUTPLANS} })
	    {
		$addedLines = $addedLines . $outputPlan->netlist($dialect, $circuit);
	    }
	}

### sweepplan substitution
	if ( $line =~ /#sweepPlanDef/ )
	{
	    my $sweepPlanDef = "";
	    if ($#{$self->{SWEEPPLANS} } > -1)
	    {
		foreach my $sweepPlan (@ {$self->{SWEEPPLANS} })
		{
                ### sweepplan defs should not have \n 
		    my $netlist = $sweepPlan->netlist($dialect, $circuit);
		    chomp $netlist;
		    $sweepPlanDef = $sweepPlanDef . $netlist;
		}
	    } else
	    {
		carp("sweepPlan not defined\nSkipped for" . $self->dump2str . "\n");
	    }
	    $line =~ s/#sweepPlanDef/$sweepPlanDef/gs;
	}

	if ($line =~ /#sweepPlanName/ )
	{
	    my $sweepPlanNames = "";
	    if ($#{$self->{SWEEPPLANS} } > -1)
	    {
		my $index = 1;
		foreach my $sweepPlan (@ {$self->{SWEEPPLANS} })
		{
		    $sweepPlanNames = $sweepPlanNames . "SweepPlan[$index]=" . '"' . $sweepPlan->analysisName . '" ';
		    $index = $index + 1;
		}
	    } else
	    {
		carp("sweepPlan not defined\nSkipped for" . $self->dump2str . "\n");
	    }
	    $line =~ s/#sweepPlanName/$sweepPlanNames/gs;
	### add definitions of sweepPlans
	    foreach my $sweepPlan (@ {$self->{SWEEPPLANS} })
	    {
		$addedLines = $addedLines . $sweepPlan->netlist($dialect, $circuit);
	    }
	}

    ### subanalysis substitution
	if ( $line =~ /#subAnalysisDef/ )
	{
	    my $subAnalysisDef = "";
	    if ($#{$self->{SUBANALYSES} } > -1)
	    {
		foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
		{
		    $subAnalysisDef = $subAnalysisDef . $subAnalysis->netlist($dialect, $circuit);
		}
	    } else
	    {
		carp("subanalysis not defined\nSkipped for" . $self->dump2str . "\n");
	    }
	    $line =~ s/#subAnalysisDef/$subAnalysisDef/gs;
	}

	if ($line =~ /#subAnalysisName/)
	{
	    my $subAnalysisNames = "";
	    if ($#{$self->{SUBANALYSES} } > -1)
	    {
		my $ndx=1;
		foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
		{
		    $subAnalysisNames = $subAnalysisNames . "SimInstanceName[$ndx]=" . '"' . $subAnalysis->analysisName . '"';
		    $ndx = $ndx + 1;
		}
	    } else
	    {
		carp("subanalysis not defined\nSkipped for" . $self->dump2str . "\n");
	    }
	    $line =~ s/#subAnalysisName/$subAnalysisNames/gs;

    ### add definitions of subanalyses 
	    foreach my $subanalysis (@ {$self->{SUBANALYSES} })
	    {
		$addedLines = $addedLines . $subanalysis->netlist($dialect, $circuit);
	    }
	}

	if ($self->{SURANALYSIS})
        {             
	    $self->{SURANALYSIS}->{ADDEDLINESFORTOPLEVEL} = $self->{SURANALYSIS}->{ADDEDLINESFORTOPLEVEL} . $self->{ADDEDLINESFORTOPLEVEL};
	} else
	{
	    $addedLines = $addedLines . $self->{ADDEDLINESFORTOPLEVEL};
	}
	return $line . "\n" . $addedLines;
    } else
    {
	croak("Error: could not find netlist template for dialect $dialect for " .  $self->dump2str . "\n");
    }
    return;     
}

#####################################################################
# object method : getHspiceSweptVariables
# purpose : get the names of the sweep variables
#
# call vocabulary
#
# $Analysis->getHspiceSweptVariables;
#

sub getHspiceSweptVariables {
    my $self = shift;
    my @sweptVariables = ();

    my $templateRef = $self->template;
    if (! ref $templateRef)
    {
	$templateRef = dKitTemplate->getTemplate($templateRef);
	$self->{TEMPLATE} = $templateRef;
    }
    my $line = $templateRef->{NETLISTINSTANCETEMPLATES}->{hspice};
    if (ref $line)
    {
	$line = $line->{ORIGINALTEMPLATE};
    }
    if ($line =~ /#hspiceAnalysis/)
    {
	my $variable = "";
	if ($self->{PARAMETERS}->{device})
	{
	    $variable = $self->{PARAMETERS}->{device} . ":";
	}
	$variable = $variable . $self->parameterValue('parameter');
	@sweptVariables = ($variable);
    }

    foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
    {
	@sweptVariables = (@sweptVariables, $subAnalysis->getHspiceSweptVariables);
    }
    return @sweptVariables;
}

#####################################################################
# object method : getHspiceNoiseReferences
# purpose : get the names of the sweep variables
#
# call vocabulary
#
# $Analysis->getHspiceNoiseReferences;
#

sub getHspiceNoiseReferences {
    my $self = shift;
    my @noiseReferences = ();

    my $noiseReference = $self->parameterValue('noiseReference');
    if ($noiseReference)
    {
	@noiseReferences = ($noiseReference);
    } 

    foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
    {
	@noiseReferences = (@noiseReferences, $subAnalysis->getHspiceNoiseReferences);
    }
    return @noiseReferences;
}

#####################################################################
# object method : dump2perl
# purpose : dump the Analysis content as perl in a string
# call vocabulary
#
# $Analysis->dump2perl;
#

sub dump2perl {
    my $self = shift;
    my $indent = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $string = "$indent   +{\n$indent     TEMPLATE => ";
    $string = $string . "q{" . $self->template->templateName . "}, \n";
    $string = $string . "$indent     NAME => q{$self->{NAME}}, \n";

    $string = $string . "$indent     PARAMETERS =>\n$indent    +{" ;
    my @parameters = ();
    foreach my $key (keys(% {$self->{PARAMETERS} }))
    {
	if (!defined $self->{PARAMETERS}->{$key})
        {
	    @parameters = (@parameters, "\n$indent      $key => undef");
        } else
	{
	    my $value = $self->{PARAMETERS}->{$key};
	    my @instances = ();
	    if (ref($value))
	    {
		print "Cannot save references to perl\n";
		print "ignoring " . $self->dump2str . "\n";
		return "";
	    }
	    @parameters = (@parameters, "\n$indent      $key => q{$value}");
	}
    }
    $string = $string . join(",", @parameters);
    $string = $string . "\n$indent     }";
    
    if ($#{$self->{SWEEPPLANS} } > -1)
    {
	$string = $string . ",\n$indent     SWEEPPLANS =>\n$indent     [" ;
	foreach my $sweepplan (@ {$self->{SWEEPPLANS} })
	{
	    $string = $string . "\n" . $sweepplan->dump2perl($indent . "  ");
	}
	$string = $string . "\n$indent     ]";
    }

    if ($#{$self->{OUTPUTPLANS} } > -1)
    {
	$string = $string . ",\n$indent     OUTPUTPLANS =>\n$indent     [" ;
	foreach my $outputplan (@ {$self->{OUTPUTPLANS} })
	{
	    $string = $string . "\n" . $outputplan->dump2perl($indent . "  ");
	}
	$string = $string . "\n$indent     ]";
    }

    if ($#{$self->{SUBANALYSES} } > -1)
    {
	$string = $string . ",\n$indent     SUBANALYSES =>\n$indent     [" ;
	foreach my $analysis (@ {$self->{SUBANALYSES} })
	{
	    $string = $string . "\n" . $analysis->dump2perl($indent . "  ");
	}
	$string = $string . "\n$indent     ]";
    }

    $string = $string . "\n$indent    }";
    return $string;
}


#####################################################################
# object method : dump2str
# purpose : dump the analysis content in a string
# call vocabulary
#
# $Analysis->dump2str;
#

sub dump2str {
    my $self = shift;
    my $string = "Analysis Analysis:\n";
    my $templateRef = $self->template;
    if (! ref $templateRef)
    {
	$templateRef = dKitTemplate->getTemplate($templateRef);
	$self->{TEMPLATE} = $templateRef;
    }
    $string = $string . " TemplateName: " . $self->template->templateName . "\n";
    $string = $string . " AnalysisName: $self->{NAME}\n";
#    $string = $string . " Nodes: " . hash2str(% {$self->{NODES} }) . "\n";
    $string = $string . " Parameters:" . hash2str(% {$self->{PARAMETERS} }) . "\n";
    if ($#{$self->{SUBANALYSES} } > -1)
    {
	$string = $string . " SubAnalyses:\n";
	foreach my $subAnalysis (@ {$self->{SUBANALYSES} })
	{
	    $string = $string . "Subanalysis:\n" . $subAnalysis->dump2str . "endSubAnalysis\n";
	}
	$string = $string . " EndSubAnalyses\n"
    }
    return $string;
}

#####################################################################
# object method : dump
# purpose : dump the Analysis content
# call vocabulary
#
# $Analysis->dump;
#

sub dump {
    if ($Debugging)
    {
	my $self = shift;
	print $self->dump2str;
    }
}



############################################################################
### utility functions

sub list2str
{
    return join (", ", @_);
}

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


#######
# Given an array return the array without duplicates
#
# like uniq in UNIX shells
sub copyWithoutDuplicates
{
  my %hash = map{($_,0)} @_;
  return( keys %hash );
}


########
# create a list with the values for a given sweepplan
#


sub convertSweepPlan2List($)
{
    my $sweepPlan = shift;

    my $template = $sweepPlan->template;
    my $templateName = $template->templateName;
    my @values = ();

#    print "templateName = $templateName\n";

    if ($templateName eq "SWEEPPLAN_LIN")
    {
        my $start = $sweepPlan->{PARAMETERS}->{"start"};
        my $stop = $sweepPlan->{PARAMETERS}->{"stop"};
        my $numPts = $sweepPlan->{PARAMETERS}->{"numPts"};
        my $step = $sweepPlan->{PARAMETERS}->{"step"};
        my $scale = $sweepPlan->{PARAMETERS}->{"hspiceScale"};
        my $offset = $sweepPlan->{PARAMETERS}->{"hspiceOffset"};
        if ($start > $stop)
        {
            my $tempVar = $stop;
            $stop = $start;
            $start = $tempVar;
            $step = abs($step);
        }
        if (!defined $sweepPlan->{PARAMETERS}->{"hspiceScale"})
        {
            $scale = 1.0;
        }
        if (!defined $sweepPlan->{PARAMETERS}->{"hspiceOffset"})
        {
            $offset = 0.0;
        }
    
        if ($numPts ne "")
        {      
            $step = $stop - $start;
            if ($numPts > 1)
            {
                $step = $step / ($numPts - 1);
            } else 
            {
                print "SWEEPPLAN_LIN numPts less then 2. hspice will make it 2\n";
            }
        } 
    
        if ($step == 0)
        {
            $step = 1;
        }
        $start = $start * $scale + $offset;
        $stop  = $stop * $scale + $offset;
        $step  = $step * $scale;
        if ($step > 0)
        {
            for (my $value = $start;  $value < $stop; $value = $value + $step)
            {
                @values = (@values, $value);
            }
            @values = (@values, $stop);
        } else
        {
            for (my $value = $start;  $value > $stop; $value = $value + $step)
            {
                @values = (@values, $value);
            }
            @values = (@values, $stop);
        }
    } elsif ($templateName eq "SWEEPPLAN_PT")
    {
        my @tmpValues = split(', ', $sweepPlan->{PARAMETERS}->{"values"});
        @tmpValues = copyWithoutDuplicates(\@tmpValues);
    
        my $scale = $sweepPlan->{PARAMETERS}->{"hspiceScale"};
        my $offset = $sweepPlan->{PARAMETERS}->{"hspiceOffset"};
        if (!defined $sweepPlan->{PARAMETERS}->{"hspiceScale"})
        {
            $scale = 1.0;
        }
        if (!defined $sweepPlan->{PARAMETERS}->{"hspiceOffset"})
        {
            $offset = 0.0;
        }
        foreach my $value (@tmpValues)
        {
            $value = $value * $scale + $offset;
            @values = (@values, $value);
        }
    } else
    {
        croak("Error: sweepplan expansion $templateName not implemented for dialect hspice:\n" .  $sweepPlan->dump2str . "\n");
    }
    return @values;
}


#######
# create the datasweep values
#

sub expandSweeps
{
    my $prefix = shift;
    my @sweepRefs = @_;
    my $lines = "";
    my $sweep = shift @sweepRefs;

    if ($#{$sweep->{SWEEPPLANS} } > 0)
    {
	croak("Error: sweepplan expansion more then 1 sweepplan defined for " .  $sweep->dump2str . "\n");
    }

    my $sweepPlan = $ {$sweep->{SWEEPPLANS} }[0];

    my @values = convertSweepPlan2List($sweepPlan);

    foreach my $value (@values)
    {
	if ($#sweepRefs > -1)
	{
	    $lines = $lines . expandSweeps($prefix . $value . " ", @sweepRefs);
	} else
	{
	    $lines = $lines . "+ " . $prefix . $value . "\n";
	}
    }

    return $lines;
}



#####################################################################
# object method : nodeHash
# purpose : set/get the node hash for a analysis
# call vocabulary
#
# $Analysis->nodes(n1=>node1, n2=>node2);
#
# e.g.
#  $C->nodeHash(n1=>_net1, n2=>_net2);
#

#sub nodeHash {
#    my $self = shift;
#    if ($self)
#    {
#        if (@_) 
#        {
#	    my %nodes = @_;
#	    foreach my $node (keys %nodes)
#            {
#		if (exists $self->{NODES}->{$node})
#                {
#		    $self->{NODES}->{$node} = $nodes{$node};
#		} else
#                {
#		    $Debugging = 1;
#		    croak("\n Error: node $node does not exists for " . $self->dump2str . "\n");
#		}
#	    }
#        }
#        return % { $self->{NODES} } ;
#    }
#}

#####################################################################
# object method : nodeName
# purpose : set/get the external node name for a given node of an analysis
# call vocabulary
#
# $Analysis->nodeName(internalName[, externalName]);
#
# e.g.
#  $C->nodeName(n1, _net1);
#

sub nodeName {
#    my $self = shift;
#    if (@_) 
#    {
#	my $node = shift;
#	if (@_) 
#	{
#            my $nodeName = shift;
#	    if (exists $self->{NODES}->{$node})
#	    {
#		$self->{NODES}->{$node} = $nodeName;
#	    } else
#	    {
#		croak("\n Error: node $node does not exists for " .  $self->dump2str . "\n");
#	    }
#	} 
#	return $self->{NODES}->{$node};
#    }
    return undef;
}

1




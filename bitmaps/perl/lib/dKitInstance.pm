package dKitInstance;

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
$dKitInstance::VERSION = $VERSION;

#### Debugging
use Carp;
my $Debugging = 0;

################################################
# class method : debug
# purpose : set5 debugging level for class
# call vocabulary
#
# dKitInstance->debug(level);
#   0 : debugging off.
#

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : dKitInstance->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
	carp ("dKitInstance debugging turned on\n");
    } else
    {
	carp ("dKitInstance debugging turned off\n");
    }
}

my %Instances = ();

################################################
# class method : getInstance
# purpose : get instance given its name
# call vocabulary
#
# dKitInstance->getInstance(instanceName);
#

sub getInstance
{
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %myInstances;
    if (ref $proto)
    { #object
	%myInstances = % { $proto->{_GlobalInstances} };
    } else
    { # class
	%myInstances = %Instances;
    }

    if (@_)
    {
        my $type = shift;
        return $myInstances{$type};
    } else
    {
        croak("usage :  dKitInstance->getInstance(\"instanceName\");\n");
        return 0;
    }
    return undef;
}

################################################
# class method : dumpInstances
# purpose : list all Instances defined
# call vocabulary
#
# dKitInstance->dumpInstances;
#

sub dumpInstances
{
    my $self = shift;
    my %myInstances;
    if (ref $self)
    { #object
	%myInstances = % { $self->{_GlobalInstances} };
    } else
    { # class
	%myInstances = %Instances;
    }

    print "These Instances are currently defined:\n";
    foreach my $instance (keys %myInstances)
    {
	print $instance . " ";
	print $myInstances{$instance}->dump2str;
    }
}

######################################
# class method : new
# purpose : create instance
# call vocabulary
#
# dKitInstance->new("templateName", "instanceName");
#
#e.g
#  $C = dKitInstance->new(Capacitor, C1);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    if (! @_)
    {
        croak("usage : dKitInstance->new(\"TemplateName\"[, \"InstanceName\"]);\n");
        return;
    }
    my $templateName = shift;
    my $template = dKitTemplate->getTemplate($templateName);
    if (! $template)
    {
	croak("Could not find template definition for $templateName.\nExiting.");
    }

    my $instanceName = shift;
    if ($instanceName)
    {
	if ($Instances{$instanceName})
	{
	    croak("Please change instanceName\n$instanceName already defined as " . $Instances{$instanceName}->dump2str . "\nExiting.");
	}
    }
    if (my $requiredPrefix = $template->requiredPrefix)
    {
	if (!($instanceName =~ /^$requiredPrefix/i))
	{
	    croak("Instance of type $templateName has wrong name $instanceName.\nName should start with $requiredPrefix.\nExiting.");
	} 
    }
    my $self = +{};
    $self->{TEMPLATE} = $template;
    if ($instanceName)
    {
	$self->{NAME} = $instanceName;
	$self->{_GlobalInstances} = \%Instances;
	$Instances{$instanceName} = $self;
    }

    # instanciate the nodes from the template
    $self->{NODES} = +{};
    foreach my $node ($template->nodeList)
    {
         $self->{NODES}->{$node} = undef;
    }
    # instanciate the parameters from the template
    $self->{PARAMETERS} = +{};
    foreach my $param (keys %{$template->{PARAMETERS}})
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
	carp("creating new instance\n");
    }
    return $self;
}

######################################
# object method : copyToNamespace
# purpose : create instance with name 
# call vocabulary
#
# $instance->copyToNamespace("namespace");
#
#e.g
#  $C->copyToNamespace('x7');

sub copyToNamespace {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (! @_)
    {
        croak("usage : \$instance->copyToNamespace(\"namespace\"]);\n");
        return;
    }
    my $class = ref($self) ;
    my $namespace = shift;

### we need to append namespaces because otherwise we'll get in trouble with 
##  instance prefixes ...

    my $instanceName = $self->instanceName . $namespace;
    if ($instanceName)
    {
	if ($Instances{$instanceName})
	{
	    ### when copying to namespace 
	    ## we delete previous existences automatically

	    delete $Instances{$instanceName};
	}
    }
    my $template = $self->template;
    if (my $requiredPrefix = $template->requiredPrefix)
    {
	if (!($instanceName =~ /^$requiredPrefix/i))
	{
	    croak("Instance of type " . $template->templateName . " has wrong name $instanceName.\nName should start with $requiredPrefix.\nExiting.");
	} 
    }
    my $newInstance = +{};
    $newInstance->{TEMPLATE} = $template;
    if ($instanceName)
    {
	$newInstance->{NAME} = $instanceName;
	$newInstance->{_GlobalInstances} = \%Instances;
	$Instances{$instanceName} = $newInstance;
    }

    # instanciate the nodes from the original instance
    $newInstance->{NODES} = +{};
    foreach my $node (keys %{$self->{NODES}})
    {
         $newInstance->{NODES}->{$node} = ${$self->{NODES}}{$node};
    }
    # instanciate the parameters from the original instance
    $newInstance->{PARAMETERS} = +{};
    foreach my $param (keys %{$self->{PARAMETERS}})
    {
	$newInstance->{PARAMETERS}->{$param} = ${$self->{PARAMETERS}}{$param};
#	print "$param new : " . $newInstance->{PARAMETERS}->{$param} . " old: " . ${$self->{PARAMETERS}}{$param} ."\n";
    }

    #### figure out whether or not to inline
    ###  when inline is true for subcircuit... 
    ##   flatten circuit instead of using subcircuit call
    # inline is a hash table, one entry for each dialect

    $newInstance->{INLINE} = +{};
    foreach my $param (keys %{$self->{INLINE}})
    {
	$newInstance->{INLINE}->{$param} = ${$self->{INLINE}}{$param};
    }

    bless($newInstance, $class);
    if ($Debugging > 100)
    {
	carp("creating new instance\n");
    }
    return $newInstance;
}

######################################
# object method : fixConnectivityForNamespace
# purpose : fix the connectivity for the flattened circuit (i.e. new namespace)
#         replace external nodes with external nodenames,
#         add namespace to internal nodenames...
# call vocabulary
#
# $instance->fixConnectivityForNamespace("namespace", "parentNodeHashRef");
#

sub fixConnectivityForNamespace($$) 
{
### rename all nodes
    my $instance = shift;
    if (! @_)
    {
        croak("usage : \$instance->fixConnectivityForNamespace(\"namespace\", parentNodeHashRef]);\n");
        return;
    }
    my $namespace = shift;
    my $parentNodeHashRef = shift;

    my %instNodeHash = $instance->nodeHash;
    foreach my $node (keys %instNodeHash)
    {
	my $extNode = $instance->nodeName($node);
	my $parentNodeName = ${parentNodeHashRef}->{$extNode};
        if (defined $parentNodeName)
	{
	    $instance->nodeName($node, $parentNodeName);
	} else
	{
	    if ($extNode eq "0")
	    {
		$instance->nodeName($node, $extNode);
	    } else
	    {
		$instance->nodeName($node, $extNode . $namespace);
	    }
	}
    }
    return;
}

######################################
# object method : fixParametersForNamespace
# purpose : fix the parameters for this intance when placed in the new namespace
# call vocabulary
#
# $instance->fixParametersForNamespace("namespace", circuitParameterHashRef);
#

sub fixParametersForNamespace($$) 
{
    my $instance = shift;
    if (! @_)
    {
        croak("usage : \$instance->fixParametersForNamespace(\"namespace\", circuitParameterHashRef);\n");
        return;
    }
    my $namespace = shift;
    if (! @_)
    {
        croak("usage : \$instance->fixParametersForNamespace(\"namespace\", circuitParameterHashRef);\n");
        return;
    }
    my $circuitParameterHashRef = shift;

    my %instParameterHash = $instance->parameterHash;
    foreach my $parameter (keys %instParameterHash)
    {
	my $paramValue = $instance->parameterValue($parameter);
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
		    if (defined ${circuitParameterHashRef}->{$1})
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
	    $instance->parameterValue($parameter, $newParamValue);
# print "parameter $parameter set to $newParamValue\n";
	}
    }
    return;
}

######################################
# object method : init
# purpose : make reference point to templates instead of name
# call vocabulary
#
# $Instance->init;
#
 
sub init {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $template = $self->{TEMPLATE};
    if (! ref $template)
    {
	$template = dKitTemplate->getTemplate($template);
	$self->{TEMPLATE} = $template;
    }
    return;
}

######################################
# object method : DESTROY
# purpose : destoy instance
# call vocabulary
#
# $Instance->DESTROY;
#
 
sub DESTROY {
    my $self = shift;
    delete ${$self->{_GlobalInstances}}{$self->instanceName};
}

#####################################################################
# object method : instanceName
# purpose : get the instanceName for an instance
# call vocabulary
#
# $Instance->instanceName;
#

sub instanceName {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_) 
    {
	my $newName = shift;
	carp("Cannot change instanceName to $newName\nOld instanceName $self->{NAME} still in use\n");
#	$self->{NAME} = $newName;
#	if ($Debugging > 100)
#	{
#	    carp("setting instanceName to $self->{NAME}\n");
#	}
    }
    return $self->{NAME};
}

#####################################################################
# object method : name
# purpose : get the name for an instance
# call vocabulary
#
# $Instance->name;
#

sub name {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    return $self->{NAME};
}

#####################################################################
# object method : template
# purpose : set/get the reference to the template for an Instance
# call vocabulary
#
# $Instance->template;
#

sub template {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
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
# $Instance->inline(dialect);
#

sub inline {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_) 
    {
	my $dialect = shift;
	if (@_)
	{
	    if (! $self->isSubcircuit($dialect))
	    {
		carp("$self->instanceName is not a subcircuit for dialect $dialect.\n \$Instance->inline function ignored;\n");
		return undef;
	    }
	    my $inline = shift;
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
# object method : nodeHash
# purpose : set/get the node hash for an instance
# call vocabulary
#
# $Instance->nodes(n1=>node1, n2=>node2);
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
# object method : parameters
# purpose : set/get the parameters for an instance
# call vocabulary
#
# $Instance->parameterHash(%templateParameterHash);
#
# e.g.
#    $C->parameterHash(C=>"");

sub parameterHash {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
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
# $Instance->parameterValue(name [, value]);
#
# e.g.
#  $C->parameterValue(C, "10pf");
#

sub parameterValue {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
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
# object method : netlist
# purpose : return a string with the netlist
# call vocabulary
#
# $Instance->netlist(dialect);
#

sub netlist 
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    if (@_)
    {
 	my $dialect = shift;
    ### use internaly stored raw representation;
 	my $netlistTemplateRef = dKitTemplate->prepareNetlistTemplate($self, $dialect);

        if ($netlistTemplateRef)
        {
 	    dKitTemplate->nt_substituteVariables($self);
	    dKitTemplate->nt_substituteNodes($self);
	    dKitTemplate->nt_substituteName($self);
	    return $self->{NETLIST} . "\n";
        } else
        {
	    croak("Error: could not find netlist template for dialect $dialect for " .  $self->dump2str . "\n");
        }
    } else
    {
	croak("usage : \$Instance->netlist(dialect);\n");
	return;
    }
}

#####################################################################
# object method : dump2perl
# purpose : dump the instance content as perl in a string
# call vocabulary
#
# $Instance->dump2perl;
#

sub dump2perl {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
    my $string = "   +{\n     TEMPLATE => q{" . $self->template->templateName . "}, \n";
    $string = $string . "     NAME => q{$self->{NAME}}, \n";

    if (defined $self->{INLINE})
    {
	$string = $string . "     INLINE => +{\n";
	my @dialects = ();
	foreach my $key (keys(%{$self->{INLINE}}))
	{
	    my $value = $self->{INLINE}->{$key};
	    if (ref($value))
	    {
		print "Cannot save references to perl\n";
		print "ignoring $self->dump\n";
		return "";
	    }
	    @dialects = (@dialects, "      $key => q{$value}");
	}
	$string = $string . join(",\n", @dialects);
	$string = $string . "\n     },\n";
    }

    $string = $string . "     NODES => +{\n" ;
    my @nodes = ();
    foreach my $key (keys(%{$self->{NODES}}))
    {
        my $value = $self->{NODES}->{$key};
        if (ref($value))
        {
            print "Cannot save references to perl\n";
 	    print "ignoring $self->dump\n";
	    return "";
	}
	@nodes = (@nodes, "      $key => q{$value}");
    }
    $string = $string . join(",\n", @nodes);
    $string = $string . "\n     },\n     PARAMETERS => +{\n";

    my @parameters = ();
    foreach my $key (keys(%{$self->{PARAMETERS}}))
    {
	if (!defined $self->{PARAMETERS}->{$key})
        {
	    @parameters = (@parameters, "      $key => undef");
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
	    @parameters = (@parameters, "      $key => q{$value}");
	}
    }
    $string = $string . join(",\n", @parameters);
    $string = $string . "\n     }\n    }";
    return $string;
}


#####################################################################
# object method : dump2str
# purpose : dump the instance content in a string
# call vocabulary
#
# $Instance->dump;
#

sub dump2str {
    my $self = shift;
    my $string = "Instance:\n";
    $string = $string . " TemplateName: " . $self->template->templateName. "\n";
    $string = $string . " InstanceName: " . $self->instanceName . "\n";
    $string = $string . " Inline: " . hash2str(%{$self->inline}) . "\n";
    $string = $string . " Nodes: " . hash2str(%{$self->{NODES}}) . "\n";
    $string = $string . " Parameters:" . hash2str(%{$self->{PARAMETERS}}) . "\n";
    return $string;
}

#####################################################################
# object method : dump
# purpose : dump the instance content
# call vocabulary
#
# $Instance->dump;
#

sub dump {
    if ($Debugging)
    {
	my $self = shift;
	print $self->dump2str;
    }
}


#####################################################################
# object method : isSubcircuit
# purpose : isSubcircuittest wheter this instance is a subcircuit
# call vocabulary
#
# $Instance->isSubcircuit;
#

sub isSubcircuit()
{
    my $self = shift;
    if (! ref $self) 
    { 
	if (@_)
	{
	    my $instanceName = shift;
	    $self = $Instances{$instanceName};
	} else
        {
	    croak("usage : dKitInstance->isSubcircuit(instanceName, dialect);\n");
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
	croak("usage : \$Instance->isSubcircuit(dialect);\n or\n        dKitInstance->isSubcircuit(instanceName, dialect);\n");
	return 0;
    }
    return undef;
}

#####################################################################
# object method : blessContent
# purpose : add the necessary class definitions to each value
# call vocabulary
#
# $Instance->blessInstances
#
# e.g.
#    $instance->blessContent;

sub blessContent
{
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}
#    foreach my $instance (@ {$self->{INSTANCES} })
#    {
#       bless($instance, "dKitInstance");
#    }
    return;
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
	    $value = ${$value};
	}
        if (ref($value) eq "SCALAR")
        {
	    $value = "(->:" . ${$value} . ")";
        } elsif (ref($value) eq "ARRAY")
        {
	    $value = "(->L:" . list2str (@{$value}) . ")";
        } elsif (ref($value) eq "HASH")
        {
 	    $value = "(->H:" . hash2str (%{$value}) . ")";
        } else
        {
	    $value = "";
        }
	$string = $string . "\n  $key=$myHash{$key} $value" ;
    }
    return $string
}

1




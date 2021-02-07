package dKitTemplate;

use strict;

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
$dKitTemplate::VERSION = $VERSION;

#############################################################################
####
## include predefined templates
##
## each workdirectory may have a different database...
#

use Cwd;
my $workDirectory = cwd;

my %Templates;

if ( -f "$workDirectory/dKitTemplateDB.pl")
{
    require "$workDirectory/dKitTemplateDB.pl";
} else
{
    %Templates = ();
}


##################################################
#### Debugging
#
use Carp;
my $Debugging = 0;

################################################
# class method : debug
# purpose : set debugging level for class
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
	carp ("dKitTemplate debugging turned on\n");
    } else
    {
	carp ("dKitTemplate debugging turned off\n");
    }
}

##################################################
#### Creation of template file
#

########################################################################################
# class method : createTemplateDatabaseFile
# purpose : save all Templates defined in the local file 
#                                             $workDirectory/dKitTemplateDB.pl
#
# call vocabulary
#
# dKitTemplate->createTemplateDatabaseFile()
#

sub createTemplateDatabaseFile
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }

    my $templateHashRef = shift;
    if ($templateHashRef && ! ref $templateHashRef) 
    { 
	confess "createTemplateDatabaseFile: Expecting reference to hash table as first argument\n";
    }
    my $outFileName = shift;
    if (!$outFileName)
    {
	$outFileName = "$workDirectory/dKitTemplateDB.pl";
    } else
    {
	if (ref $outFileName) 
	{ 
	    confess "createParameterDatabaseFile: Expecting filename instead of reference as second argument\n";
	}
    }
    if (-f $outFileName)
    {
        rename($outFileName, $outFileName. ".old");
    }

    my $templateDefinitions = dKitTemplate->templates2perl($templateHashRef);

    open(OUTPUT,">$outFileName") 
        || die "Can't open output template file $outFileName";
    print OUTPUT "dKitTemplate->templateHash($VERSION, ";
    print OUTPUT "$templateDefinitions";
    print OUTPUT ");\n";
    print OUTPUT "\n1\n";
    return 1;
}

################################################
# class  method : templateHash
# purpose : set template Hash table
# call vocabulary
#
# dKitTemplate->templateHash(version, %HashTable)
#

sub templateHash
{
    my $module = shift;
    if (!ref $module) 
    { 
	if (@_)
	{
	    my $version = shift;
	    %Templates = @_;
	} else
	{
	    croak("Usage dKitTemplate->templateHash(version, %hashTable);\n");
	}
    } else
    {
	croak("Usage dKitTemplate->templateHash(version, %hashTable);\n");
    }

    #### initialize...
    foreach my $template (values %Templates)
    {
	bless($template, "dKitTemplate");
	$template->init;
    }
    return;
}


#############################################################################
# class method : createtemplateModule
# purpose : create the templateModule file with the 
#           curently defined items.
#           
# call vocabulary
#
# dKitTemplate->createtemplateModule;
#

sub createTemplateModule
{
    print "\nWARNING : The function dKitTemplate->createTemplateModule is included\n";
    print "for backward compatibility only.\n";
    print "Replace it by dKitTemplate->createTemplateDatabaseFile if you do not\n";
    print "want to see this message again.\n";
    print "Info : The local template definitions are now stored in\n";
    print "dKitTemplateDB.pl instead of in dKitTemplate.pm.\n\n";
    my $module = shift;
    dKitTemplate->createTemplateDatabaseFile(@_);
}

###########################################################################
### template database retrieval and save functions
#

################################################
# class method : getTemplate
# purpose : list all templates defined
# call vocabulary
#
# dKitTemplate->getTemplate(templateName);
#

sub getTemplate
{
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %myTemplates;
    if (ref $proto)
    { #object
	%myTemplates = % { $proto->{_GlobalTemplates} };
    } else
    { # class
	%myTemplates = %Templates;
    }

    if (@_)
    {
        my $type = shift;
        return $myTemplates{$type};
    } else
    {
        croak("usage :  dKitTemplate->getTemplate(\"templateName\");\n");
        return 0;
    }
}

################################################
# class method : templates2perl
# purpose : list all templates defined
# call vocabulary
#
# dKitTemplate->templates2perl;
# dKitTemplate->templates2perl(\%mytemplates);
#

sub templates2perl
{
    my $self = shift;
    my %myTemplates;
    if (ref $self)
    { # object
	%myTemplates = % { $self->{_GlobalTemplates} };
    } else
    { # class
	my $myTemplates = shift;
	if ($myTemplates eq "")
	{
	    %myTemplates = %Templates;
	} else
	{ 
	    %myTemplates = %{$myTemplates}; 
	}
    }

    my $string = "(\n";
    my @templates = ();
    foreach my $templateName (sort keys %myTemplates)
    {
        my $template = dKitTemplate->getTemplate($templateName);
        @templates = (@templates, $template->templateName . "=>\n" . $template->dump2perl);
    }
    $string = $string . join( ",\n", @templates);
    $string = $string . "\n)";
    return  $string;
}


#####################################################################
# object method : dump2perl
# purpose : dump the template content in perl language to string
# call vocabulary
#
# $template->dump2perl;
#

sub dump2perl 
{
    my $self = shift;
    if (! ref $self) 
    {
        my $templateName = shift;
	$self = dKitTemplate->getTemplate($templateName);
    }
    my $string = "+{\n";
    $string = $string . "  TEMPLATENAME => q{$self->{TEMPLATENAME}}, \n";
    $string = $string . "  REQUIREDPREFIX => q{$self->{REQUIREDPREFIX}}, \n";
    $string = $string . "  DESCRIPTION => q{$self->{DESCRIPTION}}, \n";

    $string = $string . "  NODES => +{\n" ;
    my @nodes = ();
    foreach my $key (sort keys(%{$self->{NODES}}))
    {
        my $value = $self->{NODES}->{$key};
        if (ref($value))
        {
            print "Cannot save references to perl\n";
 	    print "ignoring $self->dump\n";
	    return "";
	}
	@nodes = (@nodes, "   $key => q{$value}");
    }
    $string = $string . join(",\n", @nodes);
    $string = $string . "\n  },\n  PARAMETERS => +{\n";

    my @parameters = ();
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
	    @parameters = (@parameters, "   $key => q{$value}");
	}
    }
    $string = $string . join(",\n", @parameters);
    $string = $string . "\n  },\n  NETLISTINSTANCETEMPLATES => ";

    if (defined $self->{NETLISTINSTANCETEMPLATES})
    {
	my @netlisttemplates = ();
	$string = $string . "+{\n";
	foreach my $key (sort keys %{$self->{NETLISTINSTANCETEMPLATES}})
	{
	    my $value = $self->netlistInstanceTemplate($key);
	    @netlisttemplates = (@netlisttemplates , "   $key => q{$value}");
	}
	$string = $string . join(",\n", @netlisttemplates);
	$string = $string . "\n  },\n  DKITSUBCIRCUITNAMES => ";
    } else
    {
	$string = $string . "undef,\n  DKITSUBCIRCUITNAMES => ";
    }

    if (defined $self->{DKITSUBCIRCUITNAMES})
    {
	my @subCircuitNames = ();
	$string = $string . "+{\n";
	foreach my $key (sort keys %{$self->{DKITSUBCIRCUITNAMES}})
	{
	    my $value = $self->dKitSubcircuitName($key);
	    @subCircuitNames = (@subCircuitNames , "   $key => q{$value}");
	}
	$string = $string . join(",\n", @subCircuitNames);
	$string = $string . "\n  },\n  INLINE => ";

	### inlined is only valid when having subcircuits

	if (defined $self->{INLINE})
	{
	    my @dialects = ();
	    $string = $string . "+{\n";
	    foreach my $key (keys(%{$self->{INLINE}}))
	    {
		my $value = $self->{INLINE}->{$key};
		if (ref($value))
		{
		    print "Cannot save references to perl\n";
		    print "ignoring $self->dump\n";
		    return "";
		}
		@dialects = (@dialects, "   $key => q{$value}");
	    }
	    $string = $string . join(",\n", @dialects);
	    $string = $string . "\n  }\n }";
	    
	} else
	{
	    $string = $string . "undef\n }";
	}    
    } else 
    {
	$string = $string . "undef\n }";
    }
    return $string;
}


#############################################################################
### Class/object function to create/edit the parameters
#

######################################
# class method : new
# purpose : create template
# call vocabulary
#
# dKitTemplate->new("templateName");
#
#e.g
#  $C = dKitTemplate->new(Capacitor);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self;
    if (@_)
    {
        my $templateName = shift;
        if ($Templates{$templateName})
        {
            croak("Template $templateName already defined\nExiting.");
        }
        $self = +{};
        $self->{TEMPLATENAME} = $templateName;
        $self->{_GlobalTemplates} = \%Templates;
        $Templates{$templateName} = $self;
    } else
    {
        croak("usage : dKitTemplate->new(\"templateName\");\n");
        return;
    }
    $self->{DESCRIPTION} = '';
    $self->{REQUIREDPREFIX} = '';
    $self->{NODES} = +{};
    $self->{PARAMETERS} = +{};
    $self->{NETLISTINSTANCETEMPLATES} = +{};
# the following is to define the circuit for non-standard components
    $self->{DKITSUBCIRCUITNAMES} = undef;
# the following is to define wheter these subcircuits need to be inlined
    $self->{INLINE} = undef;

    bless($self, $class);
    if ($Debugging > 100)
    {
	carp("creating new template\n");
    }
    return $self;
}

######################################
# object method : DESTROY
# purpose : destoy template
# call vocabulary
#
# $Template->DESTROY;
#

sub DESTROY {
    my $self = shift;
    delete ${$self->{_GlobalTemplates}}{$self->templateName};
}


#####################################################################
# object method : templateName
# purpose : get the templateName for a template
# call vocabulary
#
# $template->templateName;
#

sub templateName {
    my $self = shift;
    if (@_) 
    {
	carp("Cannot change templateName to $self->{TEMPLATENAME}\nOld templateName $self->{TEMPLATENAME} still in use\n");
#	$self->{TEMPLATENAME} = shift;
#	if ($Debugging > 100)
#	{
#	    carp("setting templateName to $self->{TEMPLATENAME}\n");
#	}
    }
    return $self->{TEMPLATENAME};
}


#####################################################################
# object method : requiredPrefix
# purpose : set/get a requiredPrefix
# call vocabulary
#
# $template->requiredPrefix(value);
#

sub requiredPrefix {
    my $self = shift;
    if (@_) 
    {
	my $value = shift ;
	$self->{REQUIREDPREFIX} = $value;
	if ($Debugging > 100)
	{
	    carp("setting parameter description, initialized as $value\n");
	}
    }
    return($self->{REQUIREDPREFIX});
}

#####################################################################
# object method : description
# purpose : set/get a description
# call vocabulary
#
# $template->description(value);
#

sub description {
    my $self = shift;
    if (@_) 
    {
	my $value = shift ;
	$self->{DESCRIPTION} = $value;
	if ($Debugging > 100)
	{
	    carp("setting template description, initialized as $value\n");
	}
    }
    return($self->{DESCRIPTION});
}

#####################################################################
# object method : nodeList
# purpose : set/get the nodes for a template
# call vocabulary
#
# $template->nodeList(@templateNodeList);
#
# e.g.
#  $C->nodeList(n1, n2);
#

sub nodeList {
    my $self = shift;
    my @myList;
    if (@_) 
    {
	@myList = @_;
	foreach my $node (@myList)
        {
	    ${$self->{NODES}}{$node} = scalar keys %{$self->{NODES}};
        }
	if ($Debugging > 100)
	{
	    carp("setting nodes to " . list2str($self->nodeList) . "\n");
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
# purpose : add a node for a template
# call vocabulary
#
# $template->addNode(node);
#
# e.g.
#  $C->addNode(n1);
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
	    carp("setting nodes to " . list2str(@{$self->{NODES}}) . "\n");
	}
    }
}

#####################################################################
# object method : parameterHash
# purpose : set/get the parameterHash for a template
# call vocabulary
#
# $template->parameterHash(%templateParameterHash);
#
# e.g.
#    $C->parameterHash(C=>"", Temp=>"25");

sub parameterHash {
    my $self = shift;
    if (@_) 
    { 
        % { $self->{PARAMETERS} } = @_ ;
	if ($Debugging > 100)
	{
	    carp("setting parameterHash to " . hash2str(% { $self->{PARAMETERS} }) . "\n");
	}
    }
    return % { $self->{PARAMETERS} } ;
}


#####################################################################
# object method : addParameter
# purpose : add a parameter to the parameter list, initialize to undef
# call vocabulary
#
# $Template->addParameter(parameterName);
#
# e.g.
#    $C->addParameter(C);

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
	croak("usage : \$Template->addParameter(parameterName);\n");
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
# object method :  netlistInstanceTemplateHash
# purpose : set/get netlist template Hash for template instance
# call vocabulary
#
# $Template->netlistInstanceTemplateHash(%templateHashTable);
# e.g.
#$C->netlistInstanceTemplateHash(
#		    hspice=> "#instanceName \%n1 \%n2 \$C", 
#		    ads   => "C:#instanceName \%n1 \%n2 C=\$C");
#
# nodes/parameters are extracted from templates, so we need to process 
# each entry separately

sub netlistInstanceTemplateHash {
    my $self = shift;
    if (@_) 
    { 
	my %dialectHash = @_;

        #### reset templateHash
	$self->{NETLISTINSTANCETEMPLATES} = +{};

	foreach my $dialect (keys %dialectHash)
        {
	    $self->netlistInstanceTemplate($dialect, $dialectHash{$dialect});
        }
    }
    return % { $self->{NETLISTINSTANCETEMPLATES} } ;
}


#####################################################################
# object method :  processTemplate
# purpose : get/set netlist template for given dialect
# call vocabulary
#
# dKitTemplate->processTemplate(template);
#

sub processTemplate 
{
    my $self = shift;
    if (@_) 
    {
        my $template = shift;
        if (! ref $template)
        {
            my $dialectRef = +{};
	    $dialectRef->{ORIGINALTEMPLATE} = $template;

        #### optional parameter extraction 
	    my @fragments = split('\[\[', $dialectRef->{ORIGINALTEMPLATE});
	    my $line = shift @fragments;
	    my @optionalVars = ();

	    foreach my $fragment (@fragments)
	    {
		my $var;
		my $remainder;
		($var, $remainder) = ($fragment =~ /(.*)\]\](.*)/s);
		@optionalVars = (@optionalVars, $var);
		$line = $line . "\@" . @optionalVars . $remainder;
	    }
	    $dialectRef->{INTERNALTEMPLATE} = $line;
	    $dialectRef->{OPTIONALVARTEMPLATELIST} = \@optionalVars;
#            print "template ($dialectRef) = " . hash2str(%{$dialectRef}) . "\n";
            return $dialectRef;
	}
	return $template;
    }
}

#####################################################################
# object method :  netlistInstanceTemplate
# purpose : get/set netlist template for given dialect
# call vocabulary
#
# $Template->netlistInstanceTemplate("dialect" [, "template"]);
#
# e.g.
# $L->netlistInstanceTemplate(ads, "L:#instanceName \%n1 \%n2 L=\$L");
#
#

sub netlistInstanceTemplate {
    my $self = shift;
    if (@_) 
    {
        my $dialect = shift;
	if (@_) 
	{
            my $template = shift;

### process template
	    my $dialectRef = dKitTemplate->processTemplate($template);
	    $self->{NETLISTINSTANCETEMPLATES}->{$dialect} = $dialectRef;

### add optional parameters
            my $line = $dialectRef->{INTERNALTEMPLATE};
            foreach my $option (@{$dialectRef->{OPTIONALVARTEMPLATELIST}})
            {
	        my @parameters = ($option =~ /\<([\w]+)\>/gsx);
                foreach my $parameter (@parameters)
	        {
		    $self->addParameter($parameter);
	        }
            }

### add required parameters
	    my @parameters = ($line =~ /\<([\w]+)\>/gsx);
            foreach my $parameter (@parameters)
	    {
		$self->addParameter($parameter);
	    }

### add nodes
	    my @nodes = ($line =~ /\%([\w]+)\W?[^\%]*/gsx);
            foreach my $node (@nodes)
	    {
		$self->addNode($node);
	    }

	    if ($Debugging > 100)
	    {
		carp("added netlistInstanceTemplate, current hash: " . hash2str(% { $self->{NETLISTINSTANCETEMPLATES} }) . "\n");
	    }
	} 
	return $self->{NETLISTINSTANCETEMPLATES}->{$dialect}->{ORIGINALTEMPLATE};
    } else
    {
	croak("usage : \$Template->netlistInstanceTemplate(dialect[, template]);\n");
	return;
    }
}


#####################################################################
# object method :  dKitSubcircuitName
# purpose : get/set the Name of the dKit subCircuit defining this template
# for the given dialect 
#
# call vocabulary
#
# $Template->dKitSubcircuitName("dialect" [, "subCircuitName"]);
#
#
#

sub dKitSubcircuitName {
    my $self = shift;
    if (@_) 
    {
        my $dialect = shift;
	if (@_) 
	{
	    $self->{DKITSUBCIRCUITNAMES}->{$dialect} = shift;
	} 
	if (defined $self->{DKITSUBCIRCUITNAMES}->{$dialect})
	{
	    return $self->{DKITSUBCIRCUITNAMES}->{$dialect};
	}
	return undef;
    } else
    {
	croak("usage : \$Template->dKitSubcircuitName(dialect[, subCircuitName]);\n");
	return;
    }
}


#####################################################################
# object method :  dKitSubcircuitName
# purpose : get/set the Name of the dKit subCircuit defining this template
# for the given dialect 
#
# call vocabulary
#
# $Template->dKitSubcircuitName("dialect" [, "subCircuitName"]);
#
#
#

sub inline {
    my $self = shift;
    if (@_) 
    {
        my $dialect = shift;
	if (@_) 
	{
	    $self->{INLINE}->{$dialect} = shift;
	} 
	if (defined $self->{INLINE}->{$dialect})
	{
	    return $self->{INLINE}->{$dialect};
	}
	return undef;
    } else
    {
	### copy hash table
	my %hashTable = ();
	foreach my $key (keys %{$self->{INLINE}})
	{
	    ${hashTable}{$key} = ${$self->{INLINE}}{$key}
	}
	return \%hashTable;
    }
}

#############################################################################
###
# object operations 
#

##############################################################################
# object method : init
# purpose : init templates saved in hashtable
# call vocabulary
#
# $Template->init;
#

sub init {
    my $self = shift;
    if (! ref $self) { confess "Object method called as class method";}

    foreach my $dialect (keys %{$self->{NETLISTINSTANCETEMPLATES}})
    {
        my $dialectRef = dKitTemplate->processTemplate($self->{NETLISTINSTANCETEMPLATES}->{$dialect});
        $self->{NETLISTINSTANCETEMPLATES}->{$dialect} = $dialectRef;
    }
}


#############################################################################
#### dump to string for routines  debugging and error reporting purposes

################################################
# class method : dumpTemplates
# purpose : dump all Templates defined
# call vocabulary
#
# dKitTemplate->dumpTemplates;
#

sub dumpTemplates
{
    my $self = shift;
    my %myTemplates;
    if (ref $self)
    { #object
	%myTemplates = % { $self->{_GlobalTemplates} };
    } else
    { # class
	%myTemplates = %Templates;
    }

    my $debug = $Debugging;
    $Debugging = 1;
    print "These templates are currently defined:\n";
    foreach my $template (sort keys %myTemplates)
    {
        my $template = dKitTemplate->getTemplate($template);
        $template->dump;
    }
    $Debugging = $debug;
}


#####################################################################
# object method : dump2str
# purpose : dump the template content to string
# call vocabulary
#
# $Template->dump2str;
#

sub dump2str {
    my $self = shift;
    my $string = "Template:\n";
    $string = $string . " TemplateName: $self->{TEMPLATENAME}\n";
    $string = $string . " RequiredPrefix: $self->{REQUIREDPREFIX}\n";
    $string = $string . " Description: $self->{DESCRIPTION}\n";
    $string = $string . " Nodes: " . list2str($self->nodeList) . "\n";

    $string = $string . " Parameters:";

    foreach my $key (sort keys(%{$self->{PARAMETERS}}))
    {
	my $tmpString = "$key=$self->{PARAMETERS}->{$key}";
        while (length $tmpString < 39)
	{
	    $tmpString = $tmpString . " ";
        }
	$string = $string . "\n  $tmpString" ;
        foreach my $dialect (keys %{$self->{NETLISTINSTANCETEMPLATES}})
        {
	    if ( $self->netlistInstanceTemplate($dialect) =~ /\<$key\>/ )
	    {
		$string = $string . " ($dialect)";
            } else
            {
		my $tmpString = " ";
		while (length $tmpString <  length $dialect)
		{
		    $tmpString = $tmpString . " ";
		}
		$string = $string . "  $tmpString ";
	    }
        }

    }
    $string = $string . "\n";

    $string = $string . " NetlistInstanceTemplates:\n";
    foreach my $dialect (keys %{$self->{NETLISTINSTANCETEMPLATES}})
    {
	 $string = $string . "  $dialect=>" . $self->netlistInstanceTemplate($dialect) . "\n";
    }

    if (defined $self->{DKITSUBCIRCUITNAMES})
    {
	$string = $string . " dKitSubcircuitNames:\n";
	foreach my $dialect (keys %{$self->{DKITSUBCIRCUITNAMES}})
	{
	    $string = $string . "  $dialect=>" . $self->dKitSubcircuitName($dialect) . "\n";
	}
    }

    if (defined $self->{INLINE})
    {
	$string = $string . " inline:\n";
	foreach my $dialect (keys %{$self->{INLINE}})
	{
	    $string = $string . "  $dialect=>" . $self->inline($dialect) . "\n";
	}
    }
    return $string;
}

#####################################################################
# object method : dump
# purpose : dump the template content to stdout
# call vocabulary
#
# $Template->dump;
#

sub dump {
    if ($Debugging)
    {
	my $self = shift;
	print $self->dump2str;
    }
}


############################################################################
#####  utility functions to create/deal with netlist template strings

#####################################################################
# object method : prepareNetlistTemplate  
# purpose : prepare item (Component/analysis/...) for netlisting,
#           i.e. create netlist string
# call vocabulary
#
# dKitTemplate->prepareNetlistTemplate(TemplateRef);
#

sub prepareNetlistTemplate 
{
    my $self = shift;
    if (@_) 
    {
        my $item = shift;
        my $dialect = shift;
        my $template = $item->template;

 	my $netlistTemplateRef = dKitTemplate->processTemplate($template->{NETLISTINSTANCETEMPLATES}->{$dialect});
	$template->{NETLISTINSTANCETEMPLATES}->{$dialect} = $netlistTemplateRef;
	$item->{NETLISTTEMPLATE} = $netlistTemplateRef;
	$item->{NETLISTDIALECT} = $dialect;
	$item->{NETLIST} = $netlistTemplateRef->{INTERNALTEMPLATE};
	$item->{ADDEDLINES} = "";
	$item->{ADDEDLINESFORTOPLEVEL} = "";
	return $netlistTemplateRef;
    }
    return 0;
}


#####################################################################
# object method : nt_substituteVariables  
# purpose : substitute the variable of a linefragment with their values
#
# call vocabulary
#
# nt_substituteVariablesInString();
#  arg 1 the inputline
#  arg 2 the item
#  arg 3 required > 0 : error if parameter not defined
#                 < 0 : return empty line if parameter not defined
#                 0   : ignore parameter not defined
#

sub
nt_substituteVariablesInString
{
    my $inpLine = shift;
    my $item = shift;
    my $required = shift;

    my @fragments = split('\<', $inpLine);
    my $fragment;
    my $var;
    my $remainder;
    my $line = shift @fragments;

    foreach $fragment (@fragments)
    {
	($var, $remainder) = ($fragment =~ /([\w]+)\>(\W?.*)/s);
	if (defined $item->parameterValue($var))
	{
	    if ($var eq "parameter2dialect")
	    {
		my $newParam = dKitParameter->dKit2dialect($item->parameterValue($var), $item->{NETLISTDIALECT});
		
		$line = $line . $newParam . $remainder;
	    } else
	    {
		### try to evaluate possible perl expressions in 
		## parametervalues
		my $parameterValue = $item->parameterValue($var);
# print "parameterValue: $parameterValue\n";

		my $newParameterValue = nt_evaluateExpressions($parameterValue,$item, 0);
		if ($newParameterValue)
		{
# print "newparameterValue: $newParameterValue\n";
		    $line = $line . $newParameterValue . $remainder;
		} else
		{
		    $line = $line . $parameterValue . $remainder;
		}
	    }
	} else
	{
	    if ($required > 0)
	    {
     	        croak("Error: required variable $var not set for " . $item->dump2str . "\n");
	    } elsif ($required < 0)
            {
		return "";
	    }
	    $line = $line . $remainder;
	}
    }
    return $line;
}


#####################################################################
# object method : nt_substituteVariables  
# purpose : substitute the variables with their values
#
# call vocabulary
#
# dKitTemplate->nt_substituteVariables(itemRef);
#

sub nt_substituteVariables
{
    my $self = shift;
    if (@_) 
    {
        my $item = shift;

        ### substitute required variables
        my $line = nt_evaluateExpressions($item->{NETLIST}, $item, 1);
# print "my line 1 : $line\n";
	$line = nt_substituteVariablesInString($line, $item, 1);

	### substitute optional variables
	my @optionalVars = @{$item->{NETLISTTEMPLATE}->{OPTIONALVARTEMPLATELIST}};
	my $ndx = 0;
	foreach my $option (@optionalVars)
	{
	    $ndx = $ndx + 1;
	    my $lead = nt_evaluateExpressions($option, $item, -1);
	    $lead = nt_substituteVariablesInString($lead, $item, -1);
	    $line =~ s/\@$ndx/$lead/;
# print "my line $line\n";
	}

# print "my line (result) $line\n";

        $item->{NETLIST} = $line;
    }
    return 0;
}

#####################################################################
# local method : nt_evaluateExpressions 
# purpose : evaluate expressions 
#
# call vocabulary
#
# nt_evaluateExpressions($string, $item, $required);
#
# if $required > 0, top-level evals should not be empty...
#

sub
nt_evaluateExpressions
{
    my $line = shift;
    my $item = shift;
    my $required = shift;

    #### evaluate the expressions
    my @fragments = split('\~eval\(', $line);

    if ($#fragments > 0)
    {
# print "substituting expressions for $line\n";
	my @stack = ();
	my $lead = shift @fragments;
	if (!$lead)
	{
	    $lead = "#dummy#";
	}
# print "pushing $lead on the stack\n"; 
	push(@stack, $lead);
	foreach my $fragment (@fragments)
	{
	    $fragment =~ s/\)end/\)end]+]+/g;
            my @endfragments = split('\)end', $fragment);
            my $lead = shift @endfragments;
            if (!$lead)
	    {
		$lead = "#dummy#";
	    }
            push(@stack, $lead);
# print "pushing $lead on the stack\n"; 
            foreach my $endfragment (@endfragments)
	    {
# print "endfragment=$endfragment\n";
		$endfragment =~ s/^\]\+\]\+//g;
# print "endfragment=$endfragment\n";
		my $expression = pop(@stack);
		my $result = "";
		if (!($expression eq "#dummy#"))
		{
		    my $newExpression = nt_substituteVariablesInString($expression, $item, 0);
		    $result = eval($newExpression);
		    if ($@)
                    {
			print "When creating netlistInstance encountered error :\n   $@ while evaluating :\n   $newExpression\n which originated from :\n   $expression\nSetting eval result to \"\" and continuing.\n"
		    }
		} 
# print "my result $result\n";
		$expression = pop(@stack);
		if (!($expression eq "#dummy#"))
		{
		    $expression = $expression . $result . $endfragment;
		} else
		{
		    $expression = $result . $endfragment;
		}

# print "stackdepth $#stack\n";

		if ($#stack == -1 && $required)
                {
		    if ($result eq "")
                    {
			if ($required > 0)
                        {
			    die "\nSome required perl evaluations failed or returned \"\" in the netlist definition :\n    $line\n  You might need to set some parameters for ". $item->dump2str . "\n";
			} else
			{
			    return "";
			}
                    }
		}
		push(@stack, $expression);
# print "pushing $expression on the stack\n"; 
	    }
        }
        $line = pop(@stack);
    }
    return $line;
}



#####################################################################
# object method : nt_substituteNodes 
# purpose : substitute the Nodes with their actual names
#
# call vocabulary
#
# dKitTemplate->nt_substituteNodes(instanceRef);
#

sub nt_substituteNodes
{
    my $self = shift;
    if (@_) 
    {
        my $item = shift;
        #### node substitution
	my @fragments = split('\%', $item->{NETLIST});
	my $line = shift @fragments;
        my $var;
        my $remainder;
	foreach my $fragment (@fragments)
	{
	    ($var, $remainder) = ($fragment =~ /([\w]+)(\W?.*)/s);
	    if (defined $item->{NODES}->{$var})
	    {
		$line = $line . $item->{NODES}->{$var} . $remainder;
	    } else
	    {
		carp("node $var not set\nSkipped for" . $item->dump2str . "\n");
		$line = $line . $remainder;
	    }
	}
	$item->{NETLIST} = $line;
    }
}

#####################################################################
# object method : nt_substituteName
# purpose : substitue the actual name of the item
#
# call vocabulary
#
# dKitTemplate->nt_substituteName(itemRef);
#

sub nt_substituteName
{
    my $self = shift;
    if (@_) 
    {
        my $item = shift;
        $item->{NETLIST} =~ s/#instanceName/$item->{NAME}/gs;
    }
}


##### higher level utility functions

######################################
# class method : createSubcircuit
# purpose : create subcircuit template and initiatate netlist instance template
# call vocabulary
#
# dKitTemplate->createSubcircuit(templateName, circuitDefinition, nodeList, requiredParameterList, optionalParameterList)
#
#e.g
#  $C = dKitTemplate->createSubcircuit(test, 
#                                      $circuit, 
#                                      [n1, n2, n3], 
#                                      ['t1=1', 't2', ],
#                                      ['t='});

#### this function obsoleted because too restrictive !!!! 
### functionality moved to circuits module 

sub createSubcircuit
{
    print "this function has been replaced by\n";
    my $self = shift;
    if (@_)
    {
        my $type  = shift;
	if (@_)
	{
            my $circuit = shift;
	    print "this function has been replaced by\n";
	}
    }

    return undef;
}

############################################################################
### local utility functions

#####################################################################
# getParametersFromTemplate
# purpose : get the parameters used in Template
# call vocabulary
#
# getParametersFromTemplate(template);


sub getParametersFromTemplate 
{
    if (@_) 
    {
	my $template = shift;
	my @parameters = ($template =~ /\$([\w]+)\W?[^\$]*/gsx);
	return @parameters;
    }
}    

sub getNodesFromTemplate 
{
    if (@_) 
    {
	my $template = shift;
	my @nodes = ($template =~ /\%([\w]+)\W?[^\%]*/gsx);
	return @nodes;
    }
}    

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



#####################################################################
# Obsoleted functions
#
#

#####################################################################
# object method : parameter
# purpose : set/get a parameter 
# call vocabulary
#
# $template->parameter(parameterName, value);
#
# e.g.
#    $C->parameter(C);
#    $C->parameter(C, undef);
#
#sub parameter {
#    my $self = shift;
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
#	croak("usage : \$Template->parameter(parameterName [,value];\n");
#	return;
#    } 
#}

1



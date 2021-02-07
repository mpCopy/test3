package dKitParameter;

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
$dKitParameter::VERSION = $VERSION;

#### Keep track of Parameter warning messages already issued
#### Please keep this hash table empty...
my %warnedForNonExisting = ();

#############################################################################
####
## include predefined parameters
##
## each workdirectory may have a different database...
#

use Cwd;
my $workDirectory = cwd;

my %dKitXrefTable;
my %dialectXrefTable;

if ( -f "$workDirectory/dKitParameterDB.pl")
{
    require "$workDirectory/dKitParameterDB.pl";
} else
{
    %dKitXrefTable = ();
    %dialectXrefTable = ();
}



##################################################
#### Debugging
#
use Carp;
my $Debugging = 0;

################################################
# class method : debug
# purpose : set5 debugging level for class
# call vocabulary
#
# dKitParameter->debug(level);
#   0 : debugging off.
#

sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : dKitParameter->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
	carp ("dKitParameter debugging turned on\n");
    } else
    {
	carp ("dKitParameter debugging turned off\n");
    }
    return $Debugging;
}


###############################################################################
## keep track of what warning levels to output...

my $WarnImmediatelyForNonExisting = 1;

################################################
# class method : warnImmediatelyForNonExisting
# purpose : set variable to determine if user is immediately warned or not when
# the parameter module receives a translation request for an undefined 
# parameter 
#
# call vocabulary
#
# dKitParameter->warnImmediatelyForNonExisting(level);
#   0 : no warnings
#

sub warnImmediatelyForNonExisting
{
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ < 2) { confess "usage : dKitParameter->warnImmediatelyForNonExisting(level)" }
    if (@_ == 1)
    { 
	$WarnImmediatelyForNonExisting = shift;
    }
    return $WarnImmediatelyForNonExisting;
}



##################################################
#### Creation/import of parameter file functions
#

##############################################################################
# class method : createParameterDatabaseFile
# purpose : save all parameters defined in the local file 
#                                           $workDirectory/dKitParamerterDB.pl
#
# call vocabulary
#
# dKitParameter->createParameterDatabaseFile()
#

sub createParameterDatabaseFile
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }

    my $parameterHashRef = shift;
    if ($parameterHashRef && ! ref $parameterHashRef) 
    { 
	confess "createParameterDatabaseFile: Expecting reference to hash table as first argument\n";
    }
    my $outFileName = shift;
    if (! $outFileName)
    {
	$outFileName = "$workDirectory/dKitParameterDB.pl";
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

    my $parameterDefinitions = dKitParameter->dKitXrefs2perl($parameterHashRef);

    open(OUTPUT,">$outFileName") 
        || die "Can't open output parameter file $outFileName";
    print OUTPUT "dKitParameter->parameterHash($VERSION, ";
    print OUTPUT "$parameterDefinitions";
    print OUTPUT ");\n";
    print OUTPUT "\n1\n";
    return;
}

################################################
# class  method : parameterHash
# purpose : set the parameter Hash table
# call vocabulary
#
# dKitParameter->parameterHash(version, %HashTable)
#

sub parameterHash
{
    my $module = shift;
    if (!ref $module) 
    { 
	if (@_)
	{
	    my $version = shift;
	    %dKitXrefTable = @_;
	} else
	{
	    croak("Usage dKitParameter->parameterHash(version, %hashTable);\n");
	}
    } else
    {
	croak("Usage dKitParameter->parameterHash(version, %hashTable);\n");
    }

    #### initialize...
    ###  and build cross reference table ...
    %dialectXrefTable = ();
    foreach my $parameter (values %dKitXrefTable)
    {
	bless($parameter, "dKitParameter");
	$parameter->addToDialectXrefTable;
    }

    return 1;
}


##############################################
# class method : createParameterModule
# purpose : create the ParameterModule file with the 
#           curently defined parameters.
#           
# call vocabulary
#
# dKitParameter->createParameterModule;
# dKitParameter->createParameterModule(dKitHashRef, dialectHashRef, outFileName);
#

sub createParameterModule
{

#### note dialectHashRef is not saved any more, but build at load of dKitHashRef
    my $self = shift;

    my $dKitHashRef = shift;
    my $dialectHashRef = shift;
    my $outFileName = shift;

    print "\nWARNING : The function dKitParameter->createParameterModule is included\n";
    print "for backward compatibility only.\n";
    print "Replace it by dKitParameter->createparameterDatabaseFile if you do not\n";
    print "want to see this message again.\n";
    print "Info : The local parameter definitions are now stored in\n";
    print "dKitParameterDB.pl instead of in dKitParameter.pm.\n\n";
    return dKitParameter->createParameterDatabaseFile($dKitHashRef, $outFileName);
}

############################################################################
#### parameter retrieval/store/save functions
#

################################################
# class method : dKitXrefs2perl
# purpose : list all  dKitXrefs defined
# call vocabulary
#
# dKitParameter->dKitXrefs2perl;
#

sub dKitXrefs2perl
{
    my $self = shift;
    my %myTemplates;
    if (ref $self)
    { #object
	croak("wrong usage of paramXrefs2perl, use dKitParameter->dKitXrefs2perl\n");
    } else
    { # class
	my $myTemplates = shift;
	if ($myTemplates eq "")
	{
	    %myTemplates = %dKitXrefTable;
	} else
	{ 
	    %myTemplates = %{$myTemplates}; 
	}
    }

    my $string = "(\n";
    my @templates = ();
    foreach my $parameter (sort keys %myTemplates)
    {
        my $Xref = dKitParameter->getDKitXref($parameter);
        @templates = (@templates, "$parameter=>\n" . $Xref->dKitXref2perl);
    }
    $string = $string . join( ",\n", @templates);
    $string = $string . "\n)";
    return  $string;
}

################################################
# class method : getDKitXref
# purpose : get a DKitXref
# call vocabulary
#
# dKitParameter->getDKitXref(parameter);
#

sub getDKitXref
{
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %myTemplates;
    if (ref $proto)
    { #object
	croak("wrong usage of dKitXrefs2perl, use dKitParameter->getDKitXref(\"parameter\")\n");
    } else
    { # class
	%myTemplates = %dKitXrefTable;
    }

    if (@_)
    {
        my $type = shift;
        return $myTemplates{$type};
    } else
    {
        croak("usage :  dKitParameter->getDKitXref(\"parameter\");\n");
        return 0;
    }
}


#####################################################################
# object method : dKitXref2perl
# purpose : dump the dKitXref content in perl language to string
# call vocabulary
#
# $parameter->dKitXref2perl;
#

sub dKitXref2perl 
{
    my $self = shift;
    if (! ref $self) 
    {
        my $parameterName = shift;
	$self = dKitParameter->getTemplate($parameterName);
    }

    my $string = "+{\n";
    $string = $string . "  PARAMETER => q{$self->{PARAMETER}}, \n";
    $string = $string . "  DESCRIPTION => q{$self->{DESCRIPTION}}, \n";
    $string = $string . "  DIALECTREFERENCES => +{\n" ;

    my @references = ();
    foreach my $dialect (sort keys(%{$self->{DIALECTREFERENCES}}))
    {
	if (!defined $self->{DIALECTREFERENCES}->{$dialect})
        {
	    @references = (@references, "      $dialect => undef");
        } else
        {
	    my $value = $self->{DIALECTREFERENCES}->{$dialect};
	    if (ref($value))
	    {
		print "Cannot save references to perl\n";
		print "ignoring $self->dumpDKitXref\n";
		return "";
	    }
	    @references = (@references, "   $dialect => q{$value}");
 	}
    }
    $string = $string . join(",\n", @references);
    $string = $string . "\n  },\n";

    if (!defined $self->{RESULTNAME})
    {
	$string = $string . "  RESULTNAME => undef, \n";
    } else
    {
	$string = $string . "  RESULTNAME => q{$self->{RESULTNAME}}, \n";
    }

    $string = $string . " }";

    return $string;
}

#############################################################################
# object method : addToDialectXrefTable
# purpose : add entry to the dialect Xref table
# call vocabulary
#
# $parameter->addToDialectXrefTable([dialect]);
#

sub addToDialectXrefTable
{
    my $self = shift;
    if (!ref $self)
    { #class
	croak("wrong usage of addToDialectXrefTable, use \$parameter->addToDialectXrefTable([dialect, value]\n");
    }
    if (defined $self->{RESULTNAME})
    {  
	my @dialects = ();
	my $dialect = shift;
	if ($dialect)
	{   ## one dialect
	    @dialects = ($dialect);
	} else
	{   ## all dialects
	    @dialects = keys %{$self->{DIALECTREFERENCES}};
	}
	foreach $dialect (@dialects)
	{
	    my $value = $self->dialectReference($dialect);
	    if ($value ne "")
	    {
		if (defined $dialectXrefTable{$dialect}->{$value})
		{
		    if ($dialectXrefTable{$dialect}->{$value} ne "$self->{RESULTNAME}")
		    {
			carp("Setting the resultName of parameter $self->{PARAMETER} to $value will create ambiguity.\nTherefor it will be ignored\nThe resultName for $dialect parameter $value was already set to $dialectXrefTable{$dialect}->{$value}\n");
		    }
		} else
		{
		    $dialectXrefTable{$dialect}->{$value} = $self->{RESULTNAME};
		}
	    }
	}
    }
    return;
}
    
################################################
# class method : dialectXrefs2perl
# purpose : list all dialectXrefs defined
# call vocabulary
#
# dialectXrefs2perl;
#

sub dialectXrefs2perl
{
    my %myTemplates;

    my $myTemplates = shift;
    if ($myTemplates eq "")
    {
	%myTemplates = %dialectXrefTable;
    } else
    { 
	%myTemplates = %{$myTemplates}; 
    }

    my $string = "(\n";
    my @templates = ();
    foreach my $dialect (sort keys %myTemplates)
    {
        @templates = (@templates, "$dialect=>\n" . dialectXref2perl($dialectXrefTable{$dialect}));
    }
    $string = $string . join( ",\n", @templates);
    $string = $string . "\n)";
    return  $string;
}


#####################################################################
# object method : dialectXref2perl ($dialect)
# purpose : dump the dialect content in perl language to string
# call vocabulary
#
# dialectXref2perl;
#

sub dialectXref2perl 
{
    my $self = shift;

    my $string = "+{\n";
    my @templates = ();
    foreach my $parameter (sort keys % {$self})
    {
	@templates = (@templates , "  $parameter => q{$self->{$parameter}}");
    }
    $string = $string . join( ",\n", @templates);
    $string = $string . "\n }";

    return $string;
}


######################################
# class method : new
# purpose : create parameter
# call vocabulary
#
# dKitParameter->new("parameter");
#
#e.g
#  $C = dKitParameter->new("dc");

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self;
    if (@_)
    {
        my $type = shift;
        if ($dKitXrefTable{$type})
        {
            croak("Parameter $type already defined\nExiting.");
        }
        $self = +{};
        $self->{PARAMETER} = $type;
        $dKitXrefTable{$type} = $self;
    } else
    {
        croak("usage : dKitParameter->new(\"parameter\");\n");
        return;
    }
    $self->{DESCRIPTION} = '';
    $self->{DIALECTREFERENCES} = +{};

    bless($self, $class);
    if ($Debugging > 100)
    {
	carp("creating new parameter $self->{PARAMETER}\n");
    }
    return $self;
}


################################################
# object method : parameter
# purpose : get the parameter
# call vocabulary
#
# $parameter->parameter;
#

sub parameter
{
    my $self = shift;
    if (@_) 
    {
	my $newParameter = shift;
	carp("Cannot change parameter to $newParameter\nOld parameter $self->{PARAMETER} still in use\n");
#	$self->{PARAMETER} = $newParameter;
#	if ($Debugging > 100)
#	{
#	    carp("setting parameter to $self->{PARAMETER}\n");
#	}
    }
    return $self->{PARAMETER};
}


#####################################################################
# object method : description
# purpose : set/get a description
# call vocabulary
#
# $parameter->description(value);
#

sub description {
    my $self = shift;
    if (@_) 
    {
	my $value = shift ;
	$self->{DESCRIPTION} = $value;
	if ($Debugging > 100)
	{
	    carp("setting parameter description, initialized as $value\n");
	}
    }
    return($self->{DESCRIPTION});
}


#####################################################################
# object method : dialectReference
# purpose : set/get a dialectReference
# call vocabulary
#
# $parameter->dialectReference(dialect,value);
# $parameter = dKitParameter->dialectReference(parameter, dialect, value);
#

sub dialectReference 
{
    my $self = shift;

    if (!ref $self) {
	### class call
	my $parameter = shift;
	$self = dKitParameter->getDKitXref($parameter);
	if (!$self)
	{
	    $self = dKitParameter->new($parameter);
	}
    }

    if (@_) 
    {
	my $dialect = shift ;
	if (@_) 
	{
	    my $value = shift ;
	    if ($value ne "")
            {
	        $self->{DIALECTREFERENCES}->{$dialect} = $value;
	        if ($Debugging > 100)
	        {
		    carp("setting dialect $dialect, initialized as $value\n");
	        }
		$self->addToDialectXrefTable($dialect, $value);
	    }
	} 
	return($self->{DIALECTREFERENCES}->{$dialect});    
    } else
    {
	croak("usage : \$parameter->dialectReference(dialect [,value];\n");
	return;
    }

}

#####################################################################
# object method : resultName
# purpose : set/get a resultNam
# call vocabulary
#
# $parameter->resultName(value);
#or 
# dKitParameter->resultName(parameter, value);
#

sub resultName {
    my $self = shift;

    if (!ref $self) {
	### class call
	my $parameter = shift;
	$self = dKitParameter->getDKitXref($parameter);
	if (!$self)
	{
	    $self = dKitParameter->new($parameter);
	}
    }

    if (@_) 
    {
	my $value = shift ;
	if ($value ne "")
	{
	    $self->{RESULTNAME} = $value;
	    if ($Debugging > 100)
	    {
		carp("setting resultName, initialized as $value\n");
	    }
	    $self->addToDialectXrefTable();
	}
    }
    return($self->{RESULTNAME});
}


#####################################################################
# class method : dKit2dialect
# purpose : dKit2dialect
# call vocabulary
#
# $parameter = dKitParameter->dKit2dialect(parameter, dialect);
#

sub dKit2dialect {
    my $self = shift;

    if (ref $self) {
	### object call
	croak("wrong usage of dKit2dialect, use dKitParameter->dKit2dialect(\"parameter\", \"dialect\")\n");
    }

    if (@_) 
    {
	my $parameter = shift;
	my $dialect = shift;
	$self = dKitParameter->getDKitXref($parameter);

	if (! defined $self->{DIALECTREFERENCES}->{$dialect})
	{
	    if (! exists ($warnedForNonExisting{"dKit2$dialect"}{"$parameter"}))
            {
		my $message = "Please define parameter " . $parameter . " using the functions provided by the module dKitParameter.pm for dialect $dialect\n";
		if ($WarnImmediatelyForNonExisting)
		{
		    print $message;
		}
		$warnedForNonExisting{"dKit2$dialect"}{"$parameter"} = $message;
	    }
	    return $parameter;
	} else
	{
	    return ($self->{DIALECTREFERENCES}->{$dialect});
	}
    } else
    {
	croak("usage : \$parameter->dKit2dialect(\"parameter\", \"dialect\");\n");
	return;
    }
}

#####################################################################
# class method : dKit2result
# purpose : dKit2result
# call vocabulary
#
# $parameter = dKitParameter->dKit2result(parameter);
#

sub dKit2result {
    my $self = shift;

    if (ref $self) {
	### object call
	croak("wrong usage of dKit2result, use dKitParameter->dKit2result(\"parameter\")\n");
    }

    if (@_) 
    {
	my $parameter = shift;
	$self = dKitParameter->getDKitXref($parameter);

	if (! defined $self->{RESULTNAME})
	{
	    if (! exists ($warnedForNonExisting{"dKit2Result"}{"$parameter"}))
            {
		my $message = "Please define the resultName of parameter " . $parameter . " using the functions provided by the module dKitParameter.pm\n";
		if ($WarnImmediatelyForNonExisting)
		{
		    print $message;
		}
		$warnedForNonExisting{"dKit2Result"}{"$parameter"} = $message;
	    }
	    return $parameter;
	} else
	{
	    return ($self->{RESULTNAME});
	}
    } else
    {
	croak("usage : \$parameter->dKit2result(\"parameter\");\n");
	return;
    }
}



#####################################################################
# class method : dialect2result
# purpose : dialect2result
# call vocabulary
#
# $parameter = dKitParameter->dialect2result(parameter, dialect);
#

sub dialect2result {

    my $self = shift;

    if (ref $self) {
	### object call
	croak("wrong usage of dialect2result, use dKitParameter->dialect2result(\"parameter\", \"dialect\")\n");
    }

    if (@_) 
    {
	my $parameter = shift;
	my $dialect = shift;
	if (! defined $dialectXrefTable{$dialect}->{$parameter})
	{
	    if (! exists ($warnedForNonExisting{"$dialect"."2result"}{"$parameter"}))
            {
		my $message = "Please define a parameter using the functions provided by the module dKitParameter.pm so that the $dialect parameter " . $parameter . " can be mapped to a result parameter\n";
		if ($WarnImmediatelyForNonExisting)
		{
		    print $message;
		}
		$warnedForNonExisting{"$dialect"."2result"}{"$parameter"} = $message;
	    }
	    return $parameter;
	} else
	{
	    return ($dialectXrefTable{$dialect}->{$parameter});
	}
    } else
    {
	croak("usage : \$parameter->dialect2result(\"parameter\", \"dialect\");\n");
	return;
    }
}


##############################################################################
### debugging and diagnostiics output routines


################################################
# class method : listMissingParameterDefinitions
# purpose : give a list of Parameters not defined
# call vocabulary
#
# dKitParameter->listMissingParameterDefinitions;
#

sub listMissingParameterDefinitions
{
    my $self = shift;
    my %myTemplates;
    if (ref $self)
    { #object
	croak("wrong usage of listMissingParameterDefinitions, use dKitParameter->listMissingParameterDefinitions\n");
    } else
    { # class
	%myTemplates = %warnedForNonExisting;
    }

    my $line = "";
    foreach my $class (sort keys %myTemplates)
    {
        my $segment = "";
	foreach my $parameter (sort keys %{$myTemplates{$class}} )
	{
	    $segment = $segment . "  $parameter";
	}
	if ($segment ne "")
        {
	    $segment = " $class :\n" . $segment
	}
	$line = $line . $segment . "\n";
    }
    if ($line ne "")
    {
	$line = "These parameters are undefined:\n" . $line . "\n";
    } else
    {
	$line = "All parameters are defined.\n";
    }
    return $line;
}


################################################
# class method : dumpDKitXrefs
# purpose : dump all parameters defined
# call vocabulary
#
# dKitParameter->dumpDKitXrefs;
#

sub dumpDKitXrefs
{
    my $self = shift;
    my %myTemplates;
    if (ref $self)
    { #object
	croak("wrong usage of dKitXrefs2perl, use dKitParameter->dumpDKitXrefs\n");
    } else
    { # class
	%myTemplates = %dKitXrefTable;
    }

    my $debug = $Debugging;
    $Debugging = 1;
    print "These parameter X references are currently defined:\n";
    foreach my $parameter (sort keys %myTemplates)
    {
        my $template = dKitParameter->getDKitXref($parameter);
        $template->dump;
    }
    $Debugging = $debug;
}


#####################################################################
# object method : dump
# purpose : dump the content to stdout
# call vocabulary
#
# $Parameter->dump;
#

sub dump {
    if (1)
    {
	my $self = shift;
	print $self->dKitXref2str;
    }
}

#####################################################################
# object method : dKitXref2str
# purpose : dump the parameter content in perl language to string
# call vocabulary
#
# $parameter->dKitXref2perl;
#

sub dKitXref2str
{
    my $self = shift;
    if (! ref $self) 
    {
        my $parameter = shift;
	$self = dKitParameter->getTemplate($parameter);
    }

    my $string = "";
    $string = $string . "PARAMETER = $self->{PARAMETER} \n";
    $string = $string . "  DESCRIPTION: $self->{DESCRIPTION} \n";
    $string = $string . "  DIALECTREFERENCES: \n" ;

    my @references = ();
    foreach my $dialect (sort keys(%{$self->{DIALECTREFERENCES}}))
    {
        my $value = $self->{DIALECTREFERENCES}->{$dialect};
        if (ref($value))
        {
            print "Cannot save references to perl\n";
 	    print "ignoring $self->dumpDKitXref\n";
	    return "";
	}
	@references = (@references, "    $dialect => $value");
    }
    $string = $string . join("\n", @references);
    $string = $string . "\n";

    if (!defined $self->{RESULTNAME})
    {
	$string = $string . "  RESULTNAME undefined\n";
    } else
    {
	$string = $string . "  RESULTNAME: $self->{RESULTNAME}\n";
    }

    return $string;
}


1




package PtolemyParameter;

use strict;
use Carp;
use Class::Struct;


############################################################################
#
# Maps units in XML file to units used in create_parm
#
############################################################################

%PtolemyParameter::unitMap = (
	""        => "UNITLESS_UNIT",
	"Hz"      => "FREQUENCY_UNIT",
	"Ohm"     => "RESISTANCE_UNIT",
	"S"       => "CONDUCTANCE_UNIT",
	"H"       => "INDUCTANCE_UNIT",
	"F"       => "CAPACITANCE_UNIT",
	"m"       => "LENGTH_UNIT",
	"sec"     => "TIME_UNIT",
	"deg"     => "ANGLE_UNIT",
	"W"       => "POWER_UNIT",
	"V"       => "VOLTAGE_UNIT",
	"A"       => "CURRENT_UNIT",
	"km"      => "DISTANCE_UNIT",
	"Celsius" => "TEMPERATURE_UNIT",
	"dB"      => "DB_GAIN_UNIT",
);


############################################################################
#
# Maps units in XML file to units used in Genesys
#
############################################################################

%PtolemyParameter::unitGenesysMap = (
	""        => 0,
	"Hz"      => 1001,
	"Ohm"     => 2001,
	"S"       => 3001,
	"H"       => 4003,
	"F"       => 5006,
	"m"       => 6004,
	"sec"     => 7004,
	"deg"     => 8001,
	"W"       => 11001,
	"V"       => 9001,
	"A"       => 10001,
	"km"      => 6004,
	"Celsius" => 12001,
	"dB"      => 13002,
);


############################################################################
#
# Maps Ptolemy parameter types to PARM types used in create_parm
#
############################################################################

%PtolemyParameter::typeMap = (
	"int"           => "PARM_INT",
	"fix"           => "PARM_FIX",
	"real"          => "PARM_REAL",
	"complex"       => "PARM_COMPLEX",
	"string"        => "PARM_STRING",
	"int array"     => "PARM_INTARRAY",
	"fix array"     => "PARM_FIXARRAY",
	"real array"    => "PARM_REALARRAY",
	"complex array" => "PARM_COMPLEXARRAY",
	"string array"  => "PARM_STRINGARRAY",
	"enum"          => "PARM_INT",
	"real enum"     => "PARM_REAL",
	"filename"      => "PARM_STRING",
	"precision"     => "PARM_PRECISION",
	"instrument"    => "PARM_STRING",
);


############################################################################
#
# Maps Ptolemy parameter types to Genesys types
#
############################################################################

%PtolemyParameter::typeGenesysMap = (
	"int"           => "Int",
	"fix"           => "Double",
	"real"          => "Double",
	"complex"       => "Complex",
	"string"        => "BString",
	"int array"     => "Array_Int",
	"fix array"     => "Array_Double",
	"real array"    => "Array_Double",
	"complex array" => "Array_Complex",
	"string array"  => "Array_BString",
	"enum"          => "Int",
	"real enum"     => "Double",
	"filename"      => "BString",
	"precision"     => "BString",
	"instrument"    => "BString",
);


############################################################################
#
# The following definition will automatically create (through the use of the 
# Class:Struct module) a PtolemyParameter class with 
#
# scalar members: name, type, description, default, unit
#
# array members:  enums, attributes, file_extensions
#
# It will also create methods to access and set the above members. 
# These methods have the same name as the member they access/set. For example, 
# methods called name, type, description, default, etc. are created. If no 
# arguments are passed to these methods they return the value of the member 
# (a reference to the array for the array members). If an argument is passed 
# to them, they set the value of the member. Setting elements of the arrays 
# requires that the index of the array element is also passed. This is not user 
# friendly, so add methods were created and they are the ones that should be 
# used to add elements in the enums, attributes, and file_extensions arrays. 
# Retrieving the elements of an array is also a little user unfriendly, so 
# iterators were created that help you iterate over all the elements in the 
# arrays.
#
############################################################################

struct PtolemyParameter => {
	name            => '$',
	type            => '$',
	description     => '$',
	default         => '$',
	symbol          => '$',
	value_range     => '$',
	unit            => '$',
	enums           => '@',
	attributes      => '@',
	file_extensions => '@',
};


############################################################################
#
# Adds an enum to the enums array.
# Takes a PtolemyEnum reference as an argument.
#
############################################################################

sub PtolemyParameter::addEnum {
	my $self = shift;
	my $enumRef = shift;
	if ( ref( $enumRef ) && ref( $enumRef ) eq "PtolemyEnum" ) {
		push @{$self->enums()}, $enumRef;
	}
	else {
		croak "Argument to PtolemyParameter::addEnum must be a reference to PtolemyEnum.\n";
	}
}


############################################################################
#
# Adds an attribute to the attributes array.
# Takes a string as an argument.
#
############################################################################

sub PtolemyParameter::addAttribute {
	my $self = shift;
	my $attr = shift;
	if ( ! ref( $attr ) ) {
		push @{$self->attributes()}, $attr;
	}
	else {
		croak "Argument to PtolemyParameter::addAttribute must be a scalar.\n";
	}
}


############################################################################
#
# Adds a file extension to the file_extensions array.
# Takes a string as an argument.
#
############################################################################

sub PtolemyParameter::addFileExtension {
	my $self = shift;
	my $fileExt = shift;
	if ( ! ref( $fileExt ) ) {
		push @{$self->file_extensions()}, $fileExt;
	}
	else {
		croak "Argument to PtolemyParameter::addFileExtension must be a scalar.\n";
	}
}


############################################################################
#
# Returns the number of enums.
#
############################################################################

sub PtolemyParameter::getEnumNumber {
	my $self = shift;
	return $#{$self->enums()} + 1;
}


############################################################################
#
# Returns the number of attributes.
#
############################################################################

sub PtolemyParameter::getAttributeNumber {
	my $self = shift;
	return $#{$self->attributes()} + 1;
}


############################################################################
#
# Returns the number of file extensions.
#
############################################################################

sub PtolemyParameter::getFileExtensionNumber {
	my $self = shift;
	return $#{$self->file_extensions()} + 1;
}


############################################################################
#
# Returns an iterator for the enums.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyParameter.
#
# my $nextEnum = $xyz->getEnumIterator();
#
# while ( my $enum = $nextEnum->() ) {
#    ...
# }
#
############################################################################

sub PtolemyParameter::getEnumIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->enums()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->enums()->[$index];
		}
	}
}


############################################################################
#
# Returns an iterator for the attributes.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyParameter.
#
# my $nextAttr = $xyz->getAttributeIterator();
#
# while ( my $attr = $nextAttr->() ) {
#    ...
# }
#
############################################################################

sub PtolemyParameter::getAttributeIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->attributes()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->attributes()->[$index];
		}
	}
}


############################################################################
#
# Returns an iterator for the file_extensions.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyParameter.
#
# my $nextFileExt = $xyz->getFileExtensionIterator();
#
# while ( my $fileExt = $nextFileExt->() ) {
#    ...
# }
#
############################################################################

sub PtolemyParameter::getFileExtensionIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->file_extensions()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->file_extensions()->[$index];
		}
	}
}


############################################################################
#
# Returns 1 if the file extension specified in the argument passed 
# exist in the @file_extensions array. Returns 0 otherwise.
#
############################################################################

sub PtolemyParameter::fileExtensionExists {
	my $self = shift;
	my $ext = shift;
	for my $i ( 0 .. $#{$self->file_extensions()} ) {
		if ( $ext eq $self->file_extensions()->[$i] ) {
			return 1;
		}
	}
	return 0;
}


############################################################################
#
# Returns the first file extension in the @file_extensions array.
# If array is empty, it returns "txt".
#
############################################################################

sub PtolemyParameter::getFirstFileExtension {
	my $self = shift;
	if ( $#{$self->file_extensions()} >= 0 ) {
		return $self->file_extensions()->[0];
	}
	else {
		return "txt";
	}
}


############################################################################
#
# Returns the PDE unit string used in create_parm
#
############################################################################

sub PtolemyParameter::getPDE_Unit {
	my $self = shift;
	return $PtolemyParameter::unitMap{ $self->unit() };
}


############################################################################
#
# Returns the Genesys unit enum
#
############################################################################

sub PtolemyParameter::getGenesysUnit {
	my $self = shift;
	return $PtolemyParameter::unitGenesysMap{ $self->unit() };
}


############################################################################
#
# Returns the Genesys type
#
############################################################################

sub PtolemyParameter::getGenesysType {
	my $self = shift;
	return $PtolemyParameter::typeGenesysMap{ $self->type() };
}


############################################################################
#
# Returns the PDE parameter type string used in create_parm
#
############################################################################

sub PtolemyParameter::getPDE_Type {
	my $self = shift;
	return $PtolemyParameter::typeMap{ $self->type() };
}


############################################################################
#
# Returns 1 if parameter has the PARM_NO_DISPLAY attribute, 0 otherwise.
#
############################################################################

sub PtolemyParameter::isNotShownOnSchematic {
	my $self = shift;
	my $nextAttribute = $self->getAttributeIterator();
	
	while ( my $attribute = $nextAttribute->() ) {
		if ( $attribute eq "PARM_NO_DISPLAY" ) {
			return 1;
		}
	}

	return 0;
}


############################################################################
#
# Returns 1 if parameter has the PARM_OPTIMIZABLE attribute, 0 otherwise.
#
############################################################################

sub PtolemyParameter::isOptimizable {
	my $self = shift;
	my $nextAttribute = $self->getAttributeIterator();
	
	while ( my $attribute = $nextAttribute->() ) {
		if ( $attribute eq "PARM_OPTIMIZABLE" ) {
			return 1;
		}
	}

	return 0;
}

1;

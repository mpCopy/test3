package PtolemyPort;

use strict;
use Class::Struct;

############################################################################
#
# The following definition will automatically create (through the use of the 
# Class:Struct module) a PtolemyPort class with 
#
# scalar members: pin_no, name, type, description, optional, and commutative
#
# It will also create methods to access and set the above members. 
# These methods have the same name as the member they access/set. For example, 
# methods called pin_no, name, type, description, optional, and commutative 
# are created. If no arguments are passed to these methods they return the 
# value of the member. If an argument is passed to them, they set the value 
# of the member.
#
############################################################################

struct PtolemyPort => {
	pin_no        => '$',
	name          => '$',
	type          => '$',
	description   => '$',
	optional      => '$',
	commutative   => '$',	
};


############################################################################
#
# This method translates the method StarSymbol::portThickness( )
#
# It returns an integer which is the thickness of the arrow stem.
#
############################################################################

sub PtolemyPort::getThickness {

	my $thinArrowStem = 1;
	my $thickArrowStem = 3;

	my $self = shift;
	my $type = $self->type();

	if ( $type =~ /matrix/ ) {
		return $thickArrowStem;
	}
	else {
		return $thinArrowStem;
	}
}


############################################################################
#
# This method translates the method StarSymbol::portLayer( )
#
# It returns an integer which is the la.
#
############################################################################

sub PtolemyPort::getLayer {

	my $self = shift;
	my $type = $self->type();

	if ( $type =~ /int/ ) {
		return 13;
	}
	elsif ( $type =~ /fix/ ) {
		return 14;
	}
	elsif ( $type =~ /real/ ) {
		return 15;
	}
	elsif ( $type =~ /complex/ ) {
		return 16;
	}
	elsif ( $type =~ /timed/ ) {
		return 17;
	}
	elsif ( $type =~ /anytype/ ) {
		return 18;
	}
	else {
		return 19;
	}
}


1;

package PtolemyEnum;

use strict;
use Class::Struct;

############################################################################
#
# The following definition will automatically create (through the use of the 
# Class:Struct module) a PtolemyEnum class with 
#
# scalar members: alias, abbreviation, and value
#
# It will also create methods to access and set the above members. 
# These methods have the same name as the member they access/set. For example, 
# methods called alias, abbreviation, and value are created. If no 
# arguments are passed to these methods they return the value of the member.
# If an argument is passed to them, they set the value of the member.
#
############################################################################

struct PtolemyEnum => {
	alias         => '$',
	abbreviation  => '$',
	value         => '$',
};

1;

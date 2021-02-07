#!/usr/local/bin/perl -w
# Copyright  2006 - 2017 Keysight Technologies, Inc  

############################################################################
#
# Usage: perl createPtolemyUI_Files.pl -[a][s][b][m][l][p][t][i] ComponentDescription.xml
#        -a creates ADS ael file
#        -s creates ADS symbol file
#        -b creates ADS bitmap file
#        -m prints to STDOUT Genesys model xml description
#        -l prints to STDOUT Genesys symbol xml description
#        -p prints to STDOUT Genesys part xml description 
#        -w created wiki markup file for parameter, input, output table
#        -t prints to STDOUT the information read in the form of a pl file
#        -i prints to STDOUT the information read in the form FIELD NAME = VALUE
#
# perl executable from ADS installation directory should be used.
#
# All files are created in the directory where the command is executed.
#
# Symbol and bitmap filenames are the contents of the <PDE_SYMBOL> and 
# <PDE_BITMAP> XML tags in the XML description file.
#
# If bitmap is created on UNIX/Linux it will not be usable on Windows 
# and vice versa.
#
# There are four files created for ael. Assuming the content of the <NAME> 
# XML tag (under <COMPONENT>) is CompName, the following files are created:
# CompName.ael, CompName-bmp.ael, CompName.ctl, CompName1.rec
#
############################################################################

use FindBin;
use lib "$FindBin::Bin";

use PtolemyComponent;
use PtolemyParameter;
use PtolemyEnum;
use PtolemyPort;

use XML::Parser;
use Getopt::Std;

our ( $opt_a, $opt_s, $opt_b, $opt_m, $opt_l, $opt_p, $opt_w, $opt_t, $opt_i );

getopts( 'asbmlpwti' );

if ( !$opt_a && !$opt_s && !$opt_b && !$opt_m && !$opt_l && !$opt_p && !$opt_w && !$opt_t && !$opt_i || $#ARGV == -1 ) {

	if ( $#ARGV == -1 ) {
		print "\nComponentDescription.xml file not specified.\n";
	}

	print "\n";
	print "Usage: perl createPtolemyUI_Files.pl -[a][s][b][i][p] ComponentDescription.xml\n";
	print "       -a creates ADS ael file\n";
	print "       -s creates ADS symbol file\n";
	print "       -b creates ADS bitmap file\n";
	print "       -m prints to STDOUT Genesys model xml description\n";
	print "       -l prints to STDOUT Genesys symbol xml description\n";
	print "       -p prints to STDOUT Genesys part xml description\n";
	print "       -w created wiki markup file for parameter, input, output table\n";
	print "       -t prints to STDOUT the information read in the form of a pl file\n";
	print "       -i prints to STDOUT the information read in the form FIELD NAME = VALUE\n";
	print "\n";
	exit;
}

$file = shift;

# Test to see if $file is a non-empty file that can be opened for reading.

if ( ! ( -e $file ) ) {
	die "File \"$file\" does not exist.\n";
}
elsif ( -z $file ) {
	die "File \"$file\" is an empty file.\n";
}
elsif ( ! ( -r $file ) ) {
	die "You do not have read permission for file \"$file\".\n";
}

unless ( open( INFILE, "<$file" ) ) {
	die "Cannot open file \"$file\" for reading.\n";
}

close( INFILE );

$pl_xml_file_exists_and_can_be_read = 1;

if ( $opt_w ) {

# *.pl.xml file has actually been renamed to *.pl

	$pl_xml_file = $file;
	$pl_xml_file =~ s/xml$/pl/;

	# Test to see if $pl_xml_file is a non-empty file that can be opened for reading.

	if ( ! ( -e $pl_xml_file ) || ( -z $pl_xml_file ) ||  ! ( -r $pl_xml_file ) ) {
		$pl_xml_file_exists_and_can_be_read = 0;
	}
	else {
		if ( ! open( INFILE, "<$pl_xml_file" ) ) {
			$pl_xml_file_exists_and_can_be_read = 0;
		}
		else {
			close( INFILE );
		}
	}
}

$last_handler = "";  # keeps track of the last handler that was called
@tags = ();          # stack used to store parsed opening xml tags
@contents = ();      # stack used to store parsed content between tags
@enumRefArray = ();  # array used to store enumerations 

@fileExtArray = ();  # array used to store file extensions
                     # extensions need to be added in the order they are listed 
                     # in the xml file; the stack approach would actually add 
                     # them in the reverse order and so this array is used as 
                     # a second stack (FIFO) to effectively restore the order

$comp = PtolemyComponent->new();

my $parser = new XML::Parser(ErrorContext => 2);

############################################################################
#
# start_handler: Just pushes on the @tags stack the opening xml tags
# char_handler:  Just pushes on the @contents stack the information content
#                between tags
# end_handler:   If the closing tag is one of PARAMETER, ENUM, INPUT, OUTPUT,
#                COMPONENT then the contents of the @tags and @contents stacks
#                are popped and processed until the corresponding opening tag 
#                is popped. If the closing tag is one of PARAMETER, ENUM, 
#                INPUT, OUTPUT a new object of type PtolemyParameter, 
#                PtolemyEnum, PtolemyPort, PtolemyPort respectively is created. 
#                The PtolemyParameter or PtolemyPort is added to the global 
#                PtolemyComponent $comp. For ENUM and since ENUMs are processed 
#                before PARAMETER is processed (ENUM is nested in PARAMETER and 
#                stack operation is last in first out) the created PtolemyEnum 
#                objects are stored in the global array @enumRefArray and when 
#                the new PtolemyParameter object is created (when closing 
#                PARAMETER tag is parsed) they are added to the 
#                PtolemyParameter object.
#
############################################################################

$parser->setHandlers( Start => \&start_handler,
                      End   => \&end_handler,
                      Char  => \&char_handler );

$parser->parsefile($file);




############################################################################
# start_handler
############################################################################

sub start_handler {
	my ($xp, $el) = @_;
	push @tags, $el;
	$last_handler = "START";
}



############################################################################
# end_handler
############################################################################

sub end_handler {

	my ($xp, $el) = @_;

############################################################################
# if the end handler is called right after the start handler, then there was 
# no content between the XML tags, e.g. <UNIT></UNIT> (for UNITLESS_UNIT), so 
# so push an empty string in the array
############################################################################

	if ( $last_handler eq "START" ) {
		push @contents, "";
	}

	if ( $el eq "PARAMETER" ) {

		my $parm = PtolemyParameter->new();
		my $lastTag = pop @tags;

		while ( $lastTag ne $el ) {

			my $lastContent = pop @contents;

			if ( $lastTag eq "NAME" ) {
				$parm->name( $lastContent );
			}
			elsif ( $lastTag eq "DESCRIPTION" ) {
				$parm->description( $lastContent );
			}
			elsif ( $lastTag eq "TYPE" ) {
				$parm->type( $lastContent );
			}
			elsif ( $lastTag eq "UNIT" ) {
				$parm->unit( $lastContent );
			}
			elsif ( $lastTag eq "DEFAULT" ) {
				$parm->default( $lastContent );
			}
			elsif ( $lastTag eq "SYMBOL" ) {
				$parm->symbol( $lastContent );
			}
			elsif ( $lastTag eq "VALUE_RANGE" ) {
				$parm->value_range( $lastContent );
			}
			elsif ( $lastTag eq "ATTRIBUTE" ) {
				$parm->addAttribute( $lastContent );
			}
			elsif ( $lastTag eq "FILE_EXTENSION" ) {
				push @fileExtArray, $lastContent;
			}
			else {
#				print "$lastTag: unrecognized child tag for PARAMETER.\n";
			}

			$lastTag = pop @tags;
		}

		for $i ( 0 .. scalar( @enumRefArray ) - 1 ) {
			$parm->addEnum( $enumRefArray[$i] );
		}

		@enumRefArray = ();

		while ( scalar( @fileExtArray ) > 0 ) {
			$parm->addFileExtension( pop @fileExtArray );
		}

		@fileExtArray = ();

		$comp->addParameter( $parm );

	}

	elsif ( $el eq "ENUM" ) {

		my $enum = PtolemyEnum->new();
		my $lastTag = pop @tags;

		while ( $lastTag ne $el ) {

			my $lastContent = pop @contents;

			if ( $lastTag eq "ALIAS" ) {
				$enum->alias( $lastContent );
			}
			elsif ( $lastTag eq "ABBREVIATION" ) {
				$enum->abbreviation( $lastContent );
			}
			elsif ( $lastTag eq "VALUE" ) {
				$enum->value( $lastContent );
			}
			else {
#				print "$lastTag: unrecognized child tag for ENUM.\n";
			}

			$lastTag = pop @tags;

		}

		push @enumRefArray, $enum;

	}

	elsif ( $el eq "INPUT" || $el eq "OUTPUT" ) {

		my $port = PtolemyPort->new();
		my $lastTag = pop @tags;

		while ( $lastTag ne $el ) {

			my $lastContent = pop @contents;

			if ( $lastTag eq "NAME" ) {
				$port->name( $lastContent );
			}
			elsif ( $lastTag eq "TYPE" ) {
				$port->type( $lastContent );
			}
			elsif ( $lastTag eq "DESCRIPTION" ) {
				$port->description( $lastContent );
			}
			elsif ( $lastTag eq "PIN_NO" ) {
				$port->pin_no( $lastContent );
			}
			elsif ( $lastTag eq "OPTIONAL" ) {
				$port->optional( $lastContent );
			}
			elsif ( $lastTag eq "COMMUTATIVE" ) {
				$port->commutative( $lastContent );
			}			
			else {
#				print "$lastTag: unrecognized child tag for INPUT/OUTPUT.\n";
			}

			$lastTag = pop @tags;

		}

		( $el eq "INPUT" ) ? $comp->addInput( $port ) : $comp->addOutput( $port );

	}

	elsif ( $el eq "COMPONENT" ) {

		my $lastTag = pop @tags;

		while ( $lastTag ne $el ) {

			my $lastContent = pop @contents;

			if ( $lastTag eq "NAME" ) {
				$comp->name( $lastContent );
			}
			elsif ( $lastTag eq "DESCRIPTION" ) {
				$comp->description( $lastContent );
			}
			elsif ( $lastTag eq "INSTANCE_NAME" ) {
				$comp->instance_name( $lastContent );
			}
			elsif ( $lastTag eq "LIBRARY" ) {
				$comp->library( $lastContent );
			}
			elsif ( $lastTag eq "DOMAIN" ) {
				$comp->domain( $lastContent );
			}
			elsif ( $lastTag eq "PDE_SYMBOL" ) {
				$comp->pde_symbol( $lastContent );
			}
			elsif ( $lastTag eq "PDE_BITMAP" ) {
				$comp->pde_bitmap( $lastContent );
			}
			elsif ( $lastTag eq "MODEL_TYPE" ) {
				$comp->model_type( $lastContent );
			}
			elsif ( $lastTag eq "NETLIST_NAME" ) {
				$comp->netlist_name( $lastContent );
			}
			else {
#				print "$lastTag: unrecognized child tag for COMPONENT.\n";
			}

			$lastTag = pop @tags;

		}

		if ( $opt_i ) {
			$comp->printInfo();
		}

		if ( $opt_t ) {
			$comp->printPL();
		}

		if ( $opt_a ) {
			$comp->createAEL();
		}

		if ( $opt_s ) {
			$comp->createSymbol();
		}

		if ( $opt_b ) {
			$comp->createBitmap();
		}

		if ( $opt_m ) {
			$comp->createGenesysModel();
		}

		if ( $opt_l ) {
			$comp->createGenesysSymbol();
		}

		if ( $opt_p ) {
			$comp->createGenesysPart();
		}

		if ( $opt_w ) {
			if ( $pl_xml_file_exists_and_can_be_read == 1 ) {
				open( INFILE, "<$pl_xml_file" );
				my $footnotes = "";
				while ( <INFILE> ) {
					if ( /FOOTNOTES/ ) {
						$footnotes = $_;
						$footnotes =~ s:.*<FOOTNOTES>(.*)</FOOTNOTES>:$1:;
						last;
					}
				}
				close( INFILE );
				$comp->createWiki( $footnotes );
			}
			else {
				$comp->createWiki( "" );
			}
		}
	}

	$last_handler = "END";
}



############################################################################
# char_handler
############################################################################

sub char_handler {

	my ($xp, $data) = @_;

############################################################################
# char handler is called even for the tabs that are used to indent 
# the tags in the xml file. Remove these tabs and new lines and push 
# data in the contents stack only if data is non-empty.
############################################################################

	$data =~ s/\t//g;
	$data =~ s/\n//g;

	if ( $data ne "" ) {

############################################################################
# This is to handle weird character sequences like "&lt;" as shown below
# <VALUE_RANGE>[1:2&lt;sup&gt;L&lt;/sup&gt;-1]</VALUE_RANGE>
#
# These sequences somehow force the char handler to be called multiples 
# times consecutively and so the content between the tags is split among 
# multiple calls of char handler. Therefore, if char handler is called 
# multiple times consecutively then merge the contents into one string 
# by poping the last element of the contents stack, concatenating the new 
# content and pushing it back
############################################################################

		if ( $last_handler eq "CHAR" ) {
			my $last = pop @contents;
			$last = $last . $data;
			push @contents, $last;
		}
		else {
			push @contents, $data;
		}

	}

	$last_handler = "CHAR";
}

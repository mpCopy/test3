#!/bin/perl
# Copyright  2001 - 2017 Keysight Technologies, Inc  

#-------------------------------------------------------------
# MAIN
#-------------------------------------------------------------
MAIN:
{
   &remove_header($ARGV[0]);
} #MAIN


#-------------------------------------------------------------
# Subroutine: remove_header
# Parameters: $ARGV[0] (filename)
# remove header lines from an ESG dataset file 
#-------------------------------------------------------------
sub remove_header {

	$datafile = $_[0];
	$datafile_tmp = $_[0].".tmp";
	open (INPUT, $datafile) || die "\n!! Cannot open $datafile file !!\n";
	while ($line = <INPUT>) {
		$alldata .= $line;
	}
	#open (OUTPUT, ">$datafile_tmp");
	@temp = split(/Data_Header_End/, $alldata);
	$temp[1] =~ s/^\n//;
	print $temp[1];

	close (INPUT);
	#close (OUTPUT);
	
}

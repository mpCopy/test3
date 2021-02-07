#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# Determine_modeloutputType()
#
#   This routine determines which outputType we should use.
#   The passed in parameter $SpecMap{$spectreType} may have
#   one name for an ADS netlist and another for IFF output.
#   The values are separated by a comma.
#
###############################################################################
sub Determine_modeloutputType
{
   my ($type) = @_;

   my @L = ();

############################
#
# NOTE: We made need to change this a bit due to
# three issues. IFF name, Netlist name, and "spiceType"
# name. We probably should have a convention that that
# it's seperated by commas and have three entries in
# the map file: 
#
# |Netlist Name,IFF Name (could be the same),SpiceType name|
#

   @L = split(",",$type);

   # They may be only entered once in the rules file. That would
   # indicate they map to the same name so we check here...
   if (@L[1] eq "") { @L[1] = @L[0]; }

   if ($WantGeminiOutput) { return(@L[0]); }
   else { return(@L[1]); }

} # sub Determine_modeloutputType

return(1);

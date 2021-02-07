#!/usr/local/bin/perl
# Copyright Keysight Technologies 2001 - 2017  

###############################################################################
#
# Determine_outputType()
#
#   This routine determines which outputType we should use.
#   The passed in parameter $SpecMap{$spectreType} may have
#   one name for an ADS netlist and another for IFF output.
#   The values are separated by a comma.
#
###############################################################################
sub Determine_outputType
{
   my ($type) = @_;

   my @L = ();

   @L = split(",",$type);

   # They may be only entered once in the rules file. That would
   # indicate they map to the same name so we check here...
   if (@L[1] eq "") { @L[1] = @L[0]; }

   if ($WantGeminiOutput) { return(@L[0]); }
   else { return(@L[1]); }

} # sub Determine_outputType

return(1);

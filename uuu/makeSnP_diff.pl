#@(#) $Source: /cvs/sr/src/geminiui/ael/makeSnP_diff.pl,v $ $Revision: 1.4 $ $Date: 2011/08/28 20:24:41 $
# Copyright Keysight Technologies 2006 - 2011  
# This PERL script is used to generate SnP_Diff netlist and SnP_Diff.ael item definitions with arbitrary number
# of differential ports.

if ( $ARGV[0] == /-h/ || $ARGV[0] == /-help/ ) {
    print "Usage: makeSnP num_of_port\n";
    exit(1);
}

if ( "X$ENV{'HPEESOF_DIR'}" != /prod/ ) {
    print "Please define ADS environment variable HPEESOF_DIR, and then try again.\n";
    print "Usage: makeSnP num_of_port\n";
    exit(1);
}

$numPorts = $ARGV[0];

if ( $numPorts < 1 ) {
    print "Usage: makeSnP num_of_port\n";
    print "    Please give the number of ports, for example if n=99, type:\n";
    print "    makeSnP 99\n";
    exit(1);
}

$inFile = "$ENV{'HPEESOF_DIR'}/circuit/ael/SnP.netlist";
$outFile = "S$numPorts" . "P_Diff";

open( INnet, "<$inFile" ) || die( "Cannot open master netlist $inFile\n" );
open( OUTnet, ">$outFile" ) || die( "Cannot generate netlist $outFile\n" );

$define = "define S$numPorts" . "P_Diff(";

$count = 0;
while ( $count < $numPorts ) {
   $count++;
   $define .= "p$count" . "_plus p$count" . "_minus ";
}
$define .= ")\n";

print OUTnet "$define";

while ( <INnet> ) {
   if ( /^  NPORTS=3/ ) {
      print OUTnet "  NPORTS=$numPorts\n";
   }
   elsif ( /^   S_Port:CMP1 p1 p0 p2 p0 p3 p0 / ) {
      $count = 0;
      $portList = "";
      while ( $count < $numPorts ) {
         $count++;
         $portList .= "p$count" . "_plus p$count" . "_minus ";
      }
      print OUTnet "   S_Port:CMP1 $portList \\\n";
   }
   else {
      print OUTnet;
   }
}

print OUTnet "end S$numPorts" . "P_Diff\n";

close( INnet );
close( OUTnet );
print "\nTwo files are created:\n";
print "  \"$outFile\": netlist definition, please place it under the <current_prj> directory.\n";

$inFile = "$ENV{'HPEESOF_DIR'}/circuit/ael/SnP.ael";
$outFile = "S$numPorts" . "P_Diff.ael";

open( INael, "<$inFile" ) || die( "Cannot open master AEL file $inFile\n" );
open( OUTael, ">$outFile" ) || die( "Cannot generate AEL file $outFile\n" );

while ( <INael> ) {
  if ( /create_item/ ) {
       print OUTael "create_item (\"S$numPorts" . "P_Diff\",                          \/\/name\n";
  }
  elsif ( /Port S-parameter File/ ) {
       print OUTael "             \"Differential $numPorts-Port S-parameter File\",      \/\/label\n";
  }
  elsif ( /SYM_S_N_PORT_P/ ) {
       print OUTael "             \"SYM_S$numPorts" . "P_Diff\",                      \/\/symbolName\n";
  }
  elsif ( /S_N_PORT_P/ ) {
       print OUTael "             \"S$numPorts" . "P_Diff\",                          \/\/netlistData\n";
  }
  else {
      print OUTael;
  }
}

close( INael );
close( OUTael );

print "  \"$outFile\": parameter definition, please place it under the <current_prj>/networks directory.\n\n";

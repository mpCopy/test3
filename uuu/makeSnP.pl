#@(#) $Source: /cvs/sr/src/geminiui/ael/makeSnP.pl,v $ $Revision: 1.3 $ $Date: 2011/08/27 00:01:07 $
# Copyright Keysight Technologies 2006 - 2011  
# This PERL script is used to generate SnP netlist and SnP.ael item definitions with arbitrary number
# of ports.

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
$outFile = "S$numPorts" . "P";

open( INnet, "<$inFile" ) || die( "Cannot open master netlist $inFile\n" );
open( OUTnet, ">$outFile" ) || die( "Cannot generate netlist $outFile\n" );

$define = "define S$numPorts" . "P(";

$count = 0;
while ( $count < $numPorts ) {
   $count++;
   $define .= "p$count ";
}
$define .= "p0)\n";

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
         $portList .= "p$count p0 ";
      }
      print OUTnet "   S_Port:CMP1 $portList \\\n";
   }
   else {
      print OUTnet;
   }
}

print OUTnet "end S$numPorts" . "P\n";

close( INnet );
close( OUTnet );
print "\nTwo files are created:\n";
print "  \"$outFile\": netlist definition, please place it under the <current_prj> directory.\n";

$inFile = "$ENV{'HPEESOF_DIR'}/circuit/ael/SnP.ael";
$outFile = "S$numPorts" . "P.ael";

open( INael, "<$inFile" ) || die( "Cannot open master AEL file $inFile\n" );
open( OUTael, ">$outFile" ) || die( "Cannot generate AEL file $outFile\n" );

while ( <INael> ) {
  if ( /create_item/ ) {
       print OUTael "create_item (\"S$numPorts" . "P\",                          \/\/name\n";
  }
  elsif ( /Port S-parameter File/ ) {
       print OUTael "             \"$numPorts-Port S-parameter File\",      \/\/label\n";
  }
  elsif ( /SYM_S_N_PORT_P/ ) {
       print OUTael "             \"SYM_S$numPorts" . "P\",                      \/\/symbolName\n";
  }
  elsif ( /S_N_PORT_P/ ) {
       print OUTael "             \"S$numPorts" . "P\",                          \/\/netlistData\n";
  }
  else {
      print OUTael;
  }
}

close( INael );
close( OUTael );

print "  \"$outFile\": parameter definition, please place it under the <current_prj>/networks directory.\n\n";
print "Note: The symbol definition for the component must be generated, named \"SYM_$outFile.dsn\".\n";
print "      To generate the symbol definition, please run the AEL function generate_snp_symbol($num)\n";
print "      from the ADS Main Window > Tools > Command Line.\n";

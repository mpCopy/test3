#!/usr/bin/env python
## THERE IS NO SUPPORT OR GUARANTEE FOR THIS SCRIPT. USE IT AT YOUR OWN RISK.
"""  
 PURPOSE:
 This script is an example IDF_NETLIST_FILTER, which is defined in 'idf.cfg' file. 
 It is intended to work around contradicted pcell subckt definitions caused by 
 instantiating multiple Dynamic Link instances containing the same Cadence pcell, 
 which can generate the same subckt name with a different definition in another 
 Cadence netlist session.
 
 USAGE:
 Perform the following list of tasks before starting Cadence:

 1. Make sure Python is in your $PATH. 
    An option is to use the Python that came with ADS on a 32-bit Linux system by 
    issuing the following two commands in a Korn Shell before starting Cadence:
     export PATH=$HPEESOF_DIR/tools/linux_x86/bin:$PATH
     export LD_LIBRARY_PATH=$HPEESOF_DIR/lib/linux_x86:$LD_LIBRARY_PATH

 2. In your Dynamic Link configuration file (./idf.cfg) add the following line:  
     IDF_NETLIST_FILTER="$HPEESOF_DIR/idf/examples/pcell_workaround.py"

 3. Make sure the target pattern ( _pcell followed by an optional underline and 
    then a series of digits ) does not appear in the netlist file other than the 
    lines referring to pcell instances.

 When defined as IDF_NETLIST_FILTER, this script is only called when Cadence netlist 
 is created through a live Dynamic Link session. Since Freeze Mode does not recreate 
 netlist (it simply includes previously generated netlist), this script has no effect 
 in Freeze Mode. However, after applying this script in an interactive Dynamic Link 
 session to create Cadence sub-circuit netlists, the ensuing Freeze Mode simulations 
 will include modified netlists that contain unique pcell subckt definitions in each 
 file. 

 This script reads string input line by line from STDIN, modifies all _pcell patterns
 mentioned in step 3 above (except in lines beginning with define or end), then 
 writes each line (modified or not) to STDOUT. Dynamic Link calls this script 
 with the following Linux/SunOS system call: 
 (mv netFile netFile.$$; pcell_workaround.py < netFile.$$ > netFile; rm -f netFile.$$)

 If you create your own IDF_NETLIST_FILTER script or program, please first test it
 with the above commands at the system prompt. Replace 'pcell_workaround.py' with 
 your program name and replace 'netFile' with the name of a copy of one of your 
 Dynamic Link netlist files located at:
   simulation/<cell>/adsDL/schematic/netlist/netlist.DL 
 
 BACKGROUND:
 Each Dynamic Link instance is netlisted to a separate file in a session independent 
 of the other Dynamic Link instances. Using multiple Dynamic Link instances with 
 the same pcell can lead to incorrect simulation results due to a pcell subckt 
 definition in a netlist file being redefined by another netlist file included later 
 on.

 Beginning in ADS 2009, a warning message similar to the following will be issued
 when duplicate subckt definitions are found:
     Warning detected by hpeesofsim during netlist parsing.
         In file `./networks/p1_block3_schematic.net' at, or just before, line 12.
         Subcircuit `res1_pcell_2' is redefined.  Discarding the earlier definition
         from `./networks/p1_block1_schematic.net:17'.

 To avoid this situation, this script appends the library_cell_view name of the 
 Cadence top level design to each occurrence of _pcell<digits> or _pcell_<digits>
 in the netlist file created from the Cadence design.
"""  

import os
import re
import sys

beginWithDefine=re.compile(r'''^define ''', re.VERBOSE)
beginWithEnd=re.compile(r'''^end ''', re.VERBOSE)


def last_design_name(lines):
    """
input:  The whole netlist file for a Dynamic Link Cadence top-level design
return: Last sub-circuit name in a line beginning with 'define ',
        which should be the library_cell_view of the top Cadence design.
"""
    lineBelowDefine=''
    for line in reversed(lines):
        if beginWithDefine.search(line):
            defineLineAndTheLineBelowIt=line+lineBelowDefine
            # A very long lib_cell_view name would be on a separate line and 
            # both this line and define line will end with a back slash character.
            # Therefore, backslash, space, and new line are used to split the 
            # define statement, of which the second word is the ADS subcircuit name.
            words=re.split(r'[\s\\\n]+', defineLineAndTheLineBelowIt)
            design_name=words[1]
            return design_name.strip()
        # Due to lines being reversed, the line below 'define' appears before 
        # the 'define' line in this loop.
        lineBelowDefine=line 
    return str(os.getpid()).strip()     # This should not happen in DL netlist


def extended_string(matchobj):
    """
This function is called as the second argument in the re.sub() call in
the main program below. It appends top_design_name to each reference of 
pcell instances to avoid name collision across multiple netlist files 
containing the same pcell instance(s).
"""
    return matchobj.group() + top_design_name


lines=sys.stdin.readlines()
top_design_name=last_design_name(lines)
for line in lines:
    # Rename all pcell references except those in lines beginning with 'define ' or 'end '
    if not beginWithDefine.search(line) and not beginWithEnd.search(line):
        #
        # It may be necessary to narrow down the pattern in the first 
        # field below. For example, make it begin with 'polyres_pcell' 
        # instead of simply '_pcell' as used below.
        #
        line=re.sub(r'''(_pcell[_]?[0-9][0-9]*)''', extended_string, line, 0)
    sys.stdout.write( line )


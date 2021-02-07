# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/lib/tcl/ptcl.tcl,v $ $Revision: 100.8 $ $Date: 2007/02/17 00:26:57 $
# Copyright (c) 1990-1996 The Regents of the University of California.
# All rights reserved.
# 
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in all
# copies of this software.
# 
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
# THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
# 
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
# PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
# CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
# ENHANCEMENTS, OR MODIFICATIONS.
# 
# 						PT_COPYRIGHT_VERSION_2
# 						COPYRIGHTENDKEY
#
# This is the startup file for ptcl.  It is run by the ptcl binary
# after initializing all the ptolemy extensions to tcl (primarily
# the PTcl class's commands), but before any user's rc file is
# run, and before any command line options like -f have been processed.
#
# We must find and load the tcl libraries, and then do any
# argument processing we want.
#
# Author: Kennard White
# ptcl.tcl	1.10 01/23/97
#

set ptkRunFlag(HPtolemy) ACTIVE

proc ptcl_init_env {} {
    global env tcl_prompt1 tcl_prompt2 tk_library tk_version
    global hptolemy HPTOLEMY

   if { ![info exist env(HPTOLEMY)] } {
	set env(HPTOLEMY) $env(HPEESOF_DIR)/adsptolemy
    }
    set hptolemy $env(HPTOLEMY)
    set HPTOLEMY $env(HPTOLEMY)

    if { ![info exist env(TCL_LIBRARY)] } {
	set env(TCL_LIBRARY) $env(HPEESOF_DIR)/tools/lib/tcl8.5
    }
    if { ![info exist env(TK_LIBRARY)] } {
	set env(TK_LIBRARY) $env(HPEESOF_DIR)/tools/lib/tk8.5
    }
    set tk_library $env(TK_LIBRARY)
    uplevel #0 {
	source $env(TCL_LIBRARY)/init.tcl
#	Use pttk.tcl instead of tk.tcl
#	source $env(TK_LIBRARY)/tk.tcl
	source $hptolemy/lib/tcl/pttk.tcl
    }

    set tcl_prompt1 "puts -nonewline stdout {ptcl> }"
    set tcl_prompt2 "puts -nonewline stdout {ptcl? }"
    
}

ptcl_init_env

# A procedure to return the rgb value of all color names used in Pigi.
source $hptolemy/lib/tcl/ptkColor.tcl

#Set the Defaults for fonts, colors, etc. for the Pigi Windows.
source $hptolemy/lib/tcl/ptkOptions.tcl

# Load the help system for ptcl
source $env(HPTOLEMY)/lib/tcl/ptcl_help.tcl

# Math extensions for parameter parsing
source $env(HPTOLEMY)/lib/tcl/mathexpr.tcl

source $env(HPTOLEMY)/lib/tcl/utilities.tcl

source $env(HPTOLEMY)/lib/tcl/ptkControl.tcl
source $env(HPTOLEMY)/lib/tcl/ptkBarGraph.tcl
source $env(HPTOLEMY)/lib/tcl/ptkPlot.tcl

ptkRunControlStandalone "HPtolemy" "ADS Ptolemy"

option add Pigi.meterWidthInC 8.0 startupFile
option add Pigi.scaleWidthInC 7.0 startupFile



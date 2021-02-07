# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/lib/tcl/hptolemyInit.tcl,v $ $Revision: 1.21 $ $Date: 2006/03/20 17:45:30 $
# Master initialization file for the tcl/tk HPtolemy interface
# Author: Jose Luis Pino

# This is based on ptkInit.tcl from UCB Ptolemy

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

set ptkRunFlag(HPtolemy) ACTIVE

proc hptolemy_init_env {} {
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
#	source $env(TK_LIBRARY)/tk.tcl
# a hack to get tk8.4 working, it should've been the above tk.tcl
	source $hptolemy/lib/tcl/pttk.tcl
    }

    set tcl_prompt1 "puts -nonewline stdout {hptolemy> }"
    set tcl_prompt2 "puts -nonewline stdout {hptolemy? }"

}

hptolemy_init_env

# A procedure to return the rgb value of all color names used in Pigi.
source $hptolemy/lib/tcl/ptkColor.tcl

# Change color scheme to bisque
#tk_setPalette background grey85 activeBackground grey92 activeForeground black background grey85 disabledForeground grey64 foreground black highlightBackground grey85 highlightColor black insertBackground black selectColor maroon selectBackground grey76 selectForeground black troughColor grey76 

#Set the Defaults for fonts, colors, etc. for the Pigi Windows.
source $hptolemy/lib/tcl/ptkOptions.tcl

# FIXME: Remove when no longer needed
set unique 1

source $hptolemy/lib/tcl/utilities.tcl

source $hptolemy/lib/tcl/ptkControl.tcl
source $hptolemy/lib/tcl/ptkBarGraph.tcl
source $hptolemy/lib/tcl/ptkPlot.tcl

option add Pigi.meterWidthInC 8.0 startupFile
option add Pigi.scaleWidthInC 7.0 startupFile

proc curuniverse {} {
    return "HPtolemy";
}

proc ptkSimMenu {w univ} {
set m $w.menu.control
menu $m
$w.menu add cascade -label "Simulation" -menu $m -underline 0 
$m add radio -label "Pause" -command "ptkPause $univ" -variable $ptkRunFlag($univ) -value PAUSED
$m add radio -label "Run"  -command "ptkResume $univ" -variable $ptkRunFlag($univ) -value ACTIVE
$m add command -label "Quit" -command "destroy $w"
bind $w <Destroy> "ptkStop $univ"
}

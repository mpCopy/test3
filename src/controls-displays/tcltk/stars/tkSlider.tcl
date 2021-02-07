# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/tkSlider.tcl,v $ $Revision: 100.10 $ $Date: 2006/04/28 21:26:39 $
# Tcl/Tk source for a slider controler
#
# Author: Edward A. Lee
# Version: tkSlider.tcl	1.10	3/3/95
#
# Copyright (c) 1990-1995 The Regents of the University of California.
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
# See the file $PTOLEMY/copyright for copyright notice,
# limitation of liability, and disclaimer of warranty provisions.
#

set s $ptkControlPanel.slider_$starID

# If a window with the right name already exists, we assume it was
# created by a previous run of the very same star, and hence can be
# used for this new run.  Some trickiness occurs, however, because
# parameter values may have changed, including the number of inputs.

if {[winfo exists $s]} {
    set window_previously_existed 1
} {
    set window_previously_existed 0
}

if {!$window_previously_existed} {
    if {[set ${starID}(PutInControlPanel)]} {
	frame $s
	pack after $ptkControlPanel.low $s {frame e}
    } {
        toplevel $s
	raise $s 
	raise $ptkControlPanel
        wm title $s "Sliders"
        wm iconname $s "Sliders"
    }
    frame $s.f
}

proc setOut_$starID {position} "
	set val \[expr {[set ${starID}(Low)]+([set ${starID}(High)]-\
	[set ${starID}(Low)])*\$position/[set ${starID}(Granularity)]}]
        setOutputs_$starID \$val
        $s.f.m.value configure -text \$val
"

proc setValue_$starID {val} "
    setOutputs_$starID \$val
    $s.f.m.value configure -text \$val
"

set gran [set ${starID}(Granularity)]

set position [expr \
	{round($gran*([set ${starID}(Value)]-[set ${starID}(Low)])/ \
	([set ${starID}(High)]-[set ${starID}(Low)]))}]

ptkMakeScale $s.f m [set ${starID}(Identifier)] $gran $position setOut_$starID
if {[set highw [string length [set ${starID}(High)]]] > 5} \
    { $s.f.m.value configure -width $highw }
$s.f.m.value configure -text $position

if {!$window_previously_existed} {

    pack append $s $s.f top

    proc destructorTcl_$starID {starID} {
	global $starID
	if {[set ${starID}(PutInControlPanel)]} {
	    # Remove the slider from the control panel, if it still exists
	    global ptkControlPanel
	    destroy $ptkControlPanel.slider_$starID
	}
    }
    tkwait visibility $s
}

# Initialize the output
setOutputs_$starID [set ${starID}(Value)]

unset s

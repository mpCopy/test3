# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/tkShowBooleans.tcl,v $ $Revision: 100.5 $ $Date: 2006/04/04 18:55:40 $
# Tcl/Tk source for a display that shows Booleans
#
# Author: Edward A. Lee
# Version: tkShowBooleans.tcl	1.2   3/3/95
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

set s $ptkControlPanel.booleans_$starID

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

    proc tkShowBooleanMakeWindowSDF {putInCntrPan win label numInputs univ starID ids} {
	if {![winfo exists $win]} {
	    global ptkControlPanel
            if {$putInCntrPan} {
	        frame $win
	        pack $win -after $ptkControlPanel.low -fill x -expand 1
            } {
                toplevel $win
		raise $win
		raise $ptkControlPanel
                wm title $win "Show Booleans"
                wm iconname $win "Show Booleans"
            }

            frame $win.f
	    if {$label != {}} {
		message $win.msg -width 12c
		pack $win.msg -expand 1
	    }
            pack $win.f -fill both -expand 1 -padx 10 -pady 10
	}
	if {$label != {}} {
	    $win.msg configure -text $label
	}

	# The following flag is used if the waitBetweenOutputs parameter is set
	global $starID
	set ${starID}(tkShowBooleanWaitTrig) 0
        for {set i 0} {$i < $numInputs} {incr i} {
	    catch {destroy $win.f.att$i}
	    frame $win.f.att$i
    	    button $win.f.att$i.button -relief flat -width 40 \
		-command "incr ${starID}(tkShowBooleanWaitTrig)" \
		-state disabled -disabledforeground black
	    $win.f.att$i.button configure \
		    -text "[lindex $ids $i]: no Boolean yet"

	    pack $win.f.att$i.button -fill x -expand 1
	    pack $win.f.att$i -fill x -expand 1
        }

#	if {[set ${starID}(WaitBetweenOutputs)]} {
	    # Arrange for the tkShowBooleanWaitTrig variable
	    # to be updated if the run status changes (for example,
	    # a halt is requested)
#	    global ptkRunFlag
#	    trace variable ptkRunFlag($univ) w tkShowBooleanReleaseWaitSDF
#	}
    }
}

proc tkShowBooleanReleaseWaitSDF {runflag univ op} "
	global ${starID}
	incr ${starID}(tkShowBooleanWaitTrig)
"

tkShowBooleanMakeWindowSDF [set ${starID}(PutInControlPanel)] \
	$s [set ${starID}(Label)] \
	[set ${starID}(numInputs)] [curuniverse] $starID \
	[set ${starID}(Identifiers)]

if {!$window_previously_existed} {

    proc tkShowBooleanSetValuesSDF {starID numInputs win ids} {
        set c $win.f
        set inputVals [grabInputs_$starID]
	for {set i 0} {$i < $numInputs} {incr i} {
            if {[lindex $inputVals $i]} {
		set in {TRUE}
	    } {
		set in {FALSE}
	    }
	    catch { $win.f.att$i.button configure -text \
			"[lindex $ids $i]: $in" }
	}
    }

    proc tkShowBooleanWaitSDF {flag starID numInputs win univ} {
	if {$flag} {
	    global $starID
	    set ${starID}(tkShowBooleanWaitTrig) 0
	    for {set i 0} {$i < $numInputs} {incr i} {
	        $win.f.att$i.button configure -state normal
	    }
	    tkwait variable ${starID}(tkShowBooleanWaitTrig)
	    for {set i 0} {$i < $numInputs} {incr i} {
		# In case the window was dismissed, trap errors
	        catch {$win.f.att$i.button configure -state disabled}
	    }
	}
    }
}

# In the following definition, the value of $s
# is evaluated when the file is sourced.
proc goTcl_$starID {starID} "
        tkShowBooleanSetValuesSDF $starID [set ${starID}(numInputs)] $s \
		[list [set ${starID}(Identifiers)]]
"

proc destructorTcl_$starID {starID} {
        global $starID
        if {[set ${starID}(PutInControlPanel)]} {
            # Remove the meters from the control panel, if they still exist
            global ptkControlPanel
            destroy $ptkControlPanel.booleans_$starID
        }
}
unset s

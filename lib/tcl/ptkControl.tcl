# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/lib/tcl/ptkControl.tcl,v $ $Revision: 1.18 $ $Date: 2006/03/20 17:45:30 $
# Definition of a bunch of control panels for the tcl/tk Ptolemy interface
# Author: Edward A. Lee
# Version: ptkControl.tcl	1.56	01/29/97
#
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
# The global array ptkRunFlag($name), indexed by the name of the universe,
# has the following values:
#	undefined		no active run window, universe not created
#	IDLE			active run window, but no run yet
#	ACTIVE			active run
#	PAUSED			paused run
#	FINISHED		finished a run
#	ERROR			the last run terminated with an error
#	STOP_PENDING		pending stop requested
#	ABORT			pending abort requested

# Need a dummy value in ptkRunFlag(main) for startup
set ptkRunFlag(main) ACTIVE
# The global variable ptkControlPanel is the name of the master control
# panel window that is currently being used for a run.  This name is therefore
# available to stars that wish to insert frames into the control panel.
# It is equal to .run_$octHandle.
set ptkControlPanel ""

#######################################################################
# Procedure to initialize the run control panel for those parts
# of the window that do not depend on the Oct interface (octHandle arg)
# Used by ptkRunControl and ptkRunControlStandalone
#
proc ptkRunControlInit { name ctrlPanel title msgtext } {
    global ptkDebug ptkRunFlag ptkRunEventLoop ptkScriptOn

    # Reset global settings
    # -- set ptkRunFlag as open run panel but with nothing running yet
    set ptkDebug($name) 0
    set ptkRunFlag($name) "ACTIVE"
    set ptkRunEventLoop($name) 1
    set ptkScriptOn($name) 0

    catch {destroy $ctrlPanel}
    # Sets the Class of the Window.  This is used to set all options
    #   for widgets used in the Contol window
    toplevel $ctrlPanel -class PigiControl
    wm title $ctrlPanel $title
    wm iconname $ctrlPanel $title

    # The following empty frames are created so that they are available
    # to stars to insert custom controls into the control panel.
    # By convention, we tend to use "high" for entries, "middle"
    # for buttons, and "low" for sliders.  The full name for the
    # frame is .run_${octHandle}.$position, where $name is the name of the
    # universe, and $position is "high", "middle", or "low".
    frame $ctrlPanel.high
    frame $ctrlPanel.middle
    frame $ctrlPanel.low
}

#######################################################################
# Procedure to initialize the run control panel for standalone programs
# as an alternative to ptkRunControl; it defines those parts of the
# run control panel that do not depend on the Oct interface
# Used by the compile-SDF target
#
proc ptkRunControlStandalone { name title } {
    wm withdraw .
    set ctrlPanel .run_$name
    ptkRunControlInit $name $ctrlPanel "$title" "$name"

    global ptkControlPanel
    set ptkControlPanel $ctrlPanel

    frame $ctrlPanel.panel -bd 10
        button $ctrlPanel.panel.pause -text "Pause" \
		-command "ptkPauseStandalone $name $ctrlPanel" -width 14
        button $ctrlPanel.panel.quit -text "Quit" \
		-command "ptkAbort $name" -width 14

	pack append $ctrlPanel.panel \
	    $ctrlPanel.panel.pause {left fill} 
	pack append $ctrlPanel.panel \
	    $ctrlPanel.panel.quit {left fill} 

    pack $ctrlPanel.panel
    pack $ctrlPanel.high -fill x
    pack $ctrlPanel.middle -fill x
    pack $ctrlPanel.low -fill x

    wm geometry $ctrlPanel +400+400
    set univ {curuniverse}
    set ptkRunFlag($univ) "ACTIVE" 
    wm protocol $ctrlPanel WM_DELETE_WINDOW "ptkAbort $name"
    
    wm deiconify $ctrlPanel
    raise $ctrlPanel
    focus -force $ctrlPanel

    return $ctrlPanel
}

#######################################################################
# a number of places call ptkStop where they really ought to call
# ptkAbort; provide synonym for backwards compatibility
proc ptkStop { name } {
    ptkAbort $name
}

#######################################################################
# procedure to stop a run
# any run-control-window script will see an error from "run",
# and will be terminated if it doesn't catch the error
proc ptkAbort { name } {
    global ptkRunFlag
    if {![info exists ptkRunFlag($name)]} {
	# Assume the window has been deleted already and ignore command
	return
    }
    # Ignore if the named system is not running or "PAUSED"
    if {$ptkRunFlag($name) != "ACTIVE" && \
	$ptkRunFlag($name) != "PAUSED"} return

    if {[ptclTargetTasks] != "0"} {
	global exitOkPrompt
	set exitOk [ toplevel .exitOk -class PigiControl ]
	wm title $exitOk "Quit ADS Ptolemy?"
	wm iconname $exitOk "Quit ADS Ptolemy?"
	message $exitOk.msg -aspect 1000 \
	    -text "Data collection has not completed.
Are you sure you want to quit?"
	set exitOkB [ frame $exitOk.buttons ]
	button $exitOkB.continue -text Continue -width 14 \
	    -command { set exitOkPrompt 1 }
	button $exitOkB.quit -text Quit -width 14 \
	    -command {set exitOkPrompt 0 }
	bind $exitOk <Destroy> { set exitOkPrompt 1 }
	pack $exitOkB.continue $exitOkB.quit -side left
	pack $exitOk.msg $exitOkB -side top
	grab $exitOk
	tkwait variable exitOkPrompt
	grab release $exitOk
	catch { bind $exitOk <Destroy> {} }
	destroy $exitOk
	if ($exitOkPrompt) { return }
    }

    # Note that the following set will release the ptkPause proc
    set ptkRunFlag($name) ABORT
    abort
    destroy .
}

#######################################################################
# procedure to pause a run
proc ptkPauseStandalone { name ctrlPanel} {
    global ptkRunFlag ptkPlotPause
    if {[info exists ptkRunFlag($name)] && \
    	$ptkRunFlag($name) == "ACTIVE"} {
        $ctrlPanel.panel.pause configure -text "Continue"
        set ptkRunFlag($name) "PAUSED"
	set ptkPlotPause 1
        tkwait variable ptkRunFlag($name) 
    } \
    elseif {[info exists ptkRunFlag($name)] && \
    	$ptkRunFlag($name) == "PAUSED"} {
        $ctrlPanel.panel.pause configure -text "Pause"
        set ptkRunFlag($name) "ACTIVE"
	set ptkPlotPause 0
    } 
}

#######################################################################
# procedure to pause a run
proc ptkPause { name } {
    global ptkRunFlag
    set ptkRunFlag($name) "PAUSED"
    tkwait variable ptkRunFlag($name)
}

#######################################################################
# procedure to continue a run
proc ptkResume { name } {
    global ptkRunFlag
    set ptkRunFlag($name) "PAUSED"
}

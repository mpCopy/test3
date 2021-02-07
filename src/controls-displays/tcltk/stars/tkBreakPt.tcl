# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/stars/tkBreakPt.tcl,v $ $Revision: 100.3 $ $Date: 1997/11/20 11:37:10 $
# Tcl/Tk source TkBreakPt, a star that pauses when its input values meet
#			   the user settable condition
#
# Author: Alan Kamas
# Version: 3/3/95 tkBreakPt.tcl	1.5
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

proc goTcl_$starID {starID} {
	global ptkControlPanel $starID

	# put the inputs into the form expected by the condition statement
	set inputList [grabInputs_$starID]
	set j 0
	foreach i $inputList {
    	    set input([incr j]) $i
	}

	set conderror 0
	if [catch { expr [set ${starID}(Condition)] } result] {
	    set conderror 1
	}
	if {$result != 0} {
	    # Break point has been reached
	    # implement the action defined in the break point script
	    set script [set ${starID}(OptionalAlternateScript)] 
	    if { $conderror == 0 && ([string length $script] > 0) } {
		eval $script
	    } else {
		# No readable script passed:  Default Script: Pause the run

		# Put explanation in the control window
		set s $ptkControlPanel
		set s.brpt $s.breakpoint_$starID
		if { ! [winfo exists $s.brpt] } {
		    # make overall, text, and entry frames
		    frame $s.brpt
		    set result [expr {$conderror ? "Error: $result\n\n" : ""}]
		    message $s.brpt.m -aspect 300 -text \
			    "${result}Star [set ${starID}(fullName)] has hit a\
			    breakpoint. You may edit the breakpoint condition\
			    below; set it to 0 (zero) to disable it.  Press\
			    Continue to continue."
                    ptkMakeEntry $s.brpt e Condition ${starID}(Condition)
		    pack $s.brpt.m $s.brpt.e -in $s.brpt
		    pack $s.brpt -in $s -after $s.low
		    # make sure messages are displayed before the pause
		    update idletasks
		}
		$ptkControlPanel.panel.pause invoke
		# ptkClearHighlights
                catch {pack forget $s.brpt}
		catch {destroy $s.brpt}
	    }
	}
}

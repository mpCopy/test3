# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/lib/tcl/ptkBarGraph.tcl,v $ $Revision: 100.9 $ $Date: 2005/04/04 23:50:36 $
# Definition of a bunch of utility procedures for the tcl/tk Ptolemy interface
# Author: Edward A. Lee
# Version: ptkBarGraph.tcl	1.9	2/29/96
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

set ptkBarGraphScaleFactor(main) 1

#######################################################################
# Procedure to make an animated bar graph display of an array.
# Arguments:
#	w		toplevel window name to use (with the leading period)
#	desc		description to attach to the window
#	geo		geometry of the window
#	numBars		number of bars in the bar graph
#	barGraphWidth	width in centimeters
#	barGraphHeight	height in centimeters
proc ptkMakeBarGraph {w desc geo numBars barGraphWidth barGraphHeight univ} {
    global ptkBarGraphScaleFactor
    global ptkControlPanel
    catch {destroy $w}
    toplevel $w
    raise $w
    raise $ptkControlPanel
    wm title $w "$desc"
    wm iconname $w "$desc"

    set startScale [${w}rescale 1.0]

    menu $w.menu 
    set m $w.menu.file 
    menu $m 
    $w.menu add cascade -label "File" -menu $m -underline 0
    $m add check -label "Pause" \
	-command "ptkPauseStandalone $univ .run_HPtolemy" -variable ptkPlotPause
    $m add command -label "Exit $desc" -command "destroy $w"

    set ptkBarGraphScaleFactor($w) 1.0
    set m $w.menu.zoom
    menu $m  
    $w.menu add cascade -label "View" -menu $m -underline 0
    $m add command -label "Original View" -command "changeBarScaleOriginal $w"
#    $m add command -label "View All" -command ""
    $m add separator
    global ptkPlotZoomFlag
    set ptkPlotZoomFlag($w) 0
    $m add command -label "Zoom In x2" -command "changeBarScale $w 0.5"
    $m add command -label "Zoom Out x2" -command "changeBarScale $w 2.0"

    $w configure -menu $w.menu

    frame $w.pf 
    canvas $w.pf.plot -relief sunken -bd 2 -background white \
	    -height ${barGraphHeight}c -width ${barGraphWidth}c

    frame $w.pf.axis 
    label $w.pf.axis.top -text [lindex $startScale 0]
    label $w.pf.axis.bottom -text [lindex $startScale 1] 
    pack append $w.pf.axis \
	$w.pf.axis.top top \
	$w.pf.axis.bottom bottom

    pack append $w.pf \
	$w.pf.axis {left fill } \
	$w.pf.plot {top fill expand} 

    # bar entry, button and slider section, empty by default
    frame $w.high -bd 2
    frame $w.middle -bd 2
    frame $w.low -bd 2

    pack append $w \
	    $w.low {bottom fillx } \
	    $w.middle {bottom fillx } \
	    $w.high {bottom fillx } \
	    $w.pf {top fill expand } 
		

    wm geometry $w $geo
    wm minsize $w 400 200
    tkwait visibility $w.pf.plot
    # Binding to redraw the plot when the window is resized.
    bind $w.pf.plot <Configure> "${w}redraw"
}

proc changeBarScale {w s} {
    global ptkBarGraphScaleFactor
    set newScale [${w}rescale $s]
    set ptkBarGraphScaleFactor($w) \
	[expr $s * $ptkBarGraphScaleFactor($w)]
    $w.pf.axis.bottom configure -text [lindex $newScale 1] 
    $w.pf.axis.top configure -text [lindex $newScale 0] 
    ${w}redraw
}

proc changeBarScaleOriginal {w} {
    global ptkBarGraphScaleFactor
    changeBarScale $w [expr 1/$ptkBarGraphScaleFactor($w)]
}

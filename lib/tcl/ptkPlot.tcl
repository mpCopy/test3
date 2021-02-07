# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/lib/tcl/ptkPlot.tcl,v $ $Revision: 100.17 $ $Date: 2007/02/14 22:42:34 $
# 
#  Tcl interface for creating a plotting utility
# 
#  Author: Jose Luis Pino

#  Based on a version by: Wei-Jen Huang and E. A. Lee
#  Version: ptkPlot.tcl 1.9    2/29/96
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

set ptkPlotButtonFlag 0
set ptkPlotZoomFlag(main) 0
set ptkPlotRecordFlag(main) 0
set ptkPlotFileName(main) ""
set ptkPlotFileNameFlag(main) 0
set ptkPlotOrientation(main) 0

proc ptkPlotButtonPress {w x y} {
    global ptkPlotZoomFlag 
    if $ptkPlotZoomFlag($w) {
        global ptkPlotButtonFlag
    	set ptkPlotButtonFlag 1
    	$w.pf.c create rectangle $x $y $x $y -tag zoomrect
    }
}

proc ptkPlotButtonRelease {w x y} {
    global ptkPlotZoomFlag
    if $ptkPlotZoomFlag($w) {
        global ptkPlotButtonFlag
        set ${w}ptkPlotButtonFlag 0
        ptkPlotMotion $w $x $y
        eval ptkXYPlotResize$w [$w.pf.c coords zoomrect]
        $w.pf.c delete zoomrect
        set ptkPlotZoomFlag($w) 0
    }
}

proc ptkPlotMotion {w x y} {
     global ptkPlotButtonFlag
     if $ptkPlotButtonFlag {
	set currentcoords [$w.pf.c coords zoomrect]
	if {[llength $currentcoords] == {4}} {
	    $w.pf.c coords zoomrect \
		    [lindex $currentcoords 0] \
		    [lindex $currentcoords 1] \
		    $x $y
	}
    }
}

proc ptkAddRecordMenuCommand {w univ} {
    global ptkPlotPause
    set m $w.menu.file 
    if [catch {$m index "Record"} index] {
	error "Record not in menu"
    }
    $m entryconfigure $index -state normal
}

proc ptkCreateXYPlot {w title geo univ} {
    global ptkRunFlag ptkPlotOrientation \
	ptkPlotFileName ptkPlotFileNameFlag ptkPlotPause
    set ptkPlotFileName($w) [pwd]/[lindex $title 0].eps
    set ptkPlotFileNameFlag($w) 0

    # Create the top-level window
    global ptkControlPanel
    catch {destroy $w}
    toplevel $w
    raise $w
    raise $ptkControlPanel

    wm title $w "$title"
    wm iconname $w "ADS Ptolemy Plot"

    wm geometry $w $geo
    # The following allows the window to resize
    wm minsize $w 200 200

    menu $w.menu 
    set m $w.menu.file 
    menu $m 
    $w.menu add cascade -label "File" -menu $m -underline 0
    $m add command -label "Save" -command "ptkPlotSave $w \"$title\"" -accelerator Ctrl+S 
    bind $w <Control-S> "ptkPlotSave $w \"$title\""
    $m add command -label "Save As ..." -command "ptkPlotSaveAs $w \"$title\""

    global ptkPlotRecordFlag
    $m add check -label "Record" \
	-variable ptkPlotRecordFlag($w) -state disabled \
	-command "ptkXYPlotToggleRecordFlag$w"
    $m add command -label "Print"  \
	-command "ptkPrintPlot $w \"$title\"" -accelerator Ctrl+P
    bind $w <Control-P>  "ptkPrintPlot $w \"$title\""
    $m add separator
    $m add check -label "Pause" \
	-command "ptkPauseStandalone $univ .run_HPtolemy" -variable ptkPlotPause
    $m add command -label "Exit $title" -command "destroy $w"

    set m $w.menu.zoom
    menu $m  
    $w.menu add cascade -label "View" -menu $m -underline 0
    $m add command -label "Original View" -command "ptkXYPlotZoomOriginal$w"
    $m add command -label "View All" -command "ptkXYPlotZoomFit$w"
    $m add separator
    global ptkPlotZoomFlag
    set ptkPlotZoomFlag($w) 0
    $m add command -label "Zoom Window" -command "set ptkPlotZoomFlag($w) 1"
    $m add command -label "Zoom In x2" -command "ptkXYPlotZoom$w 0.5"
    $m add command -label "Zoom Out x2" -command "ptkXYPlotZoom$w 2"

    $w configure -menu $w.menu
    pack [frame $w.pf] -side top -fill both -expand yes
    pack [canvas $w.pf.c -relief sunken -bd 2 -background white] -expand yes -fill both

    bind $w.pf.c <ButtonPress-1> "ptkPlotButtonPress $w %x %y"
    bind $w.pf.c <ButtonRelease-1> "ptkPlotButtonRelease $w %x %y"
    bind $w.pf.c <Motion> "ptkPlotMotion $w %x %y"

    # To support redrawing when the window is resized.
    update
    bind $w.pf.c <Configure> "ptkXYPlotRedraw$w"

    set ptkPlotOrientation($w) 1
}

proc ptkPlotSave {w title} {
    global ptkPlotFileNameFlag
    if $ptkPlotFileNameFlag($w) {
	ptkPlotSaveFile $w
    } else {
	ptkPlotSaveAs $w $title
    }
}

proc ptkPlotSaveAs {w title} {
    global ptkPlotFileName ptkPlotFileNameFlag
    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Encapsulated Postscript Files"		{.eps}	}
	{"All files"		*}
    }
    set file [tk_getSaveFile -filetypes $types -parent $w \
        -title "Save As: $title" -initialfile $ptkPlotFileName($w) -defaultextension .eps]
    if [string compare $file ""] {
	set ptkPlotFileNameFlag($w) 1
	set ptkPlotFileName($w) $file
	ptkPlotSaveFile $w
    }
}

proc ptkPlotSaveFile {w} {
    global ptkPlotFileName
    set printCommand [ptkPlotPrintCommand $w]
    append printCommand " -file $ptkPlotFileName($w)"
    eval $printCommand
}

proc ptkPrintPlot {w title} {
    global ptkPlotPlatform
    if { $ptkPlotPlatform == "windows" } {
	PrintWindow $w	
    } else {
	ptkPrintXYPlot $w $title
    }
}

proc ptkPrintXYPlot {w title} {
    catch "destroy ${w}_print"
    toplevel [set wpr ${w}_print]
    wm title $wpr "Print: $title"
    wm iconname $wpr "Print"

    #########################################################################
    # Choose portrait or landscape mode
    #
    global ptkPlotOrientation
    set orientation $ptkPlotOrientation($w)
    frame $wpr.portland -relief groove -bd 2
    radiobutton $wpr.portland.portrait -text "Portrait" \
        -var ptkPlotOrientation($w) -relief flat -val 1
    radiobutton $wpr.portland.landscape -text "Landscape" \
        -var ptkPlotOrientation($w) -relief flat -val 0
    radiobutton $wpr.portland.larger -text "Best fit" \
        -var ptkPlotOrientation($w) -relief flat -val 2
    pack $wpr.portland.portrait -side left
    pack $wpr.portland.landscape -side left
    pack $wpr.portland.larger -side right
    pack $wpr.portland -padx 5 -pady 5

    ###############################################################
    # Print/Cancel
    #
    pack [frame $wpr.cntr] -side bottom -fill x -expand 1 -padx 5 -pady 5
    frame $wpr.cntr.prfr -relief sunken -bd 2
    button $wpr.cntr.prfr.print -text "PRINT" -command "ptkPrintXYPlotGo $w; destroy $wpr"
    button $wpr.cntr.cancel -text "CANCEL" -command "destroy $wpr"

    pack $wpr.cntr.prfr.print -fill x -expand 1
    pack $wpr.cntr.prfr -side left -fill x -expand 1
    pack $wpr.cntr.cancel -side right -fill x -expand 1

    #################################################################
    # Print Command
    #
    frame $wpr.p
    pack [label $wpr.p.plabel -text "Print Command: "] \
	-side left -fill none -anchor nw
    pack [entry $wpr.p.printer -relief sunken -bg white -width 20] -side right
    bind $wpr.p.printer <Return> "ptkPrintXYPlotGo $w; destroy $wpr"
    bind $wpr.p.printer <Tab> "focus $wpr.file"
    pack $wpr.p -side bottom -anchor w -padx 5 -pady 5
    $wpr.p.printer insert @0 "lp"
}

proc ptkPlotPrintCommand {w} {
   global ptkPlotOrientation
   set canvWidth [winfo width $w]  
   set canvHeight [winfo height $w]

   set command "$w.pf.c postscript "
   set orientation $ptkPlotOrientation($w) 
   if {$ptkPlotOrientation($w) == 2} {
	if {$canvWidth < $canvHeight} {
		set orientation 1
	} else { set orientation 0 }
   }
   if {$orientation == 0} {
	# landscape
	if [expr {(10.25/$canvWidth)<(7.5/$canvHeight)}] {
		append command " -pagewidth 10.25i -rotate 1"
	} else {
		append command " -pageheight 7.5i -rotate 1"
	}
   } elseif {$orientation == 1} {
	# portrait
	if [expr {(7.5/$canvWidth)<(10.25/$canvHeight)}] {
		append command " -pagewidth 7.5i"
	} else {
		append command " -pageheight 10.25i"
	}
   }
   return $command
}

proc ptkPrintXYPlotGo w {
    set wpr ${w}_print
    set printCommand [ptkPlotPrintCommand $w]
    set tempfile "ptkPlot"
    append tempfile [pid] ".ps"
    append printCommand " -file $tempfile"
    eval $printCommand
    set printCommand "exec [$wpr.p.printer get] $tempfile"
    if [catch {eval $printCommand} result] {
	catch "destroy ${w}_printerror"
	toplevel [set wpre ${w}_printerror]
	wm title $wpre "Print Error"
	wm iconname $wpre "Print Error"
	label $wpre.m -text "Printing failed: $result"
	button $wpre.ok -text "OK" -command "destroy $wpre"
	pack $wpre.m $wpre.ok
    }
    catch {exec rm $tempfile}
}

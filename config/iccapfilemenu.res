# @(#) $Source: /cvs/sr/src/dds/config/iccapfilemenu.res,v $ $Revision: 1.4 $ $Date: 2011/11/28 22:12:19 $

"&File"					"File Operations"	T
"&New	Ctrl+N"			"Open a new data display window"	dds_action_cb_ael	ddsMenuFileNew		dds_menu_sens_cb_ael	ddsMenuFileNew
"&Open...	Ctrl+O"		"Open a saved data display window"	dds_action_cb_ael	ddsMenuFileOpen		dds_menu_sens_cb_ael	ddsMenuFileOpen
"&Close"		"Close the dds file"				dds_action_cb_ael	ddsMenuFileClose	dds_menu_sens_cb_ael	ddsMenuFileClose
---
"&Save	Ctrl+S"			"Save this window"					dds_action_cb_ael	ddsMenuFileSave		dds_menu_sens_cb_ael	ddsMenuFileSave
"Save &As..."			"Save this window with a new name"	dds_action_cb_ael	ddsMenuFileSaveAs	dds_menu_sens_cb_ael	ddsMenuFileSaveAs
"Save Cop&y As..."			"Save this display setup with a new name"	dds_action_cb_ael	ddsMenuFileSaveCopyAs	dds_menu_sens_cb_ael	ddsMenuFileSaveCopyAs
"Save As Te&mplate..."	"Save selected as a template"		dds_action_cb_ael	ddsMenuFileSaveAsTemplate	dds_menu_sens_cb_ael	ddsMenuFileSaveAsTemplate
# ---
# "&Delete Dataset..."	"Delete a dataset"					dds_action_cb_ael	ddsMenuFileDeleteDataset	dds_menu_sens_cb_ael	ddsMenuFileDeleteDataset
"&Manage Dataset Aliases..."	"Add, delete, edit dataset aliases"					dds_action_cb_ael	ddsMenuFileManageDatasetAliases	dds_menu_sens_cb_ael	ddsMenuFileManageDatasetAliases
---
"&Print...	Ctrl+P"		"Print this window"					dds_action_cb_ael	ddsMenuFilePrint		dds_menu_sens_cb_ael	ddsMenuFilePrint
"P&rint Selected..."		"Print the selected objects in this window"					dds_action_cb_ael	ddsMenuFilePrintSelected		dds_menu_sens_cb_ael	ddsMenuFilePrintSelected
"Print All Pages..."		"Print all pages contained in this window"	dds_action_cb_ael	ddsMenuFilePrintAllPages		dds_menu_sens_cb_ael	ddsMenuFilePrintAllPages

#
# NOTE: The menu seperator at the bottom of this file is used to identify
#       the boundary between the recent data displays menu picks and the
#       end of the menu. If you add menu picks to this menu resource file
#       alway place a seperator at the end of the file. If it is removed 
#       the menu picks to the next menu seperator will be removed when 
#       the recent files are updated.
#

---

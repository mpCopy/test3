# @(#) $Source: /cvs/sr/src/dds/config/viewmenu.res,v $ $Revision: 1.13 $ $Date: 2011/08/24 21:10:35 $ 

"&View"					"Change the window view"	T
"&View All	F"		"Zoom to view the entire drawing area"		dds_action_cb_ael		ddsToolZoomAll			dds_menu_sens_cb_ael	ddsToolZoomAll
"Redraw View"		"Redraw the window"		dds_action_cb_ael		ddsMenuViewRedrawView		dds_menu_sens_cb_ael		ddsMenuViewRedrawView
-----
"Calculate	C"		"Calculate object"					dds_action_cb_ael	ddsMenuViewCalculateObject					dds_menu_sens_cb_ael		ddsMenuViewCalculateObject
-----
>zoomview.res
-----
"Restore Last View	Ctrl+L"		"Undo the last view command"		dds_action_cb_ael		ddsRestoreLastView		dds_menu_sens_cb_ael		ddsRestoreLastView
-----
"Save Named View..."		"Save the current view as a named view"		dds_action_cb_ael		ddsSaveNamedView		dds_menu_sens_cb_ael		ddsSaveNamedView
"Restore Named View..."		"Restore a previously saved named view"		dds_action_cb_ael		ddsRestoreNamedView		dds_menu_sens_cb_ael		ddsRestoreNamedView
"Delete Named View..."		"Delete a named view"		dds_action_cb_ael		ddsDeleteNamedView		dds_menu_sens_cb_ael		ddsDeleteNamedView

-----
>scrlmenu.res
>zoommenu.res
-----
"^All Tool&bars"				"Toggle toolbar display"					dds_toolbar_mode_cb		0						dds_toolbar_mode_ui		0
"^It&em Palette"		"Toggle palette display"					dds_palette_mode_cb		0						dds_palette_mode_ui		0
-----
"^&Grid Display	Ctrl+G"	"Toggle Grid Display"	dds_grid_on_cb	ddsMenuEditPreferences		dds_grid_on_sens_cb		ddsMenuEditPreferences

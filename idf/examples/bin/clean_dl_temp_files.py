#!/usr/bin/env python
###############################################################################
# THERE IS NO WARRANTY OR SUPPORT ASSOCIATED WITH THIS EXPERIMENTAL PROGRAM!
###############################################################################
#
# File:         clean_dl_temp_files.py
# Description:  Removes *.nodes and *.params created by spectre_nodes.py
# Created:      Thu Jan 15 11:11:11 PST 2014
# Modified: 
# Language:     Python
# Package:      N/A
# Status:       Experimental (Do Not Distribute)
#
###############################################################################
#

import glob
import os

delimiter=os.path.sep
dlNodesFiles=glob.glob('.DL' + delimiter + '*.nodes')
dlParamsFiles=glob.glob('.DL' + delimiter + '*.params')
nodesFiles=glob.glob('*.scs.nodes')
paramsFiles=glob.glob('*.scs.params')

for file in dlNodesFiles + dlParamsFiles + nodesFiles + paramsFiles:
    os.remove( file )

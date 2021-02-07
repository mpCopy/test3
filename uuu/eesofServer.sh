#! /bin/sh
# Copyright Keysight Technologies 2010 - 2016  
# @(#) $Source$ $Revision: 9647 $ $Date: 2011-08-28 13:27:57 -0700 (Sun, 28 Aug 2011) $

#
# This script launches the emds_viewer using the fem install directory
#

usage="
Usage: $0 <FEM_INSTALL_DIRECTOY> <GeometryFile> <Server> <MOM|FEM>"

if [ $# -lt 4 ]; then
    echo $usage
    exit 0
fi

femDir=$1
projectName=$2
serverName=$3
projectType=$4
if [ $# -eq 5 ]; then
	projectDir=$5
fi

if [ ! -d $femDir ] ; then
    echo $femDir : not a directory
    echo $usage
    exit 0
fi



echo "Linux Execution"

viewer_path=$femDir/emds_viewer
export LD_LIBRARY_PATH=$femDir:$LD_LIBRARY_PATH
export HOOPS_PICTURE=X11/$DISPLAY
export PATH=$femDir:$PATH

if [ -n "$QT_PLUGIN_PATH" ] && [ "$EMPRO_PRESERVE_QT_PLUGIN_PATH" != "TRUE" ]; then
  if [ "$EMPRO_PRESERVE_QT_PLUGIN_PATH" != "FALSE" ]; then
    echo "unsetting QT_PLUGIN_PATH (use EMPRO_PRESERVE_QT_PLUGIN_PATH=TRUE/FALSE to control)"
  fi
  unset QT_PLUGIN_PATH
fi

if [ $projectType = "MOM" ]; then
	if [ $# -eq 5 ]; then
		viewer_opts="--server $serverName --mom --project $projectName --project_dir $projectDir"
	else
		viewer_opts="--server $serverName --mom --project $projectName"
	fi
    
else
	if [ $# -eq 5 ]; then
		viewer_opts="--server $serverName --project $projectName --project_dir $projectDir"
	else
		viewer_opts="--server $serverName --project $projectName"
	fi
    

fi

echo $viewer_path
echo $viewer_opts

$viewer_path $viewer_opts &




exit 0




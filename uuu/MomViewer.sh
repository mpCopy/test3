#! /bin/sh
# Copyright Keysight Technologies 2010 - 2015  
# @(#) $Source$ $Revision: 10892 $ $Date: 2012-08-24 01:26:52 -0700 (Fri, 24 Aug 2012) $

#
# This script launches the emds_viewer using the fem install directory
#

usage="
Usage: $0 <GeometryFile> <solution> "

if [ $# -lt 1  ]
  then
    echo $usage
    exit 0
fi

echo ""
echo "Launching 3D Viewer"

projectName=$1

fem_arch="Linux32"
mosaic_fem_arch="linux_x86_32"

if [ $SIMARCH = "linux_x86_64" ]
    then
    fem_arch="Linux64"
    mosaic_fem_arch="linux_x86_64"
fi

if [ $SIMARCH = "sun_sparc_64" ]
    then
    fem_arch="Sun32"
    mosaic_fem_arch="sun_sparc_32"
fi

if [ $SIMARCH = "sun_sparc" ]
    then
    fem_arch="Sun32"
    mosaic_fem_arch="sun_sparc_32"
fi

if [ -z "$HPEESOF_DIR" ]
 then
  echo "The HPEESOF_DIR environment variable must be set to find the FEM component"
  exit 1
fi

mosaic_fem_path=`menv getRefvalue --name fem --product_root ${HPEESOF_DIR}`
if [ -d $mosaic_fem_path ]
then
  echo "FEM component: $mosaic_fem_path"
else
  echo "The FEM component could not be located."
  exit 1
fi

fem_path=$mosaic_fem_path/$mosaic_fem_arch/bin
echo "FEM path:" $fem_path

viewer_path=$fem_path/emds_viewer
export LD_LIBRARY_PATH=$fem_path:$LD_LIBRARY_PATH
export HOOPS_PICTURE=X11/$DISPLAY
export PATH=$fem_path:$PATH

if [ -n "$QT_PLUGIN_PATH" ] && [ "$EMPRO_PRESERVE_QT_PLUGIN_PATH" != "TRUE" ]; then
  if [ "$EMPRO_PRESERVE_QT_PLUGIN_PATH" != "FALSE" ]; then
    echo "unsetting QT_PLUGIN_PATH (use EMPRO_PRESERVE_QT_PLUGIN_PATH=TRUE/FALSE to control)"
  fi
  unset QT_PLUGIN_PATH
fi

if [ $# -eq 2 ]
then
    echo "Results for:" $projectName
    viewer_opts="--project_load $projectName --solution"
else
    echo "Preview for:" $projectName
    viewer_opts="--project_load $projectName"
fi

$viewer_path $viewer_opts --mom &

exit 0




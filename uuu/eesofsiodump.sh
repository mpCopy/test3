#!/bin/ksh
# Copyright Keysight Technologies 2009 - 2018  

USAGE="Usage:\n  eesofsiodump <SMatrixIO file>\n"

if [ "X$HPEESOF_DIR" = "X" ]
then
    echo "HPEESOF_DIR should be set for eesofsiodump.sh"
    exit 1
fi

PATH=$HPEESOF_DIR/bin:$PATH

. sim-bootscript.sh

siodump "$@"

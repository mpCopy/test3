#!/bin/ksh
# THERE IS NO WARRANTY OR SUPPORT ASSOCIATED WITH THIS EXPERIMENTAL PROGRAM!
# 12/18/2014
# Flatten HSPICE model files included by HCCW

. $HPEESOF_DIR/bin/bootscript.sh

if [ $# != 1 -o ! -f "$1" ]; then
    echo "ERROR: An argument is required and it must be a filename of ADS or HSPICE netlist!"
    exit
fi

idx=1
out="test${idx}.ads"
while [ -f "${out}" ]; do
    idx=`expr $idx + 1`
    out="test${idx}.ads"
done

$HPEESOF_DIR/tools/linux_x86_64/bin/python $HPEESOF_DIR/circuit/python/encrypt_spice.pyc -f -s $1 -o $out

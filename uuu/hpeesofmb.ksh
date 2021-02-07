#!/bin/sh
# Copyright  1998 - 2017 Keysight Technologies, Inc  
# Set up ADS Ptolemy modelbuilder under MKS
if [ -z "$HPEESOF_DIR" ] ; then
    echo "Error!  HPEESOF_DIR is not set." 1>&2
    exit 1
fi
PATH="$HPEESOF_DIR/bin:$HPEESOF_DIR/tools/bin:$PATH"
export ARCH=win32
export MAKE_MODE=unix
export CEDA_SITE=gent
unset ENV
bash $HPEESOF_DIR/adsptolemy/bin/hpeesofmb "$@"

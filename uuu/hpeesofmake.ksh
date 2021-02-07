#!/bin/sh
# Copyright Keysight Technologies 2017 - 2017  
# MKS ksh wrapper for hpeesofmake
if [ -z "$HPEESOF_DIR" ] ; then
    echo "Error!  HPEESOF_DIR is not set." 1>&2
    exit 1
fi

if [ "$HMAKE_EPATH" = "1" ]
then
 PATH="/bin;c:/cygwin/bin;$HPEESOF_DIR/bin;$HPEESOF_DIR/tools/perl/bin;$HPEESOF_DIR/tools/bin;$PATH"
else
  PATH="$HPEESOF_DIR/bin;$HPEESOF_DIR/tools/perl/bin;$HPEESOF_DIR/tools/bin;$PATH"
fi 
export PATH
export ARCH=win32
export MAKE_MODE=unix
export CEDA_SITE=gent
unset ENV
sh -c "make MAKE=make $*"

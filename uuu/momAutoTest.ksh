#!/bin/ksh
# Copyright Keysight Technologies 2000 - 2012  

echo "========= Momentum AutoTest =============================="
echo ""
echo "..Momentum AutoTest Started"


# --- check the ADS product installation ---------------------------------------

if [ -z "$HPEESOF_DIR" ] ; then
    echo "..HPEESOF_DIR not defined ???"
else
    echo "..HPEESOF_DIR = "$HPEESOF_DIR" "
fi

# --- check the HOME account ---------------------------------------------------

if [ -z "$HOME" ] ; then
    echo "..HOME not defined ???"
else
    echo "..HOME = "$HOME" "
fi

# --- copy the autoTest_prj ----------------------------------------------------

cp -rf $HPEESOF_DIR/em/test/autoTest_prj $HOME/hpeesof/.

# --- run the ADS bootscript ---------------------------------------------------

uname=`uname`

if [ "$uname" = "HP-UX" ] ; then
    echo "..System: HP-UX "
    . bootscript.sh 
fi

if [ "$uname" = "SunOS" ] ; then
    echo "..System: SunOS "
    . bootscript.sh 
fi

if [ "$uname" = "Linux" ] ; then
    echo "..System: Linux "
    . bootscript.sh 
fi

if [ "$uname" = "AIX" ] ; then
    echo "..System: AIX "
    . bootscript.sh 
fi

# --- start the GEMX daemon and the momServer ----------------------------------

# echo "..Gemx log file:     ./momGemx.log "
echo "..Server log file:   ./momServer.log "
echo "..AutoTest log file: ./momAutoTest.log "
echo "..Momentum AutoTest in progress... "
# hpeesofemx -d momGemx.log momServer -autoTest
hpeesofemx momServer -autoTest


echo "..Momentum AutoTest Completed"
echo ""
echo "=========================================================="

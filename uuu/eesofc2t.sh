#!/bin/ksh
# Copyright Keysight Technologies 2009 - 2011  

USAGE="Usage:\n  eesofc2t.sh <iCitifile> <oTouchstonefile>\n"

if [ "X$HPEESOF_DIR" = "X" ]
then
    echo "HPEESOF_DIR should be set for eesofc2t.sh"
    exit 1
fi

PATH=$HPEESOF_DIR/bin:$PATH

. sim-bootscript.sh

PARSEARG=$#

while [ $PARSEARG -gt 0 ]
do
  PARSEARG=0
  if [ "$1" = "-t" ]
  then
    shift
    PARSEARG=$#
  fi
done

TMPDATASET="/tmp/eesoft$$_imds.ds"

INPUT_TYPE="citifile"
OUTPUT_TYPE="touchstone"
OUTPUT_FORMAT="RI"

INPUT_FILE=$1
OUTPUT_FILE=$2

if [ "X$INPUT_FILE" = "X" ]
then
    echo "\nError: No input file given\n";
    echo "$USAGE"
    exit 1;
fi

if [ ! -f $INPUT_FILE ]
then
    echo "\nError: No such input file: $INPUT_FILE";
    exit 1;
fi

if [ "X$OUTPUT_FILE" = "X" ]
then
    echo "\nError: No output file given\n";
    echo "$USAGE"
    exit 1;
fi

touch $OUTPUT_FILE
if [ $? != 0 ]
then
    echo "\nError: Cannot create output file: $OUTPUT_FILE\n";
    exit 1;
fi

ds_import $INPUT_FILE -t $INPUT_TYPE -d $TMPDATASET
#if [ $? != 0 ]
#then
#    echo "\nError: Could not create indermediary dataset: $TMPDATASET\n";
#    exit 1;
#fi

ds_export $OUTPUT_FILE -t $OUTPUT_TYPE -f $OUTPUT_FORMAT -d $TMPDATASET
#if [ $? != 0 ]
#then
#    echo "\nError: Could not create indermediary dataset: $TMPDATASET\n";
#    exit 1;
#fi

rm -rf $TMPDATASET
if [ $? != 0 ]
then
    echo "\nWarning: Could not remove tmp dataset: $TMPDATASET\n";
    exit 1;
fi
exit 0

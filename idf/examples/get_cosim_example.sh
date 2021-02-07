#!/bin/sh

if [ "${HPEESOF_DIR}" = "" ]; then
  echo "Please set HPEESOF_DIR and add \$HPEESOF_DIR/bin to your PATH and try again."
  exit
elif [ ! -d ${HPEESOF_DIR}/idf/examples/examples_wrk/examples_lib ]; then
  echo "Dynamic Link examples not found. Please check your installation and try again."
  exit
elif [ ! -w ./ ]; then
  chmod -R u+w .
  rc=$?
  if [ ${rc} -ne 0 ]; then
    echo "Current working directory is not writable. Please check file permission and try again."
    exit
  fi
fi


echo "Making a copy of the ADS RectifierCosim_wrk example workspace ..."
$HPEESOF_DIR/bin/7z x -y -o`pwd` $HPEESOF_DIR/examples/Com_Sys/RectifierCosim_wrk.7zap
chmod ugo+rx -R RectifierCosim_wrk

echo "Adding rct_env_cadence ADS design to the RectifierCosim_wrk ..."
cp -r $HPEESOF_DIR/idf/examples/examples_wrk/examples_lib/rct_env_cadence RectifierCosim_wrk/RectifierCosim_lib/

echo "Adding diodem2.* model files to the RectifierCosim_wrk ..."
cp $HPEESOF_DIR/idf/examples/models/diodem2.* RectifierCosim_wrk/

echo "
The RectifierCosim_wrk has been copied to your working directory.
An ADS design, rct_env_cadence, and an ADS model, diodem2.ads, 
have been added for demonstrating cosimulation via Dynamic Link.
Follow the steps below to run a cosimulation with this example:

 - Start Cadence virtuoso, icms or msfb. 
 - Open the Dynamic Link sample cellview examples/rct/schematic.
 - Start ADS by selecting \"Launch>ADS Dynamic Link\"
   in the rct schematic window.
 - Open the local RectifierCosim_wrk from ADS Main window.
 - Open rct_env_cadence design. Choose 
       \"DynamicLink>Instance>Add Instance of Cellview\" 
   to place the examples_rct_schematic design between the two ports.
 - Add a NetlistInclude component to the rct_env_cadence design by choosing 
       \"DynamicLink> Add Netlist File Include\" 
 - Double click the NetlistInclude component and then add the 
   \"diodem2.scs\" model file to the \"Include Files\" parameter.
 - Replace the rct_Env subcircuit component with rct_env_cadence in the 
   RectifierCx design.
 - Choose Simulate>Simulate in the ADS schematic window of RectifierCx to 
   simulate the design in ADS.

Simulation result of the modified RectifierCx design with rct_env_cadence 
subcircuit should be identical with that of the original RectifierCx design, 
where rct_Env subcircuit was included.

"


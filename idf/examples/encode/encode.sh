#!/bin/ksh
#     

echo "Generating ADSlibconfig ..."
echo "dl_lib `pwd`/dl_lib.library" > ADSlibconfig

rm -f dl_lib.library 2>/dev/null
. eesofboot.sh

echo "Encoding netlist file encrypted_power_amp_with_models_dl_lib as dl_lib.library based on configurations set up in library.cfg and ADSlibconfig ... "
hpeesofencode 

if [ -f "dl_lib.library" -a ! -z "dl_lib.library" ]; then
    if [ -f $HOME/hpeesof/circuit/config/ADSlibconfig ]; then
        tmpFile=/tmp/$$.out
        cat $HOME/hpeesof/circuit/config/ADSlibconfig | grep -v "dl_lib.library" > $tmpFile
        cat ADSlibconfig >> $tmpFile
        mv -f $tmpFile $HOME/hpeesof/circuit/config/ADSlibconfig
    else
        if [ ! -d $HOME/hpeesof/circuit/config ]; then
            mkdir -p $HOME/hpeesof/circuit/config
        fi
        cp ADSlibconfig $HOME/hpeesof/circuit/config/ADSlibconfig
    fi
else
    echo "ERROR: failed to create dl_lib.library!"
fi

#!/bin/ksh
# Copyright Keysight Technologies 2000 - 2011  

#---?--------------------------------------------------------------------

if [ $# = 0 ] ; then
    echo 
    echo $0 commands are:
    echo "    start  <lib_name>     start Model Composer"
    echo "    status <lib_name>     display Model Composer status file"
    echo "    skip   <lib_name>     skip current component (asap)"
    echo "    stop   <lib_name>     stop Model Composer (asap)"
    echo "    kill                  kill Model Composer immediately"
    echo "    rm     <lib_name>     remove Model Composer build directory"
    echo "    zip    <lib_name>     zip Model Composer library"
    echo 
    exit
fi

if [ $1 = "?"  -o  $1 = "help" ] ; then
    echo 
    echo $0 commands are:
    echo "    start  <lib_name>     start Model Composer"
    echo "    status <lib_name>     display Model Composer status file"
    echo "    skip   <lib_name>     skip current component (asap)"
    echo "    stop   <lib_name>     stop Model Composer (asap)"
    echo "    kill                  kill Model Composer immediately"
    echo "    rm     <lib_name>     remove Model Composer build directory"
    echo "    zip    <lib_name>     zip Model Composer library"
    echo 
    exit
fi

#---start----------------------------------------------------------------

if [ $# = 2  -a  $1 = "start" ] ; then
    echo 
    echo "start Model Composer (library: $2)"

    if [ `uname` = "Windows_NT" ] 
        then
            #hpeesofemx -d $HOME\\gemx.log libserver -path $HOME\\hpeesof\\pmlg\\libraries\\$2\\ -name library.def
            hpeesofemx libserver -path $HOME\\hpeesof\\pmlg\\libraries\\$2\\ -name library.def
        else
            if [ -z "$COMPL_DIR" ] ; then
                export COMPL_DIR="$HPEESOF_DIR"
            fi

            if [ `uname` != "AIX" ] ; then
                if [ -z "$XNLSPATH" ] ; then
                    export XNLSPATH="$HPEESOF_DIR/lapi/lib/nls"
                else
                    export XNLSPATH="$XNLSPATH:$HPEESOF_DIR/lapi/lib/nls"
                fi
            fi

            . bootscript.sh 

            #hpeesofemx -d $HOME/gemx.log libserver -path $HOME/hpeesof/pmlg/libraries/$2/ -name library.def &
            hpeesofemx libserver -path $HOME/hpeesof/pmlg/libraries/$2/ -name library.def &
    fi
    exit
fi

#---status---------------------------------------------------------------

if [ $# = 2  -a  $1 = "status" ] ; then
    echo 
    echo "display Model Composer status file (library: $2)"
    
    if [ `uname` = "Windows_NT" ] 
        then
            tail -f -b 100 $HOME\\hpeesof\\pmlg\\libraries\\$2\\library.sta
        else
            tail -f -b 100 $HOME/hpeesof/pmlg/libraries/$2/library.sta
    fi
    exit
fi

#---skip-----------------------------------------------------------------

if [ $# = 2  -a  $1 = "skip" ] ; then
    echo 
    echo "skip current component asap (library: $2)"
    
    if [ `uname` = "Windows_NT" ] 
        then
            skiplib="$HOME\\hpeesof\\pmlg\\libraries\\$2\\skip.cmd"
        else
            skiplib="$HOME/hpeesof/pmlg/libraries/$2/skip.cmd"
    fi
    
    #echo "touch $skiplib"
    touch $skiplib
    exit
fi

#---stop-----------------------------------------------------------------

if [ $# = 2  -a  $1 = "stop" ] ; then
    echo 
    echo "stop Model Composer asap (library: $2)"

    if [ `uname` = "Windows_NT" ] 
        then
            killlib="$HOME\\hpeesof\\pmlg\\libraries\\$2\\kill.cmd"
        else
            killlib="$HOME/hpeesof/pmlg/libraries/$2/kill.cmd"
    fi

    #echo "touch $killlib"
    touch $killlib
    exit
fi

#---kill-----------------------------------------------------------------

if [ $1 = "kill" ] ; then
    echo
    echo "kill Model Composer immediately"


    if [ `uname` = "AIX" ] ; then
      killers=`ps  | grep libserver | awk '{ print $2 }'`
    else
     if [ `uname` = "Windows_NT" ]
       then
        killers=`ps -elf | grep libserver.exe  | awk '{ print $2 }'`
       else
        #ps  | grep libserver | awk '{print $1}' | xargs kill
        killers=`ps -ef | grep libserver | awk '{ print $1 }'`
      fi
    fi
    #echo $killers
    
    for mkill in $killers ; do
      if [ $mkill != $$ -a $mkill != PID ] ; then
        kill -9 $mkill
      fi
    done

    if [ `uname` = "Windows_NT" ]
    then
      killers=`ps -elf | grep libserver  | awk '{ print $2 }'`
      #echo $killers
      for mkill in $killers ; do
        if [ $mkill != $$ -a $mkill != PID ] ; then
          kill -9 $mkill
        fi
      done
    fi
    
    exit
fi

#---rm-------------------------------------------------------------------

if [ $# = 2  -a  $1 = "rm" ] ; then
    echo
    echo "remove Model Composer build directory (library: $2)"
    
    if [ `uname` = "Windows_NT" ] 
        then
            removefile="$HOME\\hpeesof\\pmlg\\build\\$2"
        else
            removefile="$HOME/hpeesof/pmlg/build/$2"
    fi
    
    #echo "remove directory $removefile"
    rm -rf $removefile
    exit
fi

#---zip------------------------------------------------------------------

if [ $# = 2  -a  $1 = "zip" ] ; then
    echo
    echo "zip Model Composer library (zip file: $2.zip)"
    
    if [ `uname` = "Windows_NT" ] 
        then
            ziplib="$HOME\\hpeesof\\pmlg\\libraries\\$2"
        else
            ziplib="$HOME/hpeesof/pmlg/libraries/$2"
    fi
    
    #echo "zip directory $ziplib"
    zip -r $2 $ziplib
    exit
fi


#---lib------------------------------------------------------------------

if [ $# = 2  -a  $1 = "lib" ] ; then
    echo
    echo "make Model Composer idf library file"
    
    if [ `uname` = "Windows_NT" ] 
        then
            dklib="$HOME\\hpeesof\\pmlg\\libraries\\$2\\circuit\\records\\$2"
        else
            dklib="$HOME/hpeesof/pmlg/libraries/$2/circuit/records/$2"
    fi
    
    #echo "hpedlibgen -list $2_ael.lst -out $2.idf"
    hpedlibgen -list "$dklib"_ael.lst -out "$dklib".idf 
    exit
fi

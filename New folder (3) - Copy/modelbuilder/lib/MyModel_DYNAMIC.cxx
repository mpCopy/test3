// Copyright Keysight Technologies 2008 - 2011  
/******************************************************************
#
# If you run UserCompiled Model from ADS, please ignore this file,
# since ADS autogenerates this file for you according your setting.
#
# This file is an example to show how to construct the file 
# *_DYNAMIC.cxx when you want to create a user-compiled dynamic link 
# library from the command line. 
# 
# If you name this file as MyModel_DYNAMIC.cxx, please add (or 
# specify) the variable in modelbuilder.mak as
#   CUI_CPLUS_DYNAMIC = MyModel_DYNAMIC.cxx
# and
#   TARGET_DYNAMIC_LIB = MyModel  ( or whatever you want to name your
#                                   library)
# !!! Do not use this file as it is. !!!
# !!! This file is an example only, and must be modified. !!!
# 
*******************************************************************/

#include "device_installer.hxx"

extern "C" {
#include "string.h"
}

/* Define model names here  */
static char     *devices[] = {
    "MyModel1",
    "MyModel2",
    /*......     !!! Add as many models as you want here. !!! */
    NULL
};

/* There is no need to modify this function */
extern  "C" int sim_query_info (
    const char       *const command,
    void             **data
    )
{
    int              status;

    *data = NULL;
    status = 1;
    if ( strcmp(command,"deviceNames") == 0)
    {
        *data = (void **) devices;
        status = 0;
    }
    return (status);
}

/* Add model loading function calls here */
/* !!! for each model, declare boot_senior_*() !!! */
extern "C" int boot_senior_MyModel1 (void);
extern "C" int boot_senior_MyModel2 (void);
/* ......  */

static int install_all_senior_devices(void)
{
    static int called=0;
    int    status = 0;

    if( !called)
    {
        called=1;

        /* !!! for each model , add this if loop !!! */
        if (!boot_senior_MyModel1() )
            status = 1;
        if (!boot_senior_MyModel2() )
            status = 1;
        /* ...... */

    }
    return status; 
}
 
/* !!! for each model, add MyModel_device call !!! */

DeviceInstaller MyModel1_device("MyModel1",install_all_senior_devices, DEVICE_INSTALLER_VERSION);
DeviceInstaller MyModel2_device("MyModel2",install_all_senior_devices, DEVICE_INSTALLER_VERSION);
/* ...... */

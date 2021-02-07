// Copyright Keysight Technologies 2002 - 2011  
/************************************************************
# This file is auto_generated by the User-Compiled Model.
# Please DO NOT try to modify this file!!!
************************************************************/

#include "device_installer.hxx"

extern "C" {
#include "string.h"
}

static char     *devices[] = {
    "U2PA",
    NULL
};

extern  "C" int sim_query_info (
    const char       *const command,
    void             **data
    )
{
    int              status;

    *data = NULL;
    status = 1;
    if ( strcmp( command, "deviceNames" ) == 0 )
    {
        *data = (void **) devices;
        status = 0;
    }
    return ( status );
}


int boot_senior_U2PA( void );

static int install_all_senior_devices( void )
{
    static int called = 0;
    if( !called )
    {
        called = 1;
        if ( !boot_senior_U2PA( ) )
        {
            return ( 1 );
        }
    }
    return ( 0 ); 
}
 
DeviceInstaller U2PA_device( "U2PA", install_all_senior_devices, DEVICE_INSTALLER_VERSION );

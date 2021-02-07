/* -*-C++-*-
*******************************************************************************
*
* File:         device_installer.hxx
* RCS:          $Header: /cvs/sr/src/gemini/source/admin/device_installer.hxx,v 100.19 2011/08/27 00:17:53 build Exp $
* Description:  
* Author:       Darryl Okahata
* Created:      Thu Apr 12 10:31:11 2001
* Modified:     Mon Oct 20 15:03:45 2008 (Darryl Okahata) darrylo@soco.keysight.com
* Language:     C++
* Package:      N/A
* Status:       Released
*
// Copyright Keysight Technologies 2001 - 2014  
*
*******************************************************************************
*/

#ifndef DEVICE_INSTALLER_HXX_INCLUDED
#define DEVICE_INSTALLER_HXX_INCLUDED
// Copyright Keysight Technologies 2001 - 2014  

#ifdef ADSVERSION_OVERRIDE
# include "adsoverride.h"
#endif	/* ADSVERSION_OVERRIDE */

#include "hpeesofsim_api.h"

#if !defined(ADSSIM_VERSION)
# define ADSSIM_VERSION		(VER)
#endif

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*
 * This defines the version of the device installer.
 *
 * Typically, this version number gets bumped whenever the internal
 * DeviceDescriptor structure changes, and is used by the DeviceInstaller
 * class to detect when a newer dynamically-linked device is loaded into an
 * older simulator, or when the device is too old to be loaded.
 *
 * However, for windows-based systems, we also bump this number every time the
 * compiler changes, because of different runtime DLLs.  Because of this, the
 * windows version number no longer tracks the version number of the
 * non-windows API.
 */
#if defined(_WIN32)
# if 1
/*
 * This nasty piece of work is only temporary, and only exists until 2009UR1
 * (this code will be turned off/deleted for the 2009UR1 release).
 */
#  undef DEVICE_INSTALLER_VERSION
#  define DEVICE_INSTALLER_VERSION		1
# else
/*
 * For windows: We bump this number as necessary (see next comment):
 */
# define DEVICE_INSTALLER_VERSION_WIN32		2
/*
 * However, the actual number also depends upon the compiler version.
 * Note that we're only using the compiler major version number; we're
 * ignoring the minor version number, because we don't want compiler
 * patches to affect this.  If it should come to pass that a compiler
 * patch affects the runtime, we'll just bump the above
 * DEVICE_INSTALLER_VERSION_WIN32 number.
 *
 * Currently, "_MSC_VER / 100":
 *	14 -> Visual Studio .net 2005
 *	15 -> Visual Studio .net 2008
 */
# define DEVICE_INSTALLER_VERSION		\
    (((((int)_MSC_VER)/100) * 1000) + (DEVICE_INSTALLER_VERSION_WIN32))
# endif	/* temporary code */

#else	/* !_WIN32 */
/*
 * For Unix: This gets bumped only when the data structures change, when
 * the API changes, or when the glibc library filename changes.  We
 * don't necesssarily have to change this with compiler changes.
 */
# define DEVICE_INSTALLER_VERSION		1	/* Unix */
#endif	/* !_WIN32 */

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/

struct DeviceDescriptor;


struct DeviceDescriptorInfo {
    char		**device_names;
    int			next_device_name;
    int			device_names_size;
};


class HPEESOFSIM_API DeviceInstaller
{
private:
    static bool		device_installed;

public:
    DeviceInstaller(const char * const name,
		    int (*func)(void),
		    const int version);
    DeviceInstaller(const bool replace_device,
		    const DeviceDescriptor * const descriptor,
		    const int version);
    DeviceInstaller(const char * const simulator_version,
		    const int version,
		    const char * const name,
		    int (*func)(void));
    DeviceInstaller(const char * const simulator_version,
		    const int version,
		    const DeviceDescriptor * const descriptor,
		    bool (*init)(void *data), bool (*cleanup)(void *data),
		    void *data, struct DeviceDescriptorInfo * const info,
		    const bool replace_device);

    static void reset_install_flag(void)
	{
	    device_installed = false;
	}

    static bool device_was_installed(void)
	{
	    return device_installed;
	}
};


extern void KLUDGE_set_disallow_bad_devices_flag(bool new_setting);


#endif	/* DEVICE_INSTALLER_HXX_INCLUDED */

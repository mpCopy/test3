#ifndef LICENSE_H_INCLUDE
#define LICENSE_H_INCLUDE
// Copyright Keysight Technologies 1998 - 2014  

#ifdef __GNUG__
#pragma interface
#endif


#include "Block.h"

/**
   

   @author Jose Luis Pino
 */
class License: public Block {
public:
  /// Constructor
  License(int progID, const char* progName, const char* progVersion = NULL);

  /// For a given block, checkOut a license if necessary
  int lock(Block&);
  
  /// For a given block, checkIn a license if necessary 
  static void unlock(Block&);

  /// Return the number of blocks refering to a license
  int referenceCount();

  /** Check out a license.  Return TRUE if license has been
      successfully checked out.  If the license is unavailable, call 
      Error::abortRun and display an appropriate error message.*/
  virtual int checkOut(Block& b) = 0;

  /** Check in a license, derived classes should call reference count
      to make sure that no other blocks are referring to the license.  */
  virtual void checkIn(Block& b) = 0;

};

/**
   

   @author Jose Luis Pino
 */
class HPEEsofLicense: public License {
public:
  ///
  HPEEsofLicense(int progID, const char* progName, const char* progVersion = NULL);

  ///
  /*virtual*/ int checkOut(Block& b);

  ///
  /*virtual*/ void checkIn(Block& b);

  enum SimulatorLicenseType{
    None,
    Designer,
    Designer_Pro
  };

  /// Return the type of simulator license
  static SimulatorLicenseType simulatorLicense();
};

/**
   A license for a HPEEsof Package

   @author Jose Luis Pino
 */
class HPEEsofPkgLicense: public HPEEsofLicense {
public:
  ///
  HPEEsofPkgLicense(int progID, const char* progName = NULL, const char* progVersion = NULL);
};


#endif

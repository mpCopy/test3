/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/NetlistName.h,v $ $Revision: 100.7 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef NETLISTNAME_H_INCLUDED
#define NETLISTNAME_H_INCLUDED
// Copyright Keysight Technologies 1998 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "StringList.h"
#include "miscFuncs.h"

/** An encoded Netlist name.

    Star names in netlists are encoded so that necessary information
    about the star can be passed to the simulator.  NetlistName
    encodes and decodes the netlist names.

    The name can be constructed from C++ with the four element ctor
    {\tt NetlistName (const char *vendor, const char *domain, const
    char *name, const char *library) }. Any character 0x01 to 0x7f is
    allowed in the vendor, domain, name, and library.  Optional star
    parameters can be added with the {\tt addParameter } method.<p>
    
    The name can also be constructed from the encoded from with the
    one element ctor {\tt NetlistName (const char *encodedname) }.
    The parts of the name can be read from the accessor methods.
    After decoding the name, the NetlistName is valid if and only the
    {\tt invalid } method returns zero.<p>

    The encoded netlist name is accessed with the encodedName method.
    The design name is accessed with the designName method.
*/

class Tokenizer;

class NetlistName
{
public:
  /// Construct a Netlist name from code.
  NetlistName (const char *vendor, const char *domain, 
	       const char *name, const char *library);
  
  /// Print design name
  StringList designName () const;
  
  /// Print encoded name.  The result can be read back in with the next
  /// constructor to create an identical NetlistName.
  StringList encodedName () const;

  /// Construct a NetlistName from an encoded string
  NetlistName (const char *encodedname);
  
  /// Print English description
  StringList englishDescription () const ;

  /// Add a flavor
  void addFlavor (const char *p) { myFlavorList << p; }

  /// Add a name parameter
  void addName (const char *p) { myNameList << p; }

  /// Add a port parameter
  void addPort (const char *p) { myPortList << p; }

  /// Add a state parameter
  void addState (const char *p) { myStateList << p; }

  /// Set the vendor
  void setVendor (const char *);

  /// Set the domain
  void setDomain (const char *);

  /// Set the name
  void setName (const char *);

  /// Set the library
  void setLibrary (const char *);

  /// Copy
  NetlistName (const NetlistName &);

  /// Assign
  const NetlistName& operator = (const NetlistName &);

  /// Destroy
  ~NetlistName ();

  /// Compare
  int operator == (const NetlistName &) const;
  static const char* matchAnything();
  
  /**@name Access to parts of name*/
  //@{
  /// The vendor
  const char* vendor () const { return myVendor; }

  /// The domain
  const char* domain () const { return myDomain; }

  /// The name
  const char* name () const { return myName; }

  /// The library
  const char* library () const { return myLibrary; }

  /// List of name parameters
  const StringList& nameList () const { return myNameList; }

  /// List of port parameters
  const StringList& portList () const { return myPortList; }

  /// List of state parameters
  const StringList& stateList () const { return myStateList; }

  //@}

  /* Access to errors.  Check after constructing a NetlistName from an
  encoded string. */
  int invalid () const { return errInvalid; }

private:
  StringList encodeString (const char *) const;
  char decodeChar (const char *);
  char* decodeString (Tokenizer &);
  void addParamater (char, const char *);
  int rxComp (const char *, const char *) const;
  int paramComp (const StringList &, const StringList &) const;
  char *safesavestring (const char *s) { return s ? savestring(s) : 0; }

  char *myVendor, *myDomain, *myName, *myLibrary;
  StringList myNameList, myStateList, myPortList, myFlavorList;
  int errInvalid, decodeTokenSize;
};


#endif

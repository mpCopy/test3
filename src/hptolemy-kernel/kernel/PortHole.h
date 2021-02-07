/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/PortHole.h,v $ $Revision: 100.44 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PORTHOLE_H_INCLUDED
#define PORTHOLE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

/* The Microsoft Visual C++ compiler defines far and near in WINDEF.H. 
   Unfortunately, this definition collides with the PortHole::far 
   method.  If you need to include WINDEF.H in your source file, do so
   before any of the Ptolemy headers.  Alternatively, you can also
   undefine the variable after WINDEF.H inclusion and redefine it 
   as far_p. Leaving it undefined will trigger a compile time error.*/

#ifdef WIN32
#ifdef far
#undef far
#define far far_p
#endif
#endif

	enum PortDirectionE
	{
		eOutputPort, eInputPort
	};


/**************************************************************************
UCB Version identification: PortHole.h	2.41	1/11/96

Copyright (c) 1990-1996 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

						PT_COPYRIGHT_VERSION_2
						COPYRIGHTENDKEY

 Programmer:  E. A. Lee and D. G. Messerschmitt, J. Buck
 Date of creation: 1/17/90

This file contains definitions relevant to connections.

A connection between Blocks consists of:

	OutPortHole---->Geodesic----->InPortHole
	    ^				  |
	    |				  |
	    -----------Plasma<-------------

This circular path carries a stream of Particles, where each
Particle is an envelope which contains a piece of data.

PortHole: A data member of a Star, it is where the stream of
	Particles enters or leaves a Star

Geodesic: The place where the Particles reside in transit
	between Stars.

Plasma: The place where Particles reside in transit back.
	Particles are re-used as a way to conserve memory.

By default, all connections with the same resolved DataType use
the same global Plasma.  This can be changed by overriding
the allocatePlasma function.  Replacing it with a call to
allocateLocalPlasma will use local Plasmas for each connection.

Particles: Defined in Particle.h

A MultiPortHole is a set of related portholes.

******************************************************************/
#ifdef __GNUG__
#pragma interface
#endif

#include "NamedObj.h"
#include "DataStruct.h"
#include "dataType.h"
#include "Particle.h"
#include "Attribute.h"
#include "type.h"
#include "FlagManager.h"
#include "ptolemyDll.h"

class CircularBuffer;
class Geodesic;
class Plasma;
class Block;
class Galaxy;
class EventHorizon;
class ToEventHorizon;
class FromEventHorizon;
class PtGate;
class ClusterPort;
class PortHole;
class MultiPortHole;
class ClusterPort;
class GenericPort;

/// A reserved flag for class GenericPort
class PortFlag:public Flag {
public:
  /// Constructors
  //@{
  ///
  PortFlag();
  ///
  PortFlag(PortFlag&);
  //@}

  /// 
  inline int& flag(GenericPort& b);
  /// 
  inline const int flag(const GenericPort& b) const;

private:
  FlagManager* myFlagManager();
  HPTOLEMY_KERNEL_API static FlagManager* portFlagManager;
};

/** Attribute bit for porthole, if TRUE the porthole is not
  visible to user interfaces */
const bitWord PB_HIDDEN = 1;

/** Attribute bit for porthole, if TRUE the porthole is optional */
const bitWord PB_OPTIONAL = 2;

/// Attribute to declare that a porthole is hidden
HPTOLEMY_KERNEL_API extern const Attribute P_HIDDEN; // make the porthole hidden

/// Attribute to declare that a porthole is visible (default)
HPTOLEMY_KERNEL_API extern const Attribute P_VISIBLE;// make the porthole visible.

/// Attribute to declare that a porthole is can be left unconnected
HPTOLEMY_KERNEL_API extern const Attribute P_OPTIONAL; // make the porthole optional

/// Attribute to declare that a porthole must be connected (default)
HPTOLEMY_KERNEL_API extern const Attribute P_REQUIRED;// make the porthole required

/** A base class that provides common elements between class PortHole
  and class MultiPortHole.  Any GenericPort object can be assumed to
  be either one or the other; we recommend avoiding deriving any new
  objects directly from GenericPort.

  GenericPort provides several basic facilities: aliases, which
  specify that another GenericPort should be used in place of this
  port, types, which specify the type of data to be moved by the port,
  and typePort, which specifies that this port has the same type as
  another port.  When a GenericPort is destroyed, any alias or
  typePort pointers are automatically cleaned up, so that other
  GenericPorts are never left with dangling pointers.  */
class GenericPort : public NamedObj {
  friend class PortFlag;
public:
  /// Return TRUE if PortHole is an input
  virtual int isItInput () const;

  /// Return TRUE if PortHole is an output
  virtual int isItOutput () const;

  /// Return TRUE if PortHole is a MultiPortHole
  virtual int isItMulti () const;

  /// Return a StringList describing the port
  /*virtual*/ StringList print (int verbose = 0) const;

  /** Return a reference to a porthole to be used for new connections.
    Class PortHole uses this one unchanged; MultiPortHole has to
    create a new member PortHole.  */
  virtual PortHole& newConnection();

  /** Return the real port after resolving any aliases.  If I have no
    alias, then a reference to myself is returned.  */
  GenericPort& realPort() {
    return *translateAliases();
  }

  /** Return the real port after resolving any aliases, const version */
  const GenericPort& realPort() const;
  
  /** Return the top level alias port, or myself if there are no from
      aliases */
  GenericPort& aliasPort();

  /** Return the top level alias port, or myself if there are no from
      aliases, const version */
  const GenericPort& aliasPort() const;

  /** Set the basic PortHole parameters: the name, parent, and data
    type */
  GenericPort& setPort(const char* portName, Block* blk, ADSPtolemy::DataType typ=ADSPtolemy::FLOAT) {
    setNameParent (portName, blk);
    myType = typ;
    return *this;
  }

  void setType( ADSPtolemy::DataType typ)
  {
	  myType = typ;
  }

  /** Set up a link for determining the type of {\tt ANYTYPE}
    connections.  this would be better named sameTypeAs().  */
  void inheritTypeFrom(GenericPort& p);

  /// Connect me with the indicated peer
  virtual void connect(GenericPort& destination,int numberDelays,
		       const char* initDelayValues = 0);

  /** Return my DataType.  This may be one of the DataType values
    associated with Particle classes, or the special type {\tt
    ANYTYPE}, which indicates that the type will be resolved by the
    {\tt setPlasma} function using information from connected ports
    and {\tt typePort} pointers.  */
  inline ADSPtolemy::DataType type () const { return myType;}

  /// class identification
  int isA(const char*) const;

  /** Return my alias, or a null pointer if I have no alias.
    Generally, Galaxy portholes have aliases and Star portholes do
    not, but this is not a strict requirement.  */
  inline GenericPort* alias() const { return aliasedTo;}

  /** Return the porthole that I am the alias for (a null pointer if
    none).  It is guaranteed that if {\tt gp} is a pointer to
    GenericPort and if {\tt gp->alias()} is non-null, then the boolean
    expression

    {\tt gp->alias()->aliasFrom() == gp}

    is always true.  */
  inline GenericPort* aliasFrom() const { return aliasedFrom;}

  /// Constructor
  GenericPort ();

  /// Destructor
  ~GenericPort();
	
  /** Return another generic port that is constrained to have the same
    type as me (0 if none).  If a non-null value is called, successive
    calls will form a circular linked list that always returns to its
    starting point; that is, the loop

    {\tt
    \begin{verbatim}
    void printLoop(GenericPort& g) {
    if (g->typePort()) {
    GenericPort* gp = g;
    while (gp->typePort() != g) {
    cout << gp->fullName() << "\back n";
    gp = gp->typePort();
    }
    }
    }
    \end{verbatim}}
    
    is guaranteed to terminate and not to dereference a null pointer.  */
  inline GenericPort* typePort() const { return typePortPtr;}

  /** Set gp to be my alias.  The aliasFrom pointer of gp is set to
    point to me.
  
    Public so that InterpGalaxy can set aliases.  Use with care, since
    derived types may want to restrict who can alias */
  void setAlias (GenericPort& gp);

  /** Return a reference to a porthole ready to connect to
    other portholes */
  virtual PortHole& newPort();

  /// Remove me from a chain of aliases
  void clearAliases();

  /** Ground the port by splicing it to BlackHole or Const, returns the
      created star */
  Block* ground();

  /** Connect to the given input port of a newly created star, returns
      the created star.  By default the domain will be the same as the
      port's galaxy (parent's parent). */
  Block* spliceStar(const char* starName, const char *portName,
		    const char *domainName = 0);

protected:

  /** Translate aliases, if any. If this method is called on a port
    with no alias, the address of the port itself is returned;
    otherwise, {\tt alias()->translateAliases()} is returned.  */
  GenericPort* translateAliases();

private:
  // Declared datatype of this porthole (may be ANYTYPE).
  // This is not necessarily what the connection will resolve to!
  ADSPtolemy::DataType myType;

  // PortHole this is aliased to
  GenericPort* aliasedTo;

  // Name of a PortHole that is aliased to me (a back-pointer)
  GenericPort* aliasedFrom;

  // My type matches type of this port.
  // If not NULL, typePort pointers form a circular loop.
  GenericPort* typePortPtr;

  // The FlagArray
  FlagArray portFlags;

};

/// Return TRUE if the port in question has the HIDDEN attribute
inline int hidden(const GenericPort& p) { 
  return (p.attributes() & PB_HIDDEN) != 0; 
}

/** Return TRUE if the port can legally be left disconnected.  All
    output portholes can be left disconnected, only input portholes
    that have been defined as P\_OPTIONAL can be left disconnected. */
inline int disconnectionAllowed(const GenericPort& p) { 
  return p.isItOutput() || (p.attributes() & PB_OPTIONAL);
}
/// A class used to store a list of PortHoles in a MultiPortHole
class PortList : private NamedObjList
{
  friend class PortListIter;
  friend class FastPortListIter;
  friend class CPortListIter;
public:
  /// Add PortHole to list
  inline void put(PortHole& p);

  /// Find a port with the given name and return pointer
  inline PortHole* portWithName(const char* name);

  /** Find a port with the given name and return pointer, const
    version */
  inline const PortHole* portWithName(const char* name) const;

  /// Remove a port
  inline int remove(PortHole* p);

  /// Return the number of ports on the port list
  using NamedObjList::size;

  /// Initialize the ports on the port list
  using NamedObjList::initElements;

  /// Delete the ports on the port list
  using NamedObjList::deleteAll;

  /// Empty the port list but do not delete the ports
  using NamedObjList::initialize;
};

/** An organized connection of related PortHoles.  Any number of
  PortHoles can be created within the PortHole; their names have the
  form {\tt mphname#1}, {\tt mphname#2}, etc., where {\tt mphname} is
  replaced by the name of the MultiPortHole.  When a PortHole is added
  to the MultiPortHole, it is also added to the porthole list of the
  Block that contains the MultiPortHole.  As a result, a Block that
  contains a MultiPortHole has, in effect, a configurable number of
  portholes.

  A pair of MultiPortHoles can be connected by a ``bus connection''.
  This technique creates {\tt n} PortHoles in each MultiPortHole and
  connects them all ``in parallel''.

  The MultiPortHole constructor sets the ``peer MPH'' to 0.  The
  destructor deletes any constituent PortHoles.  */
class MultiPortHole: public GenericPort
{
  friend class MPHIter;
  friend class CMPHIter;
  friend class PortHole;
public:

  /// Constructor
  MultiPortHole();

  /// Does nothing
  void initialize();

  /** Makes a bus connection with another multiporthole, {\tt peer},
    with width {\tt width} and delay {\tt delay}.  If there is an
    existing bus connection, it is changed as necessary; an existing
    bus connection may be widened, or, if connected to a different
    peer, all constituent portholes are deleted and a bus is made from
    scratch.  */
  void busConnect (MultiPortHole&, int width, int delay = 0,
		   const char* initDelayValues = 0);

  /// Return TRUE
  int isItMulti() const;

  /// Return TRUE if argument is ``MultiPortHole''
  int isA(const char*) const;

  /// Initialize a multiporthole
  MultiPortHole& setPort(const char* portName,
			 Block* parent,                // parent block pointer
			 ADSPtolemy::DataType type = ADSPtolemy::FLOAT);       // defaults to FLOAT
 
  /// Return the number of PortHoles in the MultiPortHole
  inline int numberPorts() const {return ports.size();}

  /// Add a new physical port to the MultiPortHole list
  /*virtual */ PortHole& newPort();

  /** Return a new port for connections.  If there is an unconnected
    porthole, return the first one; otherwise make a new one.  */
  virtual PortHole& newConnection();

  /// Return a StringList describing the MultiPortHole
  /*virtual*/ StringList print (int verbose = 0) const;

  /// Destructor
  ~MultiPortHole();

  /** Expand the given port (on the multiport list) to the given size.
      Return TRUE on success, FALSE on failure. */
  int expandPort(PortHole& portToExpand,int size);

protected:                           
  /// The list of portholes
  PortList ports;

  /** This function enerates names to be used for contained
    PortHoles.  They are saved in the hash table provided by the {\tt
    hashstring} function.  */
  const char* newName();

  /** This function adds a newly created port to the multiporthole.
    Derived MultiPortHole classes typically redefine {\tt newPort} to
    create a porthole of the appropriate type, and then use this
    function to register it and install it.  */
  virtual PortHole& installPort(PortHole& p);

  /// Set the parent multiporthole for a newly installed port
  void letMeKnownToChild(PortHole& p);

  /// Delete all contained portholes
  void delPorts();

private:

  /// peer multiporthole in a bus connection
  MultiPortHole* peerMPH;

  /// number of delays on portholes in a bus connection
  int numDelaysBus;

  /// inital values of delays in a bus connection, 3/2/94 added
  const char* initDelayValuesBus;
};


/** PortHole is the means that Blocks use to talk to each other.  It
  is derived from GenericPort; as such, it has a type, an optional
  alias, and is optionally a member of a ring of ports of the same
  type connected by {\tt typePort} pointers.  It guarantees that {\tt
  alias()} always returns a PortHole.

  In addition, a PortHole has a peer (another port that it is
  connected to, which is returned by {\tt far()}), a Geodesic (a path
  along which particles travel between the PortHole and its peer), and
  a Plasma (a pool of particles, all of the same type).  In simulation
  domains, during the execution of the simulation objects known as
  Particles traverse a circular path: from an output porthole through
  a Geodesic to an input porthole, and finally to a Plasma, where they
  are recirculated back to the input porthole.

  Like all NamedObj-derived objects, a PortHole has a parent Block.
  It may also be a member of a MultiPortHole, which is a logical group
  of PortHoles.  */

namespace ADSPtolemy {
const DataType Mark = "MARK";
}

class PortHole : public GenericPort
{
  friend class Geodesic;	        // allow Geodesic to access myPlasma
  friend class EventHorizon;	// access myBuffer
  friend class ToEventHorizon;	// access getParticle()
  friend class FromEventHorizon;	// access putParticle()
  friend class ClusterPort;
  friend class TypeConversion;

  // the following function may set indices
  friend int setPortIndices(Galaxy&);

  // the following function may set myMultiPortHole
  friend void MultiPortHole::letMeKnownToChild(PortHole&);

public:

  /** Construct a new porthole which is disconnected and nameless,
    without a parent */
  PortHole ();
	
  /// Destructor - disconnect and remove porthole from parent Block
  ~PortHole ();

  /// Set the name of the porthole, its parent, and its type
  PortHole& setPort(const char* portName,
		    Block* parent,                // parent block pointer
		    ADSPtolemy::DataType type = ADSPtolemy::FLOAT,	// defaults to FLOAT
		    int n = 1);			// number xferred

  /// Initialize the internal buffers in preparation for a run
  virtual void initialize();

  /** Remove a connection, and optionally attempt to delete the
    geodesic.  The is set to zero when the geodesic must be preserved
    for some reason (for example, from the Geodesic's destructor).
    The Geodesic is deleted only if it is ``temporary''; we do not
    delete ``persistent'' geodesics when we disconnect them.  */
  virtual void disconnect(int delGeo = 1);

  /// Return the PortHole we are connected to
  inline PortHole* far() const { return farSidePort;}

  /// Return a StringList describing the PortHole
  /*virtual*/ StringList print (int verbose = 0) const;

  /// Return myBuffer pointer
  CircularBuffer* getBuffer() { return myBuffer; }
  
  /// Return TRUE if argument is a ``PortHole''
  int isA(const char*) const;

  /** Return TRUE if this PortHole is at the wormhole boundary.  This
    is true if its peer is an inter-domain connection); FALSE
    otherwise.
	  
    Disconnected ports return TRUE, since we implement the old style
    of clusters (SDFCluster) that way (disconnected ports represent
    the cluster boundary).  */
  inline int atBoundary() const {
    return (farSidePort ? 
	    (isItInput() == farSidePort->isItInput()) : TRUE);
  }

  /** Return myself as an EventHorizon, if I am one.  The base class
    returns a null pointer.  EventHorizon objects (objects multiply
    inherited from EventHorizon and some type of PortHole) will
    redefine this appropriately.  */
  virtual EventHorizon* asEH();

  /// Return me as a ClusterPort
  virtual ClusterPort* asClusterPort();

  /// Does nothing - derived input ports redefine
  virtual void receiveData(); 

  /// Does nothing - derived output ports redefine
  virtual void sendData();

  /** Return a reference to a Particle in the PortHole's buffer.  A
    {\tt delay} value of 0 returns the ``newest'' particle.  In
    dataflow domains, the argument represents the delay associated
    with that particular particle.*/
  virtual Particle& operator % (int);

  /** Type Resolution.

      These routines are concerned with propagating type information
      around the porthole connection structure.  There are several
      considerations:
      \begin(enumerate) 
      \item We allow ports with different types to be connected
      together; the output porthole determines what particle type to
      use.
      \item ANYTYPE must be allowed and correctly resolved in three
      different cases:
      \begin(itemize)
      \item Printer and similar polymorphic stars, which accept any
      input type.
      \item Fork and similar stars, which want to bind multiple
      outputs to the type of a given input.
      \item Merge and similar stars, which want to resolve the type of
      a single output to the common type of several inputs, if
      possible.  (If there is no common input type, we use the type of
      the destination port, or declare error if the destination port
      has indeterminate type.)
      \end(itemize)
      typePort() linkages are used to bind ports together for ANYTYPE
      resolution.
      \item We have to recursively propagate type info in order to
      deal with chains of ANYTYPE stars.
      \item Wormhole boundaries need special treatment since far()
      doesn't link to the actual far end porthole, only the near side
      of the event horizon.  We have to propagate type info all the
      way through.
      \end(enumerate) 

      In Ptolemy 0.6 and earlier, the members of a multiporthole were
      always constrained to have the same type.  This is no longer
      true, since it gets in the way for polymorphic stars.  But if a
      multiporthole is tied to another porthole via inheritTypeFrom,
      then each member porthole is supposed to match the type of that
      other porthole.  (Even then, inheritTypeFrom is not a guarantee
      of type equality; we do not complain if the resolution algorithm
      ends up assigning different types.)

      Most stars that have ANYTYPE outputs should tie the port type to
      an input porthole to avoid its being undefined.  An exception is
      HOF-type stars, which escape the need to specify a porthole type
      by removing themselves from the graph before porthole type
      resolution occurs.

      In some cases the type is really undefined.  Consider this
      universe (using ptcl syntax)

      \begin(verbatim)
      star f Fork; star p Printer
      connect f output f input 1
      connect f output p input
      \end(verbatim)
		
      There are no types anywhere in the system.  We have little
      choice but to declare an error.

      To give convenient results for both Fork-like and Merge-like
      stars, we resolve types in two passes.

      \begin(enumerate)

      \item The first pass is "feed forward" from outputs to inputs:
      any output port of defined type is resolved to that type, as is
      its connected input.  Then, within any type equivalence loop in
      which all the input ports are resolved to the same type, we
      resolve unresolved outputs to that type (and resolve their
      connected inputs, leading to recursive propagation).  This pass
      handles Fork-like stars as well as Merge stars whose inputs all
      have the same type.

      \item The second pass is "feed back" from inputs to outputs: any
      unresolved input port with a defined type is resolved to that
      type, as is its connected output.  Then, within any type
      equivalence loop in which all the outputs are resolved to the
      same type, we resolve unresolved inputs to that type (and
      recursively resolve their connected outputs).  This pass allows
      us to do something reasonable with Merge stars that have inputs
      of different types: if the merge output is going to a port of
      knowable type, we may as well just output particles of that
      type.

      \item Finally, we declare error if any porthole types remain
      unresolved.  This occurs if a Merge-like star has inputs of
      nonidentical types and an output connected to an ANYTYPE input.
      The user must insert type conversion stars to coerce the Merge
      inputs to a common type, so that the system can figure out what
      type to use for the Merge output.
      \end(enumerate)*/
  //@{
  /** Return the data type computed by {\tt PortHole::initialize} to
    resolve type conversions.  For example, if an INT output porthole
    is connected to a FLOAT input porthole, the resolved type (the
    type of the Particles that travel between the ports) will be
    FLOAT.  A null pointer will be returned if the type has not been
    set, e.g.  before initialization.

    @see DataType*/
  inline ADSPtolemy::DataType resolvedType () const { return myResolvedType;}

  /** Return the "preferred type" of the porthole (never ANYTYPE).
      The result will be 0 (a null pointer) if type resolution has not
      yet been performed.*/
  inline ADSPtolemy::DataType preferredType () const { return myPreferredType; }

  /// function to resolve types during initialization.
  virtual ADSPtolemy::DataType setResolvedType(ADSPtolemy::DataType=NULL);
  //@}

  /// Return the nominal number of tokens transferred per execution
  inline int numXfer() const { return numberTokens;}

  /// Return the number of particles on my Geodesic
  int numTokens() const;

  /** Returns the number of initial delays on my Geodesic.  The initial
    tokens, strictly speaking, are only delays in dataflow domains.  */
  int numInitDelays() const;

  /// Return a string representing the initial delays on my Geodesic
  const char* initDelayValues() const;

  /// Return pointer to my Geodesic
  inline Geodesic* geo() { return myGeodesic;}

  /** Return the index value.  This is a mechanism for assigning all
    the portholes in a universe a unique integer index, for use in
    table-driven schedulers.

    The index is set by the {\tt \Ref{setPortIndices}} function.  */
  inline int index() const { return indexValue;}

  /** Return the MultiPortHole that spawned this PortHole, or
    NULL if there is no such MultiPortHole */
  inline MultiPortHole* getMyMultiPortHole() const { return myMultiPortHole; }

  /** Set the delay value with optional initial values for the
    connection */
  virtual void setDelay (int numberDelays, 
			 const char* initDelayValues = 0);

  /** Allocate a return a Geodesic compatible with this type of
    PortHole.  This may become a protected member in future Ptolemy
    releases.  */
  virtual Geodesic* allocateGeodesic();

  /**@name Support for multithreading */
  //@{
  /** Enable locking on access to the Geodesic and Plasma.  This is
    appropriate for connections that cross thread boundaries.
	  
    This mechanism is used in the Process Networks domain in Ptolemy.

    {\bf Assumption}: {\tt initialize()} has been called.  */
  void enableLocking(const PtGate& master);

  /// Disable the lock for access to the Geodesic and Plasma
  void disableLocking();

  /// Return TRUE if locking is available
  int isLockEnabled() const;
  /** Method to determine preferred types during initialization.
      Returns the preferred type of this porthole, or 0 on failure.
      Protected, not private, so that subclasses that override
      setResolvedType() can call it.*/
  ADSPtolemy::DataType setPreferredType();

  /** The resolved type of data that will be traversing the
    geodesic. The {\tt myResolvedType} data member is set by the {\tt
    PortHole::setResolvedType} method as types are resolved for a
    graph. It's value will be NULL if not determined yet.  */
  ADSPtolemy::DataType myResolvedType;

  /** "Preferred" type of porthole - intermediate step in type
      resolution process.
      
      @see setResolvedType*/
  ADSPtolemy::DataType myPreferredType;

  //@}

protected:
  /** The geodesic which connects to my peer.  If this port is not
    connected, myGeodesic == NULL.  */
  Geodesic* myGeodesic;

  /** The real port (aliases resolved) at the far end of a connection.
    Returns NULL for disconnected ports.

    This information is redundant with what's in the geodesic, but to
    access it through the geodesic, it is necessary to know whether
    the PortHole is an input or an output.  */
  PortHole* farSidePort;

  /** Pointer to the Plasma where we get our Particles or
    replace unused Particles */
  Plasma* myPlasma;

  /** Buffer where the Particles are stored.  This is actually a
    buffer of pointers to Particles, not to Particles themselves.  */
  CircularBuffer* myBuffer;

  /// This gives the size of the CircularBuffer to allocate
  int bufferSize;

  /** Number of Particles stored in the buffer each time the Geodesic
    is accessed.  Normally this is one except for dataflow-type stars,
    where it is the number of Particles consumed or generated.  */
  int numberTokens;

  /** Get {\tt numberTokens} particles from the Geodesic and move them
    into my CircularBuffer.  Actually, only Particles move.  The same
    number of existing Particles are returned to their Plasma, so that
    the total number of Particles contained in the buffer remains
    constant.  */
  void getParticle();

  /** Move {\tt numberTokens} particles from my circular buffer to the
    geodesic.  Replace them with the same number of Particles from the
    Plasma. */
  void putParticle();

  /** Clear {\tt numberTokens} particles in the circular buffer */
  void clearParticle();

  /// Allocate plasma (default method uses global Plasma)
  virtual int allocatePlasma();

  /** Alternate function allocates a local Plasma (for use in derived
    classes) */
  int allocateLocalPlasma();

  /** Delete Plasma if local; detach other end of connection from
    Plasma as well*/
  void deletePlasma();

  /// Allocate a new circular buffer
  void allocateBuffer();


  //@}

  /// Find the "true" far end, ignoring any intervening event horizons.
  PortHole* findFarEnd() const;

  
private:
  /// Type Resolution
  //@{
  /// Two recursive phases of preferred-type assignment
  //@{
  /// First pass of preferred type assignment
  ADSPtolemy::DataType assignPass1();
  /// Second pass of preferred type assignment
  ADSPtolemy::DataType assignPass2();
  //@}


  /// index value, for making scheduler tables
  int indexValue;

  /** Pointer to the MultiPortHole that spawned this PortHole, if
    there is one.  Otherwise, NULL */
  MultiPortHole* myMultiPortHole;
};

// PortList methods.  They are here because they cannot appear until
// class PortHole is declared.

inline void PortList::put(PortHole& p) {NamedObjList::put(p);}

inline 	const PortHole* PortList::portWithName(const char* name) const {
  return (const PortHole*)objWithName(name);
}

inline 	PortHole* PortList::portWithName(const char* name) {
  return (PortHole*)objWithName(name);
}

inline int PortList::remove(PortHole* p) { return NamedObjList::remove(p);}

// The following generic type is good enough to use in galaxies.
// It always has an alias.
// The "isIt" functions work by asking the alias.

/** A Galaxy PortHole. This class is used by {\tt InterpGalaxy}, and
  in other places, to create galaxy ports that are aliased to some
  port of a member block.  */
class GalPort : public PortHole {
public:
  /// Construct a galaxy port that is aliased to an interior port
  GalPort(GenericPort& a);

  /** Construct a non-aliased galaxy port, defering aliasing
    until later */
  GalPort() {}
	
  /// Destructor
  ~GalPort();

  /// Return TRUE if the interior port is an input
  int isItInput() const;

  /// Return TRUE if the interior port is an output
  int isItOutput() const;
};

/// An iterator for PortLists
class PortListIter : private NamedObjListIter {
public:
  /// Constructor
  PortListIter(PortList& plist) : NamedObjListIter (plist) {}

  /// Methods to return the next porthole
  //@{
  /// Return the next porthole
  inline PortHole* operator++(POSTFIX_OP) { return next();}

  /// Return the next porthole
  inline PortHole* next() { 
    return  (PortHole*)NamedObjListIter::next();
  }

  /** Iterate over ports which are set at the PortFlag to flag\_value.
      If test == NULL, this method functionally equivalent to
      next().*/
  inline PortHole* next(PortFlag* test, int flag_val=FALSE) {
    PortHole* port;
    while (((port = next())) != NULL &&
	   test && (test->flag(*port) != flag_val));
    return port;
  }

  /** Provided for backward compatibility to UCB Ptolemy, it is
      recommend to upgrade the code to use the {\tt PortFlag} class.*/
  inline PortHole* next(int flag_loc, int flag_value) {
    PortHole* port;
    while (((port = next())!= NULL) &&
	   (port->flags[flag_loc] != flag_value));
    return port;
  }
  //@}
 
  /// Reset the iterator to the beginning of the list
  using NamedObjListIter::reset;

  /// Remove the current port from the PortList
  using NamedObjListIter::remove;
};


class FastPortListIter : private FastNamedObjListIter {
public:
  inline FastPortListIter(PortList &p) : FastNamedObjListIter(p) {}
  inline PortHole* head() { return (PortHole*)FastNamedObjListIter::head(); }
  inline PortHole* next() { return (PortHole*)FastNamedObjListIter::next(); }
};


/** A Galaxy MultiPortHole.  This class is used by {\tt InterpGalaxy},
  and in other places, to create galaxy multiports that are aliased to
  some port of a member block.*/
class GalMultiPort : public MultiPortHole {
public:
  /** Construct a galaxy multiport that is aliased to an interior
    multiport */
  GalMultiPort(GenericPort& a);

  /** Construct a non-aliased galaxy multiport, defering
    aliasing until later */
  GalMultiPort() {}

  /// Destructor
  ~GalMultiPort();

  /// Return TRUE if the interior multiport is an input
  int isItInput() const;

  /// Return TRUE if the interior multiport is an output
  int isItOutput() const;

  /** When making a new port, create it both locally and in the
    alias and connect the two together.*/
  /*virtual*/ PortHole& newPort();

  /** Make a new port from one in the alias which already exists. */
  PortHole& newPort(PortHole &);
};

/// A list of MultiPortHoles
class MPHList : private NamedObjList
{
  friend class MPHListIter;
  friend class CMPHListIter;
public:
  /// Add MultiPortHole to list
  inline void put(MultiPortHole& p) {NamedObjList::put(p);}

  /// Find a multiport with the given name and return pointer
  inline MultiPortHole* multiPortWithName(const char* name) 
  {
	  return (MultiPortHole*)objWithName(name);
  }

  /// Remove a port
  inline int remove(MultiPortHole* p) 
  {
	  return NamedObjList::remove(p);
  }

  /** Find a multiport with the given name and return pointer, const
    version */
  inline const MultiPortHole* multiPortWithName(const char* name) const {
    return (const MultiPortHole*)objWithName(name);
  }

  /// Return the number of multiportholes on the list
  using NamedObjList::size;

  /// Initialize all of the multiportholes on the list
  using NamedObjList::initElements;

  /// Delete all of the multiportholes on the list
  using NamedObjList::deleteAll;
};

/// An iterator for MultiPortHoles
class MPHIter : public PortListIter {
public:
  /// Constructor
  MPHIter(MultiPortHole& mph) : PortListIter (mph.ports) {}
};

/// An iterator for MPHLists
class MPHListIter : private NamedObjListIter {
public:

  /// Constructor
  MPHListIter(MPHList& plist) : NamedObjListIter (plist) {}
	
  /// Return the next MultiPortHole
  inline MultiPortHole* next() { return (MultiPortHole*)NamedObjListIter::next();}

  /// Return the next MultiPortHole
  inline MultiPortHole* operator++(POSTFIX_OP) { return next();}

  /// Reset the iterator to the beginning of the list
  using NamedObjListIter::reset;
};

/** Set the indicies for all of the portholes in a galaxy.

  A {\tt \Ref{PortHole}} can have index for use in table-driven
  schedulers.  To access the index, use the method {\tt
  \Ref{PortHole::index}}.

  Returns the total number of ports.*/
int setPortIndices(Galaxy&);

inline int& PortFlag::flag(GenericPort& b) {
  return Flag::flag(b.portFlags);
}

inline const int PortFlag::flag(const GenericPort& b) const {
  return Flag::flag(b.portFlags);
}

#endif   /* PORTHOLE_H_INCLUDED */

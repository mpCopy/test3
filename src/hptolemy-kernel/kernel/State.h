/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/State.h,v $ $Revision: 100.51 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef STATE_H_INCLUDED
#define STATE_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

/***********************************************************************
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

 Programmer: I. Kuroda and J. T. Buck 
 Date of creation: 5/26/90
 Revisions:

 State is a data member of a Block, it is where paremeters and
 state information is stored for that Block.

***********************************************************************/

#ifdef __GNUG__
#pragma interface
#endif

#include "InvokeInterp.h"
#include "DataStruct.h"
#include "StringList.h"
#include "HPtolemyError.h"
#include "type.h"
#include "NamedObj.h"
#include "ComplexSubset.h"
#include "gui_stdlib.h"
#include "gui_errno.h"
#include "gui_string.h"
#include "ptolemyDll.h"
#include <list>

class Block;
class State;
class Tokenizer;

// token types: from state parser
const int T_EOF = 257;
const int T_ERROR = 258;
const int T_Float = 259;
const int T_Int = 260;
const int T_Complex = 263;
const int T_ID = 261;
const int T_STRING = 262;

/// Token, from state parser
class ParseToken {
public:
  /// 
  int tok;
  /// 
  union {
    char cval;
    char* sval;
    int intval;
    double doubleval;
    const State* s;
  }; 

  Complex complexval;

  /// 
  ParseToken () { sval = NULL; cval = '\0'; doubleval = 0; s = NULL; tok = 0; intval = 0; }
};

// attribute bit definitions.  The kernel reserves the next two bits
// (8, 16) for future expansion; domains may use higher-order bits
// for their own purposes (example: code generation domains do this).

/// Attribute bit for state, TRUE if a constant during a run (DEFAULT TRUE)
const bitWord AB_CONST = 1;

/// Attribute bit for state, TRUE if settable by the user (DEFAULT TRUE)
const bitWord AB_SETTABLE = 2;

/// Attribute bit for state, TRUE if can be modified externally (DEFAULT FALSE)
const bitWord AB_DYNAMIC = 4;

/// Attribute bit for state, TRUE if can be swept (DEFAULT TRUE)
const bitWord AB_NONSWEEPABLE = 8;

/// Attribute bit for schematic display, TRUE if to not display (DEFAULT FALSE)
const bitWord AB_NOSCHEMDISPLAY = 16;

/// Attribute bit for information parameter, TRUE means parameter no editable ( DEFAULT FALSE )
const bitWord AB_NONEDITABLE = 32;

/// Attribute bit for state, TRUE if to not netlisted ( DEFAULT FALSE )
const bitWord AB_NONNETLISTED = 64;

/// Default attributes for state ({\tt \Ref{AB_CONST}}|{\tt \Ref{AB_SETTABLE}})
const bitWord AB_DEFAULT = AB_CONST | AB_SETTABLE;

/** Attribute to declare if the value is never changed by star
    execution (DEFAULT)*/
HPTOLEMY_KERNEL_API extern const Attribute A_CONSTANT;

/// Attribute to declare if the user may set this state (DEFAULT)
HPTOLEMY_KERNEL_API extern const Attribute A_SETTABLE;    

/// Attribute to declare if the value changed by star execution
HPTOLEMY_KERNEL_API extern const Attribute A_NONCONSTANT;

/// Attribute to declare if the user may not set this state
HPTOLEMY_KERNEL_API extern const Attribute A_NONSETTABLE;	

/** Attribute to declare if the state may be modified externally
    during execution*/
HPTOLEMY_KERNEL_API extern const Attribute A_DYNAMIC;	

/// Attribute to declare if the state can be swept (DEFAULT)
HPTOLEMY_KERNEL_API extern const Attribute A_SWEEPABLE;	

/// Attribute to declare if the state can not be swept
HPTOLEMY_KERNEL_API extern const Attribute A_NONSWEEPABLE;	

/// Attribute to declare if the state is displayed on schematic (DEFAULT)
HPTOLEMY_KERNEL_API extern const Attribute A_SCHEMDISPLAY;

/// Attribute to declare if the state is not displayed on schematic
HPTOLEMY_KERNEL_API extern const Attribute A_NOSCHEMDISPLAY;

/// Attribute to declare if the state is editable. This is by default on
HPTOLEMY_KERNEL_API extern const Attribute A_EDITABLE;

/// Attribute to declare if the state is not editable, i.e. information parameter
HPTOLEMY_KERNEL_API extern const Attribute A_NONEDITABLE;

/// Attribute to declare if the state is to be netlisted. This is by default on
HPTOLEMY_KERNEL_API extern const Attribute A_NETLISTED;

/// Attribute to declare if the state is not to be netlisted
HPTOLEMY_KERNEL_API extern const Attribute A_NONNETLISTED;

/** A parameter or state information for a {\tt \Ref{Block}}.

  A State is a data structure associated with a block, used to
  remember data values from one invocation to the next.  For example,
  the gain of an automatic gain controller is a state.  A state need
  not be dynamic; for instance, the gain of fixed amplifier is a
  state.  A parameter is the initial value of a state.

  A State actually has two values: the initial value, which is always
  a character string, and a current value, whose type is different for
  each derived class of State: integer for IntState, an array of real
  values for FloatArrayState, etc.  In addition, states have
  attributes, which represent logical properties the state either has
  or does not have.

  The State base class is an abstract class; you cannot create a plain
  State.  The base class contains the initial value, which is always a
  {\tt const char*}; the derived classes are expected to provide
  current values of appropriate type.  

  Most of the protected interface in the State class consists of a
  simple recursive-descent parser for parsing integer and floating
  expressions that appear in the initial value string.  The ParseToken
  class represents tokens for this parser.  It contains a token type
  (an integer code) and a token value, which is a union that
  represents either a character value, a string value, an integer
  value, a double value, a Complex value, or a State value (for use
  when the initializer references another state).  Token types are
  equal to the ASCII character value for single-character tokens.
  Other possible token values are:

  \begin{itemize}
  \item {\tt T\_EOF} for end of file,
  \item {\tt T\_ERROR} for error,
  \item {\tt T\_Float} for a floating value,
  \item {\tt T\_Int} for an integer value,
  \item {\tt T\_ID} for a reference to a state, and
  \item {\tt T\_STRING} for a string value.
  \end{itemize}

  For most of these, the token value holds the appropriate value.

  Most derived State classes use this parser to provide uniformity of
  syntax and error reporting; however, it is not a requirement to use
  it.  Derived State classes are expected to associate a Tokenizer
  object with their initial value string.  The functions provided here
  can then be used to parse expressions appearing in that string.  */
class State : public NamedObj {
public:

  /** Constructor.  The constructor for class State sets the initial
    value to a null pointer, and sets the state's attributes to a
    value determined by the constant AB\_DEFAULT, which is defined in
    ``State.h'' to be the bitwise or of AB\_CONST and AB\_SETTABLE.  The
    destructor does nothing extra.  */
  State() : myInitValue(0), 
    unitsEnumeratedValue(State::UNITLESS_UNIT), range(0), symbol(0) {
      setAttributes(A_CONSTANT|A_SETTABLE);
  }

  /// Destructor
  ~State();

  /** Configure the state.  This function sets the name, parent,
    initial value, and optionally the descriptor for a state.  The
    character strings representing the initial value and descriptor
    must outlive the State.*/
  State& setState(const char* stateName, 
		  Block* parent ,
		  const char* ivalue,
		  const char* desc = NULL,
		  const char* rangeStr = NULL,
		  const char* symbolStr = NULL);

  /** Configure the state.  This function is the same as the other
    {\tt setState}, but it also sets attributes for the state.  The
    Attribute object represents a set of attribute bits to turn on or
    off.  */
  State& setState(const char* stateName, 
		  Block* parent ,
		  const char* ivalue,
		  const char* desc,
		  Attribute attr);

  State& setState(const char* stateName,
		  Block* parent,
		  const char* ivalue,
		  const char* desc,
		  const char* rangeStr,
		  const char* symbolStr,
		  Attribute attr);

  /** Set the initial value to {\tt valueString}.  This string must
    outlive the State.  */
  void setInitValue(const char* s);

  /// Return the initial value.
  inline const char* initValue () const { return myInitValue;}

  /** Return the type name (for use in user interfaces, for example).
    When states are created dynamically (by the KnownState or
    InterpGalaxy class), it is this name that is used to specify the
    type.  */
  virtual const char* type() const = 0;

  /// 
  virtual const char* className() const = 0;

  /** Return the size (number of distinct values) in the state.  The
    default implementation returns 1.  Array state types will return
    the number of elements.  */
  virtual int size() const;

  /// Return TRUE if this state is an array
  virtual int isArray() const;

  /** Initialize the state.  The {\tt initialize} function for a state
    is responsible for parsing the initial value string and setting
    the current value appropriately; errors are signaled using the
    {\tt \Ref{Error::initialization}} mechanism.  */
  virtual void initialize() = 0;

  /// Report error when parameter is out of range.
  void rangeError(const char* range = NULL) const;

  /// Return a string representation of the current value
  virtual StringList currentValue() const = 0;

  /** Modify the current value, in a type-independent way.  Notice
    that this function is not virtual.  It exploits the semantics of
    {\tt initialize} to set the current value using other functions;
    the initial value is not modified (it is saved and restored).  */
  void setCurrentValue(const char* newval);

  inline const char* getRange() const { return range; }

  inline const char* getSymbol() const { return symbol; }

  /** Create a new State of identical type.  Derived state classes
    override this method to create an identical object to the one the
    method is called on.  */
  virtual State* clone() const = 0;

  /// Output all info.  This is NOT redefined for each type of state.
  StringList print(int verbose) const;

  /// file reading error reporter
  inline const char* why() {
    return strerror(errno);
  }

  /// Class identification
  int isA(const char*) const;

  /** Lookup state from name. This method searches for a state named
    {\tt name} in Block {\tt b} or one of its ancestors, and either
    returns it or a null pointer if not found.  */
  const State* lookup(const char*, Block*);
  const State* lookupFullName(const char*, Block*);
 
  /**@name Support for state units, new from HP EEsof */
  //@{
  /// Set the units, argument should be one of \Ref{unitsE}
  inline void setUnits(unsigned short int u) {
    unitsEnumeratedValue = u;
  }

  /// Return the units, return value should be one of \Ref{unitsE}
  inline unsigned short int units() const {
    return unitsEnumeratedValue;
  }

  /// Return the unit type as a string
  StringList unitString() const;

  /// 
  enum unitsE {
    UNITLESS_UNIT,
    FREQUENCY_UNIT,
    RESISTANCE_UNIT,
    CONDUCTANCE_UNIT,
    INDUCTANCE_UNIT,
    CAPACITANCE_UNIT,
    LENGTH_UNIT,
    TIME_UNIT,
    ANGLE_UNIT,
    POWER_UNIT,
    VOLTAGE_UNIT,
    CURRENT_UNIT,
    DISTANCE_UNIT,
    DB_GAIN_UNIT,
    TEMPERATURE_UNIT
  };
  //@}

protected:
  /**@name Methods for parsing the initial value */
  //@{

  /** This function obtains the next token from the input stream
    associated with the Tokenizer.  If there is a pushback token, that
    token is returned instead.  If it receives a '<' token, then it
    assumes that the next string delimited by white space is a file
    name.  It substitutes references to other parameters in the
    filename and then uses the Tokenizer's include file capability to
    insert the contents of the file into the input stream.  If it
    receives a '!' token, then it assumes that that the next string
    delimited by white space is a command to be evaluated by an
    external interpreter.  It substitutes references to other
    parameters in the command, sends the resulting string to the
    interpreter defined by interp member described above for
    evaluation, and inserts the result into the input stream.  The
    information both read from an external file and returned from an
    external interpreter is also parsed by this function.  Therefore,
    the external interpreter can perform both numeric and symbolic
    computations.

    When the parser hits the end of the input stream, it returns
    T\_EOF.  The characters in the set {\tt ,[]+*-/()^} are considered
    to be special and the lexical value is equal to the character
    value.  Integer and floating values are recognized and evaluated
    to produce either T\_Int or T\_Float tokens.  However, the decision
    is based on the value of {\tt wantedType}; if it is T\_Float, all
    numeric values are returned as T\_Float; if it is T\_Int, all
    numeric values are returned as T\_Int.

    Names that take the form of a C or C++ identifier are assumed to
    be names of states defined at a higher level (states belonging to
    the parent galaxy or some ancestor galaxy).  They are searched for
    using {\tt lookup}; if not found, an error is reported using {\tt
    parseError} and an error token is returned.  If a State is found,
    a token of type T\_ID is returned if it is an array state or
    COMPLEX; otherwise the state's current value is substituted and
    reparsed as a token.  This means, for example, that a name of an
    IntState will be replaced with a T\_Int token with the correct
    value.  */
  virtual ParseToken getParseToken(Tokenizer&, int = T_Float);

  /** This method produces an appropriately formatted error message
    with the name of the state and the arguments and calls {\tt
    Error::initialization}.

    @see Error::initialization*/
  void parseError (const char*, const char* = "");

  /**@name Methods to manipulate the pushback token */
  //@{
  /// Return the current pushback token
  ParseToken pushback();
  /// Set the pushback token to the argument
  void setPushback(const ParseToken&);
  /// Clear the pushback token
  void clearPushback();
  //@}

  /**@name Recursive-descent expression parser methods

    These four functions implement a simple recursive-descent
    expression parser.

    An expression is either a term or a series of terms with
    intervening '+' or '-' signs.

    A term is either a factor or a series of factors with interventing
    '*' or '/' signs.

    A factor is either an atom or a series of atoms with intervening
    '^' signs for exponentiation.  (Note, C fans!  ^ means
    exponentiation, not exclusive-or!).

    An atom is any number of optional unary minus signs, followed
    either by a parenthesized expression or a SCALAR token.  SCALAR is
    either T\_Int or T\_Float, depending if the method name begins with
    either a evalInt or evalFloat.

    If any of these methods reads too far, the pushback token is used.
    All {\tt getParseToken} calls use {\tt wantedType} T\_Int, so any
    floating values in the expression are truncated to integer.

    The token types returned from each of these methods will be one of
    SCALAR, T\_EOF, or T\_ERROR.  */
  //@{
  /**@name SCALAR = T\_Int */
  //@{
  /// 
  ParseToken evalIntExpression(Tokenizer& lexer);
  /// 
  ParseToken evalIntTerm(Tokenizer& lexer);
  /// 
  ParseToken evalIntFactor(Tokenizer& lexer);
  /// 
  ParseToken evalIntAtom(Tokenizer& lexer);
  //@}

  /**@name SCALAR = T\_Float */
  //@{
  /// 
  ParseToken evalFloatExpression(Tokenizer& lexer);
  /// 
  ParseToken evalFloatTerm(Tokenizer& lexer);
  /// 
  ParseToken evalFloatFactor(Tokenizer& lexer);
  /// 
  ParseToken evalFloatAtom(Tokenizer& lexer);
  //@}

  /**@name SCALAR = T\_Complex */
  //@{
  /// 
  ParseToken evalComplexExpression(Tokenizer& lexer);
  /// 
  ParseToken evalComplexTerm(Tokenizer& lexer);
  /// 
  ParseToken evalComplexFactor(Tokenizer& lexer);
  /// 
  ParseToken evalComplexAtom(Tokenizer& lexer);
  //@}
  //@}

  /// 
  StringList parseFileName(const char* fileName);

  /// 
  StringList parseNestedExpression(const char* expression);

  /** An external interpreter for evaluating commands in a parameter
    definition preceded by the ! character and surrounded in quotes.
    By default, no interpreter is defined.  If the interpreter were
    defined as the Tcl interpreter, then {\tt ! "expr abs(cos(1.0))"}
    would compute 0.540302.  Other parameters can be referenced as
    usual by using curly braces, e.g.  {\tt ! "expr
    abs(cos(\{gain\}))"}.*/
  InvokeInterp interp;

  /// support one character directives
  int mergeFileContents(Tokenizer& lexer, char* token);

  int mergeFileContents(Tokenizer& lexer, StringList& token);

  /// 
  int sendToInterpreter(Tokenizer& lexer, char* token);

  int sendToInterpreter(Tokenizer& lexer, StringList& token);

  /// 
  int getParameterName(Tokenizer& lexer, char* token);

  //@}

private:
  /// pushback token, for use in parsing
  ParseToken pushbackToken;

  /// string used to set initial value by initialize()
  const char* myInitValue;

  /// unit
  unsigned short int unitsEnumeratedValue;

  const char* range;

  const char* symbol;
};

/// This class is used to store a list of states in a Block
class StateList : private NamedObjList
{
  /// 
  friend class StateListIter;
  /// 
  friend class CStateListIter;
public:
  /// Add State to list
  inline void put(State& s) {NamedObjList::put(s);}

  /** Put a new state before an existing state.  If the existing
      state is not on the list, prepend new state to the list. */
  inline void putBefore(State& newState, State& existingState) {
    NamedObjList::putBefore(newState,existingState);
  }
  
  /** Put a new state after an existing state.  If the existing
      state is not on the list, append new state to the list. */
  inline void putAfter(State& newState, State& existingState) {
    NamedObjList::putAfter(newState,existingState);
  }

  /// Find a state with the given name and return pointer
  inline State* stateWithName(const char* name) {
    return (State*)objWithName(name);
  }

  /// 
  inline const State* stateWithName(const char* name) const {
    return (const State*)objWithName(name);
  }

  /// 
  using NamedObjList::size;
  /// 
  using NamedObjList::initElements;
  /// 
  using NamedObjList::deleteAll;
  /// 
  using NamedObjList::initialize;
  /// 
  using NamedObjList::sort;
};

/// An iterator for StateList, see \Ref{Iterators}
class StateListIter : private NamedObjListIter {
public:
  /// 
  StateListIter(StateList& sl) : NamedObjListIter (sl) {}
  /// 
  inline State* next() { return (State*)NamedObjListIter::next();}
  /// 
  inline State* operator++(POSTFIX_OP) { return next();}
  /// 
  using NamedObjListIter::reset;
  ///
  using NamedObjListIter::remove;
};

class MultiState : public State {
public:

   MultiState();
   ~MultiState();
   void initialize();
   const char* type() const;
   int size() const;
   State * getState(int n);
   State& setState(State*, const char*, Block*, const char*, 
	const char*, const char*, const char*, Attribute);
   State& setState(State*, const char*, Block*, const char*, 
	const char*, const char*, const char*);
   const char* className() const;
   StringList currentValue() const;
   StringList initValue() const;
   State* clone() const;
   
private:
   std::list<State*> stateList;
};


#define MULTISTATE(s,ms) \
class ms:public MultiState { \
  public: inline s& operator[](int index) { \
    s* state = (s*)getState(index); \
    return(*state); \
  } \
};

#endif   /* STATE_H_INCLUDED */

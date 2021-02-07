#ifndef _SDFSystemC_Cosim_h
#define _SDFSystemC_Cosim_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptsystemc/kernel/SDFSystemC_Cosim.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2007 - 2014 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "SimControl.h"
#include "ADSSystemC.h"
#include "nspr.h"
#include "string.h"
#include "pripcsem.h"
#include "prmem.h"
#include "prio.h"
#include "prenv.h"
#include "TargetTask.h"
#include "Tokenizer.h"
#include "FloatState.h"
#include "IntState.h"
#include "FloatArrayState.h"
#include "IntArrayState.h"
#include "IntState.h"
#include "StringState.h"
#include "FileNameState.h"
#include "ptsystemcDll.h"

   /**
   @class SDFSystemC_Cosim
   @brief Base class to provide SystemC Cosimulation with Ptolemy.
   
   This is the base ptolemy star that provides Ptolemy side IPC for cosimulation with SystemC.
   A user must derive his(her) non-sink  ptolemy SystemC Cosim star from this base star. Sink
   stars should be derived from SystemC_CosimSink star. Only components that a user can define
   in his star are input, output, state, sc_setup (instead of setup) location, and author.
  **/
  /** 
   @var SDFSystemC_Cosim::SystemC_Executable
   @brief SystemC executable name that will Cosimulate with Ptolemy.

   It is highly recommended that user set the value of this paramter in his ptolemy star
   derived from SystemC_Cosim or SytemC_CosimSink to a default value, otherwise he could
   always set it as a paramter in Schematic. The default value could be set in user defined 
   constructor method in the derived star using SystemC_Executable.setInitValue(cosnt char *).
   If the absolute path to executable is not defined then user needs to setup PATH Environment 
   variable to point to the executable, in this case it is sufficient just to specify the name.
 
   **/
  /**
   @var SDFSystemC_Cosim::CmdArgs
   @brief Command line argument passed to SystemC executable

   Since string user defined parameter types are not allowed in SystemC Cosim, a user could
  use CmdArgs to send any paramter (String or not) to his SystemC executable. 

  **/
  /**
   @var SDFSystemC_Cosim::SystemC_Timeout
   @brief Inter Process Communication Time out period in seconds, defualt is 30 seconds.
 
   This could be used to detect deadlock in SystemC executable, especially if it multi-rate.
  However, if the user's machine is really slow then this timeout period could be increased but
  I think 30 seconds is already the limit.

  **/

  /**
  @fn SDFSystemC_Cosim::go()
  @brief go method for SystemC_Cosim

  This method performs following in sequence for each simulation run:
  -# Check for simulation control, that is a halt is requested or was there any error.
  -# Process Inputs and send those to SystemC.
  -# Read ouputs from SystemC and process those.

  **/

  /**
   @fn SDFSystemC_Cosim::setup()
   @brief setup method for SystemC_Cosim.
  
   This method performs following in sequence
   -# Call sc_setup() to set user defines multirate parameters.
   -# Parse input and outout ports.
   -# Parse user defined states (parameters)
   -# Calculate required shared memory size.
  **/


  /**
   @fn SDFSystemC_Cosim::begin()
   @brief begin method for SystemC_Cosim.

   This method performs following tasks in sequence.
   -# If isAControllingSink then initialize sinkControl.
   -# Set connectionID.
   -# Create IPC semaphores used in synchronization.
   -# Setup shared memory.
   -# Start SystemC executable.
   -# Check interface (ports and parameter) compatibility with SystemC executable
  **/

  /**
   @fn SDFSystemC_Cosim::wrapup()
   @brief wrapup method for SystemC_Cosim.

   This method performs the following tasks in sequence.
   -# Wait for SystemC executable to stop executing.
   -# Delete shared memory.
   -# Delee IPC semaphores.

  **/

class SDFSystemC_Cosim:public SDFStar
{
public:
	SDFSystemC_Cosim();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void wrapup();
	/* virtual */ void begin();
protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FileNameState SystemC_Executable;
	StringState CmdArgs;
	IntState SystemC_Timeout;
	                /** A virtual method that a SystemC user could define in his derived star to setup multirate
                paramters and  to check paramter ranges.
               **/
virtual void sc_setup (void);
	                /**
                 @brief Setup the Connection ID for Interprocess communication
 
                 The connection ID is setup using tmpnam and mapped to a valid UNIX file name.
                 This connection ID is used to identify named Semaphores and Shared Memory in
                 SystemC side interface. The connection ID is sent to SystemC as command line
                 argument.
 
                 @return TRUE on success.
                **/
bool setConnectionID (void);
	               /** 
                @brief Method to create named semaphore to provide IPC synchronization. 
 
                The function also creates Monitor for thread synchronization. The thread is used
                to implement timeout in NSPR semaphores which does not support timeout
 
               @return TRUE on success
               **/
bool createSemaphores (void);
	                 /**
                  @brief  Deletes the IPC Semaphores to release System resources.
                **/
void deleteSemaphores (void);
	                /**
                @brief This method waits for SystemC to post semaphore for IPC synchronization.

                Since NSPR semaphore does not provides a way to timeout while waiting for a semaphore, 
                this function emulates the timeout behavior. This function starts a thread that waits on NSPR semaphore
                and waits for thread to notify this function when the thread recives the semaphore using NSPR monitors. 
                Since monitors could be timed out, if the thread does not recievs the semaphore from systemC then this
                method timedout on the monitor and detects that the SystemC is timeout out and generates an error message. 
                 To release the thread in case of timeout, this method posts a false semaphore. 
                **/
void waitForSystemC (void);
	                /** @brief Notify SystemC that Ptolemy has sent data by posting semaphore. **/
void notifySystemC (void) {
#line 451 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptsystemc/kernel/SDFSystemC_Cosim.pl"
status = PR_PostSemaphore ( ADS_Semaphore );
	}
	                /**
                  @brief Parse I/O Ports to detecte that it is supported by Ptolemy SystemC Cosim.
             
                  @return TRUE on success.
                 **/
bool parseIOPorts (void);
	                /**
                @brief Parse states for supported user defined states (parameters)
                @return TRUE on success.
                **/
bool parseStates (void);
	                /**
                  @brief Calculate header and payload shared memory size to holad header and payload data.
                 **/
void calculateSharedMemSize (void);
	                 /**
                 @brief Setup shared memory segments

               This method performs the following:
                -# Creates shared  header and payload shared  memory.
                -# Write values in payload memory because its values are known during setup.
                -# Write paramter values in payload memory because paramter values are known before setup.
                
                 @return TRUE on success.
                **/
bool setupSharedMem (void);
	                /**
                  @brief Deletes shared memory to release systemc resources.
               **/
void closeSharedMem (void);
	    /**
    @brief Setup the command line arguments to be passed to SystemC Executable.

    Command line arguments includes IPC connectionID as well user defined CmdArgs.

    @param arg The command line arguments are stored in arg.

    @param exeName SystemC executable name that must be in arg[0].
    **/
bool setProcessArgs (char *** arg, char *exeName);
	                /**
                 @brief Starts SystemC process.
 
                 This method first try to access the SystemC executable if it is not successfull then it searches
                 the executable in PATH environment variable. If it also could not find it in PATH then functions,
                 abort the simulation. The method also redirect SystemC executable's stdout to stderr because ADS
                 uses stdout for signalling, which is not good but we need to bear it now. 
                **/
bool startSystemcProcess (void);
	        /**
         @brief Check that ptolemy start and SystemC side interface are compatable for ports and paramters.

        Since we have already written header data for each port and paramters, systecm side just compare 
       those and reply with its status.
        **/
void checkInterfaceCompatibility (void);
	         /**
           @brief Process inputs to ptolemy star.
 
          This method first writes input data to payload shared memory for each input port,
         then notify SystemC that data input data is ready for SystemC to read it.
         **/
void processInputs (void);
	          /**
          @brief Process ptolemy SystemC Cosim star output.
 
          This method first waits for SystemC to notify it that output data is ready to be read,
          then it reads the data from payload shared memory and post it to Ptolemy output ports.
         **/
void processOutputs (void);
	       /**  @brief Checks that if it is a sink or not. **/
virtual int isASink (void);
	        /** @brief Checks that if it is a controlling sink. **/
virtual int isAControllingSink (void);

private:
#line 168 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptsystemc/kernel/SDFSystemC_Cosim.pl"
PortList InPortList; ///< PortList to hold inputs
    
    PortList  OutPortList;  ///< PortList to hold outputs
    
    StateList UserParamList; ///< StateList to hold User paramters
    
    char ConnectionID[L_tmpnam+2]; ///< Connection ID between SystemC and 
                                   ///< Ptolemy for named Semaphores and Shared memory
 
    PRSem *ADS_Semaphore; ///< Semaphore posted by ADS Ptolemy and waited on by SystemC for synchronization
   
    PRSem *externalSemaphore; ///< Semaphore posted by SystemC and waited on by ptolemy for synchronization
    
    PRSharedMemory *headerSM;  ///< Shared memory segment to hold header datar
    
    PRSharedMemory *payloadSM; ///< Shared memory segment to hold payload data (port and paramter values)
    
    double *payloadMemory; ///< A pointer to payload data in shared memory
    
    void *headerMemory;   ///< pointer to header shared memory data
    
    char semName[L_tmpnam + MAX_PREFIX_LENGTH]; ///< Semaphore name
    
    PRStatus status; ///< Used in many functions to get status of NSPR errors after NSPR function calls.
    
    ADSSC_SyncCommand * syncCommand; ///< An enumeration type used to detect Synchronization command 
    
    int *numDataMembers; ///< Pointer to number of Data members (paramters + ports) in shared memory
    
    ADSSC_HeaderData *inputHeaderData; ///< Pointer to number of inputs in the header shared memory
    
    ADSSC_HeaderData *outputHeaderData; ///< Pointer to number of outputs in the header shared memory 
    
    ADSSC_HeaderData *paramHeaderData;  ///< Pointer to number of user paramters in the header shared memory
    
    PRSize headerMemSize;  ///< Size of header shared memory
    
    PRSize payloadMemSize; ///< Size of payload shared memory
        
    char *messageFromSC; ///< Pointer to messages from SystemC.
                              ///< This will be atmost MAX_SYSTEMC_ERROR_MESSAGE_LENGTH Character long.
 
    PRProcess *simProcess; ///< Pointer to SystemC_Executable process
    
    PRFileDesc *systemcLogFile; ///< SystemC log file
    
    ADSSC_ThreadData threadData; ///< Pointer to data for thread synchronization to implement timeout in Semaphores
    
    char **SCCmdArgs;  ///< Command line arguments passed to systemc
    
    DynamicSink sinkControl; ///< Sink control, only used when the star is a sink
    
    short sinkStopRequested; ///< A variable to detect that did a SystemC sink has requested  stop

};
#endif


#ifndef INCLUDE_ADSSYSTEMC_H
#define INCLUDE_ADSSYSTEMC_H
// Copyright 2007 - 2014 Keysight Technologies, Inc  

#define MAX_PREFIX_LENGTH 10 // Used to append prefix for Semaphore & Shared Mem Names
#define MAX_PORT_PARAM_NAME_LENGTH 128
#define MAX_SYSTEMC_ERROR_MESSAGE_LENGTH 256
#define MAX_SYSTEMC_EXECUTABLE_NAME_LENGTH 256

#include <prthread.h>
#include <pripcsem.h>
#include <prmon.h>


/// Define a data record which gets transfer to and from adsptolemy
struct ADSSC_shared_record {
        double floatdata;
  };

/** 
@brief Enum for Synchronization commands
 **/
enum ADSSC_SyncCommand {
	ADSSC_CONTINUE,
	ADSSC_STOP,
	ADSSC_INITIALIZATION,
	ADSSC_VERSION_MISS_MATCH,
	ADSSC_INTERFACE_MISS_MATCH,
	ADSSC_ABORT
};

/** typedef enum SYNC_command ADSSC_SYNC_COMMAND;**/
typedef enum ADSSC_SyncCommand ADSSC_SyncCommand;


/** Enum for Membertype in header shared memory **/
enum ADSSC_MemberType {
	ADSSC_PARAMETER,
	ADSSC_INPUT,
	ADSSC_OUTPUT
};
typedef enum ADSSC_MemberType ADSSC_MemberType;


/** Enum for Data type **/
enum ADSSC_DataType {
	ADSSC_INT,
	ADSSC_DOUBLE
};
typedef enum ADSSC_DataType ADSSC_DataType;


/** Structure to hold header data in header shared memory, for an interface. **/
struct ADSSC_HeaderData {
	/** Parameter, Input or Output?**/
	ADSSC_MemberType memberType;
	/** Name of Paramter, Output or Input **/
	char name[MAX_PORT_PARAM_NAME_LENGTH];
	/** Data type DOUBLE or INT **/
	ADSSC_DataType dataType;
	/** How many data points **/
	int length;
	/** pointer index from start of shared memory. **/
	int index;
};

typedef struct ADSSC_HeaderData ADSSC_HeaderData;


/** Structure used in thread to implement semaphore wait with time out **/
struct ADSSC_ThreadData {
	PRThread *thread; /**< Pointer to thread **/
	PRSem * extSemaphore; /**< Semaphore on which thread is waiting on **/
	PRBool gotSem;    /**< Identfier to indicate that semaphore is obtained **/
	PRMonitor *pMonitor;    /**< pointer to monitor used in thread synchronization **/
};

typedef struct ADSSC_ThreadData ADSSC_ThreadData;


#endif

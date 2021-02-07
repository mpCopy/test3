#ifndef APIDATAHELPER_H
#define APIDATAHELPER_H
// Copyright 2003 - 2014 Keysight Technologies, Inc  
#include "PtData.h"

class APIDataHelper {
public:
static void getData(void* parm, char type, int index, char*& data);
static void getData(void* parm, char type, int index, int& data);

static void getData(void* parm, char type, int index, double& data);


static int getSimDataType(ADSPtolemy::DataType type);

static int getSimData(PtData* data, double*& indep, double*& dep);

};

#endif //APIDATAHELPER_H

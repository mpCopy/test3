# Copyright Keysight Technologies 2008 - 2015  
import csv
import types

from BatchSim import *
from Design import *

class CSV_List(SweepModule):
    __module = "CSV_List"

    def load(self,container,arguments):
        self.__lineNumber = 1
        self.__fileName = None
        self.__sim = Simulation.getInstance()
        reader = self.__setup(arguments)
        sweepList = None
        sweepPlanList = None
        lenSweepData = 0

        for row in reader:
            if not sweepList:
                for i in row:
                    if type(i) != types.StringType:
                        error = CSV_List.__module
                        error += " error when parsing sweep variable names.\n"
                        error += "Variable names must be of string type.\n"
                        error += self.__errorFileLocation()
                        raise ADSException(error)
                sweepList = container.get(row)
                container.setSweeps(sweepList)
                lenSweepData = len(sweepList) 
            else:
                floatData = self.__convert(row)
                lenFloatData = len(floatData)
                if lenFloatData:
                    if len(floatData) != lenSweepData:
                        error = CSV_List.__module
                        error += ": Expected " + str(lenSweepData)
                        error += " number of points "
                        error += "but received " + str(len(floatData)) +".\n"
                        error += "Data: " +str(floatData) + "\n"
                        error += self.__errorFileLocation()
                        raise ADSException(error)
                    container.addPoints(floatData)
            self.__lineNumber += 1
            
    def __errorFileLocation(self):
        error  = "Error is occuring in file '"
        error += self.__fileName + "' around line number "
        error += str(self.__lineNumber)+"\n"
        return error
        
    def __convert(self,data):
        convertedData = []
        for i in data:
            fData = None
            singleQuote = i.find("'")
            doubleQuote = i.find("\"")
            if (singleQuote > 0 ) or (doubleQuote > 0):
                convertedData.append(i)
            else:
                if True:
                    fData = i;
                    fDataAll = ADSSim.Component_ValueConversion(i)
                    if fDataAll[0]:
                        fData = fDataAll[1]
                    try:
                        fData = float(fData)
                        convertedData.append(fData)
                    except:
                        convertedData.append(fData)
                else:
                    try:
                        fData = float(i)
                        convertedData.append(fData)
                    except:
                        convertedData.append(i)
        return convertedData
        
    def __setup(self,arguments):
        if not arguments:
            error  = CSV_List.__module
            error += " missing argument.\n"
            error += "Expected a file name.\n"
            raise ADSException(error)
        elif len(arguments) != 1:
            error  = CSV_List.__module
            error += " missing argument.\n"
            error += "Expected a file name.\n"
            raise ADSException(error)
        self.__fileName = arguments[0]
        if type(self.__fileName) != types.StringType:
            error = CSV_List.__module
            error += "file name should be a string type.\n"
            raise ADSException(error)

        fileObject = None        
        try:
            sim = Simulation.getInstance()
            filePath = sim.expandDataFilePath(self.__fileName)
            if filePath:
                self.__fileName = filePath
            fileObject = file(self.__fileName,"rb")
        except:
            error =  CSV_List.__module
            error+= ": Failed to open file '" + self.__fileName + "'\n"
            raise ADSException(error)
        reader = csv.reader(fileObject)
        return reader

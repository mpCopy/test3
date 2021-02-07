# Copyright Keysight Technologies 2008 - 2011  
import csv
import types
import time
import math
import re
from PostProcessing import *

class SPOutput(PostProcessingModule):
    __module = "SPOutput Module"
    
    def process(self,output,arguments):
        self.__fileName = None
        self.__setup(arguments)
        self.tag = None
        if not len(output):
            return
        for data in output:
            producer = data.producer()
            if producer == DataProducer.SPAnalysis:
                if self.__fileType == "touchstone":
                    (name,extension) = self.isSnP(self.__fileName)
                    if not extension:
                        netSize = self.getSize(data)
                        extension = "s"+str(netSize)+"p"
                    if data.getDimension() > 1:
                        nodes = data.nodes()
                        counter = 1
                        if self.tag:
                            self.__fileName = name + "_" + str(self.tag) + "_"
                        for i in nodes:
                            output.exportData(data,"touchstone",
                                              self.__format,
                                              self.__fileName+str(counter)+"."+extension,
                                              i
                                              )
                            counter += 1
                
                    else:
                        if self.tag:
                            self.__fileName = name + "_" + str(self.tag) + "." + extension
                        else:
                            self.__fileName = name + "." + extension
                        output.exportData(data,"touchstone",
                                          self.__format,
                                          self.__fileName
                                          )
                else:
                    if self.tag:
                        self.__fileName = name + "_" + str(self.tag)
                    if self.__fileType == "gmdif":
                        (name,extension) = self.isGmDif(self.__fileName)
                        self.__fileName = name + "." + extension
                    elif self.__fileType == "citifile":
                        (name,extension) = self.isCiti(self.__fileName)
                        self.__fileName = name + "." + extension
                    output.exportData(data,self.__fileType,
                                      self.__format,self.__fileName)

    def getSize(self,data):
        counter = 0
        dNames = data.dependentNames()
        size = len(dNames)
        startIndex = 0
        endIndex = 0
        i = 0
        name = dNames[i]
        if name.startswith("S["):
            for i in dNames:
                if i.startswith("S["):
                    counter += 1
        elif name.startswith("Y["):
            for i in dNames:
                if i.startswith("Y["):
                    counter += 1
        elif name.startswith("Z["):
            for i in dNames:
                if i.startswith("Z["):
                    counter += 1
        networkSize = int(math.sqrt(counter))
        return networkSize
        
    def isGmDif(self,fullName):
        fullName = fullName.strip()
        dot = fullName.rfind(".")
        name = None
        if dot > 0:
            extension = fullName[dot+1:]
            match = re.match("[M|m][D|d][F|f]",extension)
            if match:
                name = fullName[:dot]
                return (name,extension)
        name = fullName
        return (name,"mdf")

    def isCiti(self,fullName):
        fullName = fullName.strip()
        dot = fullName.rfind(".")
        name = None
        if dot > 0:
            extension = fullName[dot+1:]
            match = re.match("[C|c][T|t][I|i]",extension)
            if match:
                name = fullName[:dot]
                return (name,extension)
        name = fullName
        return (name,"cti")
    
    def isSnP(self,fullName):
        fullName = fullName.strip()
        dot = fullName.rfind(".")
        name = None
        if dot > 0:
            extension = fullName[dot+1:]
            match = re.match("[S|s][0-9]+[P|p]",extension)
            if match:
                name = fullName[:dot]
                return (name,extension)
        name = fullName
        return (name,None)

                            
    def __setup(self,arguments):
        self.__fileName = None
        self.__fileType = None
        self.__format = "MA"
        if not arguments or len(arguments) != 3:
            error  = SPOutput.__module
            error += " missing argument.\n"
            error += "Expected a name.\n"
            raise ADSException(error,SPOutput.__module)
        self.__fileName = arguments[0]
        self.__fileType = arguments[1]
        self.__format = arguments[2]
        if type(self.__fileName) != types.StringType:
            error = SPOutput.__module
            error += " expected an argument of type string for fileName.\n"
            raise ADSException(error,SPOutput.__module)
        if type(self.__fileType) != types.StringType:
            error = SPOutput.__module
            error += " expected an argument of type string for filetype.\n"
            raise ADSException(error,SPOutput.__module)
        if type(self.__format) != types.StringType:
            error = SPOutput.__module
            error += " expected an argument of type string for format.\n"
            raise ADSException(error,SPOutput.__module)
                            

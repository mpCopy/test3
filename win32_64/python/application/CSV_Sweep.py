# Copyright Keysight Technologies 2008 - 2014  
import csv
import types
import math

from BatchSim import *
from Design import *

class CSV_SweepType:
    Linear = 0
    Log = 1

LOG10 = 2.30258509299404568401799145468436420760110148862877

class CSV_SweepData:
    def  __init__(self,file,var,start,stop,step,sweepType):
        self.file = file 
        self.var = var
        self.start = start
        self.stop = stop
        self.step = step
        self.sweepType = sweepType
        self.points = []
        self.currentValue = start

    #LW:open this after 2015.01
    def generate(self):
        #self.generateByStim()
        self.generateInPython()
        
    def generateByStim(self):
        object = None
        sweepType = "linear"
        if self.sweepType == CSV_SweepType.Log:
            sweepType = "log"
        
        sweepStim = [sweepType, self.start, self.stop, self.step] 
        object = ADSSim.Component_SweepPoints_with_stim_create(
                    self.file,self.var,sweepStim)
    
        if object:
            size = ADSSim.Component_SweepPoints_size(object)
            for i in xrange(size):
                pt = ADSSim.Component_SweepPoints_point(object,i)
                if pt != None:
                    self.points.append(pt)
            ADSSim.Component_SweepPoints_delete(object)

    def generateInPython(self):
        self.start = self.__toFloat(self.start)
        self.stop = self.__toFloat(self.stop)
        self.step = self.__toFloat(self.step)

        if self.sweepType == CSV_SweepType.Log:
            error = None
            if self.step < 1:
                error = "Number of points in the Logarithmic sweep"
                error += " must be greater than 1.\n"
            elif self.start <=0 or self.stop <= 0:
                error = "Logarithmic sweep cannot include the point zero."
            if error:
                raise ADSException(error)

            if self.stop < self.start:
                temp = self.stop
                self.stop = self.start
                self.start = temp
            stepSize = math.exp(LOG10*math.log10(self.stop/self.start)/(self.step))
            pt = self.start
            self.points.append(pt)
            if self.stop > self.start:
                while(pt <= self.stop):
                    pt *= stepSize
                    self.points.append(pt)
                    
        elif self.sweepType == CSV_SweepType.Linear:
            pt = self.start
            if self.stop < self.start:
                if self.step > 0:
                    self.step = -self.step
                while(pt >= self.stop):
                    self.points.append(pt)
                    pt = pt + self.step
            else:
                if self.step < 0:
                    self.step = -self.step
                while(pt <= self.stop):
                    self.points.append(pt)
                    pt = pt + self.step

    def __toFloat(self,data):
        floatData = data
        try:
            floatData=float(data)
        except:
            error = CSV_Sweep.__module
            error += ": Failed to convert '"+ str(data) +"' to float.\n"
            error += self.__errorFileLocation()
            raise ADSException(error)
        return floatData


class CSV_Sweep(SweepModule):
    __module = "CSV_Sweep"

    def __addPoints(self,container,sweepList,size,index=0):
        error = 0
        
        if index == size:
            points = []
            for i in sweepList:
                points.append(i.currentValue)
            container.addPoints(points)
        else:
            sweep = sweepList[index]
            for i in sweep.points:
                sweep.currentValue = i
                error = self.__addPoints(container,sweepList,size,index+1)
        return error

    def load(self,container,arguments):
        self.__lineNumber = 1
        self.__fileName = None
        reader = self.__setup(arguments)
        sweepList = []
        sweepVars = []

        for row in reader:
            if len(row) == 0:
                continue
            if len(row) != 5:
                error = CSV_Sweep.__module
                error += " Expected 5 items in a row with the following format:\n"
                error += " sweepVariable,start,stop,step,sweepType \n"
                error += " Where sweepType is linear or log.\n"
                error += self.__errorFileLocation()
                raise ADSException(error)
            var = row[0]
            sweepVars.append(var)
            sweepType = row[4] 
            sweepType = sweepType.strip().lower()
            if sweepType.startswith("linear"):
                sweepType = CSV_SweepType.Linear
            elif sweepType.startswith("log"):
                sweepType = CSV_SweepType.Log
            else:
                error = CSV_Sweep.__module
                error += " unknown sweep type '" + sweepType + "'.\n"
                error += " Expected sweep type to be either 'linear' or 'log'.\n"
                error += self.__errorFileLocation()
                raise ADSException(error)
            sweep = CSV_SweepData(self.__fileName,var,row[1],row[2],row[3],sweepType)
            sweep.generate()
            sweepList.append(sweep)

            self.__lineNumber += 1
            
        _sweepVars = container.get(sweepVars)
        container.setSweeps(_sweepVars)
        self.__addPoints(container,sweepList,len(sweepList))
            
    def __errorFileLocation(self):
        error  = "Error is occuring in file '"
        error += self.__fileName + "' around line number "
        error += str(self.__lineNumber)+"\n"
        return error
                
    def __setup(self,arguments):
        if len(arguments) != 1:
            error  = CSV_Sweep.__module
            error += " missing argument.\n"
            error += "Expected a file name.\n"
            raise ADSException(error)
        self.__fileName = arguments[0]
        if type(self.__fileName) != types.StringType:
            error = CSV_Sweep.__module
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
            error =  CSV_Sweep.__module
            error+= ": Failed to open file '" + self.__fileName + "'\n"
            raise ADSException(error)
        reader = csv.reader(fileObject)
        return reader

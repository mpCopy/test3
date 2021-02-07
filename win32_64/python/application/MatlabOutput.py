# Copyright Keysight Technologies 2010 - 2017  
import re
import types
import time
import platform
import struct
import math
import types
import random
from PostProcessing import *
from Design import *
from Component import *

class MatlabFile:
    miINT8 = struct.pack("i",1)
    miUINT16 = struct.pack("i",4)
    miINT32 = struct.pack("i",5)
    miUINT32 = struct.pack("i",6)
    miDOUBLE = struct.pack("i",9)
    miMATRIX = struct.pack("i",14)
    

    mxCELL_CLASS = 0x1
    mxSTRUCT_CLASS = 0x2
    mxCHAR_CLASS = 0x4
    mxDOUBLE_CLASS = 0x6


    Files = {}
    
    def CreateMatlabFile(self,fileName):
        if MatlabFile.Files.has_key(fileName):
            matfileObject = MatlabFile.Files[fileName]
            matfileObject.referenceCount += 1
            return matfileObject
        matfileObject = MatlabFile(fileName,123)
        MatlabFile.Files[fileName] = matfileObject
        return matfileObject
        
    def CloseMatlabFile(self,matObject):
        if matObject.referenceCount == 1:
            matObject.close()
            #print >> sys.stderr,"Closing File ",matObject.fileName
        matObject.referenceCount -= 1

    CreateMatlabFile = classmethod(CreateMatlabFile)
    CloseMatlabFile = classmethod(CloseMatlabFile)

    def __init__(self,fileName,code=0):
        assert(code == 123)
        self.fileName = fileName
        self.fileName = self.fileName.strip()
        if len(self.fileName) == 0:
            simulation = Simulation.getInstance()
            designName = simulation.getDesignName()
            index = designName.rfind("/")
            if(index > 0):
                designName = designName[index+1:]
                pass
            index = designName.rfind("\\")
            if(index > 0):
                designName = designName[index+1:]
                pass
            index = designName.rfind("/")
            if(index > 0):
                designName = designName[index+1:]
                pass
            designName = designName.replace(".","_")
            self.fileName = designName + ".mat"
            pass
        self.file = file(self.fileName,"wb")
        self.writeHeader()
        self.referenceCount = 1

    def writeHeader(self):
        description = 'ADS simulation output, Platform: '
        description += platform.system()
        description += ", Created on:"
        description += time.strftime("%a, %d %b %Y %H:%M:%S",time.localtime())
        description = description.ljust(116,"\x00")
        
        self.file.write(description)
        subSysDataOffset = "\x00\x00\x00\x00\x00\x00\x00\x00"
        self.file.write(subSysDataOffset)
        version = struct.pack("h",0x0100)
        self.file.write(version)
        endian = 'IM'
        self.file.write(endian)

    def close(self):
        self.file.close()

class Matrix:
    def __init__(self,matlabFile):
        self.mat = matlabFile
        self.sizeLocation = 0
        self.dimensionLocation = []
        
    def _writeTag_(self,size=0):
        self.mat.file.write(MatlabFile.miMATRIX)
        self.sizeLocation = self.mat.file.tell()
        self.mat.file.write(struct.pack("i",size))
        return

    def _writeArrayFlags_(self,type,isComplex):
        self.mat.file.write(MatlabFile.miUINT32)
        self.mat.file.write(struct.pack('i',8))
        iValue = type
        if(isComplex):
           iValue = iValue | 0x0800
        self.mat.file.write(struct.pack("i",iValue))
        self.mat.file.write("\x00\x00\x00\x00")
        return

    def _writeDimensionsArray_(self,dimensions):
        self.mat.file.write(MatlabFile.miINT32)
        dimensionSize = 4*len(dimensions)
        self.mat.file.write(struct.pack('i',dimensionSize))
        for i in dimensions:
            self.dimensionLocation.append(self.mat.file.tell())
            self.mat.file.write(struct.pack('i',i))
        return

    def updateDimension(self,index,dimension):
        current = self.mat.file.tell()
        self.mat.file.seek(self.dimensionLocation[index])
        self.mat.file.write(struct.pack('i',dimension))
        self.mat.file.seek(current)

    def _writeArrayName_(self,name):
        size = len(name)
        aSize = int(math.ceil(float(size)/8)*8)
        self.mat.file.write(MatlabFile.miINT8)
        self.mat.file.write(struct.pack("i",aSize))
        self.mat.file.write(name.ljust(aSize,"\x00"))
        return

    def finalize(self):
        current = self.mat.file.tell()
        self.dataSize = current - self.sizeLocation - 4
        self.totalSize = self.dataSize + 8
        self.mat.file.seek(self.sizeLocation)
       
        self.mat.file.write(struct.pack("i",self.dataSize))
        self.mat.file.seek(current)
        return

class NumericArray(Matrix):
    def __init__(self,matlabFile,name,isComplex,dimensions):
        Matrix.__init__(self,matlabFile)
        self._writeTag_()
        self._writeArrayFlags_(MatlabFile.mxDOUBLE_CLASS,isComplex)
        self._writeDimensionsArray_(dimensions)
        self._writeArrayName_(name)
        self.__numericDataSize = 1
        for i in dimensions:
            self.__numericDataSize = self.__numericDataSize * i 

    def start(self):
        bytes = self.__numericDataSize*8
        self.mat.file.write(MatlabFile.miDOUBLE)
        self.mat.file.write(struct.pack("i",bytes))

    def write(self,value):
        if type(value) == types.ListType:
            for i in value:
                self.mat.file.write(struct.pack("d",i))
        else:
            self.mat.file.write(struct.pack("d",value))

class DoubleValue(NumericArray):
    def __init__(self,matlabFile,name,value):
        NumericArray.__init__(self,matlabFile,name,False,[1,1])
        self.start()
        self.write(value)
        self.finalize()

class ComplexValue(NumericArray):
    def __init__(self,matlabFile,name,realValue,imagValue):
        NumericArray.__init__(self,matlabFile,name,True,[1,1])
        self.start()
        self.write(realValue)
        self.start()
        self.write(imagValue)
        self.finalize()

class CharacterArray(Matrix):
    def __init__(self,matlabFile,name,data):
        Matrix.__init__(self,matlabFile)
        # TFS131118
        length = 0
        if data:
            length = len(data)

        self._writeTag_()
        self._writeArrayFlags_(MatlabFile.mxCHAR_CLASS,False)
        self._writeDimensionsArray_([1,length])
        self._writeArrayName_(name)
        self.mat.file.write(MatlabFile.miUINT16)
        self.mat.file.write(struct.pack("i",length*2))
        size = 0
        # TFS131118
        if data:
            for i in data:
                self.mat.file.write(struct.pack("h",struct.unpack("h",i + "\x00")[0]))
                size += 2
       

        leftOver = size % 8
        if (leftOver > 0):
            padSize = 8 - leftOver
            pad = str("").ljust(padSize,"\x00")
            self.mat.file.write(pad)
        self.__finalize()

    def __finalize(self):
        Matrix.finalize(self)
        return

    def finalize(self):
        return

class Cell(Matrix):
    def __init__(self,matlabFile,name,dimensions):
        Matrix.__init__(self,matlabFile)
        self._writeTag_()
        self._writeArrayFlags_(MatlabFile.mxCELL_CLASS,False)
        self._writeDimensionsArray_(dimensions)
        self._writeArrayName_(name)

class Struct(Matrix):
    def __init__(self,matlabFile,name,fieldNames):
        Matrix.__init__(self,matlabFile)
        self._writeTag_()
        self._writeArrayFlags_(MatlabFile.mxSTRUCT_CLASS,False)
        self._writeDimensionsArray_([1,1])
        self._writeArrayName_(name)

        flag = 4
        flag = flag << 16
        flag = flag | 5

        fieldLength = 0
        for i in fieldNames:
            length = len(i) + 1
            if (length > fieldLength):
                fieldLength = length
        
        fieldLength = 32
        self.mat.file.write(struct.pack("i",flag))
        self.mat.file.write(struct.pack("i",fieldLength))

        size = len(fieldNames)*fieldLength
        self.mat.file.write(MatlabFile.miINT8)
        self.mat.file.write(struct.pack("i",size))
        for i in fieldNames:
            self.mat.file.write(i[0:fieldLength-2].ljust(fieldLength,'\x00'))
            
class Data:
    def __init__(self,dataBlock):
        self.dataBlock = dataBlock
        self.data = None
        self.numberOfBlocks = 0
        
    def finalize(self):
        self.data.finalize()
        return

    def initialize(self):
        self.numberOfBlocks += 1
        if(self.data == None):
            self.data = Struct(self.dataBlock.dataset.mat,"data",["sweep",
                                                                  "independent",
                                                                  "dependents"]
                               )
        else:
            self.data.updateDimension(1,self.numberOfBlocks)
        return

    def addSweepData(self,sweeps):
        if sweeps == None:
            sweeps = []
        sweepCell = Cell(self.dataBlock.dataset.mat,"sweep",[1, len(sweeps)])
        for i in sweeps:
            T = type(i)
            if T == types.StringType:
                CharacterArray(self.dataBlock.dataset.mat,"",i)
            elif (T == types.IntType) or (T == types.FloatType):
                DoubleValue(self.dataBlock.dataset.mat,"",float(i))
            elif T == types.ComplexType:
                ComplexValue(self.dataBlock.dataset.mat,"",i)
        sweepCell.finalize()
        return

    def createIData(self,numberOfPoints):
        
        iData = NumericArray(self.dataBlock.dataset.mat,"",False,[1,numberOfPoints])    
        return iData

    def createDData(self,numberOfPoints,numberOfDependents,isComplex):
        
        dData = NumericArray(self.dataBlock.dataset.mat,"",isComplex,
                             [numberOfDependents,numberOfPoints])   
        return dData

class DataBlock:
    def __init__(self,dataset):
        self.block = None
        self.dataset = dataset

    def finalize(self):
        self.block.finalize()
        return

    def initialize(self,name,type,sweepVariables,independentVariable,dependentVariables):
        self.block = Struct(self.dataset.mat,"datablock",["name",
                                                          "type",
                                                          "sweeps",
                                                          "independent",
                                                          "dependents",
                                                          "data"])
        self.addBlock(name,type,sweepVariables,independentVariable,dependentVariables)
    
    def addBlock(self,name,type,sweepVariables,independentVariable,dependentVariables):
        CharacterArray(self.dataset.mat,"name",name)
        CharacterArray(self.dataset.mat,"type",type)
        cell = Cell(self.dataset.mat,"sweepVariables",[1,len(sweepVariables)])
        for i in sweepVariables:
            CharacterArray(self.dataset.mat,"",i)
        cell.finalize()
        CharacterArray(self.dataset.mat,"independent",independentVariable)
        cell = Cell(self.dataset.mat,"dependent",[1,len(dependentVariables)])
        for i in dependentVariables:
            CharacterArray(self.dataset.mat,"",i)
        cell.finalize()



class Dataset:
    DatasetObjects = {}
    
    def CreateDatasetObject(self,fileName,dataName,datasetFileName):
        if Dataset.DatasetObjects.has_key(fileName):
            datasetObject = Dataset.DatasetObjects[fileName]
            datasetObject.referenceCount += 1
            return datasetObject
        datasetObject = Dataset(fileName,dataName,datasetFileName,123)
        Dataset.DatasetObjects[fileName] = datasetObject
        return datasetObject
        
    def FinalizeDatasetObject(self,datasetObject):
        if datasetObject.referenceCount == 1:
            datasetObject.finalize(123)
        datasetObject.referenceCount -= 1

    CreateDatasetObject = classmethod(CreateDatasetObject)
    FinalizeDatasetObject = classmethod(FinalizeDatasetObject)
    
    
    def __init__(self,matFileName,dataName,datasetFileName,code=0):
        assert(code == 123)
        self.mat = MatlabFile.CreateMatlabFile(matFileName)
        self.dataBlocks = None
        self.__initialize__(dataName,datasetFileName)
        self.numberOfBlocks = 0
        self.referenceCount = 1

    def finalize(self,code=0):
        assert(code == 123)
        if self.dataBlocks:
            self.dataBlocks.finalize()
        else:
            self.writeEmptyDataBlock()
        self.dataset.finalize()
        MatlabFile.CloseMatlabFile(self.mat)
        self.mat = None

    def __initialize__(self,dataName,datasetFileName):
        #print >> sys.stderr , "Matlab initialize ", dataName,datasetFileName
        self.dataset = Struct(self.mat,dataName,["name","date","dataBlocks"])        
        CharacterArray(self.mat,"",datasetFileName)
        CharacterArray(self.mat,"",time.strftime("%a, %d %b %Y %H:%M:%S",time.localtime()))
        return

    def writeEmptyDataBlock(self):
        CharacterArray(self.mat,"","")
        return

    def createBlock(self,name,type,sweepVariables,independentVariable,dependentVariables):
        self.numberOfBlocks += 1
        #print >> sys.stderr,"Create Block", self.numberOfBlocks
        if(self.dataBlocks == None):
            self.dataBlocks = DataBlock(self)
            self.dataBlocks.initialize(name,type,sweepVariables,independentVariable,dependentVariables)
        else:
            self.dataBlocks.block.updateDimension(1,self.numberOfBlocks)
            self.dataBlocks.addBlock(name,type,sweepVariables,independentVariable,dependentVariables)
        return self.dataBlocks
    
    
class MatlabOutput(PostProcessingModule):
    __module = "Matlab Output Module"
    producerType = {}
    producerType[DataProducer.TranAnalysis] = "Transient"
    producerType[DataProducer.DCAnalysis] = "DC"
    producerType[DataProducer.ACAnalysis] = "AC"
    producerType[DataProducer.SPAnalysis] = "S_Param"
    producerType[DataProducer.HBAnalysis] = "HarmonicBalance"
    producerType[Expression] = "MeasurementExpression"
    RegMap = {}
    RegMap["*"] = ".*"
    RegMap["?"] = "."
    RegMap["("] = "\\("
    RegMap[")"] = "\\)"
    RegMap["["] = "\\["
    RegMap["]"] = "\\]"
    RegMap["$"] = "\\$"
    RegMap["^"] = "\\^"
    RegMap["."] = "\\."
    RegMap["{"] = "\\{"
    RegMap["}"] = "\\}"
    RegMap["|"] = "\\|"

    def getType(self,producer):
        if MatlabOutput.producerType.has_key(producer):
            return MatlabOutput.producerType[producer]
        return "Unknown"


    def checkMatch(self,name):
        for i in self.__nodeFilter:
            if i.match(name):
                return True
        return False


    def indexDependentName(self,names,filterIndex):
        if not filterIndex:
            return names
        __names = []
        for i in filterIndex:
            __names.append(names[i-1])
        return __names
        
    def indexData(self,data,filterIndex):
        if not filterIndex:
            return data[1:]
        __data = []
        for i in filterIndex:
            __data.append(data[i])
        return __data

    def processRealBlock(self,dataset,data):
        iNames = data.independentNames()
        iSize = len(iNames)
        sweepNames = iNames[:(len(iNames)-1)]
        independentName = iNames[len(iNames)-1]
        numberOfPoints = data.getNumberOfPoints(data.getDimension())
        numberOfDependents = len(data.dependentNames())
        dependentNames = data.dependentNames()
        numberOfDependents = len(dependentNames)
        if numberOfDependents == 0:
            return False
        filterIndex = None
        if self.__nodeFilter:
            filterIndex = []
            if len(self.__nodeFilter) > 0:
                index = 1
                for i in dependentNames:
                    if self.checkMatch(i):
                        filterIndex.append(index)
                    index += 1

        
        if (filterIndex != None):
            if (len(filterIndex) == 0):
                return False   
        dependentNames = self.indexDependentName(dependentNames,filterIndex)
        numberOfDependents = len(dependentNames)
        dataBlock = dataset.createBlock(data.name(),
                                        self.getType(data.producer()),
                                        sweepNames,
                                        independentName,
                                        dependentNames)
        
        mdata = Data(dataBlock)
        if numberOfPoints < 0:
            numberOfPoints = 1
        reverseData = []
        for d in data:
            reverseData.append(d)
        reverseData.reverse()
        for node in reverseData:
            mdata.initialize()
            #TFS 133021, 108581
            sweepIndepData = node.independentData()
            #TFS 140075
            if sweepIndepData:
                sweepIndepData.reverse()
            mdata.addSweepData(sweepIndepData)
            iData = mdata.createIData(numberOfPoints)
            iData.start()
            for points in node:
                iData.write(points[0])
              
            iData.finalize()
            dData = mdata.createDData(numberOfPoints,numberOfDependents,False)
            dData.start()
            for points in node:
                __data = self.indexData(points,filterIndex)
                dData.write(__data)

            dData.finalize()
        mdata.finalize()
        return True

    def processComplexBlock(self,dataset,data):
        iNames = data.independentNames()
        iSize = len(iNames)
        sweepNames = iNames[:(len(iNames)-1)]
        independentName = iNames[len(iNames)-1]
        numberOfPoints = data.getNumberOfPoints(data.getDimension())
        numberOfDependents = len(data.dependentNames())
        dependentNames = data.dependentNames()
        numberOfDependents = len(dependentNames)
        if numberOfDependents == 0:
            return False
        filterIndex = None
        if self.__nodeFilter:
            filterIndex = []
            if len(self.__nodeFilter) > 0:
                index = 1
                for i in dependentNames:
                    if self.checkMatch(i):
                        filterIndex.append(index)
                    index += 1

        
        if (filterIndex != None):
            if (len(filterIndex) == 0):
                return False   
        dependentNames = self.indexDependentName(dependentNames,filterIndex)
        numberOfDependents = len(dependentNames)
        dataBlock = dataset.createBlock(data.name(),
                                        self.getType(data.producer()),
                                        sweepNames,
                                        independentName,
                                        dependentNames)

        mdata = Data(dataBlock)
        if numberOfPoints < 0:
            numberOfPoints = 1
            pass
        reverseData = []
        for d in data:
            reverseData.append(d)
        reverseData.reverse()
        for node in reverseData:                
            mdata.initialize()
            #TFS 133021, 108581
            sweepIndepData = node.independentData()
            # TFS140075
            if sweepIndepData:
                sweepIndepData.reverse()
            mdata.addSweepData(sweepIndepData)
            iData = mdata.createIData(numberOfPoints)
            iData.start()
            for points in node:
                strpoints = str(points)
                if strpoints.find("[<NULL>,") == 0:
                    indep = 0
                else:
                    indep = points[0]
                iData.write(indep)
            iData.finalize()
            dData = mdata.createDData(numberOfPoints,numberOfDependents,True)
            dData.start()
            if len(node) > 1:
                for points in node:
                        realVector = []
                        actualData = self.indexData(points,filterIndex)
                        for i in actualData:
                            T = type(i)
                            if (T == types.ComplexType):
                                realVector.append(i.real)
                            elif (T == types.StringType):
                                realVector.append(0)
                            else:
                                realVector.append(float(i))
                                       
                        dData.write(realVector)
                dData.finalize()
                dData.start()
                for points in node:
                    imagVector = []
                    actualData = self.indexData(points,filterIndex)
                    for i in actualData:
                        T = type(i)
                        if (T == types.ComplexType):
                            imagVector.append(i.imag)
                        else:
                            imagVector.append(0)
                
                    dData.write(imagVector)
            dData.finalize()
        mdata.finalize()
        return True

    def convertToRegularExpression(self,wildCardExpression):
        regularExpression = '^'
        for i in wildCardExpression:
            if MatlabOutput.RegMap.has_key(i):
                regularExpression += MatlabOutput.RegMap[i]
            else:
                regularExpression += i
        regularExpression += "$"
        return regularExpression


    def setup(self,network,instance,arguments):
        self.__fileName = None
        self.__analysis = None
        self.__nodeFilter = None
        self.__setup(arguments)
        simulation = Simulation.getInstance()
        designName = simulation.getDesignName()
        index = designName.rfind("/")
        if(index > 0):
            designName = designName[index+1:]
        index = designName.rfind("\\")
        if(index > 0):
            designName = designName[index+1:]
        index = designName.rfind("/")
        if(index > 0):
            designName = designName[index+1:]
        designName = designName.replace(".","_")
        self.dataset = Dataset.CreateDatasetObject(self.__fileName,designName,designName) 

     
        
        if (self.__nodeFilter):
            a = network.getAnalysisQueue()
            analysisList = []
            aFlags = {"DC":1,"AC":1,"SP":1,"HB":1,"Tran":1}
            for i in a:
                analysis = i.getDefinitionName()
               # print analysis," ",aFlags.has_key(analysis)
                if aFlags.has_key(analysis):
                    analysisList.append(i)
                    pass
                pass
           # print analysisList
            outputPlan = Device("OutputPlan",[],
                                {"Type":"Output",
                                 "UseNodeNestLevel":False,
                                 "UseEquationNestLevel":False,
                                 "UseSavedEquationNestLevel":False,
                                 "UseCurrentNestLevel":False,
                                 "UseDeviceCurrentNestLevel":False,
                                 "UseDeviceVoltageNestLevel":False,
                                 })
            self.__nodeFilter = self.__nodeFilter.split(";")
            temp = []
            for i in self.__nodeFilter:      
                j = self.convertToRegularExpression(i)
                outputPlan.setParameterValue("NodeRegExpr",j)
                temp.append(re.compile(j))
                            
            self.__nodeFilter = temp
            network.addDevice(outputPlan)
            for i in analysisList:
                i.setParameterValue("OutputPlan",outputPlan.getInstanceName(True))
        return
        
    def process(self,output,arguments):
        if (len(output) == 0):
            Dataset.FinalizeDatasetObject(self.dataset)
            return
        simulation = Simulation.getInstance()
        designName = simulation.getDesignName()
        index = designName.rfind("/")
        if(index > 0):
            designName = designName[index+1:]
        index = designName.rfind("\\")
        if(index > 0):
            designName = designName[index+1:]
        designName = designName.replace(".","_")
        outputName = output.getFileName()
        if outputName.rfind(".ds") < 0:
            outputName = outputName + ".ds"

        dataWritten = False
        for data in output:
            if data:
                producer = data.producer()
                status = False
                if ((producer == DataProducer.TranAnalysis) or
                    (producer == DataProducer.DCAnalysis)):
                    if((self.__analysis == -1) or (self.__analysis == producer)):
                        status = self.processRealBlock(self.dataset,data)
                elif ((producer == DataProducer.ACAnalysis) or
                      (producer == DataProducer.SPAnalysis) or
                      (producer == DataProducer.HBAnalysis)):
                    if((self.__analysis == -1) or (self.__analysis == producer)):
                        status = self.processComplexBlock(self.dataset,data)
                        pass
                        pass
                elif (self.__analysis == -1):
                    status = self.processComplexBlock(self.dataset,data)

        Dataset.FinalizeDatasetObject(self.dataset)
        
        return

    def __setup(self,arguments):
        if not arguments or (len(arguments) < 2):
            error  = MatlabOutput.__module
            error += " missing arguments.\n"
            raise ADSException(error,MatlabOutput.__module)
        self.__fileName = arguments[0]
        self.__analysis = arguments[1]
        self.__useNodeFilter = arguments[2]
        self.__nodeFilter = None
        if self.__useNodeFilter:
            if len(arguments) > 3:
                self.__nodeFilter = arguments[3]
                if len(self.__nodeFilter) == 0:
                    self.__nodeFilter = None
        if 0:
            print >> sys.stderr , "----------------------------------------------------"
            print >> sys.stderr , arguments
            print >> sys.stderr , self.__fileName
            print >> sys.stderr , self.__analysis
            print >> sys.stderr , self.__useNodeFilter
            print >> sys.stderr , self.__nodeFilter
            print >> sys.stderr , "----------------------------------------------------"
        if type(self.__fileName) != types.StringType:
            error = MatlabOutput.__module
            error += " expected an argument of type string for file name.\n"
            raise ADSException(error,MatlabOutput.__module)         

        
        if type(self.__analysis) != types.StringType:
            error = MatlabOutput.__module
            error += " expected an argument of type string for analysis argument.\n"
            raise ADSException(error,MatlabOutput.__module)
        else:
             self.__analysis =  self.__analysis .lower()
             if self.__analysis.find("all") == 0:
                 self.__analysis = -1
             elif self.__analysis.find("tr") == 0:
                 self.__analysis = DataProducer.TranAnalysis
             elif self.__analysis.find("dc") == 0:
                 self.__analysis = DataProducer.DCAnalysis
             elif self.__analysis.find("ac") == 0:
                 self.__analysis = DataProducer.ACAnalysis
             elif self.__analysis.find("sp") == 0:
                 self.__analysis = DataProducer.SPAnalysis
             elif self.__analysis.find("s_param") == 0:
                 self.__analysis = DataProducer.SPAnalysis
             elif self.__analysis.find("hb") == 0:
                 self.__analysis = DataProducer.HBAnalysis
             elif self.__analysis.find("harmonicbalance") == 0:
                 self.__analysis = DataProducer.HBAnalysis
             else:
                 error = MatlabOutput.__module
                 error += " unsupported analysis type " + self.__analysis
                 raise  ADSException(error,MatlabOutput.__module)

        if self.__nodeFilter:
            if type(self.__nodeFilter) != types.StringType:
                error = MatlabOutput.__module
                error += " expected an argument of type string for node filter argument.\n"
                raise ADSException(error,MatlabOutput.__module)
        

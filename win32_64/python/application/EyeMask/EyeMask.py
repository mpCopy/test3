# Copyright Keysight Technologies 2009 - 2015  
from ADSSim_Modules import *
from Design import *
from EyeMaskDescriptor import *


class MaskValue:
    def __init__(self):
        self.x = 0
        self.y = 0

    def __str__(self):
        return ("("+str(self.x) + "," + str(self.y) +")")

    def __repr__(self):
        return str(self)
    

class Mask:
    def __init__(self):
        self.points = []


class MaskContainer:
    def __init__(self):
        self.masks = []


class EyeMask(ModelExtractor):
    descriptor = EyeMask_Descriptor
    
    def __init__(self,instance):
	ModelExtractor.__init__(self,instance)
	self.simulation = Simulation.getInstance()
	self.maskContainer = None
	
    def setup(self,network):
	status = False
	self.network = network
        self.__fileName = self.data[FileNameID]
        self.__name = self.data[NameID]
        try:
            filePath = self.simulation.expandDataFilePath(self.__fileName)
            if filePath:
                self.__fileName = filePath
            fileObject = file(self.__fileName,"rb")
            if self.parseFile(fileObject):
                if self.maskContainer == None:
                    self.error("Unable to generate mask polygons.")
                    return False
                if len(self.maskContainer.masks) == 0:
                    self.error("Unable to generate mask polygons.")
                    return False
            else:
                self.error("Unable to parse mask file.")
                return False
        except:
            error = "Unable to access mask file '" + self.__fileName + "'." 
            self.simulation.printFatalError("EyeMask parser '"+self.__name+"'",error)
            return False


        mask = self.simulation.TDM_createMask(self.__name,
                                              len(self.maskContainer.masks))

        counter = 0
        for i in self.maskContainer.masks:
            for j in i.points:
                self.simulation.TDM_defineMaskPoints(mask,counter,j.x,j.y)
            counter += 1
        
        return True

    def error(self,msg):
        self.simulation.printFatalError("EyeMask parser '"+self.__name+"'",msg)

    def removeComments(self,maskBuffer):
        status = 0
        sIndex = maskBuffer.find("/*")
        if(sIndex >= 0):
            fIndex = maskBuffer.find("*/",sIndex)
            if fIndex < 0:
                self.error("Unterminated comment.")
                return (-1,None)
            else:
                maskBuffer = maskBuffer[0:sIndex] + maskBuffer[fIndex+2:]
                status = 1
        
        return (status,maskBuffer)

    def parseData(self,maskLines,i,maskIndex,maskSize):
        mask = Mask()
        iReturn = -1
        status = False
        listSize = len(maskLines)
        
        if((i+2+maskSize) > listSize):
            self.error("Not enough data point given.")
            return (None,-1,0)
        
        for j in xrange(maskSize):
            line = maskLines[i+2+j]
            lineList = line.split(",")
            if len(lineList) != 2:
                self.error("Syntax error data points should be given using two points x,y")
                return  (None,-1,0)
            maskValue = MaskValue()
            maskValue.x = lineList[0].strip().lower()
            maskValue.y = lineList[1].strip().lower()
           
            if maskValue.x == "min":
                maskValue.x = -1000
            elif maskValue.x == "max":
                maskValue.x = 1000
            if maskValue.y == "min":
                maskValue.y = -1000
            elif maskValue.y.lower() == "max":
                maskValue.y = 1000
            try:
                maskValue.x = float(maskValue.x)
                maskValue.y = float(maskValue.y)
            except:
                self.error("Unable to convert to float " + str( maskValue.x) + "," +  str(maskValue.y))
                return (None,-1,False)
          
            mask.points.append(maskValue)
        
        return (mask,i+1+maskSize,True)
    

    def parseFile(self,mask):
        maskBuffer = ""
        line = mask.readline()
        startSetup = False
        while(line):
            line = line.strip()
            lLine = line.lower()
            if lLine.find("setup") == 0:
                startSetup = True
            if startSetup:
                line = None
            else:
                maskBuffer = maskBuffer + line + "\n"
                line = mask.readline()

    
        status = 1
        while(status):
            (status,maskBuffer) = self.removeComments(maskBuffer)
            if status == -1:
                return False
       
        maskLines = maskBuffer.split("\n")
        temp = []
        for i in maskLines:
            b = i.strip()
            if len(b) > 0:
                temp.append(b)
        maskLines = temp
    
        i = 0
        size = len(maskLines)
        maskContainer = MaskContainer()

        while(i < size):
            line = maskLines[i]
            try:
                maskIndex = int(line)
                maskSize = 0
                if (i+1) < size:
                    line2 = maskLines[i+1]
                    try:
                        maskSize = int(line2)
                    except:
                        self.error("Unable to get size of polygon. " + line2)
                        return False
                    
                else:
                    self.error("No enough data points given to create a polygon.")
                (mask,i,status) = self.parseData(maskLines,i,maskIndex,maskSize)
                
                if not status:
                    return False
                maskContainer.masks.append(mask)
            except:
                pass
                
            i += 1
        
        self.maskContainer = maskContainer
        return True



GlobalLoaders.getComponentLoader().register(EyeMask)







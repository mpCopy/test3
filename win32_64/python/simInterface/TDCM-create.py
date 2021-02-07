# Copyright Keysight Technologies 2009 - 2011  
import os
import datetime
import getopt
import sys
import xml.parsers.expat
import shutil
import stat
import py_compile
import shutil

def printStatus(message):
    print >> sys.stderr,"Status:",message


class DesignKit:
    designKitDIR = "design_kit"
    docDIR = "doc"
    circuitDIR = "circuit"
    symbolsDIR = "circuit/symbols"
    aelDIR = "circuit/ael"
    modelsDIR = "circuit/models"
    bitmapsDIR = "circuit/bitmaps"
    bitmapPCDIR= "circuit/bitmaps/pc"
    bitmapUNIXDIR = "circuit/bitmaps/unix"
    recordsDIR = "circuit/records"
    deDIR = "de"
    deAELDIR = "de/ael"
    libDIR = "lib"
    sourceDIR = "source"
    sourceCodeDIR = "source/measurements"
    sourceConstraintsDIR = "source/constraints"
    sourceSymbolsDIR = "source/symbols"
    sourceBitmapDIR = "source/bitmaps"
    sourceBitmapPCDIR = "source/bitmaps/pc"
    sourceBitmapUNIXDIR = "source/bitmaps/unix"
    sourceInternalDIR = "source/measurements/.internal"
    
    dirList = [designKitDIR,
               docDIR,
               circuitDIR,
               symbolsDIR,
               aelDIR,
               modelsDIR,
               bitmapsDIR,
               bitmapPCDIR,
               bitmapUNIXDIR,
               recordsDIR,
               deDIR,
               deAELDIR,
               libDIR,
               sourceDIR,
               sourceCodeDIR,
               sourceConstraintsDIR,
               sourceInternalDIR,
               sourceSymbolsDIR,
               sourceBitmapDIR,
               sourceBitmapPCDIR,
               sourceBitmapUNIXDIR
               ]

    
    def __init__(self,name,version,description,revision="Rev 1.0"):
        self.name = name
        self.version = version
        self.description = description
        self.revision = revision
        self.adsLibFile = None
        self.bootFile = None
        self.paletteFile = None
        self.varName = None
        self.generateSourceOnly = False
        self.cleanCVS = False

    def __makedir__(self,directory):
        try:
            os.stat(directory)
        except:
            printStatus("Creating directory '"+str(directory)+"'")
            os.mkdir(directory)

    def __createDirectories__(self):
        for directory in DesignKit.dirList:
            if self.generateSourceOnly:
                if directory.find("source") == 0:
                    self.__makedir__(directory)
            else:
                self.__makedir__(directory)
            
    def __createConfigFile__(self):
        try:
            os.stat("source/config.xml")
        except:
            printStatus("Creating config.xml ")
            config = file("source/config.xml","w")
            print >> config,'<?xml version="1.0" encoding="UTF-8"?>'
            print >> config,'<Package Name="'+self.name +'" Version="'+self.version +'" Type="Compliance">'
            print >> config,'\n\n<Symbol Name="SYM_'+self.name+'"/>'
            print >> config,'<Icon Name="'+self.name+'"/>'
            print >> config,'<Description>'
            print >> config,'Computes the '+ self.name + ' measurements and performs standard compliance tests.'
            print >> config,'</Description>\n\n'
            
            print >>config,'<ParameterSet>'
            print >>config,'<ParameterGroup>'
            print >>config,'<Parameter Name="SpeedGrade" Label="Speed Grade" DataType="RealType" Range="[0:inf]" Default="800">'
            print >>config,'</Parameter>'
            print >>config,'</ParameterGroup>'
            print >>config,'</ParameterSet>\n\n'

            print >>config,'<ProbeSet>'
            print >>config,'<SignalTypes Name="Clock" Label="Clock"/>'
            print >>config,'</ProbeSet>'

            print >>config,'<MeasurementSet>'
            print >>config,'<MeasurementGroup Name="ClockMeasurements" Label="Clock Measurements">'
            print >>config,'<Signals Type="Clock" Name="Clock"/>'
            print >>config,'<Measurement Name="clock.period" Label="Clock Period">'
            print >>config,'<Description>Measures the clock period.</Description>'
            print >>config,'</Measurement>'
            print >>config,'</MeasurementGroup>'
            print >>config,'</MeasurementSet>\n\n'            
            print >>config,"</Package>"
            config.close()

    def __createADSlibFile__(self):
        self.adslibFile = file(DesignKit.designKitDIR+"/ads.lib","w")
       # print >> self.adslibFile,self.name.upper(),"| | de/ael/boot |",self.version
       
    def __createBootFile__(self):
        self.bootFile = file(DesignKit.deAELDIR+"/boot.ael","w")

        print self.name
        print self.version
        VAR_NAME = "TDCM_" + self.name.replace(".","_") + "_" + self.version.replace(".","_") 
       
        buffer  = 'decl '+VAR_NAME+'_PATH = expandenv(designKitRecord[1]);\n'
        buffer += 'decl '+VAR_NAME+'_BITMAP_DIR = sprintf("%s/circuit/bitmaps/%s/",'
        buffer += VAR_NAME+'_PATH,on_PC?"pc":"unix");\n'
        
        buffer += 'decl '+VAR_NAME+'_CIRCUIT_AEL_DIR = sprintf("%s/circuit/ael/",'
        buffer += VAR_NAME+'_PATH);\n'
        
        buffer += 'decl '+VAR_NAME+'_CIRCUIT_MODEL_DIR = sprintf("%s/circuit/models/",'
        buffer += VAR_NAME+'_PATH);\n'

        buffer += 'decl '+VAR_NAME+'_DE_AEL_DIR = sprintf("%s/de/ael/",'
        buffer += VAR_NAME+'_PATH);\n'
        buffer += 'load(strcat('+VAR_NAME+'_DE_AEL_DIR,"palette"),"CmdOp");\n'
        print >> self.bootFile,buffer
        self.varName = VAR_NAME

    def __createPaletteFile__(self):
        self.paletteFile = file(DesignKit.deAELDIR+"/palette.ael","w")
        
        VAR_NAME = "TDCM_" + self.name.replace(".","_") + "_" + self.version.replace(".","_") 
        paletteLoader  = 'decl '+VAR_NAME+'_PATH = expandenv(designKitRecord[1]);\n'
        paletteLoader += 'decl '+VAR_NAME+'_BITMAP_DIR = sprintf("%s/circuit/bitmaps/%s/",'
        paletteLoader += VAR_NAME+'_PATH,on_PC?"pc":"unix");\n'
        print >> self.paletteFile , paletteLoader
        
       
    def __createAboutFile__(self):
        aboutFile = file(os.path.join(DesignKit.docDIR,"about.txt"),"w")
        buffer  = "Name: " + self.name.upper() + "\n"
        buffer += "Version: " + self.version + "\n"
        d = datetime.date.today()
        buffer += "Date: "+str(d.month)+"/"+str(d.day)+"/"+str(d.year)+"\n"
        buffer += "Description: "+str(self.description)+"\n"
        buffer += "Revision History: "+str(self.revision)+"\n"
        print >> aboutFile,buffer
        sourceDoc = os.path.join(DesignKit.sourceDIR,"doc")
        docFiles = None
        try:
            docFiles = os.listdir(sourceDoc)
            for i in docFiles:
                if i != "CVS":
                    shutil.copy(os.path.join(sourceDoc,i),DesignKit.docDIR)
                    print >> sys.stderr,"Copied doc :",os.path.join(sourceDoc,i)
                    
        except:
            pass
        aboutFile.close()
        
    def __buildPackage__(self):
        b = Builder(self.name,self)
        b.setup()

    def rm_rf(self,d):
        if os.path.isdir(d):
            shutil.rmtree(d)
        
    def __delete__CVS__(self,dirList):
        for i in dirList:
            s = os.stat(i)
            if stat.S_ISDIR(s[stat.ST_MODE]):
                if i.find("CVS") >= 0:
                    self.rm_rf(i)
                else:
                    head = os.listdir(i)
                    os.chdir(i)
                    self.__delete__CVS__(head)
                    os.chdir("..")
                    
    def setup(self):
        self.__makedir__(self.name)
        os.chdir(self.name)
        self.__createDirectories__()
        if not self.generateSourceOnly:
            self.__createADSlibFile__()
            self.__createBootFile__()
            self.__createAboutFile__()
            self.__createPaletteFile__()
        self.__createConfigFile__()
        os.chdir("..")
        self.__buildPackage__()
        if self.cleanCVS:
            os.chdir(self.name)
            head = os.listdir(".")
            self.__delete__CVS__(head)
            os.chdir("..")
        
        
class PackageExpander:
    def __init__(self,package):
        self.package = package
        self.designkit = None

    def setup(self):
        name = self.package.name
        version = self.package.version
        description = "TDM package"
        if self.package.description.data:
            description = self.package.description.data
        print "N=",name,"V=",version,"D=",description
        self.designKit = DesignKit(name,version,description)
        self.designKit.setup()


def start_element(name, attrs):
    if name == "Package":
        Builder.Instance.packageHandlerStart(attrs)
    elif name == "Symbol":
        Builder.Instance.packageItemHandlerStart("Symbol",attrs)
    elif name == "Icon":
        Builder.Instance.packageItemHandlerStart("Icon",attrs)
    elif name == "Description":
        Builder.Instance.descriptionHandlerStart(attrs)
    elif name == "ParameterSet":
        Builder.Instance.parameterSetHandlerStart(attrs)
    elif name == "ParameterGroup":
        Builder.Instance.parameterGroupHandlerStart(attrs)
    elif name == "Parameter":
        Builder.Instance.parameterHandlerStart(attrs)
    elif name == "UIOptions":
        Builder.Instance.uiOptionsHandlerStart(attrs)
    elif name == "Argument":
        Builder.Instance.argumentHandlerStart(attrs)
    elif name == "ProbeSet":
        Builder.Instance.probeSetHandlerStart(attrs)
    elif name == "SignalTypes":
        Builder.Instance.signalTypesHandlerStart(attrs)
    elif name == "MeasurementSet":
        Builder.Instance.measurementSetHandlerStart(attrs)
    elif name == "Signals":
        Builder.Instance.signalsHandlerStart(attrs)
    elif name == "MeasurementGroup":
        Builder.Instance.measurementGroupHandlerStart(attrs)
    elif name == "Measurement":
        Builder.Instance.measurementHandlerStart(attrs)
        
    else:
        Builder.Instance.unhandledStart(name,attrs)

def end_element(name):
    if name == "Package":
        Builder.Instance.packageHandlerEnd()
    elif name == "Symbol":
        Builder.Instance.packageItemHandlerEnd("Symbol")
    elif name == "Icon":
        Builder.Instance.packageItemHandlerEnd("Icon")
    elif name == "Description":
        Builder.Instance.descriptionHandlerEnd()
    elif name == "ParameterSet":
        Builder.Instance.parameterSetHandlerEnd()
    elif name == "ParameterGroup":
        Builder.Instance.parameterGroupHandlerEnd()
    elif name == "Parameter":
        Builder.Instance.parameterHandlerEnd()
    elif name == "UIOptions":
        Builder.Instance.uiOptionsHandlerEnd()
    elif name == "Argument":
        Builder.Instance.argumentHandlerEnd()
    elif name == "ProbeSet":
        Builder.Instance.probeSetHandlerEnd()
    elif name == "SignalTypes":
        Builder.Instance.signalTypesHandlerEnd()
    elif name == "MeasurementSet":
        Builder.Instance.measurementSetHandlerEnd()
    elif name == "Signals":
        Builder.Instance.signalsHandlerEnd()
    elif name == "MeasurementGroup":
        Builder.Instance.measurementGroupHandlerEnd()
    elif name == "Measurement":
        Builder.Instance.measurementHandlerEnd()
    else:
        Builder.Instance.unhandledEnd(name)
        
def char_data(data):
    Builder.Instance.handleData(data)


class Package:
    ITEMNAME="Package"
    
    def __init__(self,name,version,type,customLoader):
        self.name = name
        self.version = version
        self.type = type

        self.symbol = None
        self.icon = None
        self.description = None

        self.parameterSet = []
        self.parameterSetMap = {}

        self.probeSet = []
        self.probeSetMap = {}

        self.complianceSet = []
        self.complianceSetMap = {}
        
        self.measurementSet = []
        self.measurementSetMap = {}
        
        self.done = False
        self.customLoader = customLoader
        
    def __repr__(self):
        buffer = "Package: " + str(self.name) + "\n"
        for i in self.measurements:
            buffer += "\t" + str(self.measurements[i]) + "\n"
        return buffer

class Symbol:
    ITEMNAME="Symbol"
    def __init__(self,name):
        self.name = name

class Icon:
    ITEMNAME="Icon"
    def __init__(self,name):
        self.name = name

class Description:
    ITEMNAME="Description"
    def __init__(self):
        self.data = ""

    def format(self):
        size = 35
        data = ""
        description = self.data
        description = description.strip()
        justifiedData = None
        nLines = 0
        while(description and len(description) > 0):
            if len(description) < size:
                justifiedData = description.ljust(size)
                data += justifiedData + "\n"
                description = None
            else:
                i = description[:size].rfind(' ')
                if i == -1:
                    justifiedData = description[:size]
                    justifiedData = justifiedData.ljust(size)
                    data += justifiedData + "\n"
                    description = description[size:].strip()
                else:
                    justifiedData = description[:i]
                    justifiedData = justifiedData.ljust(size)
                    data += justifiedData + "\n"
                    description = description[i:].strip()
            nLines += 1
        
        self.data = data
#        print self.data
        return data

class ParameterSet:
    ITEMNAME = "ParameterSet"
    def __init__(self):
        self.parameterGroups = []
        
class ParameterGroup:
    groupIndex = 0
    def __init__(self,name,label):
        self.name = name
        self.label = label
        self.index = ParameterGroup.groupIndex
        ParameterGroup.groupIndex += 1
        self.parameters = []

class UIOptions:
    def __init__(self,dtype):
        self.dtype = dtype
        self.arguments = []

class Argument:
    def __init__(self,name):
        self.name = name
        self.data = None

class Parameter:
    paramIndex = 0
    def __init__(self,name):
        self.name = name
        self.dataType = None
        self.default = None
        self.modifiable = None
        self.range = None
        self.group = None
        self.label = None
        self.units = None
        self.index = Parameter.paramIndex
        self.uiOptions = None
        Parameter.paramIndex += 1
        
    def __repr__(self):
        buffer = "Parameter: Name:" + str(self.name) + " Type:" + str(self.dataType) + " " 
        buffer += "Default:"+str(self.default) + " Modifiable:"
        buffer += str(self.modifiable)  + " Range:" + str(self.range)
        return buffer


class ProbeSet:
    def __init__(self):
        self.signalTypes = []

class SignalTypes:
    def __init__(self,name,label):
        self.name = name
        self.label = label
        self.size = None

class MeasurementSet:
    def __init__(self):
        self.measurementGroups = []

class MeasurementGroup:
    def __init__(self,name,label):
        self.name = name
        self.label = label
        self.measurements = []
        self.measurementGroups = []
        self.signals = []
        self.description = None

class Measurement:
    def __init__(self,name,label):
        self.name = name
        self.label = label
        self.description = None

class Signals:
    def __init__(self):
        self.name = None
        self.type = None
        
    
class Builder:
    Instance = None
    PackageParameter = {"Name":1,"Version":2,"Type":3,"CustomLoader":4}
    SymbolParameter = {"Name":1}
    IconParameter = {"Name":1}

    ParameterSetParameter = {}
    ParameterGroupParameter = {"Name":1,"Label":2}
    ParameterParameter = {"Name":1,
                          "DataType":2,
                          "Range":3,
                          "Default":4,
                          "Modifiable":5,
                          "Label":6,
                          "Group":7,
                          "Units":8
                          }
    UIOptionsParameter = {"Type":1}
    ArgumentParameter = {"Name":1}
    ProbeSetParameter = {}
    SignalTypesParameter = {"Name":1,"Label":2,"Size":3}

    MeasurementSetParameter = {}
    MeasurementGroupParameter = {"Name":1,"Label":2}
    MeasurementParameter = {"Name":1,"Label":2}
    SignalParameter = {"Name":1,"Type":2,"Label":3}
    
    DataTypes = {
        "BooleanType":0,
        "IntegerType":1,
        "RealType":2,
        "ComplexType":3,
        "StringType":4}

    def __init__(self,packageName,designKit):
        self.packageName = packageName
        self.designKit = designKit
        self.file = None
        self.buffer = None
        self.parser = xml.parsers.expat.ParserCreate()
        self.parser.StartElementHandler = start_element
        self.parser.EndElementHandler = end_element
        self.parser.CharacterDataHandler = char_data
        Builder.Instance = self
        self.package = None
        self.currentMeasurement = None
        self.currentParameter = None
        self.currentDescription = None
        self.currentParameterSet = None
        self.currentParameterGroup = None
        self.currentParameter = None

        self.currentUIOptions = None
        self.currentArgument = None


        self.currentProbeSet = None
        self.currentSignalTypes = None


        self.currentMeasurementSet = None
        self.currentMeasurementGroup = None
        self.currentMeasurement = None

        self.currentData = None


    def setup(self):
        status = 0
        try:
            status = os.stat(self.packageName)
        except:
            raise Exception("Unable to open package " + self.packageName)
        if not stat.S_ISDIR(status[stat.ST_MODE]):
            raise Exception("Package " +
                            self.packageName +
                            " is not a package directory.")
        
        try:
            status = os.stat(self.packageName+"/source")
        except:
            raise Exception("Unable to source directory")
        if not stat.S_ISDIR(status[stat.ST_MODE]):
            raise Exception("Package " +
                            self.packageName +
                            "/source is not a directory.")
        
        try:
            status = os.stat(self.packageName+"/source/config.xml")
        except:
            raise Exception("Unable to open " +
                            self.packageName +
                            "/source/config.xml")
        if not stat.S_ISREG(status[stat.ST_MODE]):
            raise Exception("Package " +
                            self.packageName +
                            "/source is not a file.")

        self.file = file(self.packageName+"/source/config.xml","r")
        self.buffer = self.file.read()
        self.parser.Parse(self.buffer)
        if not self.designKit.generateSourceOnly:
            itemFileName = os.path.join(self.packageName,
                                        "circuit","ael",
                                        "TDM_"+self.package.name+"_item.ael")
            fileObject = file(itemFileName,'w')
            dialogObject = file(self.packageName+"/circuit/ael/TDM_"+self.package.name+"_dialog.ael","w")
            loadString = 'load(strcat('+self.designKit.varName+'_CIRCUIT_AEL_DIR,"TDM_'
            loadString += self.package.name+'_item"),"CmdOp");\n'
            loadString += 'load(strcat('+self.designKit.varName+'_CIRCUIT_AEL_DIR,"ComplianceReport"),"CmdOp");\n'
            print >> self.designKit.bootFile , loadString
            print >> self.designKit.adslibFile,self.designKit.name.upper(),"| | de/ael/boot |",self.package.version


            paletteLoader  = 'dk_define_palette_group(SCHEM_WIN,"analogRF_net",\n'
            paletteLoader += '\t"'+self.packageName+" v"+self.package.version+'",'
            if(self.package.description):
                paletteLoader += '"' + self.package.description.data + '",0,\n'
            else:
                paletteLoader += '"TDCM package",0,\n'  
            paletteLoader += '\t"' + self.package.name + '_Measurement","Probe",'
       
            if(self.package.icon):
                paletteLoader += 'strcat('+self.designKit.varName+'_BITMAP_DIR,"'+self.package.icon.name+'"),\n'
                paletteLoader += '\t"ComplianceReport","Probe",strcat('+self.designKit.varName+'_BITMAP_DIR,"ComplianceReport"));\n'
            else:
                paletteLoader += 'strcat('+self.designKit.varName+'_BITMAP_DIR,"'+self.package.name+'"),\n'
                paletteLoader += '\t"ComplianceReport","Probe",strcat('+self.designKit.varName+'_BITMAP_DIR,"ComplianceReport"));\n'
            print >> self.designKit.paletteFile , paletteLoader
            ui = Generate_UI(self.designKit)
            ui.generate(self.package,fileObject,dialogObject)
            f = __file__.rfind("/")
            location = __file__[:f]
            sourceDIR = os.path.join(self.package.name,DesignKit.sourceDIR)
            symbolDIR = os.path.join(self.package.name,DesignKit.symbolsDIR)
            bitmapPCDIR = os.path.join(self.package.name,DesignKit.bitmapPCDIR)
            bitmapUNIXDIR = os.path.join(self.package.name,DesignKit.bitmapUNIXDIR)
            aelDIR = os.path.join(self.package.name,DesignKit.aelDIR)
            shutil.copy(os.path.join(location,"ComplianceReport.py"),
                        os.path.join(sourceDIR,"python","ComplianceReport.py"))
            shutil.copy(os.path.join(location,"ComplianceReport.ael"),aelDIR)
            shutil.copy(os.path.join(location,"SYM_COMPLIANCE_REPORT.dsn"),symbolDIR)
            shutil.copy(os.path.join(location,"pc","ComplianceReport.bmp"),bitmapPCDIR)
            shutil.copy(os.path.join(location,"unix","ComplianceReport.bmp"),bitmapUNIXDIR)

            
            cAELFile = file(os.path.join(aelDIR,"ComplianceReport.ael"),'a')
          
            __buff__ = 'create_item("ComplianceReport",\n'
            __buff__ += '"Compliance Report",\n'
            __buff__ += '"ComplianceReport",\n'
            __buff__ += '0,\n'
            __buff__ += '-1,\n'
            __buff__ += '"ComplianceReport",\n'
            __buff__ += '"ComplianceReport",\n'
            __buff__ += '"*",\n'
            __buff__ += 'ComponentNetlistFmt,\n'
            __buff__ += '"TDCM Compliance Report",\n'
            __buff__ += 'ComponentAnnotFmt,\n'
            __buff__ += '"SYM_COMPLIANCE_REPORT",\n'
            __buff__ += 'no_artwork,\n'
            __buff__ += 'NULL,\n'
            __buff__ += 'ITEM_PRIMITIVE_EX,\n'
            __buff__ += 'list(dm_create_cb(ITEM_NETLIST_CB,"TDCM_ComplianceReport_netlist_cb",\n'
            __buff__ += 'list('+self.designKit.varName+'_PATH),TRUE)),\n'
	    __buff__ += 'create_parm("FileName","Output Control",PARM_STRING,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","")),\n'
            __buff__ += 'create_parm("Save_ComplianceSummary","Output Control",PARM_INT|PARM_NO_DISPLAY,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","yes")),\n'
            __buff__ += 'create_parm("Save_MeasurementSummary","Output Control",PARM_INT|PARM_NO_DISPLAY,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","yes")),\n'
            __buff__ += 'create_parm("Save_MeasurementMS","Output Control",PARM_INT|PARM_NO_DISPLAY,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            __buff__ += 'create_parm("Save_MeasurementSS","Output Control",PARM_INT|PARM_NO_DISPLAY,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            __buff__ += 'create_parm("Save_MeasurementPS","Output Control",PARM_INT|PARM_NO_DISPLAY,\n'
            __buff__ += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","yes"))\n'
            __buff__ += ');\n'
            __buff__ += 'de_add_item_dialog("ComplianceReport","TDCM_ComplianceReport_create_dialog",NULL);\n'
            cAELFile.write(__buff__)
            cAELFile.close()

        
        parameterInclude = Generate_InternalCode()
        internalDIR = self.packageName+"/"+DesignKit.sourceInternalDIR+"/"
        sourceDIR = self.packageName+"/"+DesignKit.sourceCodeDIR+"/"
        parameterInclude.generate(self.package,internalDIR,sourceDIR)
        genMakeDef = Generate_Makedefs()
        genMakeDef.generate(self.package,
                            self.package.name,
                            self.package.name+"/"+DesignKit.sourceDIR,
                            self.package.name+"/"+DesignKit.sourceCodeDIR)
        genCMake = Generate_CMakefiles()
        genCMake.generate(self.package,
                          self.package.name,
                          self.package.name+"/"+DesignKit.sourceDIR,
                          self.package.name+"/"+DesignKit.sourceCodeDIR,
                          self.package.name+"/"+DesignKit.aelDIR,
                          self.package.name+"/"+DesignKit.symbolsDIR,
                          self.package.name+"/"+DesignKit.bitmapPCDIR,
                          self.package.name+"/"+DesignKit.bitmapUNIXDIR,
                          )
        
        if not self.designKit.generateSourceOnly:
            g = Generate_Python()
            sourceDIR = self.packageName+"/"
            g.generate(self.package,sourceDIR)
            fileObject.close()
            dialogObject.close()
        


    def packageHandlerStart(self,attribute):
        name = None
        version = None
        packageType = None
        customLoader = None
        if self.package:
            raise Exception("There can only be one package in a package file.")
        
        for i in attribute:
            if not Builder.PackageParameter.has_key(i):
                raise Exception("Invalid Package attribute " + i)
            if i == "Name":
                name = attribute[i]
            elif i == "Version":
                version = attribute[i]
            elif i == "Type":
                packageType = attribute[i]
            elif i == "CustomLoader":
                customLoader = attribute[i]
               
        if not name:
            raise Exception("Package name not specified.")
        if not version:
            raise Exception("Package version not specified.")
        if not packageType:
            raise Exception("Package type not specified.")
        self.package = Package(name,version,packageType,customLoader)

    def packageHandlerEnd(self):
        if not self.package:
            raise Exception("Package file ended without a start.")
        self.package.done = True
        return

    def packageItemHandlerStart(self,name,attribute):
        attributeValue = None
        pObject = None
        if name == "Symbol":
            for i in attribute:
                if not Builder.SymbolParameter.has_key(i):
                    raise Exception("Invalid Symbol attribute " + i)
            if i == "Name":
                attributeValue = attribute[i]
                symbolFileName = os.path.join(self.packageName,"source","symbols",attributeValue+".dsn")
            symbolFileFound = False
            try:
                status = os.stat(symbolFileName)
                symbolFileFound = True
            except:
                print >> sys.stderr,("Warning unable to locate symbol file '" +  symbolFileName + "'")
            if symbolFileFound:
                try:
                    shutil.copy(symbolFileName,
                                os.path.join(self.packageName,"circuit","symbols"))
                    print >> sys.stderr,"Copied symbol file :",symbolFileName
                except:
                    print >> sys.stderr,("Warning unable to copy symbol file '" +  symbolFileName + "'")
            pObject = Symbol(attributeValue)
            self.package.symbol = pObject
        elif name == "Icon":
            for i in attribute:
                if not Builder.IconParameter.has_key(i):
                    raise Exception("Invalid Icon attribute " + i)
            iconFileNamePC = None
            iconFileNameUNIX = None
            if i == "Name":
                attributeValue = attribute[i]
                iconFileNamePC = os.path.join(self.packageName,"source","bitmaps","pc",attributeValue+".bmp")
                iconFileNameUNIX = os.path.join(self.packageName,"source","bitmaps","unix",attributeValue+".bmp")
            iconFilePCFound = False
            iconFileUNIXFound = False
            try:
                status = os.stat(iconFileNamePC)
                iconFilePCFound = True
            except:
                print >> sys.stderr,("Warning unable to locate bitmap file '" +  iconFileNamePC + "'")
            if iconFilePCFound:
                try:
                    shutil.copy(iconFileNamePC,
                                os.path.join(self.packageName,"circuit","bitmaps","pc"))
                    print >> sys.stderr,"Copied bitmap file :",iconFileNamePC
                except:
                    print >> sys.stderr,("Warning unable to copy bitmap file '" +  iconFileNamePC + "'")
            try:
                status = os.stat(iconFileNameUNIX)
                iconFileUNIXFound = True
            except:
                print >> sys.stderr,("Warning unable to locate bitmap file '" +  iconFileNameUNIX + "'")
            if iconFileUNIXFound:
                try:
                    shutil.copy(iconFileNameUNIX,
                                os.path.join(self.packageName,"circuit","bitmaps","unix"))
                    print >> sys.stderr,"Copied bitmap file :",iconFileNameUNIX
                except:
                    print >> sys.stderr,("Warning unable to copy bitmap file '" +  iconFileNameUNIX + "'")
            pObject = Icon(attributeValue)
            self.package.icon = pObject
        else:
            raise Exception("Invalid Type " + i)
        if not attributeValue:
            raise Exception("Symbol or Icon require Name to be provided.")
        if not pObject:
            raise Exception("Failed to create Symbol/Icon object.")
        return

    def descriptionHandlerStart(self,attributes):
        self.currentDescription = Description()
        self.currentData = "Description"

    def descriptionHandlerEnd(self):
        self.currentData = None
        if not self.currentDescription:
            raise Exception("Description not defined yet.")
        if self.currentMeasurement:
            self.currentMeasurement.description = self.currentDescription
        elif  self.currentMeasurementGroup:
            self.currentMeasurementGroup.description = self.currentDescription
        elif self.package:
            self.package.description = self.currentDescription
        self.currentDescription = None


    def parameterSetHandlerStart(self,attributes):
        if not self.package:
            raise Exception("ParameterSet must be defined within a package.")
        if self.currentParameterSet:
            raise Exception("ParameterSet cannot be defined within another ParameterSet.")
        self.currentParameterSet = ParameterSet()
        
    def parameterSetHandlerEnd(self):
        if not self.package:
            raise Exception("ParameterSet must be defined within a package.")
        if not self.currentParameterSet:
            raise Exception("Parameter set not defined yet.")
        self.package.parameterSet = self.currentParameterSet
        self.currentParameterSet = None

    def parameterGroupHandlerStart(self,attributes):
        if not self.currentParameterSet:
            raise Exception("ParameterGroup must be defined within a ParameterSet.")
        name = None
        label = None
        for i in attributes:
            if not Builder.ParameterGroupParameter.has_key(i):
                raise Exception("ParameterGroup does not have a parameter named '"+i+"'")
            if i == "Name":
                name = attributes[i]
            elif i == "Label":
                label = attributes[i]
        
                    
        self.currentParameterGroup = ParameterGroup(name,label)
        self.currentParameterSet.parameterGroups.append(self.currentParameterGroup)
        

    def parameterGroupHandlerEnd(self):
        self.currentParameterGroup = None


    def parameterHandlerStart(self,attribute):
        if not self.currentParameterGroup:
            raise Exception("Parameter can only be defined with a ParameterGroup.")
        name = None
        dataType = "RealType"
        range = None
        default = None
        modifiable = "True"
        label = None
        group = None
        units = None
        if self.currentParameter:
            raise Exception("Previous Parameter not closed.")
        
        for i in attribute:
            if not Builder.ParameterParameter.has_key(i):
                raise Exception("Parameter does not have a parameter named '"+i+"'")
                            
            if i == "Name":
                name = attribute[i]
            elif i == "DataType":
                dataType = attribute[i]
                
            elif i == "Range":
                range = attribute[i]
            elif i == "Default":
                default =  attribute[i]
            elif i == "Modifiable":
                modifiable = attribute[i]
            elif i == "Group":
                group = attribute[i]
            elif i == "Label":
                label = attribute[i]
            elif i == "Units":
                units = attribute[i]
                if (units == "voltage") or (units == "frequency") or (units == "datarate"):
                    units = attribute[i]
                else:
                    raise Exception("Unknown units type "+attribute[i])
                
        if not name:
            raise Exception("Parameter name not specified.")
        
        self.currentParameter = Parameter(name)
        self.currentParameter.dataType = dataType
        self.currentParameter.range = range
        self.currentParameter.default = default
        self.currentParameter.modifiable = modifiable
        self.currentParameter.label = label
        self.currentParameter.group = group
        self.currentParameter.units = units
        self.currentParameterGroup.parameters.append(self.currentParameter)
        
    def parameterHandlerEnd(self):
        if not self.currentParameterGroup:
            raise Exception("Parameter can only be defined with a ParameterGroup.")
        if not self.currentParameter:
            raise Exception("Parameter being closed before opening.")
        self.currentParameter = None
        return

    def uiOptionsHandlerStart(self,attributes):
        if not self.currentParameter:
            raise Exception("UIOptions can only be defined with a Parameter.")
        dType = None
        for i in attributes:
            if not Builder.UIOptionsParameter.has_key(i):
                raise Exception("UIOptions does not have a parameter named '"+i+"'")
            if i == "Type":
                dType = attributes[i]
        if not dType:
            raise Exception("UIOption requires a parameter named Type.")
        self.currentUIOptions = UIOptions(dType)
        self.currentParameter.uiOptions = self.currentUIOptions
        
    
    def uiOptionsHandlerEnd(self):
        if not self.currentUIOptions:
            raise Exception("UIOptions being closed before opening.")
        self.currentUIOptions = None
        return

    def argumentHandlerStart(self,attributes):
        if not self.currentUIOptions:
            raise Exception("Argument can only be defined within UIOptions.")
        name = None
        for i in attributes:
            if not Builder.ArgumentParameter.has_key(i):
                raise Exception("Argument does not have a parameter named '"+i+"'")
            if i == "Name":
                name = attributes[i]
        if not name:
            raise Exception("Argument requires a parameter named 'Name'.")
        self.currentArgument = Argument(name)
        self.currentData = "Argument"
        return
        
    def argumentHandlerEnd(self):
        if not self.currentArgument:
            raise Exception("Argument being closed before opening.")
        self.currentUIOptions.arguments.append(self.currentArgument)
        self.currentData = None
        self.currentArgument = None
        return
        
    def probeSetHandlerStart(self,attributes):
        if not self.package:
            raise Exception("ProbeSet must be defined within a package.")
        if self.currentProbeSet:
            raise Exception("ProbeSet cannot be defined within another ProbeSet.")
        self.currentProbeSet = ProbeSet()
        
    def probeSetHandlerEnd(self):
        if not self.package:
            raise Exception("ProbeSet must be defined within a package.")
        if not self.currentProbeSet:
            raise Exception("ProbeSet not defined yet.")
        self.package.probeSet = self.currentProbeSet
        self.currentProbeSet = None
        return

    def signalTypesHandlerEnd(self):
        if not self.currentProbeSet:
            raise Exception("ProbeSet not defined yet.")
        self.currentSignalTypes = None

    def signalTypesHandlerStart(self,attributes):
        if not self.currentProbeSet:
            raise Exception("SignalTypes must be defined within a ProbeSet.")
        name = None
        label = None
        size = None
        for i in attributes:
            if not Builder.SignalTypesParameter.has_key(i):
                raise Exception("SignalTypes does not have a parameter named '"+i+"'")
            if i == "Name":
                name = attributes[i]
            elif i == "Label":
                label = attributes[i]
            elif i == "Size":
                size = attributes[i]
        self.currentSignalTypes = SignalTypes(name,label)
        self.currentSignalTypes.size = size
        self.currentProbeSet.signalTypes.append(self.currentSignalTypes)
        return

    def measurementSetHandlerStart(self,attributes):
        if not self.package:
            raise Exception("MeasurementSet must be defined within a package.")
        if self.currentMeasurementSet:
            raise Exception("MeasurementSet cannot be defined within another MeasurementSet.")
        self.currentMeasurementSet = MeasurementSet()
        return

    def measurementSetHandlerEnd(self):
        if not self.package:
            raise Exception("MeasurementSet must be defined within a package.")
        if not self.currentMeasurementSet:
            raise Exception("MeasurementSet not defined yet.")
        self.package.measurementSet = self.currentMeasurementSet
        self.currentMeasurementSet = None
        return
    
    def measurementGroupHandlerStart(self,attributes):
        if not self.currentMeasurementSet:
            raise Exception("MeasurementGroup must be defined within a MeasurementSet.")
        name = None
        label = None
        for i in attributes:
            if not Builder.ParameterGroupParameter.has_key(i):
                raise Exception("MeasurementGroup does not have a parameter named '"+i+"'")
            if i == "Name":
                name = attributes[i]
            elif i == "Label":
                label = attributes[i]
                            
        self.currentMeasurementGroup = MeasurementGroup(name,label)
        self.currentMeasurementSet.measurementGroups.append(self.currentMeasurementGroup)
        

    def measurementGroupHandlerEnd(self):
        self.currentMeasurementGroup = None
        return

    def signalsHandlerStart(self,attributes):
        name = None
        sType = None
        if not self.currentMeasurementGroup:
            raise Exception("Signals can only be defined within MeasurementGroup")
        for i in attributes:
            if not Builder.SignalParameter.has_key(i):
                raise Exception("Signals does not have a parameter named '"+i+"'")
            if i == "Name":
                name = attributes[i]
            elif i == "Type":
                sType = attributes[i]
        if name == None:
            raise Exception("Signal name must be provided.")
        if sType == None:
            raise Exception("Signal type must be provided.")
        self.currentSignals = Signals()
        self.currentSignals.name = name
        self.currentSignals.type = sType
        self.currentData = "Signals"
        self.currentMeasurementGroup.signals.append(self.currentSignals)
        return

    def signalsHandlerEnd(self):
        if not self.currentSignals:
            raise Exception("Signals closing without opening.")
        self.currentData = None
        self.currentSignals = None
  
    def measurementHandlerStart(self,attributes):
        if not self.currentMeasurementGroup:
            raise Exception("Measurement can only be defined with a MeasurementGroup.")
        name = None
        label = None
        if self.currentMeasurement:
            raise Exception("Previous Measurement not closed.")
        
        for i in attributes:
            if not Builder.MeasurementParameter.has_key(i):
                raise Exception("Measurement does not have a parameter named '"+i+"'")
            
            if i == "Name":
                name = attributes[i]
            elif i == "Label":
                label = attributes[i]
                                
        if not name:
            raise Exception("Measurement name not specified.")
        if not label:
            raise Exception("Measurement label not specified.")
        
        self.currentMeasurement = Measurement(name,label)
        self.currentMeasurementGroup.measurements.append(self.currentMeasurement)
        return
       
    def measurementHandlerEnd(self):
        if self.currentDescription:
            self.currentMeasurement.description = self.currentDescription
        self.currentMeasurement = None
        
    def packageItemHandlerEnd(self,name):
        pass


    def unhandledStart(self,name,attributes):
        print "Unhandled-start ",name," ",attributes
        return
        
    def unhandledEnd(self,name):
        #print "Unhandled-end ",name
        return

    def handleData(self,data):
        if self.currentData == "Description" and self.currentDescription:
            self.currentDescription.data += str(data).strip()
        elif self.currentData == "Argument" and self.currentArgument:
            if self.currentArgument.data == None:
                self.currentArgument.data = str(data).strip()
            else:
                self.currentArgument.data += str(data)
        elif self.currentData == "Signals" and self.currentSignals:
            self.currentSignals.data += str(data).strip()
        elif self.currentData == None and len((data.strip())) == 0:
            pass
        elif self.currentData == None:
            pass
        else:
            print ("Unknown data"+str(self.currentData)+" "+((data.strip())))
            assert 0,("Unknown data"+str(self.currentData)+" "+((data.strip())))

def error(data,code):
    buff =  " Error when parsing\n"
    buff += "Format should be of the form [valueA:valueB]\n"
    buff += "where valueA < valueB\n"
    buff += "Code : "+str(code)+"\n"
    raise Exception(buff)
    
def parse(data):
    if not data:
	    return "NULL"
    data = data.strip().replace(" ","")
    rA = None
    rB = None
    vA = None
    tA = None
    vB = None
    tB = None
    length = len(data)
    if length <= 3:
        error(data,0)
    if data[0] == "[":
        rA = 1
    elif data[0] == "(":
        rA = 0
    else:
        error(data,1)
    if data[length-1] == "]":
        rB = 1
    elif data[length-1] == ")":
        rB = 0
    else:
        error(data,2)
    a = data.find(":")
    if a < 0:
        error(data,3)
    elif a >= (length-2):
        error(data,4)
    else:
        vA = data[1:a]
        vB = data[a+1:length-1]
        if (len(vA) <= 0) or (len(vB) <= 0):
            error(data,3)
    if vA == "-inf":
        tA = -1
    elif vA == "inf":
        error(data,4)
    else:
        try:
            vA = float(vA)
            tA = 0
        except:
            error(data,5)
    if vB == "inf":
        tB = +1
    elif vB == "-inf":
        error(data,5)
    else:
        try:
            vB = float(vB)
            tB = 0
        except:
            error(data,6)
    if (tA == 0) and (tB == 0):
        if vA >= vB:
            error(data,7)
    buffer = ""
    if rA == 1:
        buffer += "RangeUtility::GTE("
    else:
        buffer += "RangeUtility::GT("
    if tA == -1:
        buffer += "N_INF),"
    else:
        buffer += str(vA) + "),"
        
    if rB == 1:
        buffer += "RangeUtility::LTE("
    else:
        buffer += "RangeUtility::LT("
    if tB == 1:
        buffer += "P_INF)"
    else:
        buffer += str(vB) + ")"
    buffer = "new Range("+buffer+")"
    return buffer
    
class Generate_InternalCode:
       
    def generate(self,package,internalDIR,sourceDIR):
        packageIncludeFileName = "__TDCM__Package__"+package.name
        packageIncludeFile = file(internalDIR+packageIncludeFileName,'w')
        print >> packageIncludeFile,"class  __TDCM__Parameter__{"
        print >> packageIncludeFile,"public:"
        parameterSet = package.parameterSet
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                name = p.name
                index = p.index           
                if p.dataType == "IntegerType" or p.dataType == "BooleanType":
                    print >> packageIncludeFile, "\tint "+ p.name  +";"
                elif p.dataType == "RealType":
                    print >> packageIncludeFile, "\tdouble "+ p.name  +";"
                elif p.dataType == "ComplexType":
                    print >> packageIncludeFile,"\tComplex "+ p.name  +";"
                elif p.dataType == "StringType":
                    print >> packageIncludeFile, "\tstd::string "+ p.name  +";"
                else:
                    assert 0,"Unhandled data type"    
        print >> packageIncludeFile,"}parameter;"
        print >> packageIncludeFile,"\n"
        print >> packageIncludeFile,"void __initializeParameterValue__(){"
        
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                if p.default != None:
                    print >> packageIncludeFile,("\tparameter."+p.name),"=",p.default,";"
        print >> packageIncludeFile,"}\n"

        print >> packageIncludeFile,"virtual void registerParameters(){"
        print >> packageIncludeFile,"\tmemset(&this->parameter,0,sizeof(__TDCM__Parameter__));"
        print >> packageIncludeFile,"\t__initializeParameterValue__();"
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                if p.default != None:
                    print >> packageIncludeFile,("\tthis->registerParameter("+str(p.index)+",&parameter."+p.name+");")
                                                     
        print >> packageIncludeFile,"}\n"

        interfaceFile = file(internalDIR+"/Interface.cxx",'w')
        print >> interfaceFile,'#include "TDCM_Interface.h"'
        print >> interfaceFile,'#include "Descriptor.h"\n'
        print >> interfaceFile,'TDCM_EXPORT int TDCM_LoadPackage(const char* packageName,'
        print >> interfaceFile,'\t\tconst char* instanceName,'
        print >> interfaceFile,'\t\tTDCM_Interface* interface,'
        print >> interfaceFile,'\t\tint signalSize){'
        print >> interfaceFile,'\treturn TDCM::Package::loadPackage(instanceName,'
        print >> interfaceFile,'\t\tinterface,signalSize,'
        print >> interfaceFile,('\t\tnew '+package.name+"_PD);")
        print >> interfaceFile,"}\n"

        descriptorFile = file(internalDIR+"/Descriptor.h","w")
        print >> descriptorFile,('#ifndef __'+package.name+'__DESCRIPTOR__INCLUDE_FILE__')
        print >> descriptorFile,('#define __'+package.name+'__DESCRIPTOR__INCLUDE_FILE__')
        print >> descriptorFile,'#include "TDCM.h"\n'
        print >> descriptorFile,('class '+package.name+'_PD:public TDCM::PackageDescriptor{')
        print >> descriptorFile,'public:'
        print >> descriptorFile,("\t"+package.name+'_PD();')
        print >> descriptorFile,("\tvirtual ~"+package.name+'_PD();')
        print >> descriptorFile,"\tvirtual TDCM::Package* createInstance();"
        print >> descriptorFile,"};\n\n"
        
        for measurement in package.measurementSet.measurementGroups:
            className = package.name + "_"
            print >> descriptorFile,("class "+ className +measurement.name +"_MD:public TDCM::MeasurementDescriptor{")
            print >> descriptorFile,"public:"
            print >> descriptorFile,("\t"+className + measurement.name +"_MD();")
            print >> descriptorFile,("\t virtual ~"+className +measurement.name +"_MD();")
            print >> descriptorFile,"\t virtual TDCM::Measurement* createInstance();"
            print >> descriptorFile,"};\n\n"

        print >> descriptorFile,("class "+package.name+"_Package:public TDCM::Package{")
        print >> descriptorFile,"public:"
        print >> descriptorFile,("\t"+package.name+"_Package();")
        print >> descriptorFile,("\t virtual ~"+package.name+"_Package();")
        print >> descriptorFile,('#include "'+packageIncludeFileName+'"\n')
        print >> descriptorFile,"\tvirtual char* getConstraintsFileName();\n"
        print >> descriptorFile,"\tvirtual void check(TDCM::Measurement* measurement,"
	print >> descriptorFile,"\t\tconst char* name,"
        print >> descriptorFile,"\t\tTDCM::DoubleVector& value,const char* outputName){"
        print >> descriptorFile,"\t\t\tif(value.size() == 0){\n"
        print >> descriptorFile,"\t\t\t\treturn;}\n"
        print >> descriptorFile,"\t\t\tPackage::check(measurement,name,value,outputName);\n}"
        print >> descriptorFile,"\t\t\tvirtual void finalize(){\n"
        print >> descriptorFile,"\t\t\tPackage::finalize();\n"
        __buff__  = "TDCM::Container<TDCM::Measurement*>* link = measurements.head();\n"
        __buff__ += "while(link){\n"
        __buff__ += "TDCM::Measurement* m = link->data();\n"
        __buff__ += "m->initialize();link = link->next();}}\n"
        
        __buff__ += 'virtual void initialize(){\n'
        __buff__ += 'char buffer[1024];\n'
        __buff__ += 'if(!this->measurementsCreated){\n'
        __buff__ += 'Package::initialize();\n}\n'
        if 0:
            __buff__ += 'for(int i=0;i<this->signalSize;i++)\n'
            __buff__ += 'signals[i].reference.clear();\n'
            __buff__ += 'this->measurementsCreated = true; \n'
            __buff__ += 'TDCM::Container<TDCM::MeasurementDescriptor*>* mlink = this->addedMeasurements.head();\n'
            __buff__ += 'TDCM::MeasurementDescriptor* measurementDescriptor = NULL;\n'
            __buff__ += 'while(mlink){\n'
            __buff__ += 'measurementDescriptor = mlink->data();\n'
            __buff__ += 'TDCM::Vector<TDCM::SignalDescriptor*> signalDescriptor = \n'
            __buff__ += 'measurementDescriptor->getSignalDescriptors();\n'
            __buff__ += 'TDCM::Container<TDCM::SignalDescriptor*>* signalLink = signalDescriptor.head();\n'
            __buff__ += 'TDCM::SignalType* mSignals = new TDCM::SignalType[signalDescriptor.size()];\n'
            __buff__ += 'int counter = 0;\n'
            __buff__ += 'while(signalLink){\n'
            __buff__ += 'TDCM::SignalDescriptor* s = signalLink->data();\n'
            __buff__ += 'const char* sName = s->getName().c_str();\n'
            __buff__ += 's->setSignalType(descriptor->getSignalType(sName));\n'
            __buff__ += 'mSignals[counter] = s->getSignalType();\n'
            __buff__ += 'counter++;\n'
            __buff__ += 'signalLink = signalLink->next();\n'
            __buff__ += '}\n'
            __buff__ += 'this->createMeasurements(mSignals,signalDescriptor.size(),measurementDescriptor);\n'
            __buff__ += 'delete[] mSignals;\n'
            __buff__ += 'mlink = mlink->next();\n'
            __buff__ += '}\n'
            __buff__ += '}\n'
        __buff__ += '}\n'
        print >> descriptorFile,__buff__
        print >> descriptorFile,"};\n\n"
        print >> descriptorFile,"#endif"

        descriptorFile = file(internalDIR+"/Descriptor.cxx","w")
        print >> descriptorFile,'#include "Descriptor.h"'
        for measurement in package.measurementSet.measurementGroups:
            fName = measurement.name + ".h"
            print >> descriptorFile,('#include "' + fName + '"')
        print >> descriptorFile,"using namespace TDCM;"
        for measurement in package.measurementSet.measurementGroups:
            className =  package.name + "_" + measurement.name +'_MD'
            buff =  (className+"::"+className+'():\n\tMeasurementDescriptor("'+measurement.name+'"){\n')
            for s in measurement.signals:
                buff += '\tthis->defineSignal("'+s.name+'");\n'
            buff += "}\n\n"
            
            buff += (className+"::~"+className+'(){}\n\n')
            buff += "Measurement* " +className+"::createInstance(){\n"
            buff += "\treturn (new " +  measurement.name + "());\n"
            buff += "}\n\n"
            print >> descriptorFile ,buff

        counter = 0
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                counter += 1
                
        packageClass = package.name+'_PD'
        buff  = packageClass + "::" + packageClass +"():\n"
        buff += 'PackageDescriptor("' + package.name + '"){\n'
        buff += "\tthis->setNumberOfParameters("+str(counter)+");\n"
        buff += "\tinit();\n"
        buff += "\tRange* range = NULL;\n"
        _index = -1
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                _index += 1
                if p.dataType == "IntegerType" or p.dataType == "BooleanType":
                    buff += "\trange = " + parse(p.range) + ";\n"
                    buff += "\tdefineParameter("+str(_index)
                    buff += ',ParameterUtility::IntegerParameter("' + p.name + '",range'
                    buff += ")"
                    buff += ");\n"
                elif p.dataType == "RealType":
                    buff += "\trange = " + parse(p.range) + ";\n"
                    buff += "\tdefineParameter("+str(_index)
                    buff += ',ParameterUtility::RealParameter("' + p.name + '",range'
                    buff += ")"
                    buff += ");\n"
                elif p.dataType == "ComplexType":
                    buff += "\tdefineParameter("+str(_index)
                    buff += ",ParameterUtility::ComplexParameter(" + p.name + '",'
                    buff += "NULL"
                    buff += ")"
                    buff += ");\n"
                elif p.dataType == "StringType":
                    buff += "\tdefineParameter("+str(_index)
                    buff += ",ParameterUtility::StringParameter(" + p.name + '",'
                    buff += "NULL"
                    buff += ")"
                    buff += ");\n"
                else:
                    assert 0,"Unhandled data type."+p.dataType

        
        buff += "\n"
        for measurement in package.measurementSet.measurementGroups:
            buff += "\tdefineMeasurement(new "+package.name+"_"+ measurement.name + "_MD);\n"

        buff += "\n"
        for i in package.probeSet.signalTypes:
            buff += '\tdefineSignalType("'+i.name+'");\n'
        buff += "}\n"

        buff += packageClass + "::~"+packageClass+"(){}\n\n"
        buff += "Package* " + packageClass + "::createInstance(){\n"
        buff += "\tPackage* package = new "+package.name+"_Package;\n"
        buff += "\tpackage->setDescriptor(this);\n"
        buff += "\treturn package;\n"
        buff += "}\n\n"
        print >> descriptorFile,buff

        packageFileName = sourceDIR+"/Package.cxx"
        try:
            os.stat(packageFileName)
        except:
            packageFile = file(packageFileName,"w")
            buff = '#include "TDCM_Package.h"'
            buff += '#include "Descriptor.h"\n'
            buff += "using namespace TDCM;\n\n"
            buff += package.name + "_Package::" + package.name + "_Package():Package(){}\n\n"
            buff += package.name + "_Package::~" + package.name + "_Package(){}\n\n"
            buff += "char* " + package.name + "_Package::getConstraintsFileName(){\n"
            buff += "\treturn Package::getConstraintsFileName();\n}\n"
            print >> packageFile,buff

        for measurement in package.measurementSet.measurementGroups:
            fileName = "__TDCM__Measurement__"+measurement.name
            fileObject = file(internalDIR+fileName,'w')
            buff  = package.name+"_Package* package;\n\n"
            buff += "virtual void setPackage(Package* _package){\n"
            buff += "\tthis->package = ("+package.name+"_Package*)_package;\n"
            buff += "}\n"
            buff += "virtual Package* __package__(){\n"
            buff += "\treturn this->package;\n"
            buff += "}\n"
            print >> fileObject,buff
            buff = "class __TDCM__Signals__{\n"
            buff += "public:\n"
            for s in measurement.signals:
                buff += "\tSignal " + s.name + ";\n"
            buff += "}signal;\n\n"
            buff += "virtual void registerSignals(){\n"
            for s in measurement.signals:
                buff += '\tthis->package->registerSignal("'+s.type+'",&signal.'+s.name+');\n'
            buff += "}\n"
            print >> fileObject,buff

        self.generateSource(package,internalDIR,sourceDIR)
        return

    def generateSource(self,package,internalDIR,sourceDIR):
        for measurement in package.measurementSet.measurementGroups:
            includeFileName = sourceDIR + measurement.name + ".h"
            sourceFileName  = sourceDIR + measurement.name + ".cxx"
            try:
                os.stat(includeFileName)
            except:
                fileObject = file(includeFileName,"w")
                buff = '#include "TDCM.h"\n'
                buff += '#include "Descriptor.h"\n\n'
                buff += 'using namespace TDCM;\n\n'
                buff += 'class ' + measurement.name + ":public Measurement{\n"
                buff += "public:\n"
                buff += "\t"+measurement.name+"();\n"
                buff += "\t virtual ~"+measurement.name+"();\n\n"
                buff += "\t virtual void initialize();\n"
                buff += "\tvirtual void event(Trigger* trigger);\n"
                buff += "\tvirtual void evaluate(double time);\n"
                buff += "\tvirtual void finalize();\n"
                buff += "\tvirtual void checkCompliance();\n"
                ppfileName = "__TDCM__Measurement__"+measurement.name
                buff += '#include "'+ ppfileName + '"\n'
                buff += "\n\n};"
                print >> fileObject,buff
                fileObject.close()
            try:
                os.stat(sourceFileName)
            except:
                fileObject = file(sourceFileName,"w")
                className = measurement.name
                buff  = '#include "'+measurement.name+'.h"\n\n'
                buff +=  className + "::" + className +"(){}\n\n"
                buff +=  className + "::~" + className +"(){}\n\n"
                buff += "void " + className + "::initialize(){}\n"
                buff += "void " + className + "::event(Trigger* trigger){}\n"
                buff += "void " + className + "::evaluate(double time){}\n"
                buff += "void " + className + "::finalize(){}\n"
                buff += "void " + className + "::checkCompliance(){}\n"
                print >> fileObject,buff
     
class Generate_UI:
    def __init__(self,dk):
        self.dk = dk
    
    def __generateNetlister(self,package,fileObject,dialogFileObject):
        varName = '"'+package.name+'_Measurement"'
        filename = dialogFileObject.name
        filename = filename[:filename.find(".ael")]
        if filename.rfind("/") > 0:
            filename = filename[filename.rfind("/")+1:]
            
        buf = 'de_add_item_dialog('+varName+','+'"TDCM_create_'
        buf = buf+package.name+'_dialog",NULL);\n\n'
        print >> fileObject,buf
  
    def comment(self,fileObject,message,tab):
        buf = ""
        for i in xrange(tab):
            buf += "\t"
        buf += "//" + message
        print >> fileObject,buf

    def code(self,fileObject,message,tab):
        buf = ""
        for i in xrange(tab):
            buf += "\t"
        buf += message
        print >> fileObject,buf

    def compareIndex(self,a,b):
        i = a.index
        j = b.index
        if i > j:
            return 1
        elif i == j:
            return 0
        else:
            return -1

    def __createParameterBuffer(self,package,fileObject):
        buff = "decl parameterData = list(\n"
        parameterSet = package.parameterSet
    
        counter1 = len(parameterSet.parameterGroups)
        for i in parameterSet.parameterGroups:
            groupName = ''
            groupLabel = ''
           
            if i.name:
                groupName = i.name
            if i.label:
                groupLabel = i.label
            buff = buff + "\n\tlist(\""+groupName+"\",\""+groupLabel+"\",\n"
            counter2 = len(i.parameters)
            for p in i.parameters:
                if p.uiOptions:
                    if p.uiOptions.dtype == "ComboBox":
                        buff = buff + '\n\t\tlist("3",'
                        buff += '"'+ p.label +'",'
                        buff += '"'+ p.name +'",\n'
                        buff += "\t\t\tlist("
                        counter3 = len(p.uiOptions.arguments)
                        for k in p.uiOptions.arguments:
                            buff = buff + '"' + str(k.data)  + '"'
                            if counter3 > 1:
                                buff += ","
                            counter3 = counter3 - 1
                        buff += ")"
                        if counter2 > 1:
                            buff += '),\n'
                        else:
                            buff += ')\n'
                    elif p.uiOptions.dtype == "Activate_EditBrowse_FileBrowser":
                        buff = buff + '\n\t\tlist("4",'
                        buff += '"'+ p.label +'",'
                        buff += '"'+ p.name +'",'
                        buff += '"0",'
                        buff += '"' + str(p.default) + '"'
                        buff += ")\n"
                        if counter2 > 1:
                            buff += '\t\t,\n'
                        else:
                            buff += '\t\t\n'
                    else:
                        raise Exception("Unknown UI Option " + str(p.uiOptions.dtype))
                else:
                    buff += '\t\tlist("1",\n'
                    buff += '\t\t"'+ p.label +'",\n'
                    buff += '\t\t"'+ p.name +'",\n'
                    buff += '\t\t"'+ p.default + '",\n'
                    if p.units:
                        buff += '\t\t"'+ p.units + '",\n'
                    else:
                        buff += '\t\t"",\n'
                    if counter2 > 1:
                        buff += '\t\t""),\n'
                    else:
                        buff += '\t\t"")\n'
                counter2 = counter2-1

            #print "Param Name: ",str(p)
            if counter1 > 1:
                buff = buff + "\t),"
            else:
                buff = buff + "\t)"
            counter1 = counter1-1
        #print "-----------------------------"
        buff += "\n);\n"
        return buff

    def __generateCreateDialog(self,package,fileObject):
        varName = '"'+package.name+'_Measurement"'
        buf = "defun TDCM_create_"+package.name+"_dialog(winInst, dialogName, itemInfo){"
        print >> fileObject,buf
        print >> fileObject,"\tdecl dialog = api_find_dialog(winInst, dialogName);"
        print >> fileObject,"\tif(dialog == NULL){"
        buf = self.__createParameterBuffer(package,fileObject)
        print >> fileObject,buf
        
        buf = "decl probeSetData = list(";
        probeSet = package.probeSet
        probeMap = {}
        if probeSet:
            counter = len(probeSet.signalTypes)
            for signal in probeSet.signalTypes:
                if counter > 1:            
                    buf += 'list("' + signal.name + '",\n"' + signal.label + '"),\n'
                else:
                    buf += 'list("' + signal.name + '",\n"' + signal.label + '")\n'
                probeMap[signal.name] = signal.label
                counter = counter-1
            buf += ");\n"
        print >> fileObject,buf
      
        mCount = 0
        gCount = 0
        msList = 'decl __MEASUREMENT__DATA__ = list('
        groupSignalList = "decl __GROUP_SIGNAL_DATA__ = list(\n"
        msLength = len(package.measurementSet.measurementGroups)
        mGroupDescriptionList = []
        mGroupDescriptionIndex = 0
        mDescriptorList = []
        mDescriptorIndex = 0
        for measurementGroup in package.measurementSet.measurementGroups:
            gName = measurementGroup.name.replace(".","_")
            mList = []
            sList = []
            groupSignalList += "\nlist("
            signalCounter = len(measurementGroup.signals)
            for s in measurementGroup.signals:
                if not probeMap.has_key(s.type):
                    raise Exception("Unable to locate signal type '" + s.type + "'") 
                groupSignalList += '"' + str(probeMap[s.type]) + '"'
                signalCounter = signalCounter - 1
                if(signalCounter != 0):
                    groupSignalList += ","
            groupSignalList += ")"
            if msLength > 1:
                groupSignalList += ","
            else:
                groupSignalList += "\n);\n"
                
            for measurement in measurementGroup.measurements:
                mName = measurement.name.replace(".","_")
                mName = "__measurement" + gName + "_" + mName
                mList.append(mName)
                M = "\t decl " + mName
                M += " = list(\"" + measurement.name + "\"\n"
                M += ",\"" + measurement.label + "\",\n"
                mDesc = ""
                if(measurement.description):
                    mDesc = "\"" + measurement.description.data +"\""
                
                mDescriptorList.append(mDesc)
                M += str(mDescriptorIndex)+");\n"
                mDescriptorIndex += 1
                print >> fileObject,M
            _mList = "list("
            length = len(mList)
            for i in mList:
                _mList += i
                if length != 1:
                    _mList += ",\n"
                length = (length - 1)
            _mList += ")"
            sList = "list("
            length = len(measurementGroup.signals)
            for signal in measurementGroup.signals:
                sList += '"' + signal.type + '"'
                if length != 1:
                    sList += ","
                length = length -1
            sList += ")"
            b = '\tdecl __group'+gName+' = list("'+measurementGroup.name+'","'+measurementGroup.label+"\",\n"
            groupDesc = ""
            if measurementGroup and measurementGroup.description and measurementGroup.description.data:
                groupDesc= "\"" + measurementGroup.description.data + "\""
            b += str(mGroupDescriptionIndex) + ",\n"
            mGroupDescriptionIndex += 1
            mGroupDescriptionList.append(groupDesc)
            b += sList + ',\n' + _mList + ");\n"
            print >> fileObject,b
            msList +=  '__group'+gName
            if msLength != 1:
                msList += ",\n"
            msLength = msLength - 1
        msList += ");"
        print >> fileObject,"\t",msList
        print >> fileObject, groupSignalList
        counter = len(mDescriptorList)
        descBuffer = "decl __MEAS_DESC__ = list("
        for i in mDescriptorList:
            descBuffer += i 
            counter = counter - 1
            if counter != 0:
                descBuffer += ","
            descBuffer += "\n"
        descBuffer += ");\n"
        print >>fileObject,descBuffer
        counter = len(mGroupDescriptionList)
        descBuffer = "decl __GROUP_DESC__ = list("
        
        for i in mGroupDescriptionList:
            descBuffer += i 
            counter = counter - 1
            if counter != 0:
                descBuffer += ","
            descBuffer += "\n"
        descBuffer += ");\n"
        print >>fileObject,descBuffer
        
        print >> fileObject,"\t\tdialog = TDCM_create_Dialog(dialog,dialogName,"+varName+",\nwinInst,parameterData,probeSetData,__MEASUREMENT__DATA__,\n__MEAS_DESC__,__GROUP_DESC__,\n__GROUP_SIGNAL_DATA__);"
        print >> fileObject,"\t}"
        print >> fileObject,'\tdeitem_install_dialog_callbacks(winInst,dialog,"TDCM_initDialog");'
        print >> fileObject,'\n\treturn (dialog);'
        print >> fileObject,'}'

    def __generateCreateItem(self,package,fileObject):
        buff = ""
        netlister =   'TDCM_Netlister_generic_netlist_cb'
        varName = '"'+package.name+'_Measurement"'
        self.code(fileObject,"create_item("+varName+",",0)
        self.code(fileObject,'"TDM Probe",',1)
        self.code(fileObject,varName+',',1)
        self.code(fileObject,"0,",1)
        self.code(fileObject,"-1,",1)
        if package.icon:
            self.code(fileObject,'"'+package.icon.name+'",',1)     
        else:
            self.code(fileObject,'NULL,',1)
        self.code(fileObject,varName+',',1)
        self.code(fileObject,'"*",',1)
        self.code(fileObject,"ComponentNetlistFmt,",1)
        self.code(fileObject,'"TDM Probe",',1)
        self.code(fileObject,"ComponentAnnotFmt,",1)
        if not package.symbol:
            self.code(fileObject,'"SYM_TDM_Probe",',1)
        else:
            package.symbol.name = package.symbol.name.strip()
            i = package.symbol.name.find(".dsn")
        if i > 0:
            self.code(fileObject,'"'+package.symbol.name[:i]+'",',1)
        else:
             self.code(fileObject,'"'+package.symbol.name+'",',1)
        self.code(fileObject,"no_artwork,",1)    
        self.code(fileObject,"NULL,",1)
        self.code(fileObject,"ITEM_PRIMITIVE_EX,",1)
        
        self.code(fileObject,'list(dm_create_cb(ITEM_NETLIST_CB,"'
                  + netlister + '",list("TDM_'+
                  package.name+'","'+
                  package.name +"\"," +
                  self.dk.varName + "_PATH"
                  '),TRUE)),',1)

        parameterSet = package.parameterSet
        measurementSet = package.measurementSet

      
        for i in measurementSet.measurementGroups:
            buff += '\tcreate_parm("Save_' + i.name + '",'
            buff += '"Output Control",PARM_NO_DISPLAY,"StdFileFormSet",UNITLESS_UNIT,'
            buff += 'prm("StdForm","no")),\n'
          
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                if p.uiOptions and p.uiOptions.dtype == "Activate_EditBrowse_FileBrowser":
                    buff += 'create_parm("Enable_' + p.name + '",'
                    unit = 'UNITLESS_UNIT'
                    buff += '"DESC",PARM_NO_DISPLAY,"StdFileFormSet",'+unit+','
                    buff += 'prm("StdForm","no"))'
                    buff += ","
                    buff += "\n"
                    buff += 'create_parm("' + p.name + '",'
                    unit = 'UNITLESS_UNIT'
                    buff += '"DESC",PARM_NO_DISPLAY,"StringAndReferenceFormSet",'+unit+','
                    if p.default:
                        buff += 'prm("StringAndReference","'+str(p.default)+'"))'
                    else:
                        buff += 'prm("StringAndReference",""))'
                else:
                    buff += 'create_parm("' + p.name + '",'
                    unit = 'UNITLESS_UNIT'
                    if p.units:
                        if p.units == "voltage":
                            unit = "VOLTAGE_UNIT"
                        elif p.units == "frequency":
                            unit = "FREQUENCY_UNIT"
                        elif p.units == "datarate":
                            unit = "DATARATE_UNIT"
                    buff += '"DESC",PARM_NO_DISPLAY,"StdFileFormSet",'+unit+','
                    if p.default:
                        buff += 'prm("StdForm","'+str(p.default)+'"))'
                    else:
                        buff += 'prm("StdForm",0))'

                buff += ","
                buff += "\n"
    #buff = buff[:len(buff)-2]
        buff += 'create_parm("ProbeSetData","Probe Set Data",PARM_REPEATED|PARM_NO_DISPLAY,'
        buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,list(prm("StringAndReference",""))),\n'
        
        buff += 'create_parm("PerformCompliance",' 
        buff += '"Flag to indicate if compliance test should be performed",PARM_NO_DISPLAY,'
        buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n' 
                
        buff += 'create_parm("UseStartTime",'
        buff += '"Use analysis start time", PARM_NO_DISPLAY,'
        buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n' 
        
        buff += 'create_parm("StartTime",' 
        buff += '"Analysis start time", PARM_NO_DISPLAY, "StdFileFormSet",UNITLESS_UNIT,prm("StdForm","0.0"))\n' 
        
        
        if (1):
            buff += ",\n"
            buff += 'create_parm("SaveWaveform",'
            buff += '"Save waveform", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n' 
            
            buff += 'create_parm("SuppressTransient",'
            buff += '"Suppress Transient output", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","yes"))\n' 
        if(0):
            buff += 'create_parm("SaveMeasurementStat",'
            buff += '"Save measurement statistics", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","yes")),\n' 
            
            buff += 'create_parm("SaveMeasurementForEveryBit",'
            buff += '"Save measurement for every bit", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("SaveCompliance_HTML",'
            buff += '"Save compliance to HTML", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("Compliance_HTML_FileName",'
            buff += '"Compliance HTML file name", PARM_NO_DISPLAY,'
            buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,prm("StringAndReference","\\"ComplianceReport.html\\"")),\n'
            
            buff += 'create_parm("SaveCompliance_XLS",'
            buff += '"Save compliance to XLS",PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("Compliance_XLS_FileName",'
            buff += '"Compliance Excel file name", PARM_NO_DISPLAY,'
            buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,prm("StringAndReference","\\"ComplianceReport.xls\\"")),\n'
            
            buff += 'create_parm("SaveCompliance_CSV",'
            buff += '"Save compliance to CSV", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("Compliance_CSV_FileName",'
            buff += '"Compliance CSV file name", PARM_NO_DISPLAY,'
            buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,prm("StringAndReference","\\"ComplianceReport.csv\\"")),\n'
            
            buff += 'create_parm("SaveMeasurement_XLS",'
            buff += '"Save compliance to XLS", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("Measurement_XLS_FileName",'
            buff += '"Measurement Excel file name", PARM_NO_DISPLAY,'
            buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,prm("StringAndReference","\\"MeasurementReport.xls\\"")),\n'
            
            buff += 'create_parm("SaveMeasurement_CSV",'
            buff += '"Save compliance to CSV", PARM_NO_DISPLAY,'
            buff += '"StdFileFormSet",UNITLESS_UNIT,prm("StdForm","no")),\n'
            
            buff += 'create_parm("Measurement_CSV_FileName",'
            buff += '"Measurement CSV file name", PARM_NO_DISPLAY,'
            buff += '"StringAndReferenceFormSet",UNITLESS_UNIT,prm("StringAndReference","\\"MeasurementReport.csv\\""))\n'
            
        self.code(fileObject,buff,2)
        self.code(fileObject,");",0)
    
    
    def generate(self,package,itemFileObject,dialogFileObject):
        buf = "//Auto generated file"
        print >> itemFileObject,buf
        print >> itemFileObject,'set_simulator_type(1);'
        print >> itemFileObject,'set_design_type(analogRFnet);\n\n'
        self.__generateCreateDialog(package,itemFileObject)
        self.__generateCreateItem(package,itemFileObject)
        self.__generateNetlister(package,itemFileObject,itemFileObject)
        buf = "//\n"
        buf += "// ***** DO NOT DELETE THE FOLLOWING!!!!! *****\n"
        buf += "//\n"
        buf += "// This obviously isn't a C++ file, but the C++ editing mode works.\n"
        buf += "//\n"
        buf += "// Local Variables:\n"
        buf += "// mode: c++\n"
        buf += "// header-comment-character: ?*\n"
        buf += '// header-prefix: "/* -*-C++-*-"\n'
        buf += '// header-suffix: "*/"\n'
        buf += '// End:\n'
        buf += '//\n'
        print >> itemFileObject,buf
 

class Generate_CMakefiles:
    def generate(self,package,
                 packageDIR,
                 sourceDIR,
                 codeDIR,
                 aelDIR,
                 symbolDIR,
                 bitmapPCDIR,
                 bitmapUNIXDIR
                 ):
        makeFile = file(packageDIR+"/CMakeLists.txt","w")
        print >> makeFile ,"PROJECT(",package.name,")"
        print >> makeFile ,"ADD_SUBDIRECTORY(source)"
        print >> makeFile ,"FIND_PACKAGE(TDCM)"
        
        makeFile = file(sourceDIR+"/CMakeLists.txt","w")
        print >> makeFile,"ADD_SUBDIRECTORY(measurements)"

        makeFile = file(codeDIR+"/CMakeLists.txt",'w')
        buff = 'SET('+package.name+'_SRCS\n'
        buff += '.internal/Descriptor.cxx\n'
        buff += '.internal/Interface.cxx\n'
        buff += 'Package.cxx\n'
        for measurement in package.measurementSet.measurementGroups:
            buff += measurement.name+'.cxx\n'
        buff += ')\n'
        print >> makeFile,buff

        f = __file__.rfind("/")
        location = __file__[:f]
        #shutil.copy(os.path.join(location,"FindTDCM_Utility.cmake"),
        #            os.path.join(codeDIR,".internal"))

        #shutil.copy(os.path.join(location,"ComplianceReport.py"),
         #           os.path.join(sourceDIR,"python","ComplianceReport.py"))


      #  shutil.copy(os.path.join(location,"ComplianceReport.ael"),aelDIR)
       # shutil.copy(os.path.join(location,"SYM_COMPLIANCE_REPORT.dsn"),symbolDIR)
        #shutil.copy(os.path.join(location,"pc","ComplianceReport.bmp"),bitmapPCDIR)
        #shutil.copy(os.path.join(location,"unix","ComplianceReport.bmp"),bitmapUNIXDIR)
        
        print >> makeFile,'set(CMAKE_MODULE_PATH ${'+package.name+'_SOURCE_DIR}/source/measurements/.internal)'
        print >> makeFile,'MESSAGE(${CMAKE_MODULE_PATH})'
      
        print >> makeFile,"FIND_PACKAGE(TDCM_Utility)"
        print >> makeFile,"TDCM_FIND_TDA_TOOLS()"
        print >> makeFile,"__TDA_COMPILE_DLL("
        print >> makeFile,"\t",package.name
        print >> makeFile,"\t${"+package.name+"_SOURCE_DIR}/source/measurements/"
        print >> makeFile,"\t${"+package.name+"_SRCS}"
        print >> makeFile,"\t)"

class Generate_Makedefs:
    def generate(self,package,
                 packageDIR,
                 sourceDIR,
                 codeDIR):
        sourceFile = file(codeDIR+"/.internal/Source.xml","w")
        print >> sourceFile,'<?xml version="1.0" encoding="UTF-8"?>'
        print >> sourceFile,('<SourceDescription Name="'+package.name+
                             '" Type="TDCM" Version="'+package.version+'">')
        #  print >> sourceFile,('<LinkLibrary Name="TDCM"/>')
        #   print >> sourceFile,('<IncludePath Name=".internal"/>')
        #   print >> sourceFile,('<IncludePath Name="../../"/>')
        #   print >> sourceFile,('<IncludePath Name="../"/>')
        print >> sourceFile,('<Source Name="Descriptor.cxx"/>')
        print >> sourceFile,('<Source Name="Interface.cxx"/>')
        print >> sourceFile,('<Source Name="../Package.cxx"/>')

        for measurement in package.measurementSet.measurementGroups:
            print >> sourceFile,('<Source Name="../'+measurement.name+'.cxx">')
        
      
class Generate_Python:
    def generate(self,package,sourceDIR):
        source = file(sourceDIR+"/"+package.name +"_Descriptor.py","w")
        print >> source,"from ADSSim_Modules import *"
        print >> source,"from Design import *"
        print >> source,"from Component import *"
        _index = -1
        descriptorObject = package.name + "_Descriptor"
        buff = descriptorObject + ' = TDCM_Descriptor("' + package.name + '")'
        print >> source,buff

        parameterSet = package.parameterSet
        for i in parameterSet.parameterGroups:
            for p in i.parameters:
                _index += 1
                parameterID = p.name  +"ID" 
                buff = parameterID + " = " + str(_index)
                print >> source,buff
                b = descriptorObject + "[" + parameterID + "]"
                buff  = b +' = ParameterDescriptor("'+p.name+'")\n'
                if p.modifiable != None:
                    buff += b +".setIsModifiable("+str(p.modifiable)+")\n"
                buff += b +".setIsReadable(True)\n"
                if p.default:
                    buff += b +".setIsRequired(False)\n"
                else:
                    buff += b +".setIsRequired(True)\n"
                if p.dataType == "IntegerType" or p.dataType == "BooleanType":
                    buff += b +".setDataType(PrimitiveDataType[types.IntType]|PrimitiveDataType[types.FloatType])\n"
                elif p.dataType == "RealType":
                    buff += b +".setDataType(PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType])\n"
                elif p.dataType == "StringType":
                    buff += b +".setDataType(PrimitiveDataType[types.StringType])\n"
                else:
                    assert 0,"Handled Type"
                print >> source,buff,"\n\n"

        if package.customLoader:
            source = file(sourceDIR+"/__init__.py","w")
            print >> source,"from " + package.name +"_Descriptor import *"
            print >> source,"from " + package.customLoader + " import *\n\n"
            print >> source,"GlobalLoaders.getComponentLoader().register(",package.name,")"
        else:
            source = file(sourceDIR+"/__init__.py","w")
            print >> source,"from " + package.name +"_Descriptor import *"
            print >> source,"class ",package.name,"(TDCM_Loader):"
            __buff = "\tdescriptor = "+package.name+"_Descriptor\n"
            print >> source,__buff
            print >> source,"\tdef __init__(self,instance):"
            print >> source,"\t\tTDCM_Loader.__init__( self, instance )"
            __buff  = '\t\tself.package = "' + package.name + '"\n'
            print >> source,__buff,"\n\n"
            print >> source,"GlobalLoaders.getComponentLoader().register(",package.name,")"
        
            

def usage():
    print "Usage:"
    print "\tsetup-tdcm-package [-s] [-c] -p<name>"
    print "\tsetup-tdcm-package [-s] [-c] --package=<name>"
    print "\t Use -s to generate just the source."

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hp:vzsc", ["help", "package="])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)
    package = None
    verbose = False
    generateSourceOnly = False
    cleanCVS = False
    zipFile = False
    for o, a in opts:
        if o == "-v":
            verbose = True
        elif o == "-c":
            cleanCVS = True
        elif o == "-s":
            generateSourceOnly = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-p", "--package"):
            package = a
        elif o == "-z":
            zipFile = True
        else:
            assert False, "unhandled option"
    if package == None:
        print "Package name not specified."
        usage()
        sys.exit(2)

    if zipFile == False:
        kit = DesignKit(package,"1.0","Default Description")
        kit.generateSourceOnly = generateSourceOnly
        kit.cleanCVS = cleanCVS
        kit.setup()
    else:
        os.system("mkdir -p temp")
        os.system("cd temp;cp -rf ../" + package + " .")
        os.system("cd temp;python ../../python-script/TDCM-create.py -c -p" + package)
        os.system("cd temp;zip -r " +package+ ".zip "+ package )
        os.system("cp temp/"+package+".zip .")
                         
if __name__ == "__main__":
    #try:
    main()
    #except:
     #   print "Error when creating package."

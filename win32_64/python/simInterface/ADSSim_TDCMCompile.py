# Copyright Keysight Technologies 2009 - 2015  
import os
import sys
import xml.parsers.expat
import stat
import getopt
import subprocess
import re

LOGFILE = None

def printInfo(message):
    # s = Design.Simulation.getInstance()
    #s.printInfo(message+"\n")
    print >> sys.stderr,message

def prepare_argument_for_platform(arg):
    if re.search('\s', arg):
        return "\"" + arg + "\""
    else:
        return arg

class Exception:
    def __init__(self,error):
        self.error = error

class SourceDescription:
    def __init__(self):
        self.linkLibrary = []
        self.source = []
        self.linkPath = []
        self.includePath = []
        self.target = None
        self.type = None
        self.version = None
        self.name = None
        
    def __str__(self):
        s  = "Source: " + str(self.source) + "\n"
        lp = "LinkPath: " + str(self.linkPath) + "\n"
        ip = "IncludePath: "+str(self.includePath) + "\n"
        return (s + lp + ip)
        
class Compiler:
    def __init__(self,version,isDebug,_32bits,SIMARCH,TDA_ROOT):
        self.root = None
        self.compiler = None
        self.SIMARCH = SIMARCH
	self.TDA_ROOT = TDA_ROOT
        self.sourceDescriptor = None
        self.objectFiles = []
        self._32bits = _32bits
        self.compileVersion = version
        self.needBuilding = True
        self.dependency = {}
        self.newDependency = {}
        self.checkFileDependency = True
        self.TDCM_Root = None
        self.debug = isDebug
        self.target = None

    def setTDCMRoot(self,directory):
        self.TDCM_Root = directory
      
    def setCheckFileDependency(self,state):
        self.checkFileDependency = state
        
    def setRoot(self,root):
        self.root = root
        
    def setCompiler(self,compiler):
        self.compiler = compiler

    def setup(self):
        try:
            os.stat(self.root)
        except:
            raise Exception("Unable to find root package directory.")
        self.needBuilding = self.__checkVersion__()
        self.__buildDependency__()
        if ((self.needBuilding) or (self.checkFileDependency)):
            self.__checkCompiler__()
            sourceFile = self.__checkRoot__()
            builder = SourceBuilder()
            builder.build(sourceFile)
            self.sourceDescriptor = builder.sourceDescriptor
            if not self.needBuilding:
                self.needBuilding = self.__checkDependency__()
        return

    def __checkDependency__(self):
        sourceDirectory = prepare_argument_for_platform(os.path.join(self.root,"source","measurements",".internal"))
        state = False
        f = None
        for i in self.sourceDescriptor.source:
            f = i
            fileName = os.path.join(sourceDirectory,i)
            if self.SIMARCH.find("win32") >= 0:
                fileName = fileName.replace("/","\\")
                f = f.replace("/","\\")
            statInfo = None
            if self.dependency.has_key(f):
                statInfo = self.dependency[f]
            newStatInfo = os.stat(fileName)[stat.ST_MTIME]
            newStatInfo = str(newStatInfo)
            if statInfo != newStatInfo:
                if LOGFILE:
                    print >> LOGFILE,("Source file "+i+" is not up to date. stat.new("+str(newStatInfo)+") stat.cache("+str(statInfo) + ")")
                state = True
            else:
                if LOGFILE:
                    print >> LOGFILE,("Source file "+i+" is not up to date. stat.new("+str(newStatInfo)+") stat.cache("+str(statInfo)+")")
        return state
        
    def __buildDependency__(self):
        fileName = prepare_argument_for_platform(os.path.join(self.root,"lib",self.SIMARCH,"dependency-info.txt"))
        try:
            dependencyFile = file(fileName,"r")
            sourceName = dependencyFile.readline()
            sourceStat = dependencyFile.readline()
            while((sourceName != "") and (sourceStat != "")):
                self.dependency[sourceName.strip()] = sourceStat.strip()
                sourceName = dependencyFile.readline()
                sourceStat = dependencyFile.readline()                
        except:
            printInfo("Dependency file does not exist.")
            self.dependency = {}
      

    def __checkVersion__(self):
        status = True
        fileName = os.path.join(self.root,"lib",self.SIMARCH,"version-info.txt")
        try:
            os.stat(fileName)
            versionFile = file(fileName,"r")
            versionInfo = versionFile.read()
            if LOGFILE:
                print >> LOGFILE,("Last Compiled Version Info : "+versionInfo.strip())
                print >> LOGFILE,("Current Version            : "+self.compileVersion.strip())
            if versionInfo.strip() == self.compileVersion.strip():
                status = False
            versionFile.close()
        except:
            printInfo("Version info file does not exist.")
            status = True
        return status
    
    def __compileSource__(self,source,sourceDirectory,
                          internalDirectory,objectDirectory):
        iCommand = " -I " + prepare_argument_for_platform(sourceDirectory)
        iCommand += " -I " + prepare_argument_for_platform(internalDirectory)
        iCommand += " -I " + prepare_argument_for_platform(os.path.join(self.TDCM_Root,"include"))
        for i in self.sourceDescriptor.includePath:
            iCommand += " -I " + i

	if self.SIMARCH.find("win32") == -1:
        	command = self.compiler + " -fPIC -pipe "
	else:
		command = prepare_argument_for_platform(self.compiler) + " -pipe "
		command += ' "-O2" '
		if not self._32bits:
			iCommand += " -I "+ prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","include"))
			iCommand += " -I "+ prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","lib","gcc","x86_64-w64-mingw32","4.6.3","include"))
			bPath = " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","bin"))
			bPath += " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","libexec","gcc","x86_64-w64-mingw32","4.6.3")) + " "
			command += bPath
        if self.debug:
            command += ' "-O2" '
        if self._32bits:
            command += " -m32 "
        else:
	    if self.SIMARCH.find("win32") == -1:	
            	command += " -m64 -D__USE_XOPEN2K8 "

        command += prepare_argument_for_platform(os.path.join(internalDirectory,source))
        objectFile = source
        command += " -c -o "+ prepare_argument_for_platform(os.path.join(objectDirectory,objectFile + ".o"))
        command += " " + iCommand 
        if LOGFILE:
            print >> LOGFILE,("<Compile> "+command+"\n")
        printInfo("Compiling:"+source)
       
        # This is so wrong, but for the momment, this is the only
        # way it seems to work due to having quotes for the strings
        # TFS106097 Jaime
        if self.SIMARCH.find("win32") == 0:
            status = subprocess.call(command)
        elif self.SIMARCH.find("linux_x86") == 0:
            status = os.system(command)

        if LOGFILE:
            print >> LOGFILE,"status: ", status

        return status


    def __collectObjectFiles__(self,objectDirectory,internalDirectory):
        objectFiles = os.listdir(objectDirectory)
        for i in objectFiles:
            self.objectFiles.append(os.path.join(objectDirectory,i))
	objectFiles = os.listdir(internalDirectory)
	for i in objectFiles:
	    if i[len(i)-2:] == ".o":
            	self.objectFiles.append(os.path.join(internalDirectory,i)) 
       

	
	return
    
    def __cleanSource__(self,objectDirectory):
        files = os.listdir(objectDirectory)
        for i in files:
            if i.rfind(".o") > 0:
                if LOGFILE:
                    print >> LOGFILE,("Removing:"+i+"")
                os.remove(os.path.join(objectDirectory,i))
        printInfo("Cleaned up source Directory....")

    def __updateDependency__(self):
        fileName = prepare_argument_for_platform(os.path.join(self.root,"lib",self.SIMARCH,"dependency-info.txt"))
        try:
            f = file(fileName,"w")
            for i in self.newDependency:
                print >> f,i
                print >> f,self.newDependency[i]
        except:
            raise Exception("Unable to create dependency file.")
        
    def __createTarget__(self):
        libDirectory = os.path.join(self.root,"lib")
        try:
            os.stat(libDirectory)
        except:
            os.mkdir(libDirectory)
        linkDirectory = os.path.join(libDirectory,self.SIMARCH)
        try:
            os.stat(linkDirectory)
        except:
            try:
                os.mkdir(linkDirectory)
            except:
                raise Exception("Unable to create lib/"+ self.SIMARCH+" directory.")
            
        oCommand = prepare_argument_for_platform(self.compiler) +  " -shared "
        if self._32bits:
            oCommand += " -m32 "
        else:
	    if self.SIMARCH.find("win32") == -1:
            	oCommand += " -m64 "
        oCommand += " -L . "
	if self.SIMARCH.find("win32") == 0:
		if not self._32bits:
			bPath = " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","bin"))
			bPath += " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","lib"))
			bPath += " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","lib","gcc","x86_64-w64-mingw32","4.6.3"))
			bPath += " -B " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","libexec","gcc","x86_64-w64-mingw32","4.6.3")) + " "
			oCommand += bPath + " -static-libgcc -pipe  -L "
			oCommand += prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw64","lib","gcc","x86_64-w64-mingw32","4.6.3")) + " "
		else:
			oCommand += " -L " + prepare_argument_for_platform(os.path.join(self.TDA_ROOT,"mingw32","lib")) + "  "	
		oCommand += " -o " + linkDirectory + "\\"
		oCommand += ("libTDCM_"+self.sourceDescriptor.name + ".dll ")
	
	else:
        	oCommand += " -o " + linkDirectory + "/"
		oCommand += ("libTDCM_"+self.sourceDescriptor.name + ".so")
        
        for i in self.objectFiles:
            oCommand += " "+ i + " "
        for i in self.sourceDescriptor.linkPath:
            oCommand += " -L " + i
        for i in self.sourceDescriptor.linkLibrary:
            oCommand += " -l" + i
        oCommand += " -L " + prepare_argument_for_platform(os.path.join(self.TDCM_Root,"lib."+self.SIMARCH)) + " "
	oCommand += (" -lTDCM")
        printInfo("Linking:"+self.sourceDescriptor.name)
        if LOGFILE:
            print >> LOGFILE,"Linking:",oCommand
        
        # This is so wrong, but for the momment, this is the only
        # way it seems to work due to having quotes for the strings
        # TFS106097 Jaime
        if self.SIMARCH.find("win32") == 0:
            status = subprocess.call(oCommand)
        elif self.SIMARCH.find("linux_x86") == 0:
            status = os.system(oCommand)

        if status != 0:
            print >> LOGFILE,"status:", status
            raise Exception("Linking Error.\n")

        versionInfoFileName = prepare_argument_for_platform(os.path.join(linkDirectory,"version-info.txt"))
        try:
            versionInfoFile = file(versionInfoFileName,"w")
            print >> versionInfoFile , self.compileVersion
        except:
            printInfo("Warning unable to create version info file.")

    def __getTargetName__(self):
        libDirectory = os.path.join(self.root,"lib")
        if self.SIMARCH.find("linux") == 0:
            linkDirectory = None
            linkDirectory = os.path.join(libDirectory,self.SIMARCH,"libTDCM_")
            self.target = linkDirectory + self.sourceDescriptor.name + ".so"
            self.target = self.target[:self.target.rfind(".")]
	elif self.SIMARCH.find("win32") == 0:
	    linkDirectory = None
            linkDirectory = os.path.join(libDirectory,self.SIMARCH,"libTDCM_")
            self.target = linkDirectory + self.sourceDescriptor.name + ".dll"
            self.target = self.target[:self.target.rfind(".")]
        else:
            assert 0,"Unhandled Platform."
        return self.target
        
    def _createTarget_(self):
        self.__createTarget__()
        self.__updateDependency__()


    def __checkFileChange__(self):
        status = False
        if self.checkFileDependency:
           for i in self.sourceDescriptor.source:
               statInfo = None
               if self.dependency.has_key(i):
                   statInfo = self.dependency[i]
               newStatInfo = os.stat(i)[stat.ST_MTIME]
               newStatInfo = str(newStatInfo).strip()
               if statInfo == newStatInfo:
                   pass


    def compile(self):
        if self.needBuilding:
            sourceDirectory = prepare_argument_for_platform(os.path.join(self.root,"source","measurements"))
            internalDirectory = prepare_argument_for_platform(os.path.join(sourceDirectory,".internal"))
            objectDirectory = prepare_argument_for_platform(os.path.join(internalDirectory,"objects"))
            try:
                os.mkdir(objectDirectory)
            except:
                pass
            self.__cleanSource__(objectDirectory)
            self.__cleanSource__(internalDirectory)
            for i in self.sourceDescriptor.source:
		if self.SIMARCH.find("win") == 0:
			v = i.replace("/","\\")
		else:
			v = i
                fileName = os.path.join(internalDirectory,v)
                newStatInfo = os.stat(fileName)[stat.ST_MTIME]
                newStatInfo = str(newStatInfo).strip()
                status = self.__compileSource__(v,sourceDirectory,
                                                internalDirectory,
                                                objectDirectory)
                if status != 0:
                    raise Exception("Compiler Error.\n")
                self.newDependency[v] = newStatInfo
            self.__collectObjectFiles__(objectDirectory,internalDirectory)
            self._createTarget_()
            self.__cleanSource__(objectDirectory)
            self.__cleanSource__(internalDirectory)
        else:
            pass
            #printInfo("Compilation not required.")
        return self.__getTargetName__()
        
    def __checkRoot__(self):
        if not self.root:
            raise Exception("Package root is not defined.")
        if not self.TDCM_Root:
            raise Exception("TDCM root is not defined.")
        sourceFile = self.root+"/source/measurements/.internal/Source.xml"
        try:
            os.stat(sourceFile)
        except:
            printInfo("Unable to find source description file "+sourceFile)
            print >> sys.stderr,"Unable to find source description file "+sourceFile
            raise Exception("Unable to find source description file "+sourceFile)
        return sourceFile

    def __checkCompiler__(self):
	if not self.compiler:
            raise Exception("Compiler not set.")
        try:
            os.stat(self.compiler)
        except:
            raise Exception("Unable to find compiler '" + str(self.compiler) + "'.")
        

def start_element(name, attrs):
    if name == "SourceDescription":
        SourceBuilder.Instance.sourceDescriptorStart(attrs)
    elif name == "Target":
        SourceBuilder.Instance.targetStart("Icon",attrs)
    elif name == "LinkLibrary":
        SourceBuilder.Instance.linkLibraryStart(attrs)
    elif name == "IncludePath":
        SourceBuilder.Instance.includePathStart(attrs)
    elif name == "LinkPath":
        SourceBuilder.Instance.linkPathStart(attrs)
    elif name == "Source":
        SourceBuilder.Instance.sourceStart(attrs)
    else:
        SourceBuilder.Instance.unhandledStart(name,attrs)
        
def end_element(name):
    if name == "SourceDescription":
        SourceBuilder.Instance.sourceDescriptorEnd()
    elif name == "Target":
        SourceBuilder.Instance.targetEnd()
    elif name == "LinkLibrary":
        SourceBuilder.Instance.linkLibraryEnd()
    elif name == "IncludePath":
        SourceBuilder.Instance.includePathEnd()
    elif name == "LinkPath":
        SourceBuilder.Instance.linkPathEnd()
    elif name == "Source":
        SourceBuilder.Instance.sourceEnd()
    else:
        SourceBuilder.Instance.unhandledEnd(name,None)

def char_data(data):
    SourceBuilder.Instance.handleData(data)


class SourceBuilder:
    Instance = None
    SourceDescriptorAttributes = {"Type":1,"Version":2,"Name":3}
    OtherAttributes = {"Name":1}

    def __init__(self):
        self.parser = xml.parsers.expat.ParserCreate()
        self.parser.StartElementHandler = start_element
        self.parser.EndElementHandler = end_element
        self.parser.CharacterDataHandler = char_data
        SourceBuilder.Instance = self
        self.sourceDescriptor = None
        self.file = None
        self.buffer = None

    def build(self,fileName):
        try:
            self.file = file(fileName,"r")
            self.buffer = self.file.read()
        except:
            raise Exception("Unable to access source file '"+fileName+'"')
        self.parser.Parse(self.buffer)
               
    def sourceDescriptorStart(self,attrs):
        self.sourceDescriptor = SourceDescription()
        for i in attrs:
            if not SourceBuilder.SourceDescriptorAttributes.has_key(i):
                raise Exception("Unknown Attribute " +
                                str(i) + "for Source Description")
            if i == "Name":
                self.sourceDescriptor.name = attrs[i]
            elif i == "Type":
                self.sourceDescriptor.type = attrs[i]
            elif i == "Version":
                self.sourceDescriptor.version = attrs[i]
            else:
                assert 0,"Error in SourceBuilder.sourceDescriptorStart"
                
        if ( (not self.sourceDescriptor.name) and 
             (not self.sourceDescriptor.type) and
             (not self.sourceDescriptor.version)):
            raise Exception("SourceDescriptor requires <Name,Type,Version>")
        return
                        
    def __genericStart(self,attrs,param):
        if not (self.sourceDescriptor):
            raise Exception("SourceDescriptor must be defined before " + param +  " first")
        name = None
        for i in attrs:
            if not SourceBuilder.OtherAttributes.has_key(i):
                raise Exception("Unknown Attribute " +
                                str(i) + "for " + param +".")
            if i == "Name":
                name = str(attrs[i])
        return name
            
    def targetStart(self,attrs):
        name = self.__genericStart(attrs,"Target")
        self.sourceDescriptor.target = name
        return

    def linkLibraryStart(self,attrs):
        name = self.__genericStart(attrs,"LinkLibrary")
        self.sourceDescriptor.linkLibrary.append(name)
        return

    def includePathStart(self,attrs):
        name = self.__genericStart(attrs,"IncludePath")
        self.sourceDescriptor.includePath.append(name)
        return

    def linkPathStart(self,attrs):
        name = self.__genericStart(attrs,"LinkPath")
        self.sourceDescriptor.linkPath.append(name)
        return

    def sourceStart(self,attrs):
        name = self.__genericStart(attrs,"Source")
        self.sourceDescriptor.source.append(name)
        return

    def targetEnd(self):
        return

    def linkLibraryEnd(self):
        return

    def includePathEnd(self):
        return

    def linkPathEnd(self):
        return

    def sourceEnd(self):
        return

    def sourceDescriptorEnd(self):
        return

    def unhandledStart(self,name,attrs):
        raise Exception("Unknown Tag " + str(name) + " " + str(attrs) )
    
    def handleData(self,data):
        return

def compilePackage(rootPackage,tdcmRoot,gcc,version,
                   isDebug,is32bit,checkDepend,HPEESOF_DIR,SIMARCH,TDA_ROOT,justCheck=False):
    if os.environ.has_key("GCC_EXEC_PREFIX"):
        os.environ["GCC_EXEC_PREFIX"] = ""
    if os.environ.has_key("LIBRARY_PATH"):
        os.environ["LIBRARY_PATH"] = ""
    if os.environ.has_key("COMPILER_PATH"):
        os.environ["COMPILER_PATH"] = ""
        
    if SIMARCH.find("linux_x86") == 0:
        if os.environ.has_key("LD_LIBRARY_PATH"):
            os.environ["LD_LIBRARY_PATH"] =  os.path.join(HPEESOF_DIR,"tiburonda","tools",SIMARCH,"lib") +":" + os.environ["LD_LIBRARY_PATH"]  
        else:
            os.environ["LD_LIBRARY_PATH"] =  os.path.join(HPEESOF_DIR,"tiburonda","tools",SIMARCH,"lib")
    elif SIMARCH.find("win32_64") == 0:
            os.environ["PATH"] =  os.path.join(HPEESOF_DIR,"tiburonda","tools","mingw64","lib") + ";" + os.environ["PATH"]
    elif SIMARCH.find("win32") == 0:
            os.environ["PATH"] =  os.path.join(HPEESOF_DIR,"tiburonda","tools","mingw32","bin") + ";" + os.path.join(HPEESOF_DIR,"tiburonda","tools","mingw32","lib") + ";" + os.environ["PATH"]
            
    compiler = Compiler(version,int(isDebug),int(is32bit),SIMARCH,TDA_ROOT) 
    compiler.setRoot(rootPackage)
    compiler.setCheckFileDependency(int(checkDepend))
    compiler.setTDCMRoot(tdcmRoot)
    compiler.setCompiler(gcc)
    compiler.setup()
    
    if justCheck == True:
        if not compiler.needBuilding:
            return compiler.__getTargetName__()
        return None
    if LOGFILE:
        print >> LOGFILE,"TDCM Compile log"
        print >> LOGFILE,"HPEESOF_DIR :",HPEESOF_DIR
        print >> LOGFILE,"SIMARCH :",SIMARCH
        print >> LOGFILE,"TDA_ROOT :",TDA_ROOT
        print >> LOGFILE,"Package :",rootPackage
        print >> LOGFILE,"TDCM :",tdcmRoot
        print >> LOGFILE,"Version :",version
        print >> LOGFILE,"Compiler :",gcc
    return compiler.compile()
    

if __name__ == "__main__":
        # Get input args
    try:
        optlist, args = getopt.gnu_getopt( sys.argv[1:], 'h',
                                  ['checkDepend=','gcc=','isDebug=',
                                   'is32bit=', 'hpeesofDir=',
                                   'rootPackage=', 'simarch=', 'tdaRoot=',
                                   'tdcmRoot=', 'version=', 'help'] )
    except getopt.GetoptError:
        # Unrecognized arguments will be processed here. The 
        # getopt.GetoptError will check the parameters 
        print 'Unrecognized parameters'
        print 'sys.argv[1:] = ', sys.argv[1:]
        sys.exit( 2 )
    for opt, arg in optlist:
        if opt in ('-h', '--help'):
            sys.exit( )
        elif opt == '--checkDepend':
            checkDepend = arg
        elif opt == '--gcc':
            gcc = arg
            print 'gcc ', gcc
        elif opt == '--isDebug':
            isDebug = arg
            print 'isDebug ', isDebug
        elif opt == '--is32bit':
            is32bit = arg
            print 'is32bit ', is32bit
        elif opt == '--hpeesofDir':
            HPEESOF_DIR = arg
            print 'HPEESOF_DIR ', HPEESOF_DIR
        elif opt == '--rootPackage':
            rootPackage= arg
        elif opt == '--simarch':
            SIMARCH= arg
        elif opt == '--tdaRoot':
            TDA_ROOT = arg
            print 'TDA_ROOT ', TDA_ROOT
        elif opt == '--tdcmRoot':
            tdcmRoot = arg
        elif opt == '--version':
            version= arg

    LOGFILE = file(os.path.join(rootPackage,"lib","Compiler.log"),"w")
    target = None
    try:
        target = compilePackage(rootPackage,tdcmRoot,gcc,version,
                                isDebug,is32bit,checkDepend,HPEESOF_DIR,SIMARCH,TDA_ROOT)
    except:
        pass
    f = file("__target__.tag","w")
    print >> f,target
    f.close()
    LOGFILE.close()
    LOGFILE = None


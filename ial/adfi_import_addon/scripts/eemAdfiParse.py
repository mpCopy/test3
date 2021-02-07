#!python
# Copyright Keysight Technologies 2009 - 2019  
# Copyright (C)  Keysight EEsof EDA
# All rights reserved.
#
# Process an DFI file for import into ADS
#
# invoked through ads_invoke_process("eesofSubed", "", ".",TRUE,TRUE,"tt")

import string
import re
import os
import sys
import subprocess
import logging

if __name__=="__main__":
    # From ADS this file is always executed as the main program
    # The current working directory is then set such that there is write permission
    logfile = './eemAdfiParse.log'
else:    
    # From EMPro this module is imported
    # The current working directory is not set and it may have no write permission
    import tempfile
    file_h, logfile = tempfile.mkstemp("_eemAdfiParse.log")
    os.close(file_h)

#enable new logging on recent versions
hversion=sys.hexversion
if hversion >= 0x20401F0:
    #setup logging before loading other modules that use logging
    logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)-8s %(message)s',
                    datefmt='%a, %d %b %Y %H:%M:%S',
                    filename=logfile,
                    filemode='w')
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('ADFI parser: %(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)
    console.flush()

    eemWriteError=logging.error
    eemWriteWarn=logging.warn
    eemWriteInfo=logging.info
    eemWriteDebug=logging.debug
else:
    def eemWriteLog(iType,iMessage):
        sys.stderr.write('%s: %s\n' % (iType,iMessage))
    def eemWriteError(iMessage):
        eemWriteLog('Error',iMessage)
    def eemWriteWarn(iMessage):
        eemWriteLog('Warning',iMessage)
    def eemWriteInfo(iMessage):
        eemWriteLog('Info',iMessage)
    def eemWriteDebug(iMessage):
        eemWriteLog('Debug',iMessage)
    eemWriteWarn('Using stderr for log output')

if hversion < 0x20401F0:
    eemWriteError('Python version not recent enough')
    sys.exit(1)


##############################################################################
# parsing using Python's xml.dom.minidom and xml.dom.pulldom modules
#
import xml.dom.pulldom
import xml.dom.minidom
import xml.sax
import xml.sax.handler

def eemGetElNodeValByTag(iNode, iTag):
    elements = iNode.getElementsByTagName(iTag)
    value = None
    if elements and len(elements)==1:
        value = getInnerText(elements[0])
    return value

def eemGetElNodeAttrByTagAttrValue(iNode, iTag, attrKeyName, attrKeyValue, attrValueName):
    elements = iNode.getElementsByTagName(iTag)
    for el in elements:
        if el.hasAttribute(attrKeyName) and el.getAttribute(attrKeyName).upper() == attrKeyValue.upper():
            if el.hasAttribute(attrValueName):
                return el.getAttribute(attrValueName)
    return None

def contentOfNode(node):
    if node.nodeType == node.TEXT_NODE:
        return node.data
    elif node.nodeType==node.ELEMENT_NODE:
        return getInnerText(node)   # recursive !!!
    elif node.nodeType==node.CDATA_SECTION_NODE:
        return node.data
    else:
        # node.nodeType: PROCESSING_INSTRUCTION_NODE, COMMENT_NODE, DOCUMENT_NODE, NOTATION_NODE and so on
       pass

def getInnerText(oNode):
    rc = ""
    nodelist = oNode.childNodes
    rc = ''.join([contentOfNode(node) for node in nodelist])
    return rc


def eemFixName(iName, iMapChar='[^a-zA-Z0-9_@`#&$%^=+-]'):
    return re.sub(iMapChar, '_', iName)


class AdfiInfo:
    def __init__(self):
        self.version=None
        self.mainVersion=-1
        self.minorVersion=None
        self.revision=0
        self.tool=None
        self.target=None
        self.drawing_units=None
        self.drawing_resolution=None

    def setAdfiToAdsAttributes(self,event,nodeAdfiToAds):
        if event==xml.dom.pulldom.START_ELEMENT and nodeAdfiToAds.localName=='AdfiToAds':
            if nodeAdfiToAds.hasAttribute('adfiVersion'):
                self.version=nodeAdfiToAds.getAttribute('adfiVersion')
                vl=self.version.split('.')
                self.mainVersion=int(vl[0])
                if len(vl)==3:
                    self.minorVersion=int(vl[1])
                self.minorVersion=int(vl[-1])
            if nodeAdfiToAds.hasAttribute('tool'):
                self.tool=nodeAdfiToAds.getAttribute('tool')
            if nodeAdfiToAds.hasAttribute('adfiTarget'):
                self.target=nodeAdfiToAds.getAttribute('adfiTarget')

    def setUnits(self,iUnitsNode):
        self.drawing_units=eemGetElNodeAttrByTagAttrValue(iUnitsNode, "Unit", 'key', 'drawing_units', 'value')
        self.drawing_resolution=eemGetElNodeAttrByTagAttrValue(iUnitsNode, "Unit", 'key', 'drawing_resolution', 'value')
        
    def getDrawingUnitConversionFactor(self):
        # TODO: add other units
        factorMap = {'m':1,'mm':1e-3,'um':1e-6,'nm':1e-9,'pm':1e-12,'mil':2.54e-5,'inch':2.54e-2,'in':2.54e-2}
        conversionFactor = 1
        unit=self.drawing_units
        if unit in factorMap.keys():
            conversionFactor = factorMap[unit]
        else:
             raise Exception('Unknown unit %s' % unit)
        return conversionFactor
    
    def checkTargetPlatform(self,target='ads'):
        if self.target == None:
            return
        if self.target!=target:
            # if self.version = 4.1.4 then the adfiTarget is always ads -> ignore check
            if self.version != None and self.version == "4.1.4":
                return
            raise Exception('Adfi target platform: %s not matching!' % self.target)
        else:
            pass


class AdfiEgsWriter:
    """This class is used to write out .egs file."""
    def __init__(self, fileName,useSolderBalls=False):
        self.fileName = fileName
        self.file = None
        self.useSolderBalls=useSolderBalls
        self.filterEgs={}

    def close(self):
        if self.file==None:
            return
        self.file.close()
        
    def writeHeader(self, egsHeader=''):
        try:
            if self.file==None:
                self.file = open(self.fileName,'w')
            self.file.write(egsHeader)
            self.file.write("\n\n")
        except:
            raise Exception("Failed to write egs header in %s!" % self.fileName)


    def writeBody(self, iEgsData='', iId='', iName='', top=None, maskNameNbMap={}):
        if self.file==None:
            raise Exception("Failed to write into egs file")
        #assemble egs here
        refDes = eemFixName(iId)
        egsData = iEgsData
        egsBody = ''
        name = iName
        if top:
            refDes += "_adfi"
        if iId in self.filterEgs.keys():
            # Filter out layer bumpLayerNb and pinLayerNb
            #eemWriteDebug("Egs data to be filtered %s" % (egsData))
            (bumpLayer, pinLayer)=self.filterEgs[iId]
            bumpLayerNb = maskNameNbMap[bumpLayer]
            pinLayerNb = maskNameNbMap[pinLayer]
            egsData = re.sub('ADD [A-Z]%s \:W.+;\n*'% bumpLayerNb,'', egsData)
            egsData = re.sub('ADD [A-Z]%s \:W.+;\n*'% pinLayerNb,'', egsData)
            #eemWriteDebug("Egs data after filtering %s" % (egsData))
            pass
        egsBody += "EDIT " + refDes + ";\n"
        egsBody += "$$ component " + name + " instance " + refDes + ";\n"
        egsBody += egsData + "\nSAVE;\n\n"
        self.file.write(egsBody)
        
    def updateFilterEgsMap(self,cmpParmsNode,iId=''):
        parameters = getComponentParms(cmpParmsNode)
        # eemWriteDebug("update egs map %s" % str(parameters))
        if self.useSolderBalls and parameters:
            if parameters.has_key('ICPKG_TYPE') and parameters['ICPKG_TYPE'] == 'DIE_FLIPCHIP':
                bumpLayer = parameters['ICPKG_BUMP_LAYER']
                pinLayer = parameters['ICPKG_PIN_LAYER']
                self.filterEgs[iId]=tuple([bumpLayer,pinLayer])
                eemWriteDebug("Found flipchip component with solder balls on layer %s to be excluded from egs." % bumpLayer)
            elif parameters.has_key('PKG_TYPE') and parameters['PKG_TYPE'] == 'BGA':
                filterEgs = True
                bumpLayer = parameters['PKG_BALL_LAYER']
                pinLayer = parameters['PKG_PIN_LAYER_ATPKG']
                self.filterEgs[iId]=tuple([bumpLayer,pinLayer])
                eemWriteDebug("Found BGA component with solder balls on layer %s to be excluded from egs." % bumpLayer)
   

def getMaskNames(iStacks):
    # get top level substrate information
    ltdFile = iStacks.getLtdFileName(None)
    ltdFp = open( ltdFile, "r" )
    maskNameNbMap = {}
    for line in ltdFp.readlines():
        words = line.split()
        if len(words) < 3:
            continue
        if (words[0].upper() != 'MASK'):
            continue
        maskNb = words[1]
        for w in words[2:]:
            subwords=w.split('=')
            if len(subwords) < 2:
                continue
            if (subwords[0].upper() != 'NAME'):
                continue
            maskName = subwords[1]
            maskNameNbMap[maskName]=maskNb
    ltdFp.close()
    return maskNameNbMap


class AdfiHdefWriter:
    """This class is used to write out .hdef file."""
    def __init__(self, fprefix, iAdfiInfo, iAblPresent=False, iUseAblRoot=False):
        fName = fprefix + '_adfi.ahdf'
        eemWriteDebug("ADFI Hierarchical Definition Filename is: %s" % fName)
        self.dirName=os.path.dirname(fName) 
        self.hasAbl=iAblPresent
        self.useAblRoot=iUseAblRoot
        self.file = open(fName, "w")
        self.file.write("\"ADFISTARTINFO|VERSION|%s|TOOL|%s\",\n" %(iAdfiInfo.version, iAdfiInfo.tool))

    def close(self):
        self.file.close()

    def writeLibrarySubstrate(self,iStacks=None):
        if self.hasAbl:
            return
        refDesName=None
        slmFile=None
        ltdFile=None
        if iStacks:
            refDesName = iStacks.getTopDesignName()
            slmFile = iStacks.getSlmFileName(refDesName)
            ltdFile = iStacks.getLtdFileName(refDesName)
        if slmFile!=None:
            if ltdFile==None:
                self.file.write("\"ADFILIBRARYSUBSTRATE|DESIGN|%s|%s\",\n" % (eemFixName(refDesName),slmFile))
            else:
                self.file.write("\"ADFILIBRARYSUBSTRATE|DESIGN|%s|%s|%s\",\n" % (eemFixName(refDesName + "_adfi"),slmFile,ltdFile))

    def writeCmpInfo(self, adfiVersion, tool, refDes, name, cmpType, topLevel, mainLevel, viewName):
        if viewName == None or viewName == '':
            self.file.write("\"ADFICMPINFO|VERSION|%s|TOOL|%s|DESIGN|%s|CMPNAME|%s|TYPE|%s|TOP|%s|MAIN|%s\",\n" %
                            (adfiVersion, tool, eemFixName(refDes), eemFixName(name), cmpType, topLevel, mainLevel))
        else:
            self.file.write("\"ADFICMPINFO|VERSION|%s|TOOL|%s|DESIGN|%s|CMPNAME|%s|TYPE|%s|TOP|%s|MAIN|%s|VIEW|%s\",\n" %
                            (adfiVersion, tool, eemFixName(refDes), eemFixName(name), cmpType, topLevel, mainLevel, eemFixName(viewName)))
        
    def writeFiguresInfo(self,iVersion, iTool, iRefDes):
        self.file.write("\"ADFIFIGURESINFO|VERSION|%s|TOOL|%s|DESIGN|%s\",\n" % (iVersion, iTool, eemFixName(iRefDes)))

    def writeCircleFormat(self):
        self.file.write("\"ADFIFIGURESCIRCLEFORMAT|LAYERNUMBER|LAYERNAME|RADIUS|XLOC|YLOC\"\n")
    def writeTraceFormat(self):
        self.file.write("\"ADFIFIGURESTRACEFORMAT|LAYERNUMBER|LAYERNAME|WIDTH|RADIUS[|X|Y]+\"\n")
    def writePolygonFormat(self):
        self.file.write("\"ADFIFIGURESPOLYGONFORMAT|LAYERNUMBER|LAYERNAME|NROFHOLES\n")
    def writeViaFormat(self):
        self.file.write("\"ADFIFIGURESVIASFORMAT|VIANAME[|X|Y]+\"\n")

    def writeCircle(self, node):
        layerName  = eemGetElNodeValByTag(node, 'LayerName')
        layerNumber= eemGetElNodeValByTag(node, 'LayerNumber')
        r = eemAdfiGetRadius(node)
        (x,y) = eemAdfiGetLocation(node,'XY')
        self.file.write("\"ADFIFIGURESCIRCLEDEF|%s|%s|%s|%s|%s\"\n" %
                        (layerNumber,layerName,r,x,y))

    def writeTrace(self,tr):
        layerName  = eemGetElNodeValByTag(tr, 'LayerName')
        layerNumber= eemGetElNodeValByTag(tr, 'LayerNumber')
        r = eemAdfiGetRadius(tr)
        w = eemAdfiGetWidth(tr)
        self.file.write("\"ADFIFIGURESTRACEDEF|%s|%s|%s|%s" %
                    (layerNumber,layerName,w,r))
        xys = tr.getElementsByTagName('XY')
        trs=""
        for xy in xys:
            x=xy.getAttribute('x')
            y=xy.getAttribute('y')
            trs+=("|%s|%s" % (x,y))    
        self.file.write("%s\"\n" %trs)

    def writePolygon(self, p):
        layerName  = eemGetElNodeValByTag(p, 'LayerName')
        layerNumber= eemGetElNodeValByTag(p, 'LayerNumber')
        outline = p.getElementsByTagName('Outline')
        verts = getInnerText(outline[0].getElementsByTagName('Vertices')[0])
        verts = verts.strip('\n')
        bulges = getInnerText(outline[0].getElementsByTagName('Bulges')[0])
        bulges = bulges.strip('\n')
        holes = p.getElementsByTagName('Hole')
        nrOfHoles = len(holes)
        eemWriteDebug("Polygon %s with holes %d: %s" % (str(p),nrOfHoles,str(holes)))
        self.file.write("\"ADFIFIGURESPOLYGONDEF|%s|%s|%d\"\n" % (layerNumber,layerName,nrOfHoles))
        self.file.write("\"ADFIFIGURESPOLYGONOUTLV|%s\"\n" % verts)
        self.file.write("\"ADFIFIGURESPOLYGONOUTLB|%s\"\n" % bulges)
        for hole in holes:
            vertsHole = getInnerText(hole.getElementsByTagName('Vertices')[0])
            vertsHole = vertsHole.strip('\n').replace(',',' ')
            bulgesHole = getInnerText(hole.getElementsByTagName('Bulges')[0])
            bulgesHole = bulgesHole.strip('\n').replace(',',' ')
            self.file.write("\"ADFIFIGURESPOLYGONHOLEV|%s\"\n" % vertsHole)
            self.file.write("\"ADFIFIGURESPOLYGONHOLEB|%s\"\n" % bulgesHole)
        self.file.write("\"ADFIFIGURESPOLYGONEND\"\n")
 
    def writeOAVias(self,v):
        viaName = eemGetElNodeValByTag(v, 'ViaName')
        xys = v.getElementsByTagName('XY')
        vS=""
        for xy in xys:
            x=xy.getAttribute('x')
            y=xy.getAttribute('y')
            vS+=("|%s|%s" % (x,y))    
        self.file.write("\"ADFIFIGURESVIASDEF|%s%s\"\n" % (viaName,vS))

    def writeAblShapes(self, shapesEvents, iRefDes):
        shapesName = iRefDes + '_shapes.xml'
        fName = os.path.join(self.dirName, shapesName)
        curString = "<abl:Shapes "
        if self.useAblRoot:
            curString += "xmlns:abl=\"http://keysight.com/eesof/abl\">\n"
        else:
            curString += "xmlns:abl=\"http://agilent.com/abl\">\n"
        nrOfNodes = 0
        shapeFile = None
        for (event,node) in shapesEvents:
            if (event==xml.dom.pulldom.START_ELEMENT
                and ( node.tagName in ('abl:Trace', 'abl:Path', "abl:oaEllipse", "abl:oaPolygon", "abl:oaLine") ) ):
                shapesEvents.expandNode(node)
                curString += node.toxml() + '\n'
                nrOfNodes+=1
                if ( nrOfNodes > 10 ):
                    if shapeFile==None:
                        shapeFile = open(fName, "w")
                    shapeFile.write( curString )
                    curString = ''
            elif (event==xml.dom.pulldom.END_ELEMENT
                  and node.tagName=='abl:Shapes'):
                break

        if ( nrOfNodes<=10):
            self.file.write("\"ADFIABL_SHAPES_START\",\n")
            self.file.write(curString)
            self.file.write("</abl:Shapes>\n\"ADFIABL_SHAPES_END\",\n")
        else:
            if ( len(curString)>0 ):
                shapeFile.write(curString)
            shapeFile.write("</abl:Shapes>\n")
            shapeFile.close()
            self.file.write("\"ADFIABL_SHAPES_FILE|%s\",\n" % shapesName)
            

    def writeFiguresEnd(self, nrOfFigures):
        self.file.write("\"ADFIFIGURESEND|%d\",\n" % nrOfFigures)

    def writeParmsToFile(self, iParms, iType, iRefDes, iTool, iVersion, iParmsFromFile):
        if (iParms or iParmsFromFile):
            self.file.write("\"ADFI%sPARMSINFO|VERSION|%s|TOOL|%s|DESIGN|%s\",\n" %
                        (iType, iVersion, iTool, eemFixName(iRefDes)))
            self.file.write("\"ADFI%sPARMSFORMAT|Key|Value\",\n" % iType)

            eemWriteDebug("parameters %s" % str(iParms))
            parms = iParms[0].getElementsByTagName('Parameter')
            parmMap = {}
            if iParmsFromFile != None:
                parmMap = iParmsFromFile

            #process the adfi exported parameters and csv list into one map
            for parm in parms:
                key = parm.getAttribute('key')
                value = parm.getAttribute('value')
                if key == 'VALUE':
                    value = eemAdfiWriteConvertToADSValues(iRefDes,value)
                value = re.sub('[Ss]iemens','S',value)
                value = re.sub('[oO][hH][mM]','Ohm',value)
                if key not in parmMap.keys():
                    parmMap[key] = value

            #write all the parameters to the file
            for key,value in parmMap.iteritems():
                self.file.write("\"ADFI%sPARM|%s|%s\",\n" % (iType, key, value))

            self.file.write("\"ADFI%sPARMSEND|%d\",\n" % (iType, len(parms)))

    def writePinInfo(self,iVersion, iTool, iRefDes):
        self.file.write("\"ADFIPININFO|VERSION|%s|TOOL|%s|DESIGN|%s\",\n" % (iVersion, iTool, eemFixName(iRefDes)))
        self.file.write("\"ADFIPINFORMAT|PINNAME|LAYERNUMBER|LAYERNAME|PORTNUMBER|PINNUMBER|"+
                    "NETNAME|XLOC|YLOC|PINTYPE|REPORTZ|IMPORTZ|PORTOFFSET|PORTNAME|POSNEG\",\n")
        self.file.write("\"ADFIPINFORMATAREA|PINNAME[|x|y]+\",\n")

    def writePinEnd(self,nrOfPins):
        self.file.write("\"ADFIPINEND|%d\",\n" % nrOfPins)

    def writePinDef(self,pinName,layerNumber,layerName,portNumber,pinNumber,netName,
                    xLoc,yLoc,pinType,rePortZ,imPortZ,portOffset,portName,posNeg):
        self.file.write("\"ADFIPINDEF|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\",\n" %
                (pinName,layerNumber,layerName,portNumber,pinNumber,netName,
                 xLoc,yLoc,pinType,rePortZ,imPortZ,portOffset,portName,posNeg))
        
    def writePinExtra(self,phi,diffPair,isMultiPortRef,usage):
        if phi != 0.0 or diffPair != None or isMultiPortRef or usage != None:
         self.file.write("\"ADFIPINEXTRA")
         if phi != 0.0:
             self.file.write("|ANGLE|%s" % phi)
         if diffPair != None:
             self.file.write("|DIFFPAIR|%s" % diffPair)
         if isMultiPortRef == True:
             self.file.write("|MULTIPORTREF|TRUE")
         if usage != None:
             self.file.write("|USAGE|%s" % usage)
         self.file.write("\"\n")

    def writePinAreaCircle(self,pinName,x,y,r):
        self.file.write("\"ADFIPINAREA|%s|%s|%s|%s|%s\",\n" % (pinName,'CR',x,y,r))

    def writePinAreaCircle(self,pinName,x,y,r):
        self.file.write("\"ADFIPINAREA|%s|%s|%s|%s|%s\",\n" % (pinName,'CR',x,y,r))

    def writePinAreaPolygon(self,pinName,verts,bulges):
        self.file.write("\"ADFIPINAREA|%s|%s|%s|%s\",\n" % (pinName,'PP',verts,bulges))

    def writePinAreaString(self,pinName,pinString):
        self.file.write("\"ADFIPINAREA|%s|%s\",\n" % (pinName,pinString))

    def writeInstsInfo(self,iVersion, iTool, iRefDes):
        self.file.write("\"ADFIINSTSINFO|VERSION|%s|TOOL|%s|DESIGN|%s\",\n" % (iVersion, iTool, eemFixName(iRefDes)))
        self.file.write("\"ADFIINSTDATAFORMAT|REFDES|CMPNAME|XLOC|YLOC|ROTATION[|VIEW]\",\n")

    def writeInstData(self, refDes, cmpName, viewName,xLoc, yLoc, rot):
        if viewName != None:
            self.file.write("\"ADFIINSTDATA|%s|%s|%s|%s|%s|%s\",\n" %
                            (eemFixName(refDes), eemFixName(cmpName), xLoc, yLoc, rot, eemFixName(viewName)))
        else:
            self.file.write("\"ADFIINSTDATA|%s|%s|%s|%s|%s\",\n" %
                            (eemFixName(refDes), eemFixName(cmpName), xLoc, yLoc, rot))

    def writeInstsEnd(self, nrOfInstances):
        self.file.write("\"ADFIINSTSEND|%d\",\n" % nrOfInstances)

    def writeRefLocation(self,refLocation):
        self.file.write("\"ADFICMPREFLOCATION|X|%s|Y|%s\",\n" % refLocation)

    def writeCmpSubstrate(self,refDes,refDesName,iStacks):
        if self.hasAbl:
            return
        slmFile = iStacks.getSlmFileName(refDesName)
        ltdFile = iStacks.getLtdFileName(refDesName)
        if slmFile!=None:
            if ltdFile==None:
                self.file.write("\"ADFICMPSUBSTRATE|%s\",\n" % slmFile)
            else:
                self.file.write("\"ADFICMPSUBSTRATE|%s|%s\",\n" % (slmFile,ltdFile))
                    
    def writeCmpEnd(self,refDes):
        self.file.write("\"ADFICMPEND|DESIGN|%s\",\n" % eemFixName(refDes))

    def writeEnd(self,nrOfComponent):
        self.file.write("\"ADFIEND|%d\"\n\n" % nrOfComponent)


def eemAdfiProcessHDefEgsFile(iAdfiDoc, iAdfiInfo, iHDefWriter, iEgsWriter, iBondWireWriter,
                              iStacks, iParmMap, iMaskNameNbMap={}):
    """extract and write pin/port/comp info"""
   
    eemWriteDebug("Writing hierarchical design data")
    tool        = iAdfiInfo.tool
    adfiVersion = iAdfiInfo.version

    parser=xml.sax.make_parser()
    # skip external dtd definition
    parser.setFeature(xml.sax.handler.feature_external_ges,0)
    # limit parser memory to about 1GByte
    events = xml.dom.pulldom.parse(iAdfiDoc,parser,1024*1024*16)

    iHDefWriter.writeLibrarySubstrate(iStacks)

    cmpName=''
    refDes=''
    refDesName=''
    viewName=''
    inComponent=None
    topLevel='FALSE'
    top=False
    mainLevel='FALSE'
    addedParameters = None
    nrOfComponent=0
    egsData=''
    name=''
    drawingConversionFactor=iAdfiInfo.getDrawingUnitConversionFactor()
    for (event,node) in events:
        if (event!=xml.dom.pulldom.START_ELEMENT
            and event!=xml.dom.pulldom.END_ELEMENT):
            continue
        elif (event==xml.dom.pulldom.START_ELEMENT
            and node.localName=="AdfiComponent"):
            cmpName = (node.getAttribute('id')).strip()
            inComponent=True
            viewName=''
            name=''
            if node.getAttribute('top') == 'true':
                topLevel = 'TRUE'
                top=True
            else:
                topLevel = 'FALSE'
                top=False
            if node.hasAttribute('main') and node.getAttribute('main') == 'true':
                mainLevel = 'TRUE'
            else:
                mainLevel = 'FALSE'
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Name"):
            events.expandNode(node)
            name=(getInnerText(node)).strip()
            if cmpName==None or cmpName=='':
                cmpName=name
            refDes = cmpName
            refDesName = refDes
            if top:
                refDes = refDes + "_adfi"
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="View"):
            events.expandNode(node)
            viewNameString=(getInnerText(node)).strip()
            if viewName==None or viewName=='':
                viewName = viewNameString
            refDes = cmpName
            refDesName = refDes
            if top:
                refDes = refDes + "_adfi"            
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Units"):
            events.expandNode(node)
            drawingConversionFactor=getDrawingUnitConversionFactor(node)
            if drawingConversionFactor==None:
                drawingConversionFactor=iAdfiInfo.getDrawingUnitConversionFactor()
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Type"):
            events.expandNode(node)
            cmpType=getInnerText(node)
            iHDefWriter.writeCmpInfo(adfiVersion, tool, refDes, name, cmpType, topLevel, mainLevel, viewName)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Geometry2D"
              and node.hasAttribute('geometry2DType')
              and node.getAttribute('geometry2DType')=='egs'
              and (not node.hasAttribute('geometry2DOp') or 
                   node.getAttribute('geometry2DOp')!='process')):
            events.expandNode(node)
            egsData=getInnerText(node)
            iEgsWriter.writeBody(egsData,cmpName,name,top,iMaskNameNbMap)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Geometry2D"
              and node.hasAttribute('geometry2DType')
              and node.getAttribute('geometry2DType')=='direct'):
            eemAdfiWriteCmpFiguresToFile(events, iHDefWriter, refDes, tool, adfiVersion)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="ComponentParms"):
            events.expandNode(node)
            eemAdfiWriteCmpParmsToFile(iHDefWriter, node, refDes, tool, adfiVersion, addedParameters)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Ports"):
            events.expandNode(node)
            eemAdfiWriteCmpPinsToFile(iHDefWriter, node, refDes, tool, adfiVersion)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="Instances"):
            events.expandNode(node)
            eemAdfiWriteCmpInstToFile(iHDefWriter, node, refDes, tool, adfiVersion, iParmMap)
            iBondWireWriter.writeCmptBondwires(node,refDes,drawingConversionFactor)
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=="RefLocation"):
            events.expandNode(node)
            eemAdfiWriteCmpRefLocationToFile(iHDefWriter, node)
        elif event==xml.dom.pulldom.END_ELEMENT and node.localName=="AdfiComponent":
            iHDefWriter.writeCmpSubstrate(refDes,refDesName,iStacks)
            iHDefWriter.writeCmpEnd(refDes)
            nrOfComponent+=1

            cmpName=''
            refDes=''
            refDesName=''
            inComponent=None
            topLevel='FALSE'
            top=False
            addedParameters = None
            egsData=''
            name=''
    iHDefWriter.writeEnd(nrOfComponent)
    eemWriteDebug("Writing hierarchical design data done")

#process the trace/circle like objects
def eemAdfiWriteCmpFiguresToFile(events, iHDefWriter, iRefDes, iTool, iVersion):
    eemWriteDebug("Processing the figures of %s" % iRefDes)
    nrOfFigures = 0
    nrOfCircles=0
    nrOfTraces=0
    nrOfPolygons=0
    nrOfVias=0
    for (event,node) in events:
        if (event==xml.dom.pulldom.START_ELEMENT
            and node.tagName=="abl:Shapes"):
            iHDefWriter.writeAblShapes(events, iRefDes)
        elif (event==xml.dom.pulldom.START_ELEMENT
            and node.localName=="Figures"):
            iHDefWriter.writeFiguresInfo(iVersion, iTool, iRefDes)
        elif (event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Circle'):
            if nrOfCircles==0:
                iHDefWriter.writeCircleFormat()
            nrOfFigures+=1
            nrOfCircles+=1
            events.expandNode(node)
            iHDefWriter.writeCircle(node)
        elif (event==xml.dom.pulldom.START_ELEMENT
            and node.localName=='Trace'):
            if nrOfTraces==0:
                iHDefWriter.writeTraceFormat()
            nrOfFigures+=1
            nrOfTraces+=1
            events.expandNode(node)
            iHDefWriter.writeTrace(node)
        elif (event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Polygon'):
            if nrOfPolygons==0:
                iHDefWriter.writePolygonFormat()
            nrOfFigures+=1
            nrOfPolygons+=1
            events.expandNode(node)
            iHDefWriter.writePolygon(node)
        elif (event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='OAVias'):
            if nrOfVias==0:
                iHDefWriter.writeViaFormat()
            nrOfFigures+=1
            nrOfVias+=1
            events.expandNode(node)
            iHDefWriter.writeOAVias(node)
        elif (event==xml.dom.pulldom.END_ELEMENT
              and ( node.localName=='Figures' or node.localName=='Geometry2D') ):
            if( nrOfFigures>0 ):
                iHDefWriter.writeFiguresEnd(nrOfFigures)
            break
    eemWriteDebug("End processing the figures of %s" % iRefDes)
        

def eemAdfiWriteCmpPinsToFile(iHDefWriter, iCmp, iRefDes, iTool, iVersion):
    eemWriteDebug("Process the pins of %s" % iRefDes)
    pins = iCmp.getElementsByTagName('PortDescription')
    if pins:
        iHDefWriter.writePinInfo(iVersion, iTool, iRefDes)
        cmpPinSet = set()
        for pin in pins:
            eemAdfiWriteCmpPinToFile(iHDefWriter, pin, cmpPinSet)
            eemAdfiWriteCmpPinAreaToFile(iHDefWriter, pin)
        iHDefWriter.writePinEnd(len(pins))
    eemWriteDebug("Processing pins %s done" % iRefDes)

def eemAdfiGetLocation (iNode, locElName='Location'):
    if (iNode.localName==locElName):
        xLoc = iNode.getAttribute('x')
        yLoc = iNode.getAttribute('y')
    else:
        location = iNode.getElementsByTagName(locElName)
        if location:
            xLoc = location[0].getAttribute('x')
            yLoc = location[0].getAttribute('y')
        else:
            xLoc = '0.0'
            yLoc = '0.0'
    return (xLoc,yLoc)

def eemAdfiGetRotation (iNode):
    phi = '0.0'
    rot = iNode.getElementsByTagName('Rotation')
    if rot:
        phi = rot[0].getAttribute('phi')
    return phi

def eemAdfiGetRadius (iNode):
    r = '0.0'
    rad = iNode.getElementsByTagName('Radius')
    if rad:
        r = rad[0].getAttribute('r')
    return r

def eemAdfiGetWidth (iNode):
    w = '0.0'
    width = iNode.getElementsByTagName('Width')
    if width:
        w = width[0].getAttribute('w')
    return w

def eemAdfiWriteCmpRefLocationToFile(iHDefWriter,iNode):
    refLocation = eemAdfiGetLocation(iNode,'RefLocation')
    if refLocation!=('0.0','0.0'):
        eemWriteDebug("Ref location found: %s,%s" % refLocation)
        iHDefWriter.writeRefLocation(refLocation)

def eemAdfiWriteCmpPinToFile(iHDefWriter, iPin, pinSet):
    pinName    = eemGetElNodeValByTag(iPin, 'PinName')
    eemWriteDebug("Process pin %s" % pinName)
    pinNumber  = eemGetElNodeValByTag(iPin, 'PinNumber')
    portNumber = eemGetElNodeValByTag(iPin, 'PortNumber')
    if portNumber == None:
        portNumber = pinNumber
    layerName  = eemGetElNodeValByTag(iPin, 'LayerName')
    layerNumber= eemGetElNodeValByTag(iPin, 'LayerNumber')
    netName    = eemGetElNodeValByTag(iPin, 'NetName')
    if netName == None:
        netName = '__NONE__'
    (xLoc,yLoc)= eemAdfiGetLocation(iPin)
    phi = eemAdfiGetRotation(iPin)
    pinType    = eemGetElNodeValByTag(iPin, 'PinType')
    if pinType == None:
        pinType = '0'
    rePortZ    = eemGetElNodeValByTag(iPin, 'RePortZ')
    if rePortZ == None:
        rePortZ = '50.0'
    imPortZ    = eemGetElNodeValByTag(iPin, 'ImPortZ')
    if imPortZ == None:
        imPortZ = '0.0'
    portOffset = eemGetElNodeValByTag(iPin, 'PortOffset')
    if portOffset == None:
        portOffset = '0.0'
    portName   = eemGetElNodeValByTag(iPin, 'PortName')
    if portName == None:
        portName = pinName
    posNeg     = eemGetElNodeValByTag(iPin, 'PosNeg')
    if posNeg == None:
        posNeg = '0'
    diffPair   = eemGetElNodeValByTag(iPin, 'DifferentialPair')
    usage   = eemGetElNodeValByTag(iPin, 'Usage')
    
    iHDefWriter.writePinDef(pinName,layerNumber,layerName,portNumber,pinNumber,netName,
                            xLoc,yLoc,pinType,rePortZ,imPortZ,portOffset,portName,posNeg)
    pinId = pinName
    isMultiPortRef = False
    if pinId in pinSet:
        isMultiPortRef = True
    else:
        pinSet.add(pinId)
    
    iHDefWriter.writePinExtra(phi,diffPair,isMultiPortRef,usage)


def eemAdfiWriteCmpPinAreaToFile(iHDefWriter, iPin):
    pinName = eemGetElNodeValByTag(iPin, 'PinName')
    pinArea = iPin.getElementsByTagName('PinArea')
    if pinArea:
        #        eemWriteDebug("Process pin polygon for %s" % pinName)
        pinAreaType = pinArea[0].getAttribute('pinAreaType')
        if pinAreaType=='direct':
            circle = pinArea[0].getElementsByTagName('Circle')
            if circle:
                r = eemAdfiGetRadius(circle[0])
                (x,y) = eemAdfiGetLocation(circle[0],'XY')
                iHDefWriter.writePinAreaCircle(pinName,x,y,r)
            else:
                polygon = pinArea[0].getElementsByTagName('Polygon')
                if polygon:
                    #eemWriteDebug("Process pin polygon %s for %s" % (pinName, str(polygon[0])))
                    outline = polygon[0].getElementsByTagName('Outline')
                    verts = getInnerText(outline[0].getElementsByTagName('Vertices')[0])
                    verts = verts.strip('\n')
                    #eemWriteDebug("Process pin polygon %s for %s\n" % (pinName, verts))
                    bulges = getInnerText(outline[0].getElementsByTagName('Bulges')[0])
                    bulges = bulges.strip('\n')
                    #eemWriteDebug("Process pin polygon %s for %s\n" % (pinName, bulges))
                    iHDefWriter.writePinAreaPolygon(pinName,verts,bulges)
        else:
            pinString = str(getInnerText(pinArea[0]))
            #eemWriteDebug("Pin area string: %s" % pinString)
            if len(pinString)>5:
                # need to check for other shapes
                pinString = re.sub('ADD ([CPLR])[0-9]+ \:W[0-9.]+ ',r'\1 ', pinString)
                pinString = pinString.strip('\n \t;')
                pinString = re.sub('[ ,]+','|', pinString)
                iHDefWriter.writePinAreaString(pinName,pinString)

def eemAdfiWriteCmpParmsToFile(iHDefWriter, iCmp, iRefDes, iTool, iVersion,iParmMap=None):
    eemWriteDebug("Process Component parameters %s" % iRefDes)
    addedParameters=None
    if ((iParmMap != None) and (refDes in iParmMap.keys())):
        addedParameters = iParmMap[refDes]
    cmpParms=[]
    if iCmp.localName=='ComponentParms':
        cmpParms.append(iCmp)
    else:
        cmpParms = iCmp.getElementsByTagName('ComponentParms')
    iHDefWriter.writeParmsToFile(cmpParms, 'CMP', iRefDes, iTool, iVersion, addedParameters)
    eemWriteDebug("Process Component parameters %s done" % iRefDes)



def eemAdfiWriteConvertToADSValues(iRefDes, iValue):
    m = re.match('([-+]?[0-9]*[\.,]?[0-9]+)([eE][-+]?[0-9]+)?([ \t]+)?([a-zA-Z]+)?',iValue)
    if m!=None:
        value = m.group(1)
        if m.group(2)!=None:
            value = value + m.group(2)
        if ((m.group(4)!=None) and
            (m.group(4)!='')):
            value = value + ' '
            if m.group(4) == 'MEG':
                value = value + 'M'
            elif len(m.group(4))==1:
                if m.group(4) in ['A','F','K','N','P','U']:
                    value = value +  m.group(4).lower()
                else:
                    value = value + m.group(4)
            elif len(m.group(4))==2:
                if ((iRefDes[0] == 'L')
                    or (iRefDes[0] == 'C')
                    or (m.group(4)[1] in ['h','H','f','F'])):
                    if (m.group(4)[0] in ['A','F','K','M','N','P','U']):
                        value = value +  m.group(4)[0].lower() + m.group(4)[1].upper()
                    else:
                        value = value +  m.group(4)[0] + m.group(4)[1].upper()
                else:
                    value = value +  m.group(4)
            else:
                value = value + m.group(4)
        else:
            if (iRefDes[0] == 'L'):
                value = value + ' nH'
            if (iRefDes[0] == 'C'):
                value = value + ' pF'
        value = re.sub(',','.',value)
        eemWriteDebug("Transformed ivalue: %s into value: %s" % (iValue,value))
        return value
    return iValue



def eemAdfiWriteCmpInstToFile(iHDefWriter, iCmp, iRefDes, iTool, iVersion, iParmMap):
    eemWriteDebug("Process instances in component %s when present"% iRefDes)
    instances = iCmp.getElementsByTagName('Instance')
    if instances:
        iHDefWriter.writeInstsInfo(iVersion, iTool, iRefDes)
        for inst in instances:
            refDes  = inst.getAttribute('id')
            cmpName = eemGetElNodeValByTag(inst, 'Component').strip()
            viewName = eemGetElNodeValByTag(inst, 'View')
            if viewName!=None:
                viewName = viewName.strip()
                eemWriteDebug("Process instance %s of component %s view %s" % (refDes, cmpName, viewName))
            else:
                eemWriteDebug("Process instance %s of component %s" % (refDes,cmpName))
            (xLoc, yLoc) = eemAdfiGetLocation(inst)
            rot = eemAdfiGetRotation(inst)
            eemWriteDebug("Process instance location %s,%s rotation %s" % (xLoc,yLoc,rot))
            iHDefWriter.writeInstData(refDes, cmpName, viewName, xLoc, yLoc, rot)                
            #hierarchical instance param values from file
            hInstName = iRefDes + '.' + refDes
            addedParameters = None
            if ((iParmMap != None) and (hInstName in iParmMap.keys())):
                addedParameters = iParmMap[hInstName]
            eemAdfiWriteInstParmsToFile(iHDefWriter, inst, refDes, iTool, iVersion, addedParameters)
            eemWriteDebug("Processing instance %s of component %s done" % (refDes,cmpName))
        iHDefWriter.writeInstsEnd(len(instances))

def eemAdfiWriteInstParmsToFile(iHDefWriter, iInst, instName, iTool, iVersion, iParmsFromFile):
    eemWriteDebug("Process instance parameters %s" % instName)
    instParms = iInst.getElementsByTagName('InstanceParms')
    iHDefWriter.writeParmsToFile(instParms, 'INST', instName, iTool, iVersion, iParmsFromFile)
    eemWriteDebug("Processing instance parameters %s done" % instName)


def eemAdfiReadOptParmFile(adfiNamePrefix):
    fname = adfiNamePrefix + "_adfi_parms.csv"
    if not os.path.isfile(fname):
        eemWriteDebug("No additional/updated parameters for components found")
        return None
    
    try:
        import csv
        eemWriteDebug("Read additional/updated parameters for components: %s" % fname)
        fp = open(fname,"rb")
        reader = csv.reader(fp)
        fp.close()
        parmMap = {}
        for row in reader:
            instMap = {}
            iName = row[0]
            if iName in parmMap.keys():
                instMap = parmMap[iName]
            parmList = row[1:]
            for i in range(0,len(parmList),2):
                instMap[parmList[i]] = parmList[i+1]
            parmMap[iName] = instMap
        return parmMap
        eemWriteDebug("Read additional and updated parameters done")
    except:
        eemWriteDebug("Can not read from ADS ADFI file: %s" % iAdfiFilename)
        return None

def getDrawingUnitConversionFactor(cInst):
    unit = eemGetElNodeAttrByTagAttrValue(cInst, "Unit", 'key', 'drawing_units', 'value')
    # TODO: add other units
    factorMap = {'m':1,'mm':1e-3,'um':1e-6,'nm':1e-9,'pm':1e-12,'mil':2.54e-5,'inch':2.54e-2,'in':2.54e-2}
    conversionFactor = 1
    if unit in factorMap.keys():
        conversionFactor = factorMap[unit]
    else:
         raise Exception('Unknown unit %s' % unit)
    return conversionFactor 

def getPinNodeListUnitInfo(iPortsDom,iAdfiInfo=None,needUnit=False):
    pins=None
    conversionFactor=None
    try:
        if(iPortsDom.nodeType==iPortsDom.DOCUMENT_NODE):
            components  = iPortsDom.getElementsByTagName('AdfiComponent')
            for cInst in components:
                if cInst.getAttribute('top') == 'true':
                    if iAdfiInfo==None and needUnit:
                        conversionFactor = getDrawingUnitConversionFactor(cInst)
                    pins = cInst.getElementsByTagName('PortDescription')
                    break
    except:
        pass # can be ports element

    try:
        if (pins==None
            and iPortsDom.nodeType==iPortsDom.ELEMENT_NODE):
            # we have a ports element
            pins = iPortsDom.getElementsByTagName('PortDescription')
    except:
        pass

    try:
        if (pins==None
            and len(iPortsDom)
            and iPortsDom[0].nodeType==iPortsDom[0].ELEMENT_NODE):
            # get a pinNodeList immediately
            pins=iPortsDom
    except:
        raise Exception('Unknown port/pin object %s' % str(iPortsDom))

    if conversionFactor==None and needUnit:
        conversionFactor = iAdfiInfo.getDrawingUnitConversionFactor()

    return (pins,conversionFactor)

class pinWriter():
    """This class is used to write out the .pin file of the top level of an adfi file."""
    def __init__(self, filename):
        self.file = open( filename, "w" )
        self.file.write(r'<?xml version="1.0" encoding="UTF-8"?>')

    # TODO: write out other pin properties
    def writePin(self,name,net,layer,purpose,x,y):
        self.file.write("""
  <pin>
    <name>"""+name+"""</name>
    <net>"""+net+"""</net>
    <layout>
      <shape>
        <layer>"""+str(layer)+"""</layer>
        <purpose>"""+str(purpose)+"""</purpose>
        <point>
          <x>"""+str(x)+"""</x>
          <y>"""+str(y)+"""</y>
        </point>
      </shape>
    </layout>
  </pin>""")

    def writePinList(self,iPortsDom,iAdfiInfo=None):
        pins=None
        conversionFactor=None
        try:
            (pins, conversionFactor) = getPinNodeListUnitInfo(iPortsDom,iAdfiInfo,True)
        except:
            raise
        
        self.file.write("""
<pin_list version="1.0">
  <!-- note: all coordinates are in meter -->""")
        for iPin in pins:
            pinName    = eemGetElNodeValByTag(iPin, 'PinName')
            eemWriteDebug("Process pin %s" % pinName)
            pinNumber  = eemGetElNodeValByTag(iPin, 'PinNumber')
            layerName  = eemGetElNodeValByTag(iPin, 'LayerName')
            layerNumber= eemGetElNodeValByTag(iPin, 'LayerNumber')
            netName    = eemGetElNodeValByTag(iPin, 'NetName')
            if netName == None:
                netName = ""
            (xLoc,yLoc)= eemAdfiGetLocation(iPin)
            phi = eemAdfiGetRotation(iPin)
            # TODO: purpose = -1 ???
            # Convert coordinates to meter
            self.writePin(pinName,netName,layerNumber,-1,
                          conversionFactor*float(xLoc),
                          conversionFactor*float(yLoc))
        self.file.write('\n'+r'</pin_list>'+'\n')

    def close(self):
        self.file.close()

def eemAdfiWritePinFile(fName, iDom, iAdfiInfo=None):
    """write out top level pins in .pin file"""
    writer = pinWriter(fName)
    writer.writePinList(iDom,iAdfiInfo)
    writer.close()

class portWriter():
    def __init__(self, filename):
        self.file = open( filename, "w" )
        self.file.write(r'<?xml version="1.0" encoding="UTF-8"?>'+'\n')

    def writeDefaultCalibrationGroupList(self):
        self.file.write("""  <calibration_group_list>
    <calibration_group id="1">
      <type>TML</type>
      <auto_split>true</auto_split>
    </calibration_group>
  </calibration_group_list>
""")

    def writePort(self,id,name,plusPinList,minusPinList,impedanceR,impedanceI):
        self.file.write("    <port id=\""+str(id)+"\">\n")
        self.file.write("      <name>"""+name+"</name>\n")
        for plusPin in plusPinList:
            self.file.write("      <plus_pin>"+plusPin+"</plus_pin>\n")
        for minusPin in minusPinList:
            self.file.write("      <minus_pin>"+minusPin+"</minus_pin>\n")
        self.file.write("      <impedance>\n")
        self.file.write("        <real>"+str(impedanceR)+"</real>\n")
        self.file.write("        <imag>"+str(impedanceI)+"</imag>\n")
        self.file.write("      </impedance>\n")
        self.file.write("      <calibration_group_ref ref=\"1\" />\n")
        self.file.write("    </port>\n")

    def writePortSetup(self,iDom):
        self.file.write(r'<port_setup version="1.1">'+'\n')
        self.writeDefaultCalibrationGroupList()
        self.writePortList(iDom)
        self.file.write(r'</port_setup>'+'\n')

    def writePortList(self,iPortsDom):
        pins=None
        conversionFactor=None
        try:
            (pins, conversionFactor) = getPinNodeListUnitInfo(iPortsDom)
        except:
            raise
        
        self.file.write("  <port_list>\n")
        portList = {}
        for iPin in pins:
            # TODO: clean-up unused elements
            pinName    = eemGetElNodeValByTag(iPin, 'PinName')
            pinNumber  = eemGetElNodeValByTag(iPin, 'PinNumber')
            portNumber = int(eemGetElNodeValByTag(iPin, 'PortNumber'))
            if portNumber == None:
                portNumber = pinNumber
            pinType    = eemGetElNodeValByTag(iPin, 'PinType')
            if pinType == None:
                pinType = '+1'
            rePortZ    = eemGetElNodeValByTag(iPin, 'RePortZ')
            if rePortZ == None:
                rePortZ = '50.0'
            imPortZ    = eemGetElNodeValByTag(iPin, 'ImPortZ')
            if imPortZ == None:
                imPortZ = '0.0'
            portOffset = eemGetElNodeValByTag(iPin, 'PortOffset')
            if portOffset == None:
                portOffset = '0.0'
            portName   = eemGetElNodeValByTag(iPin, 'PortName')
            eemWriteDebug("Process pin %s in port %s" % (pinName,portName))
            if portName == None:
                portName = pinName
            posNeg     = eemGetElNodeValByTag(iPin, 'PosNeg')
            if posNeg == None:
                posNeg = '0'
            diffPair   = eemGetElNodeValByTag(iPin, 'DifferentialPair')
            # Check if port already exists and if not create it
            if portList.has_key(portNumber):
                thisPort = portList[portNumber]
            else:
                newPort = dict(name=portName,plusPinList=[],minusPinList=[],rePortZ=rePortZ,imPortZ=imPortZ)
                thisPort = newPort
                portList[portNumber]=thisPort
            # Add pin to plus or minus pin list
            if pinType == '+1':
                thisPort['plusPinList'].append(pinName)
            else:
                        thisPort['minusPinList'].append(pinName)
        # Write out all ports
        keys = portList.keys()
        keys.sort()
        for id in keys:
            port = portList[id]
            self.writePort(id,port['name'],port['plusPinList'],port['minusPinList'],port['rePortZ'],port['imPortZ'])
        self.file.write('  </port_list>\n')

    def close(self):
        self.file.close()

def eemAdfiWritePortFile(fName, iPorts):
    """write out top level ports in .prt file"""
    writer = portWriter(fName)
    writer.writePortSetup(iPorts)
    writer.close()


class bondWireWriter():
    def __init__(self, filename,maskNameNbMap):
        self.maskNameNbMap = maskNameNbMap
        self.file = open( filename, "w" )
        self.file.write( 
"""# bondwire file format version 2.0

# uses mks units
#
# wire
#  name "<bondwire name>";
#  netname "<bondwire net name>";
#  resistivity <resistivity in Ohm*m>
#  radius <bondwire radius in m>;
#  points <nr of points n>,
#   <x1 y1 mask z1 [top|bottom]>,
#   <x2 y2 [(mask [z1|zn] [top|bottom] delta)|absolute] z2>,
#      ...
#   <xn yn mask zn [top|bottom]>;
# end_wire
# ...
""")

    def close(self):
        self.file.close()

    def writeBondWire(self,iCmp,inst,iCmpId=None,iDrawConversionFactor=None):
        cmpId=iCmpId
        if cmpId==None:
            cmpId  = iCmp.getAttribute('id')

        if iDrawConversionFactor!=None:
            drawingConversionFactor = iDrawConversionFactor
        else:
            drawingConversionFactor = getDrawingUnitConversionFactor(iCmp)
        
        bondId  = inst.getAttribute('id')
        self.file.write('\nwire\n')
        # Name
        # TODO get entire hierarchy in name
        self.file.write('  name "%s_%s";\n' % (cmpId.replace('-','_'),bondId.replace('-','_')))
        # Resistivity
        conductivityString = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Conductivity', 'value')
        condV,condUnit = conductivityString.split()
        # TODO: add other units
        # TODO: investigate case sensitivity
        factorMap = {'GS':1e9,'MS':1e6,'kS':1e3,'S':1,'mS':1e-3,'uS':1e-6,'nS':1e-9,'pS':1e-12}
        conversionFactor = 1
        if condUnit in factorMap.keys():
            conversionFactor = factorMap[condUnit]
        else:
             raise Exception('Unknown unit %s' % condUnit)
        self.file.write('    resistivity %s;\n' % (1/(float(condV)*conversionFactor)))
        # Radius
        radius = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Radius', 'value')
        self.file.write('    radius %s;\n' % (float(radius)*drawingConversionFactor))
        # Geometry
        startLocation = inst.getElementsByTagName('Location')[0]
        xStart  = drawingConversionFactor*float(startLocation.getAttribute('x'))
        yStart  = drawingConversionFactor*float(startLocation.getAttribute('y'))
        xEnd    = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'xEnd', 'value'))
        yEnd    = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'yEnd', 'value'))
        maskNameStart  = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Layer1', 'value')
        maskNameEnd    = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Layer2', 'value')
        if maskNameStart in self.maskNameNbMap.keys():
            maskNbStart = self.maskNameNbMap[maskNameStart]
        else:
            eemWriteWarn("Mask number not found start mask for %s of bondwire %s.\nUsing \"0\" instead." % (str(maskNameStart),str(bondId)))
            maskNbStart = '0'
        if maskNameEnd in self.maskNameNbMap.keys():
            maskNbEnd = self.maskNameNbMap[maskNameEnd]
        else:
            eemWriteWarn("Mask number not found end mask for %s of bondwire %s.\nUsing \"0\" instead." % (str(maskNameEnd),str(bondId)))
            maskNbEnd = '0'
        import math
        dX = xEnd - xStart
        dY = yEnd - yStart
        length = math.sqrt(dX * dX + dY * dY)
        wireAbove = (eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'RelToSubstrate', 'value') == 'ABOVE')
        if (wireAbove):
            onSide = 'top'
        else:
            onSide = 'bot'
        NumberOfLengthsSpecified = int(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'NumberOfLengthsSpecified', 'value'))
        lList = []
        zList = []
        for ind in range(1,NumberOfLengthsSpecified+1):
            li = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'l'+str(ind), 'value'))
            zi = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'z'+str(ind), 'value'))
            lList.append(li)
            zList.append(zi)
        self.file.write('    points %s,\n' % (NumberOfLengthsSpecified + 2))
        self.file.write('      %s %s mask %s %s,\n' % (xStart,yStart,maskNbStart,onSide))
        xi = xStart
        yi = yStart
        for li,zi in zip(lList,zList):
            dXi = li/length * dX
            dYi = li/length * dY
            xi += dXi
            yi += dYi
            self.file.write('      %s %s mask %s %s delta %s,\n' % (xi,yi,maskNbStart,onSide,zi))
        self.file.write('      %s %s mask %s %s;\n' % (xEnd,yEnd,maskNbEnd,onSide))
        self.file.write('end_wire\n')

    def writeDummyBondWire(self,name,paramMap):
        self.file.write('\nwire\n')
        # Name
        self.file.write('  name "%s";\n' % name)
        # Resistivity
        self.file.write('    resistivity %s;\n' % paramMap['resistivity'])
        # Radius
        radius = float(paramMap['radius'])
        self.file.write('    radius %s;\n' % (radius/10))
        # Geometry
        xStart  = float(paramMap['x']) - radius/4
        yStart  = float(paramMap['y']) - radius/4
        xEnd    = xStart + radius/2
        yEnd    = yStart + radius/2
        maskNameStart  = paramMap['mask_top']
        maskNameEnd    = paramMap['mask_bottom']
        maskNbStart = self.maskNameNbMap[maskNameStart]
        maskNbEnd = self.maskNameNbMap[maskNameEnd]
        self.file.write('    points %s,\n' % (3))
        self.file.write('      %s %s mask %s %s,\n' % (xStart,yStart,maskNbStart,'bot'))
        self.file.write('      %s %s mask %s %s delta %s,\n' % (xStart,yStart,maskNbStart,'bot', radius))
        self.file.write('      %s %s mask %s %s;\n' % (xEnd,yEnd,maskNbEnd,'top'))
        self.file.write('end_wire\n')

    def writeCmptBondwires(self, iInsts, iCmpId=None, iDrawConversionFactor=None):
        instances=[]
        if iInsts:
            instances=iInsts.getElementsByTagName('Instance')
        if instances:
            for inst in instances:
                cmpName = eemGetElNodeValByTag(inst, 'Component')
                if cmpName == 'SBOND':
                    self.writeBondWire(None ,inst, iCmpId, iDrawConversionFactor)
                    
    def writeSBDummyBondWires(self,iDom,useSolderBalls=False,sbMap=None):
        if not iDom:
            return
        if useSolderBalls:
            importer = solderBallImporter()
            sbMap = importer.getSolderBallMap(iDom,sbMap)
            for name,(id,comp,paramMap) in sbMap.iteritems():
                eemWriteDebug("Dummy bondwire for solderball with name %s and paramMap %s" % (name,str(paramMap)))
                self.writeDummyBondWire(name,paramMap)

    def writeBondWires(self,iDom,useSolderBalls=False,sbMap=None):
        if not iDom:
            return
        components  = iDom.getElementsByTagName('AdfiComponent')
        for iCmp in components:
            instances = iCmp.getElementsByTagName('Instance')
            if instances:
                for inst in instances:
                    cmpName = eemGetElNodeValByTag(inst, 'Component')
                    if cmpName == 'SBOND':
                        self.writeBondWire(iCmp,inst)
        self.writeSBDummyBondWires(iDom,useSolderBalls,sbMap)

def eemAdfiWriteBondwireFile(fName, iDom, maskNameNbMap,useSolderBalls=False,sbMap=None):
    writer = bondWireWriter(fName,maskNameNbMap)
    writer.writeBondWires(iDom,useSolderBalls,sbMap)
    writer.close()

class UnitException(Exception):
    pass

def getRLCUnitConversionFactor(unit):
    if len(unit) == 1:
        return 1
    # consider MF, MH and mO as milli, but MO as mega
    if unit == 'MO':
        return 1e6
    factorPrefix = unit.upper()[:-1]
    # case insensitive => confusion between Mega and milli
    # TODO debug possible problems with units
    factorMapWithCase = {'T':1e12,'G':1e9,'MEG':1e6,'k':1e3,'m':1e-3,'u':1e-6,'n':1e-9,'p':1e-12,'f':1e-15,'a':1e-18}
    # Extend with capitals
    factorMap = {}
    for k,v in factorMapWithCase.iteritems():
        factorMap[k.upper()]=v
    conversionFactor = 1
    if factorPrefix in factorMap.keys():
        conversionFactor = factorMap[factorPrefix]
    else:
        msg = 'Unknown unit %s.' % unit
        eemWriteDebug(msg)
        raise UnitException(msg)
    return conversionFactor 

def _layerNameToVariable(layerName,above,addQuotes=False):
    if above:
        varName = "mask_%s_Zmax" % layerName
    else:
        varName = "mask_%s_Zmin" % layerName
    if addQuotes:
        return '"%s"' % varName
    else:
        return varName

def getResistivityFromConductivityString(conductivityString):
    #resistivity = getResistivityFromConductivityString(conductivityString)
    condV,condUnit = conductivityString.split()
    # TODO: add other units
    # TODO: investigate case sensitivity
    factorMap = {'GS':1e9,'MS':1e6,'kS':1e3,'S':1,'mS':1e-3,'uS':1e-6,'nS':1e-9,'pS':1e-12,'SIEMENS':1}
    conversionFactor = 1
    if condUnit in factorMap.keys():
        conversionFactor = factorMap[condUnit]
    else:
        if condUnit[-2:].upper()=='/M':
            condUnit = condUnit[:-2]
        if condUnit in factorMap.keys():
            conversionFactor = factorMap[condUnit]
        elif condUnit.upper() in factorMap.keys():
            conversionFactor = factorMap[condUnit.upper()]
        else:
            raise Exception('Unknown unit %s' % condUnit)
    resistivity = 1/(float(condV)*conversionFactor)
    return resistivity 

class bondwireImporter():
    def __init__(self):
        self.bwMaterials={} # Map from resistivity to material

    # TODO: replace this function with the official function in EMPro
    def _makeJedecDefinition(self,alpha="60 deg", beta="15 deg", h1="30 pct", radius="0.5 mil", numFaces=6, name=None):
        import empro
        h1IsProportional = "pct" in str(h1) # this is tricky.  what if we have pct as parameter name for an absolute length?
        bonddef = empro.geometry.BondwireDefinition(name or "", radius, numFaces)
        v = empro.geometry.BondwireVertex(alpha, h1)
        v.tUnitClass = empro.units.ANGLE
        v.zUnitClass = h1IsProportional and empro.units.SCALAR or empro.units.LENGTH
        bonddef.append(v)
        v = empro.geometry.BondwireVertex("12.5 pct", "0")
        v.tReference = v.zReference = "Previous"
        v.tUnitClass = v.zUnitClass = empro.units.SCALAR
        bonddef.append(v)
        v = empro.geometry.BondwireVertex("50 pct", beta)
        v.tReference = v.zReference = "End"
        v.tUnitClass = empro.units.SCALAR
        v.zUnitClass = empro.units.ANGLE
        bonddef.append(v)
        return bonddef

    def createOrGetBondwireProfileDefinition(self,iCmp,inst):
        profileName   = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', "ProfileName", 'value')
        height   = float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', "JedecHeight", 'value'))
        alpha    = float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', "JedecAlpha" , 'value'))
        beta     = float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', "JedecBeta"  , 'value'))
        radius   = float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Radius', 'value'))
        # Radius
        drawingConversionFactor = getDrawingUnitConversionFactor(iCmp)
        radius = radius*drawingConversionFactor
        height = height*drawingConversionFactor
        # Check if a component definition can be reused
        import empro
        bwDefs = empro.activeProject.bondwireDefinitions()
        for i in range(len(bwDefs)):
            bwDef = bwDefs[i]
            if bwDef.name != profileName:
                continue
            eemWriteDebug("    This bondwire matches definition with name '%s'" % profileName)
            return bwDef
        # If not create a new one and add it to the current project
        eemWriteDebug("    Creating new bondwire definition '%s'" % profileName)
        created_bonddef = self._makeJedecDefinition(alpha = str(alpha)+" deg",beta = str(beta)+" deg", radius=radius,h1 = height,name=profileName)
        empro.activeProject.bondwireDefinitions().append(created_bonddef)
        # it's important NOT to use the bonddef you created, as a COPY is placed in bondwireDefinitions.  
        # This is something to be fixed in EMPro
        bwDefs = empro.activeProject.bondwireDefinitions()
        bonddef_to_use = bwDefs[len(bwDefs)-1]
        return bonddef_to_use

    def createBondwire(self,iCmp,inst):
        cmpId  = iCmp.getAttribute('id')
        bondId  = inst.getAttribute('id')
        # Name
        name = "%s_%s" % (cmpId.replace('-','_'),bondId.replace('-','_'))
        # Resistivity
        conductivityString = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Conductivity', 'value')
        resistivity = getResistivityFromConductivityString(conductivityString)
        # Geometry
        drawingConversionFactor = getDrawingUnitConversionFactor(iCmp)
        startLocation = inst.getElementsByTagName('Location')[0]
        xStart  = drawingConversionFactor*float(startLocation.getAttribute('x'))
        yStart  = drawingConversionFactor*float(startLocation.getAttribute('y'))
        xEnd    = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'xEnd', 'value'))
        yEnd    = drawingConversionFactor*float(eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'yEnd', 'value'))
        maskNameStart  = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Layer1', 'value')
        maskNameEnd    = eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'Layer2', 'value')
        wireAbove = (eemGetElNodeAttrByTagAttrValue(inst, "Parameter", 'key', 'RelToSubstrate', 'value') == 'ABOVE')
        ########
        eemWriteDebug("Found bondwire with name %s" % (name))
        bondwireDef = self.createOrGetBondwireProfileDefinition(iCmp,inst)
        zStart = _layerNameToVariable(maskNameStart,wireAbove,False)
        zEnd = _layerNameToVariable(maskNameEnd,wireAbove,False)
        import empro
        V=empro.geometry.Vector3d
        beginP = V(xStart,yStart,zStart)
        endP   = V(xEnd,yEnd,zEnd)
        bw = empro.geometry.Bondwire(beginP,endP,None)
        bw.definition = bondwireDef
        model = empro.geometry.Model()
        model.name = name
        model.recipe.append(bw)
        if not wireAbove:
            # rotate bondwires over 180 degrees
            import math
            model.coordinateSystem.rotate(math.pi,0,0)
        # Add attributes to model
        parameters = getInstanceParms(inst,toUpper=False)
        if parameters:
            for key,value in parameters.iteritems():
                try:
                    model.addAttribute(key,str(value))
                except TypeError:
                    model.addAttribute(key,"dummy_value")
        ## Assign material to bondwire
        #if (self.bwMaterials.has_key(resistivity)):
        #    material = self.bwMaterials[resistivity]
        #else:
        #    import empro.toolkit.ads_import
        #    session=empro.toolkit.ads_import.Import_session(units="um", wall_boundary="Radiation")
        #    material=session.create_material(name="bondwire", color=(0,0,255,255), resistivity=resistivity)
        #    empro.activeProject.materials().append(material)
        #    self.bwMaterials[resistivity]=material
        #empro.toolkit.applyMaterial(model,material)
        return model

    def getBondwireMap(self,iDom,bwComps=None):
        components  = iDom.getElementsByTagName('AdfiComponent')
        if bwComps == None:
            bwComps = {}
        import empro
        assembly=empro.geometry.Assembly()
        assembly.name = "Bondwires"
        for iCmp in components:
            instances = iCmp.getElementsByTagName('Instance')
            if instances:
                for inst in instances:
                    cmpName = eemGetElNodeValByTag(inst, 'Component')
                    if cmpName == 'SBOND':
                        comp = self.createBondwire(iCmp,inst)
                        if (comp):
                            bwComps[comp.name]=comp
        return bwComps

    def importBondwires(self,iDom,topAssembly):
        bwComps = self.getBondwireMap(iDom)
        import empro
        assembly=empro.geometry.Assembly()
        assembly.name = "Bondwires"
        for name,comp in bwComps.iteritems():
            assembly.append(comp)
        if len(assembly) > 0:
            if topAssembly == None:
                empro.activeProject.geometry().append(assembly)
            else:
                topAssembly.append(assembly)

def getComponentParms(iCmp,toUpper=True):
    return getParms(iCmp,toUpper,"ComponentParms")

def getParms(iCmp,toUpper=True,groupName="ComponentParms"):
    keyValuePairs = {}
    if (iCmp.localName == groupName):
        cmpParms=iCmp
    else:
        cmpParms = iCmp.getElementsByTagName(groupName)
        if cmpParms and len(cmpParms)==1:
            cmpParms = cmpParms[0]
        else:
            return None
    parameterNodes = cmpParms.getElementsByTagName('Parameter')
    for pNodes in parameterNodes:
        key = pNodes.getAttribute('key')
        value = pNodes.getAttribute('value')
        if toUpper:
            key = key.upper()
            value = value.upper()
        keyValuePairs[key] = value
        eemWriteDebug("   Parameter %s : %s" % (key,value))
    return keyValuePairs

def getInstanceParms(iCmp,toUpper=True):
    return getParms(iCmp,toUpper,"InstanceParms")
    InstanceParms
    InstanceParms

class componentImporter():
    def __init__(self):
        pass

    def valueToRLC(self,value,partName=""):
        R = 0
        L = 0
        C = 0
        if value.upper()[-3:]=='OHM':
            value = value[:-2]
        if value.upper()[-3:]=='MHO':
            value = value[:-3]+'S'
        try:
            #valueWithoutUnit = float(re.sub('[A-Z]+','',value.upper()))
            valueWithoutUnit = float(re.sub('[^0-9.]+','',value))
        except ValueError:
            return (R,L,C)
        unit = re.sub('[0-9.]+','',value)
        mainUnit = unit.upper()[-1:]
        if mainUnit in ['O','H','F','S']:
            if mainUnit == 'O':
                R = valueWithoutUnit * getRLCUnitConversionFactor(unit)
            elif mainUnit == 'H': 
                L = valueWithoutUnit * getRLCUnitConversionFactor(unit)
            elif mainUnit == 'F': 
                C = valueWithoutUnit * getRLCUnitConversionFactor(unit)
            elif mainUnit == 'S': 
                R = 1/(valueWithoutUnit * getRLCUnitConversionFactor(unit))
        else:
            if partName in ['R','L','C']:
                if partName == 'R':
                    unit += 'O'
                    R = valueWithoutUnit * getRLCUnitConversionFactor(unit)
                elif partName == 'L':
                    unit += 'H'
                    L = valueWithoutUnit * getRLCUnitConversionFactor(unit)
                elif partName == 'C':
                    unit += 'F'
                    C = valueWithoutUnit * getRLCUnitConversionFactor(unit)
            else:
                eemWriteDebug('Found no unit in value %s. Taking Ohm as default' % value)
                unit += 'O'
                R = valueWithoutUnit * getRLCUnitConversionFactor(unit)
        return (R,L,C)

    def createOrGetComponentDefinition(self,value,partName=""):
        if not value:
            return None
        # Check if a component definition can be reused
        try:
            (R,L,C) = self.valueToRLC(value,partName)
        except UnitException:
            return None
        if (R,L,C) == (0,0,0):
            return None
        eemWriteDebug("    Component with (R,L,C) = (%s,%s,%s)" % (R,L,C))
        import empro
        cdefs = empro.activeProject.circuitComponentDefinitions()
        for i in range(len(cdefs)):
            cmp = cdefs[i]
            if (cmp.impedance.resistance != R or cmp.impedance.inductance != L or cmp.impedance.capacitance != C) :
                continue
            if cmp.impedance.elementArrangement != "Series":
                continue
            eemWriteDebug("    This component matches definition with name '%s'" % cmp.name)
            return cmp
        # If not create a new one and add it to the current project
        name = "%s Passive Load"%value
        newCmp = empro.components.PassiveLoad(name)
        newCmp.impedance.resistance  = R
        newCmp.impedance.inductance  = L
        newCmp.impedance.capacitance = C
        newCmp.impedance.elementArrangement = "Series"
        newCmp.name = "%s Passive Load"%value
        empro.activeProject.circuitComponentDefinitions().append(newCmp)
        cdefs = empro.activeProject.circuitComponentDefinitions()
        newCmp = cdefs[len(cdefs)-1]
        return newCmp


    def getPins(self,iCmp):
        # get number,x,y,layer
        ports = iCmp.getElementsByTagName('PortDescription')
        cmpName = (eemGetElNodeValByTag(iCmp, 'Name')).strip()
        if len(ports) > 2:
            eemWriteWarn("    Components with more than 2 pins not supported! Only using pin 1 and 2 of %s." % cmpName)
        if len(ports) == 1:
            eemWriteWarn("    Components with only 1 pin not supported!")
        tailDef = None
        headDef = None
        for p in ports:
            pinName = eemGetElNodeValByTag(p, 'PinName')
            pinNumber = int(eemGetElNodeValByTag(p, 'PinNumber'))
            pinLayerName = eemGetElNodeValByTag(p, 'LayerName')
            netName = eemGetElNodeValByTag(p, 'NetName')
            if netName == None:
                netName = ''
            (xLoc,yLoc)= eemAdfiGetLocation(p)
            eemWriteDebug("    Port %s (nb %s) on %s at (%s,%s) on net %s" % (pinName,pinNumber,pinLayerName,xLoc,yLoc,netName))
            pin = {}
            pin['x'      ] = float(xLoc)
            pin['y'      ] = float(yLoc)
            pin['zLayer' ] = pinLayerName
            pin['name'   ] = pinName
            pin['number' ] = pinNumber
            pin['netName'] = netName
            if pinNumber == 1:
                tailDef = pin
            elif pinNumber == 2:
                headDef = pin
            else:
                if tailDef == None:
                    tailDef = pin
                elif headDef == None:
                    headDef = pin
        if not headDef or not tailDef:
            includeInvalidComponents = False
            if includeInvalidComponents:
                if headDef or tailDef:
                    headDef = tailDef or headDef
                    tailDef = tailDef or headDef
                    eemWriteWarn("      Colocating pins of %s since only one found in .adfi file!"%cmpName)
        return (tailDef,headDef)

    def createComponent(self,iCmp):
        cmpName = eemGetElNodeValByTag(iCmp, 'Name')
        if iCmp.hasAttribute('id'):
            id = iCmp.getAttribute('id')
        else:
            id = 'Unknown component'
        eemWriteDebug("Found component with name %s and id %s" % (cmpName,id))
        parameters = getComponentParms(iCmp)
        above = True
        compDef = None
        if (parameters and parameters.has_key('VALUE')):
            CmpValue = parameters['VALUE']
            try:
                compDef = self.createOrGetComponentDefinition(CmpValue,partName=parameters['PART_NAME'])
            except KeyError:
                compDef = self.createOrGetComponentDefinition(CmpValue)
        if (parameters and parameters.has_key('RELATIVE_TO_SUBSTRATE')):
            relToSub = parameters['RELATIVE_TO_SUBSTRATE']
            if relToSub.upper() == 'BELOW':
                above = False
        conversionFactor = getDrawingUnitConversionFactor(iCmp) 
        tailDef,headDef = self.getPins(iCmp)
        if not tailDef or not headDef:
            eemWriteWarn("      Component %s not imported due to incorrect or unsupported pin setup!"%cmpName)
            return None
        # Create new component
        import empro
        newCmp=empro.components.CircuitComponent() 
        newCmp.name= "%s %s" % (cmpName,id) 
        newCmp.definition=compDef
        newCmp.port = False
        newCmp.notes = "Component imported from .adfi file.\nParameter values: \n%s\nDrawing unit conversion factor %s" % (str(parameters),conversionFactor)
        V=empro.geometry.Vector3d
        if headDef:
            newCmp.head=V(conversionFactor*headDef['x'],conversionFactor*headDef['y'],_layerNameToVariable(headDef['zLayer'],above,False))
        if tailDef:
            newCmp.tail=V(conversionFactor*tailDef['x'],conversionFactor*tailDef['y'],_layerNameToVariable(tailDef['zLayer'],above,False))
        return newCmp


    def importComponents(self,iDom):
        components  = iDom.getElementsByTagName('AdfiComponent')
        comps = []
        for iCmp in components:
            cmpType = eemGetElNodeValByTag(iCmp, 'Type').strip()
            if cmpType.upper() == 'COMPONENT':
                comp = self.createComponent(iCmp)
                if comp:
                    comps.append(comp)
        import empro
        empro.activeProject.circuitComponents().appendList(comps)


class solderBallImporter():
    def __init__(self):
        self.sbMaterials={} # Map from resistivity to material
        self.pkgLayer = ""
        self.compType = "flipchip"

    def findPorts(self,iCmp):
        conversionFactor = getDrawingUnitConversionFactor(iCmp)
        try:
            if self.compType == "flipchip":
                pinLayer = self.parameters['ICPKG_PIN_LAYER']
            else:
                pinLayer = self.parameters['PKG_PIN_LAYER_ATPKG']
            pins  = iCmp.getElementsByTagName('PortDescription')
            sbLocs = []
            for pin in pins:
                layerName  = eemGetElNodeValByTag(pin, 'LayerName')
                if layerName != pinLayer:
                    if self.pkgLayer != layerName:
                        eemWriteDebug("Found package layer %s" % (layerName))
                        self.pkgLayer = layerName
                    continue
                pinName  = eemGetElNodeValByTag(pin, 'PinName')
                (x,y) = eemAdfiGetLocation(pin)
                x = float(x) * conversionFactor 
                y = float(y) * conversionFactor 
                eemWriteDebug("Found ball on location %s,%s" % (x,y))
                sbLocs.append((x,y,pinName))
            return sbLocs
        except:
            return []

    def getSolderBallMap(self,iDom,sbComps=None):
        if sbComps == None:
            sbComps = {}
        components  = iDom.getElementsByTagName('AdfiComponent')
        import empro
        for iCmp in components:
            self.parameters = getComponentParms(iCmp)
            if (self.parameters):
                if self.parameters.has_key('ICPKG_TYPE') and self.parameters['ICPKG_TYPE'] == 'DIE_FLIPCHIP':
                    self.compType = "flipchip"
                elif self.parameters.has_key('PKG_TYPE') and self.parameters['PKG_TYPE'] == 'BGA':
                    self.compType = "bga"
                else:
                    continue
            else:
                continue
            eemWriteDebug("Found component with solder balls.")
            id = iCmp.getAttribute('id')
            if self.compType == "flipchip":
                h = self.parameters["ICPKG_BUMP_HEIGHT"].lower()
                widthMax = self.parameters["ICPKG_BUMP_DIAMETER_MAX"].lower()
                widthFaceNear = self.parameters["ICPKG_BUMP_DIAMETER_ATDIE"].lower()
                widthFaceFar = self.parameters["ICPKG_BUMP_DIAMETER_ATPKG"].lower()
                bumpLayer = self.parameters['ICPKG_BUMP_LAYER']
                pinLayer = self.parameters['ICPKG_PIN_LAYER']
                relToSub = self.parameters['RELATIVE_TO_SUBSTRATE']
                conductivityString = self.parameters["ICPKG_BUMP_CONDUCTIVITY"]
            else:
                h = self.parameters["PKG_BALL_HEIGHT"].lower()
                try:
                    widthMax = self.parameters["PKG_BALL_DIAMETER"].lower()
                except:
                    widthMax = self.parameters["PKG_BALL_DIAMETER_MAX"].lower()
                widthFaceNear = self.parameters["PKG_BALL_DIAMETER_ATPKG"].lower()
                widthFaceFar = self.parameters["PKG_BALL_DIAMETER_ATBRD"].lower()
                bumpLayer = self.parameters['PKG_BALL_LAYER']
                pinLayer = self.parameters['PKG_PIN_LAYER_ATPKG']
                #relToSub = self.parameters['RELATIVE_TO_SUBSTRATE']
                relToSub = 'ABOVE' # TODO check if this is always true
                # Dummy value that should never be used since the material from the 'PKG_BALL_LAYER' will be taken
                conductivityString = "6.897e+006 Siemens/m"
            widthFace = "((%s)+(%s))/2.0" % (widthFaceNear,widthFaceFar)
            # e.g. "6.897e+006 Siemens/m"
            resistivity = getResistivityFromConductivityString(conductivityString)
            # radius in m for dummy bondwire
            import re
            value = widthFaceNear
            valueWithoutUnit = float(re.sub('[A-Z]+','',value.upper()))
            unit = re.sub('[0-9. ]+','',value)
            radius = valueWithoutUnit * getRLCUnitConversionFactor(unit)
            above = True
            if relToSub.upper() == 'BELOW':
                above = False
            divisions = 3
            import math
            arcRes = "45 deg" # 45/180.0*math.pi
            portList = self.findPorts(iCmp)
            V=empro.geometry.Vector3d
            z = _layerNameToVariable(bumpLayer,above,addQuotes=False)
            if above:
                z = "(%s) - (%s)" % (z,h)
            eemWriteDebug ("z dim = %s" %(z))
            session=empro.toolkit.ads_import.Import_session(units="um", wall_boundary="Radiation")
            arcResParName = "solderBall_%s_arcRes"%id
            divisionsParName = "solderBall_%s_divisions"%id
            session.create_parameter(divisionsParName,str(divisions),"Nb of divisions of solderBalls of %s"%id,True)
            session.create_parameter(arcResParName,str(arcRes),"Arc resolution of solderBalls of %s"%id,True)
            sb = empro.geometry.SolderBall(h,widthFace,widthMax,divisionsParName,arcResParName)
            for (x,y,name) in portList:
                eemWriteDebug ("Creating ball with h=%s, wFace=%s, wMax=%s" %(h,widthFace,widthMax))
                model = empro.geometry.Model()
                # Add attributes to model
                for key,value in self.parameters.iteritems():
                    try:
                        model.addAttribute(key,str(value))
                    except TypeError:
                        model.addAttribute(key,"dummy_value")
                model.name = id+"_"+name
                model.recipe.append(sb.clone())
                anchorPoint = empro.geometry.CoordinateSystemPositionExpression(V(x,y,z))
                eemWriteDebug ("anchorPoint z  %s" %( anchorPoint.position))
                model.coordinateSystem.anchorPoint = anchorPoint
                paramMap = {}
                paramMap['comp_id'] = id
                paramMap['radius'] = radius
                paramMap['resistivity'] = resistivity 
                paramMap['x'] = x 
                paramMap['y'] = y 
                paramMap['above'] = above 
                paramMap['mask_top'] = pinLayer 
                paramMap['mask_bottom'] = self.pkgLayer 
                paramMap['material_name'] = bumpLayer
                sbComps[model.name]=(id,model,paramMap)
        return sbComps

    def importSolderBalls(self,iDom,topAssembly):
        sbMap = self.getSolderBallMap(iDom)
        import empro
        assembly=empro.geometry.Assembly()
        assembly.name = "SolderBalls"
        assemblyMap = {}
        for name,(id,comp,paramMap) in sbMap.iteritems():
            if assemblyMap.has_key(id):
                assemblyMap[id].append(comp)
            else:
                newAssembly = empro.geometry.Assembly()
                assemblyMap[id] = newAssembly
                newAssembly.append(comp)
                newAssembly.name = id + "_solderBalls"
                assembly.append(newAssembly)
        if len(assembly) > 0:
            if topAssembly == None:
                empro.activeProject.geometry().append(assembly)
            else:
                topAssembly.append(assembly)
        return

def eemAdfiImportComponents(iAdfiFileName,useJedecBondwires=False,useSolderBalls=False,topAssembly=None):
    eemWriteDebug("Importing components")
    try:
        iDom = eemAdfiReadFile(iAdfiFileName)
    except:
        raise
    importer = componentImporter()
    importer.importComponents(iDom)
    if useJedecBondwires:
        importer = bondwireImporter()
        importer.importBondwires(iDom,topAssembly)
    if useSolderBalls:
        importer = solderBallImporter()
        importer.importSolderBalls(iDom,topAssembly)



##########################################################
#  Export the ltd files and do the slm conversion
#
#

class AdfiLtds:
    def __init__(self,fPrefix=None):
        self.fPrefix = fPrefix
        self.ltdMap = {}
        self.ltdRevMap = {}
        self.ltds = {}
        self.instMergeMap = {'main':{'idx':-1},
                             'top':{'idx':-1},
                             'bottom':{'idx':-1}}
        self.top = None
        self.topInstancesMap = {}
        self.topSlmData = None
        self.topSlmDataFileName = None
        self.topLtdData = None
        self.topSlmFile = None
        self.topLtdFile = None
        self.topSubName = None
        self.topTypeLtdOrSlm = None

    def assembleLtdSlmMaps(self):
        eemWriteDebug("Process layer stack informations")
        
        self.__minimizeLtds()
        try:
            self.__writeTopSlmFile()
        except:
            eemWriteError("Problem writing top slm technology file output: need to exit")
            raise                
        try:
            self.__writeLtdFiles()
        except:
            eemWriteError("Problem with ltd technology file output: need to exit")
            raise
        try:
            if self.__mergeLtdFiles()!=0:
                raise ValueError
        except:
            eemWriteError("Problem with ltd technology file merge: need to exit")
            raise
        try:
            self.__convertLtdToSlm()
        except:
            eemWriteError("Problem with ltd to slm file conversion")
            raise
        eemWriteDebug("Process layer stack informations done")
                

    def topName(self,topName=None):
        if topName!=None:
            self.top = topName
        return self.top
        
    def addLtdSlmMap(self,iDocNode,cmpName=None,top=None):
        eemWriteDebug("Add component with layer stack information")
              
        subName = eemGetElNodeValByTag(iDocNode, 'SubstrateName')
        if subName == None:
            subName=cmpName

        subData = iDocNode.getElementsByTagName('SubstrateData')
        if (subData):
            ltdOrSlm = getInnerText(subData[0])
            typeLtdOrSlm = subData[0].getAttribute('substrateDataType')
            if typeLtdOrSlm=='ltd':
                ltd = ltdOrSlm
                v=None
                if ltd in self.ltdMap.keys():
                    v = self.ltdMap[ltd]
                else:
                    v = len(self.ltdMap)
                    self.ltds[v]=ltd
                    self.ltdMap[ltd]=v
                self.ltdRevMap[subName]=v
                self.ltdRevMap[cmpName]=v
            if (top):
                eemWriteDebug("Top components %s with layer stack information identified %s" % (self.top,str(typeLtdOrSlm)))
                self.topTypeLtdOrSlm=typeLtdOrSlm
                self.topSubName=subName
                if typeLtdOrSlm=='ltd':
                    self.topLtdData=ltdOrSlm
                elif typeLtdOrSlm=='slm':
                    self.topSlmData=ltdOrSlm
                elif typeLtdOrSlm=='ltdFile':
                    self.topLtdFile==ltdOrSlm
                elif typeLtdOrSlm=='slmFile':
                    self.topSlmFile==ltdOrSlm
        eemWriteDebug("Component with layer stack information identified")

    def addSubstrateInstanceMap(self, iDocNode):
        eemWriteDebug("Add component instances with layer stack information")
        instances = iDocNode.getElementsByTagName('Instance')
        for inst in instances:
            instName = inst.getAttribute('id')
            side  = 'main'
            layer = None
            instMap= {}
            direct = None
            instMap['cmpName']=(eemGetElNodeValByTag(inst, 'Component')).strip()
            subMerge = inst.getElementsByTagName('MergeAtInterface')
            if subMerge:
                direct = subMerge[0].getAttribute('mergeDirection')
                layer  = (getInnerText(subMerge[0])).strip()
                if direct == 'up':
                    side = 'top'
                elif direct == 'down':
                    side = 'bottom'
            instMap['direct'] = direct
            instMap['side']   = side
            instMap['layer'] = layer
            self.topInstancesMap[instName] = instMap

        eemWriteDebug("Component instances with layer stack information identified")
                
    def __minimizeLtds(self):
        eemWriteDebug("Find duplicate layer stacks")        
        instances = self.topInstancesMap
                
        if self.topLtdData!=None:
            cmap=self.instMergeMap['main']
            cmap['idx'] = self.ltdRevMap[self.top]
            cmap['instNames'] = [self.top]
            cmap['layer'] = None
            self.instMergeMap['main']=cmap

        for instName,instMap in instances.iteritems():
            cmpName = instMap['cmpName']
            if not(instName in self.ltdRevMap.keys()
                   or cmpName in self.ltdRevMap.keys()):
                continue


            # instance with substrate associated with it
            side  = instMap['side']
            layer = instMap['layer']
            cmap = self.instMergeMap[side]
            if cmap['idx']<0:
                cmap['idx'] = self.ltdRevMap[instName]
                aList = []
                aList.append(instName)
                cmap['instNames'] = aList
                if layer:
                    cmap['layer'] = layer
            else:
                if ((cmap['idx'] != self.ltdRevMap[instName])
                    or (cmap['idx'] != self.ltdRevMap[cmpName])
                    or (layer != None
                        and 'layer' in cmap.keys()
                        and cmap['layer'] != layer)):
                    eemWriteWarn("Found different %s substrate definitions: keep first." % side)
                aList = cmap['instNames']
                aList.append(instName)
                cmap['instNames'] = aList

            self.instMergeMap[side] = cmap
            
            
        idxMap = {}
        instFound = []
        for wLtd in self.instMergeMap.keys():
            aList=[]
            cmap = self.instMergeMap[wLtd]
            idx = cmap['idx']
            if idx >= 0:
                idxMap[idx] = wLtd
                aList = cmap['instNames']
                instFound.extend(aList)
        
        for iKey in self.ltdRevMap.keys():
            if iKey in instFound:
                continue
            ltdIdx = self.ltdRevMap[iKey]
            a = []
            if ltdIdx not in idxMap.keys():
                cmap = {'idx':ltdIdx}
                a.append(iKey)
                cmap['instNames'] = a
                self.instMergeMap[iKey] = cmap
                idxMap[ltdIdx] = iKey
            else:
                cmap = self.instMergeMap[idxMap[ltdIdx]]
                a = cmap['instNames']
                a.append(iKey)
                cmap['instNames']= a
                self.instMergeMap[idxMap[ltdIdx]] = cmap
        eemWriteDebug("Duplicates in layer stacks identified")

    def __writeLtdFiles(self):
        eemWriteDebug("Write the found layer stacks")
        fPrefix=self.fPrefix
        for ltdName,ltdMap in self.instMergeMap.iteritems():
            if ltdMap['idx']<0:
                continue
            fName = fPrefix + "_" + str(ltdName) + ".ltd"
            ltdMap['ltdFile'] = fName
            fp = open(fName, 'w')
            fp.write(self.ltds[ltdMap['idx']])
            fp.close()
            self.instMergeMap[ltdName]=ltdMap
        eemWriteDebug("Writing layer stacks done")

    def __writeTopSlmFile(self):
        fPrefix=self.fPrefix
        if self.topSlmData!=None:
            eemWriteDebug("Write top slm file")
            fName = fPrefix + "_" + self.topSubName + ".slm"
            self.topSlmDataFileName=fName
            fp = open(fName, 'w')
            fp.write(self.topSlmData)
            fp.close()

    def __mergeLtdFiles(self):
        topComponent=self.top
        fPrefix=self.fPrefix
        eemWriteDebug("Start merge with %s for %s" % (fPrefix,topComponent))
        bottom = self.instMergeMap['bottom']
        main = self.instMergeMap['main']
        top = self.instMergeMap['top']
        r = 0
        fIn1 = ''
        fIn2 = ''
        fOut = ''
        insts=[]
        insts.append(topComponent)
        verOk = eemIsValidSubedVersion()
        if (main['idx']<0
            or (bottom['idx']<0 and top['idx']<0)
            or not verOk):
            eemWriteDebug("No merge needed or can not merge: use main substrate")
            fOut = main['ltdFile']
        elif bottom['idx']>0 and top['idx']<0:
            fIn1 = bottom['ltdFile']
            fIn2 = main['ltdFile']
            fOut = fPrefix + '_bottom_main.ltd'
            r=eemMergeLtdFile(fIn1, fIn2, fOut)
        elif bottom['idx']<0 and top['idx']>0:
            fIn1 = main['ltdFile']
            fIn2 = top['ltdFile']
            fOut = fPrefix + '_main_top.ltd'
            r=eemMergeLtdFile(fIn1, fIn2, fOut)
        else:
            fIn1 = bottom['ltdFile']
            fIn2 = main['ltdFile']
            fOut = fPrefix + '_bottom_main.ltd'
            r=eemMergeLtdFile(fIn1, fIn2, fOut)
            if r==0:
                fIn1 = fOut
                fIn2 = top['ltdFile']
                fOut = fPrefix + '_bottom_main_top.ltd'
                r=eemMergeLtdFile(fIn1, fIn2, fOut)        
        merge = {}
        merge['idx']=len(self.ltds)
        if r == 0:
            merge['ltdFile']=fOut
        else:
            merge['ltdFile']=main['ltdFile']
        merge['instNames']=insts
        self.instMergeMap['merge'] = merge
        eemWriteDebug("Merge of layerstacks %s for %s done" % (fPrefix,topComponent))
        return r
 
    def __convertLtdToSlm(self):
        eemWriteDebug("Convert ltd to slm and lay files")
        fOutNames = []
        r=0
        for mapName,mergeMap in self.instMergeMap.iteritems():
            if 'ltdFile' in mergeMap.keys():
                fIn  = mergeMap['ltdFile']
                fInSplit = os.path.splitext(fIn)
                fOut = fInSplit[0] + '.slm'
                if fOut not in fOutNames:
                    fOutNames.append(fOut)
                    r=eemConverLtdToSlmFile(fIn, fOut)
                mergeMap['slmFile']=fOut
                self.instMergeMap[mapName]=mergeMap
        eemWriteDebug("Conversion ltd to slm and lay files done")

    def getTopDesignName(self):
        return self.top
    
    def getSlmFileName(self,iName=None):
        eemWriteDebug("Check for stack info of %s" % iName)
        name = self.top
        if iName:
            name = iName
        if (not((name == self.top)
                or (name in self.ltdRevMap.keys()))):
            return None

        if self.topSlmDataFileName!=None :
            return self.topSlmDataFileName
        if self.topSlmFile!=None :
            return self.topSlmFile

        slmName=None
        for mapName,mergeMap in self.instMergeMap.iteritems():
            if (('slmFile' in mergeMap.keys())
                and ('instNames' in mergeMap.keys())
                and (name in mergeMap['instNames'])):
                slmName = mergeMap['slmFile']
                break
        if ((name == None) or
            (slmName == None)):
            slmName = self.instMergeMap['main']['slmFile']
            eemWriteDebug("No valid slm file found: return main substrate instead")
        return slmName

    def getLtdFileName(self,iName=None):
        eemWriteDebug("Check for stack info of %s ltd version" % iName)
        name = self.top
        if iName:
            name = iName
        if ((name != self.top)
            and (name not in self.ltdRevMap.keys())):
            return None
        
        if self.topLtdFile!=None :
            return self.topLtdFile
        
        for mapName,mergeMap in self.instMergeMap.iteritems():
            if (('ltdFile' in mergeMap.keys())
                and ('instNames' in mergeMap.keys())
                and (name in mergeMap['instNames'])):
                ltdFile = mergeMap['ltdFile']
                break
        if ((name == None) or
            (ltdFile == None)):
            ltdFile = self.instMergeMap['main']['ltdFile']
            eemWriteDebug("No valid ltd file found: return main substrate instead")
        return ltdFile

def subProcessStartupInfo():
    import subprocess
    try:
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags  |= subprocess.STARTF_USESHOWWINDOW
    except AttributeError:
        startupinfo = None
    return startupinfo

def subedRemoveFromEnviron_QtQpaPluginPlatform():
    envVars = os.environ.copy()
    qpaId = 'QT_QPA_PLATFORM_PLUGIN_PATH'
    if envVars.has_key(qpaId):
        del envVars[qpaId]
    return envVars

def eemIsValidSubedVersion():
    import subprocess,re,os,string
    envVars = subedRemoveFromEnviron_QtQpaPluginPlatform()
    subedCmd = ['eesofsubed','--version']
    #subedCmd = "eesofsubed --version"
    eemWriteDebug("Check subed version: %s" % subedCmd)
    myProcess = subprocess.Popen(args=subedCmd,
                                 executable=None,
                                 stdin=None,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 universal_newlines=True,
                                 startupinfo=subProcessStartupInfo(),
                                 shell=False,
                                 env=envVars)
    #wait for termination of child process
    if 'wait' in dir(os):
        cmdStatus=os.wait()

    res=''.join(myProcess.stdout.readlines())
    rMatch=re.search('Substrate Editor v(?P<version>[0-9]+\.[0-9]+)',res,re.M)
    val=0.0
    if rMatch!=None:
        val=float(rMatch.group(1))
    valNeeded = 2.1
    if val < valNeeded:
        eemWriteInfo("No valid EESof Substrate Editor found: needs version %s or higher (should be available in ADS 2009 / EMPro 2011.07 or later)" % valNeeded)
        print sys.path
        print os.environ['PATH']
        return False
    eemWriteDebug("Found valid EESof Substrate Editor")
    return True
        

def eemMergeLtdFile(fIn1,fIn2,fOut):
    envVars = subedRemoveFromEnviron_QtQpaPluginPlatform()
    subedCmd = 'eesofsubed -M --stack --pos2=top1 --out='
    subedCmd = subedCmd + fOut
    subedCmd = ' '.join([subedCmd, fIn1, fIn2])
    
    eemWriteDebug("Ltd merge operation: %s" % subedCmd)
    
    myProcess = subprocess.Popen(args=subedCmd,
                                 executable=None,
                                 stdin=None,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 universal_newlines=True,
                                 startupinfo=subProcessStartupInfo(),
                                 shell=True,
                                 env=envVars)
    #wait for termination of child process
    if 'wait' in dir(os):
        cmdStatus=os.wait()

    res=''.join(myProcess.stdout.readlines())
    if  re.search('(Merged stack saved)',res,re.M) == None:
        errorString = "Problem merging ltd files: %s and %s into %s\n" % (fIn1, fIn2,fOut)
        errorString = errorString + "Process output:\n%s" % res
        eemWriteDebug(errorString)
        raise Exception(errorString)
    
    eemWriteDebug("Success merging ltd files: %s and %s into %s" % (fIn1, fIn2,fOut))
    return 0


def eemConverLtdToSlmFile(ifIn, ifOut):
    envVars = subedRemoveFromEnviron_QtQpaPluginPlatform()
    subedCmd = 'eesofsubed -C --ltd2slm'
    fIn = '\"' + ifIn + '\"'
    fOut = '\"' + ifOut + '\"'
    subedCmd = ' '.join([subedCmd, fIn, fOut])
    
    eemWriteDebug("Ltd to slm conversion: %s" % subedCmd)
    
    myProcess = subprocess.Popen(args=subedCmd,
                                 executable=None,
                                 stdin=None,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 universal_newlines=True,
                                 startupinfo=subProcessStartupInfo(),
                                 shell=True,
                                 env=envVars)
    #wait for termination of child process
    if 'wait' in dir(os):
        cmdStatus=os.wait()

    res=''.join(myProcess.stdout.readlines())
    if re.search('(Export successful)',res,re.M) == None:
        errorString = "Converting ltd to slm file failed for: %s to  %s\n" % (fIn, fOut)
        errorString = errorString + "Process output:\n%s" % res
        eemWriteDebug(errorString)
        raise Exception(errorString)
    
    eemWriteDebug("Ltd to slm file conversion success: %s to %s\n" % (fIn, fOut))


class AdfiLayers:
    def __init__(self, adfiPrefix):
        self.layName = adfiPrefix + '.lay'
        self.layDisplayPrefName = adfiPrefix + '.lyrprf'
        self.lineTypes = {'solid':0,
                          'dotted':1,
                          'double dotted':2,
                          'short dash':3,
                          'short dot dash':4,
                          'long dash':5,
                          'long dot dash':6}
        self.layerData=[]
        self.egsProcess=None
        
    def addSubstrateLayerData(self,iLayerDataNode=None):
        if (iLayerDataNode!=None
            and self.layerData==[]):
            substrateLayerDataNode=iLayerDataNode.getElementsByTagName('SubstrateLayerData')
            if substrateLayerDataNode:
                clNode=substrateLayerDataNode[0].cloneNode(True)
                self.layerData=clNode.getElementsByTagName('SubstrateLayer')
            
    def addEgsProcess(self,iEgsHeader=None):
        self.egsProcess=iEgsHeader

    def writeLayFile(self, mainVersion):
        eemWriteDebug("Extract the lay file from adfi elements")

        if (self.egsProcess==""
            and self.layerData==[]):
            raise Exception('Both SubstrateLayerData and egs process data are missing')
    
        outFormat='%s\tnumber = %s stream = %s iges = %s color = %s fill = %s line = %s, %s %s %s, \"%s\", type = %s, dxf = \"%s\" trans = %s\n'
    
        try:
            fName = self.layName
            layerData = self.layerData
            lineTypes = self.lineTypes
            eemWriteDebug("Layer filename is: %s" % fName)
            eemWriteDebug("version and layerdata is: %d, %s" % (mainVersion, layerData))
            layFp = open(fName,"w")
            if not ((mainVersion < 4) or (layerData==[])): 
                eemWriteDebug("Version 4 or higher and SubstrateLayer data for this to work.")
                first=True
                for i in layerData:
                    layerName = i.getElementsByTagName('LayerName')[0].childNodes[0].nodeValue
                    layerNum  = i.getAttribute('id')
                    if first:
                        layFp.write( 'CurrentLayer number = ' + str(layerNum) + '\n' )
                        first=None

                    layerColor = i.getElementsByTagName('LayerColor')
                    color='1'
                    if layerColor!=[]:
                        color=layerColor[0].getAttribute('id')

                    line='0'
                    fill='1'
                    pattern='18'
                    trans='50'
                    layerParms = i.getElementsByTagName('Parameter')
                    for parm in layerParms:
                        key = parm.getAttribute('key')
                        value = parm.getAttribute('value')
                        eemWriteDebug('%s %s'%( key, value))
                        if key == 'fill':
                            val=1
                            if value == 'outline':
                                val=0
                            elif value == 'both':
                                val=2
                            fill = str(val)
                        elif key == 'line':
                            line = str(lineTypes[value])
                        elif key == 'trans':
                            trans = str(value)
                        elif key == 'pattern':
                            pattern = str(value)
                    layFp.write( outFormat % (layerName, layerNum, layerNum, layerNum, color,
                                              pattern, line, fill, '0', '1', '', '1', layerName, trans) )
            else:
                eemWriteDebug("do it from egs process data if necessary")
                layers=re.findall('EQU\s+(\w+).*?[:Cc](\d+)\s+:[P]\d+\s+(\d+);', process, re.M)
                first=True
                for layerName, color, layerNum in layers:
                    if layerName!='default':
                        if first:
                            layFp.write( 'CurrentLayer number = ' + str(layerNum) + '\n' )
                            first=None
                        line='0'
                        fill='1'
                        pattern='1'
                        trans='50'
                        layFp.write( outFormat % (layerName, layerNum, layerNum, layerNum, color,
                                                  pattern, line, fill, '0', '1', '', '1', layerName, trans) )

            layFp.close()
            eemWriteDebug("Done: Extract the lay file from adfi elements")

        except:
            eemWriteError("Can not write lay file info from ADS ADFI file.")
        raise

    def writeDisplayPreferenceFile(self, mainVersion):
        eemWriteDebug("Extract the layer preference setting and put them into the output")
        # process output
        try: 
            lineTypes = self.lineTypes
            fName = self.layDisplayPrefName
            eemWriteDebug("Layer preference filename is: %s" % fName)
            lyrFp = open(fName,"w")
            if mainVersion<4:
                # need to have at least version 4
                lyrFp.close()
                raise Exception('Main version needs to be >= 4')
            
            layerData = self.layerData
            # need at least version 4 and layerdata to work
            if layerData==[]:
                lyrFp.close()
                raise Exception('No layer data found')
            
            for i in layerData:
                line = ""
                layerName = i.getElementsByTagName('LayerName')[0].childNodes[0].nodeValue
                eemWriteDebug("layer name %s" % layerName)

                line = "layer|" + layerName
                layerColor = i.getElementsByTagName('LayerColor')
                eemWriteDebug("layer name %s" % str(layerColor))
                if layerColor!=[]:
                    r=layerColor[0].getAttribute('r')
                    g=layerColor[0].getAttribute('g')
                    b=layerColor[0].getAttribute('b')
                    line = line + '|red|' + r + '|green|' + g + '|blue|' + b
                    eemWriteDebug("layer %s color r=%s g=%s b=%s" % (layerName,r,g,b))

                    layerParms = i.getElementsByTagName('Parameter')
                    eemWriteDebug("layer parms %s" % str(layerParms))
                    fillVal=1
                    lineVal=0
                    otherLine=''
                    for parm in layerParms:
                        key = parm.getAttribute('key')
                        value = parm.getAttribute('value')
                        if key == 'fill':
                            if value == 'outline':
                                fillVal=0
                            elif value == 'both':
                                fillVal=2
                        elif key == 'line':
                            lineVal = value
                        else:
                            otherLine = otherLine + "|" + str(key) + "|" + str(value)

                    line = line + "|fill|" + str(fillVal)
                    line = line + "|line|" + str(lineTypes[lineVal])
                    line = line + otherLine
                    line = line + "\n"
                    lyrFp.write(line)
            lyrFp.close()
            eemWriteDebug("Done: Extract the layer preference setting and put them into the output")

        except Exception, err:
            errorString = "Cannot write display preference info from ADS ADFI file.\n%s" % str(err)
            eemWriteDebug(errorString)
            raise Exception(errorString)

class AdfiAblLibInfo:
    def __init__( self, targetDir, adfiPrefix, iLibName=''):
        self.present_ = False
        self.useAblRoot_ = False
        self.targetDir = targetDir
        self.fPrefix = adfiPrefix
        self.name = iLibName
        self.libName = ''
        self.refTechnologies = []
        self.userUnits = None
        self.DBUperUU = None
        self.instTextHeight='0.'
        self.portSize='0.'
        self.processTypes = {'Not defined':'PROCESS_ROLE_NONE',
                             'Conductor':'PROCESS_ROLE_CONDUCTOR',
                             'Dielectric':'PROCESS_ROLE_DIELECTRIC'}
        
        self.lineTypes = {'solid':0,
                          'dotted':1,
                          'double dotted':2,
                          'short dash':3,
                          'short dot dash':4,
                          'long dash':5,
                          'long dot dash':6,
                          'Solid':0,
                          'Dotted':1,
                          'Double Dotted':2,
                          'Short Dash':3,
                          'Short Dot Dash':4,
                          'Long Dash':5,
                          'Long Dot Dash':6}
        self.patternTypes = {'solid':18,'Solid':18,'18':18 }
        self.fillTypes = {'Outlined':0,'outline':0,
                          'Filled':1,'filled':1,
                          'Both':2,'both':2}
        self.unitsMap = {'um':'micron',
                         'micron':'micron',
                         'mm':'millimeter',
                         'millimeter':'millimeter',
                         'cm':'centimeter',
                         'centimeter':'centimeter',
                         'meter':'meter',
                         'mil':'mil',
                         'inch':'inch'}
        self.maskNameNbMap = {}
        self.layers = []
        self.layerIds = []
        self.defaultSubstrate = None
        self.substrateList = []
        self.ebondsList = []
        
    def present( self, status=None ):
        if status!=None:
            self.present_=status
        return self.present_
    
    def useAblRoot( self ):
        return self.useAblRoot_

    def getMaskMap( self ):
        return self.maskNameNbMap

    def buildAblData( self, ablNode ):
        eemWriteDebug("Process ABL library data")
        self.present_=True
        if ablNode.tagName == 'abl:ABLRoot':
            self.useAblRoot_=True
        libraryNode=ablNode.getElementsByTagName('abl:Library')[0]
        if libraryNode.hasAttribute('name') and (self.libName=='' or self.libName==None):
            self.libName = libraryNode.getAttribute('name')
        else:
            self.libName = self.name

        techNode=ablNode.getElementsByTagName('abl:Technology')[0]
        self.getRefTechnologies( techNode )
        self.getUnits( techNode )
        self.getLayers( techNode )
        self.getLayerIds( techNode )
        self.getMaterials( techNode )
        self.getSubstrates( techNode )
        self.getPreferences( ablNode )
        self.getEBondProfiles( ablNode )
        if self.libName != self.name:
            libraryNode.setAttribute('name', self.name)

        nestedSubstrateNodes=techNode.getElementsByTagName('abl:NestedSubstrate')
        for nestedSubstrate in nestedSubstrateNodes:
            nestedSubstrate.setAttribute('library', self.name)
            nestedSubstrate.setAttribute('layerMapLib', self.name)
            
        if not ablNode.hasAttribute('xmlns:abl'):
            if self.useAblRoot_:
                ablNode.setAttribute("xmlns:abl", "http://keysight.com/eesof/abl")
            else:
                ablNode.setAttribute("xmlns:abl", "http://agilent.com/abl")
        self.writeAblLibXml(ablNode)
        self.writeAblLibInfo()
        eemWriteDebug("Done: processing ABL library data")
        
    def writeAblLibXml(self, ablNode ):
        fileName = self.fPrefix + '_abl.xml'
        fp = open(fileName, 'w')
        fp.write( '<?xml version="1.0" encoding="UTF-8"?>\n' )
        xmlString = ablNode.toxml()
        fp.write(xmlString)
        fp.write('\n')
        fp.close()
        

    def writeAblLibInfo(self ):
        fileName = self.fPrefix + '_abl.aldf'
        fp = open(fileName, 'w')
        fp.write( 'ABLLIBRARY|%s|UU|%s|DBUTOUU|%s\n' %
                  ( self.name, self.unitsMap[self.userUnits], self.DBUperUU ) )
        fp.write( 'ABLLAYOUTPREFERENCES|PORT_SIZE|%s|ANNOTATION_HEIGHT|%s\n' %
                  ( self.portSize, self.instTextHeight ) )
        for tech in self.refTechnologies:
            fp.write( 'ABLREFTECH|%s\n' % tech )
        fp.write( 'ABLREFTECHEND\n' )
        fp.write( 'ABLLAYERSSTART|layername|layernumber|process_role\n' )
        for layer in self.layers:
            fp.write( 'ABLLAYERS|%s|%s|%s\n' % layer )
        fp.write( 'ABLLAYERSEND\n' )
        fp.write( 'ABLLAYERIDSTART|layer|purpose\n' )
        for layerId in self.layerIds:
            data='ABLLAYERID'
            for (key,value) in layerId.iteritems():
                data += '|' + str(key) + '|' + str(value)
            data += '\n'
            fp.write( data )
        fp.write( 'ABLLAYERIDEND\n' )
        fp.write( 'ABLMATERIALS|materials.matdb|%s\n' % os.path.join( self.targetDir, 'materials.matdb' ))
        for substrate in self.substrateList:
            substrateName = substrate + '.subst'
            fp.write( 'ABLSUBSTRATEFILE|%s|%s\n' % (substrateName, os.path.join( self.targetDir, substrateName )))
        fp.write( 'ABLLIBRARYDEFAULTSUBSTRATE|%s\n' % self.defaultSubstrate )
        fp.write( 'ABLEBONDSTART\n' )
        for ebond in self.ebondsList:
            fp.write( '%s' % ebond )
        fp.write( 'ABLEBONDEND\n' )        
        fp.write( 'ABLLIBRARYEND\n' )
        fp.close()

    def getRefTechnologies( self, techNode ):
        refTechNodes =[]
        if techNode:
            refTechNodes = techNode.getElementsByTagName( 'abl:ReferencedTechnology' )
        for node in refTechNodes:
            if node.hasAttribute( 'referencedLibraryName' ):
                self.refTechnologies.append(node.getAttribute( 'referencedLibraryName' ))

    def getUnits( self, techNode ):
        techUnitsNode = techNode.getElementsByTagName( 'abl:TechUnits' )[0]
        if techUnitsNode == None:
            return
        layoutUnitNode = techUnitsNode.getElementsByTagName( 'abl:LayoutUnits' )[0]
        if layoutUnitNode != None:
            self.userUnits=layoutUnitNode.getAttribute( 'oaUserUnits' )
            self.DBUperUU=layoutUnitNode.getAttribute( 'DBUperUU' )

    def getLayers( self, techNode ):
        layersNode = techNode.getElementsByTagName( 'abl:Layers' )[0]
        if layersNode==None:
            return
        layerNodes = layersNode.getElementsByTagName('abl:Layer' )
        for node in layerNodes:
            name = node.getAttribute('name')
            number = node.getAttribute('number')
            self.maskNameNbMap[name] = number
            processRole = self.processTypes[node.getAttribute('processRole')]
            layerEntry = tuple([name, number, processRole])
            self.layers.append( layerEntry )

    def getLayerIds( self, techNode ):
        layerIdsNode = techNode.getElementsByTagName( 'abl:DisplayProperties' )[0]
        if layerIdsNode==None:
            return
        layerIdNodes = layerIdsNode.getElementsByTagName( 'abl:DisplayProperty' )
        for node in layerIdNodes:
            layerId={}
            layerId['layer'] = node.getAttribute('layer')
            layerId['purpose'] = node.getAttribute('purpose')
            layerId['r'] = node.getAttribute('r')
            layerId['g'] = node.getAttribute('g')
            layerId['b'] = node.getAttribute('b')
            layerId['alpha'] = node.getAttribute('alpha')
            layerId['fill'] = self.fillTypes[node.getAttribute('displayMode')]
            layerId['line'] = self.lineTypes[node.getAttribute('lineType')]
            layerId['pattern'] = self.patternTypes[node.getAttribute('fillType')]
            layerId['visible'] = '1'
            layerId['protected'] = '0'
            self.layerIds.append(layerId)
          
    def getMaterials( self, techNode ):
        materialsNode = techNode.getElementsByTagName( 'abl:Materials' )[0]
        if materialsNode==None:
            return
        eemAdfiAblMaterialWriting( materialsNode, self.targetDir )

    def getSubstrates( self, techNode ):
        substratesNode = techNode.getElementsByTagName( 'abl:Substrates' )[0]
        if substratesNode==None:
            return
        defaultsNode = substratesNode.getElementsByTagName( 'abl:DefaultSubstrate' )[0]
        defaultLib = defaultsNode.getAttribute('library')
        defaultSubstrateName = defaultsNode.getAttribute('name')
        if defaultLib=='__CURRENT__':
            defaultLib = self.name
            defaultsNode.setAttribute('library', self.name)
        self.defaultSubstrate = defaultLib + '|' + defaultSubstrateName
        self.substrateList = writeSubstrates( substratesNode, self.name, self.targetDir )
        
    def getPreferences( self, ablNode ):
        libPrefNodes = ablNode.getElementsByTagName( 'abl:LibraryPreferences' )
        if libPrefNodes==[]:
            return
        libPrefNodes = ablNode.getElementsByTagName( 'abl:LayoutPreferences' )
        if libPrefNodes==[]:
            return        
        prefNodes = libPrefNodes[0].getElementsByTagName( 'abl:FileContents' )
        if prefNodes==[]:
            return
        preferences=getInnerText(prefNodes[0]).splitlines()
        for i in preferences:
            lst=i.split(' ')
            if len(lst)==2:
                name = lst[0]
                value = lst[1]
                if name == 'instTextHeight':
                    self.instTextHeight = value
                elif name == 'portSize':
                    self.portSize = value

    def getEBondProfiles( self, ablNode ):
        ebondNodes = ablNode.getElementsByTagName( 'abl:Instance' )
        if ebondNodes==[]:
            return
        for ebondNode in ebondNodes:
            if ebondNode.getAttribute('cellName')!='EBOND_Shape':
                continue
            ebondEntry = 'ABLEBOND|' + ebondNode.getAttribute('instanceName')
            parmNodes = ebondNode.getElementsByTagName( 'abl:Parameter' )
            for parmNode in parmNodes:
                name = parmNode.getAttribute('name')
                value = parmNode.getAttribute('value')
                if name.startswith(('rT','tT','vT','rZ','tZ','vZ')):
                    ebondEntry+= '|' + str(name) + '|' + str(value)
            ebondEntry += '\n'
            self.ebondsList.append(ebondEntry)
            
        

def eemAdfiAblMaterialWriting( iMaterialsNode, targetDir ):
    filename = os.path.join( targetDir, 'materials.matdb')
    file = open( filename, "w" )
    file.write( '<!DOCTYPE Materials>\n' )
    xmlString = iMaterialsNode.toxml()
    xmlString = xmlString.replace( 'abl:', '' )
    file.write(xmlString)
    file.write('\n')
    file.close()


class eemAdfiAblSubstWriter:
    def __init__( self, iLibName='', iStackName=None, iTargetDir=None ):
        self.name = iStackName
        self.libName = iLibName
        targetDir = iTargetDir
        if targetDir==None or targetDir=='':
            targetDir='.'
        filename = os.path.join( targetDir, iStackName + '.subst' )
        self.file = open( filename, "w" )
        self.file.write( '<!DOCTYPE Substrate>\n<SubstrateModel>\n' )

    def close( self ):
        self.file.write( '</SubstrateModel>\n' )
        self.file.close()

    def writeStack( self, iStackNode ):
        xmlString = iStackNode.toxml()
        xmlString = xmlString.replace( 'abl:', '' )
        xmlString = xmlString.replace( 'SubStack', 'stack' )
        xmlString = xmlString.replace( 'SubMaterial', 'material' )
        xmlString = xmlString.replace( 'SubInterface', 'interface' )
        self.file.write( xmlString )
        self.file.write( '\n' )
        
    def writeLayers( self, iLayersNode ):
        xmlString = iLayersNode.toxml()
        xmlString = xmlString.replace('abl:SubLayer', 'layer')
        self.file.write( xmlString )
        self.file.write( '\n' )

    def writeVias( self, iViaNode ):
        xmlString = iViaNode.toxml()
        xmlString = xmlString.replace( 'abl:SubVia', 'via' )
        self.file.write( xmlString )
        self.file.write( '\n' )

    def writeNestedSubstrates(self, iNestedSubstrates):
        xmlString = iNestedSubstrates.toxml()
        xmlString = xmlString.replace('abl:NestedSubstrate', 'substrate')
        xmlString = xmlString.replace('__CURRENT__', self.libName)
        self.file.write( xmlString )
        self.file.write( '\n' )

def writeSubstrates(iSubstratesNode, iLibName, targetDir):
    stackList=[]
    elements = iSubstratesNode.getElementsByTagName('abl:Substrate')
    for el in elements:
        if el.hasAttribute('name'):
            stackName = el.getAttribute('name')
            currentStack = eemAdfiAblSubstWriter( iLibName, stackName, targetDir )
            stackNode = el.getElementsByTagName( 'abl:SubStack' )[0]
            currentStack.writeStack( stackNode )
            layersNode = el.getElementsByTagName( 'abl:SubLayers' )[0]
            currentStack.writeLayers( layersNode )
            viasNode = el.getElementsByTagName( 'abl:SubVias' )[0]
            currentStack.writeVias( viasNode )
            nestedSubstratesNode = el.getElementsByTagName( 'abl:NestedSubstrates' )
            if nestedSubstratesNode:
                currentStack.writeNestedSubstrates( nestedSubstratesNode[0] )
            currentStack.close()
            stackList.append(stackName)
    return stackList


            
    

##########################################################
# Load and parse adfi file using mindom parser
# 
def eemAdfiReadFile(iAdfiFilename):
    # load content 
    try:
        eemWriteDebug("Filename is: %s" % iAdfiFilename)
        f = open(iAdfiFilename,"r")
        content = ''.join(f.readlines())
        f.close()
    except:
        eemWriteError("Can not read from ADS ADFI file: %s" % iAdfiFilename)
        raise

    # remove unnecessary white space
    content = re.sub('>\s+<','><',content)
    
    # xml dom
    eemWriteDebug("Parse ADS ADFI file document")
    try:
        eemAdfiDom = xml.dom.minidom.parseString(content)
    except:
        eemWriteError("Problem with xml.dom.minidom parser: need to exit")
        raise
    return eemAdfiDom



def eemAdfiProcessCollect(iAdfiDoc, iFprefix, iAdfiInfo, iAdfiTechData, iAdfiEgsWriter, iAdfiLayers, iAblLibInfo,targetPlatform='ads'):
    """ First pass through file using pulldom mechanism """
    
    parser=xml.sax.make_parser()
    # skip external dtd definition
    parser.setFeature(xml.sax.handler.feature_external_ges,0)
    # limit parser memory to about 1GByte
    events = xml.dom.pulldom.parse(iAdfiDoc,parser,1024*1024*16)

    inComponent=None
    top=None
    cmpName=None
    name=None
    egsHeader=''
    for (event,node) in events:
        if (event==xml.dom.pulldom.START_ELEMENT
            and node.localName=='AdfiToAds'):
            iAdfiInfo.setAdfiToAdsAttributes(event,node)
            try:
                iAdfiInfo.checkTargetPlatform(targetPlatform)
            except Exception, err:
                eemWriteWarn(str(err))
                if targetPlatform=='empro':
                    eemWriteWarn("!!! This may result in loss of objects during the import.")
                    eemWriteWarn("!!! Please regenerate your .adfi file with EMPro as target platform.")
                pass # currently not critical
        elif event==xml.dom.pulldom.START_ELEMENT and ( node.tagName=='abl:AgilentBoardLink' or node.tagName=='abl:ABLRoot' ):
            events.expandNode(node)
            iAblLibInfo.buildAblData(node)
            
        elif event==xml.dom.pulldom.START_ELEMENT and node.localName=="AdfiComponent":
            cmpName = node.getAttribute('id')
            top = (node.getAttribute('top')=='true')
            if top:
                iAdfiTechData.topName(cmpName)
            inComponent = True
        elif event==xml.dom.pulldom.END_ELEMENT and node.localName=="AdfiComponent":
            cmpName = None
            top = None
            inComponent = None
            name= None

        elif inComponent and event==xml.dom.pulldom.START_ELEMENT and node.localName=='Name':
            events.expandNode(node)
            name = eemFixName(getInnerText(node))

        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='ComponentParms'):
            events.expandNode(node)
            iAdfiEgsWriter.updateFilterEgsMap(node,cmpName)

        elif (inComponent and top
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Units'):
            events.expandNode(node)
            iAdfiInfo.setUnits(node)
              
        elif (inComponent
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Substrate'):
            events.expandNode(node)
            iAdfiTechData.addLtdSlmMap(node,cmpName,top)
            iAdfiLayers.addSubstrateLayerData(node)

        elif inComponent and top and event==xml.dom.pulldom.START_ELEMENT and node.localName=='Instances':
            events.expandNode(node)
            iAdfiTechData.addSubstrateInstanceMap(node)

        elif (inComponent and top
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Geometry2D'
              and node.hasAttribute('geometry2DType')
              and node.getAttribute('geometry2DType')=='egs'
              and node.hasAttribute('geometry2DOp')
              and node.getAttribute('geometry2DOp')=='process'):
            events.expandNode(node)
            egsHeader+=getInnerText(node)
            iAdfiLayers.addEgsProcess(egsHeader)
            iAdfiEgsWriter.writeHeader(egsHeader)
            
        elif (inComponent and top
              and event==xml.dom.pulldom.START_ELEMENT
              and node.localName=='Ports'):
            events.expandNode(node)
            try:
                fName = iFprefix + '_top.prt'
                eemWriteDebug("Port Filename is: %s" % fName)
                eemAdfiWritePortFile(fName, node)
            except Exception, err:
                eemWriteError("Problem processing definitions of ports on top level: need to exit")
                eemWriteError('ERROR: %s\n' % str(err))
                raise
            # process pins and ports on top level and write out .pin and .prt file
            try:
                fName = iFprefix + '_top.pin'
                eemWriteDebug("Pin Filename is: %s" % fName)
                eemAdfiWritePinFile(fName, node, iAdfiInfo)
            except Exception, err:
                eemWriteError("Problem processing definitions of pins on top level: need to exit")
                eemWriteError('ERROR: %s\n' % str(err))
                raise



##########################################################
# process adfi file
# 
def eemAdfiProcessFile(iAdfiFilename,targetDir=None,useJedecBondwires=False,useSolderBalls=False,bwMap=None,sbMap=None,targetPlatform='ads', oaLibName=None ):
    """Load and parse adfi file for use in ADS and EMPro"""

    fprefix = os.path.splitext(iAdfiFilename)[0]
    if (targetDir != None):
        fprefix = os.path.join(targetDir,os.path.basename(fprefix))
    adfiPrefix = fprefix + '_adfi'
    if oaLibName==None:
        oaLibName=os.path.basename(fprefix)+ '_lib'

    eemAdfiInfo=AdfiInfo()
    eemAdfiTechData=AdfiLtds(fprefix)
    eemAdfiEgsWriter=AdfiEgsWriter( adfiPrefix + '_egs',
                                    useSolderBalls )
    eemAdfiLayers=AdfiLayers(adfiPrefix)
    eemAblLibInfo=AdfiAblLibInfo(targetDir, adfiPrefix, oaLibName)
    
    try:
        eemAdfiProcessCollect(iAdfiFilename, fprefix, eemAdfiInfo, eemAdfiTechData, eemAdfiEgsWriter, eemAdfiLayers, eemAblLibInfo, targetPlatform)
    except:
        eemWriteError("Problem with initial doc parsing: need to exit")
        raise

    maskNameNbMap={}
    hasAbl=eemAblLibInfo.present()
    useAblRoot=eemAblLibInfo.useAblRoot()
    if hasAbl:
        maskNameNbMap = eemAblLibInfo.getMaskMap()
    else:
        # process LTD information
        try:
            eemAdfiTechData.assembleLtdSlmMaps()
        except:
            eemWriteError("Problem with stack processing: need to exit")
            raise
        maskNameNbMap = getMaskNames(eemAdfiTechData)
        eemWriteDebug("maskNameNbMap : %s" % (str(maskNameNbMap)))


        try:
            eemAdfiLayers.writeLayFile(eemAdfiInfo.mainVersion)
        except:
            pass # not critical
        try:
            eemAdfiLayers.writeDisplayPreferenceFile(eemAdfiInfo.mainVersion)
        except:
            pass # not critical

    eemAdfiHdefWriter=None
    try:
        eemAdfiHdefWriter=AdfiHdefWriter(fprefix,eemAdfiInfo,hasAbl,useAblRoot)
    except:
        eemWriteError("Problem creating hierachical processing file: need to exit")
        raise

    eemAdfiBondWireWriter=None
    try:
        fName = fprefix + '_adfi.dbw'
        eemWriteDebug("Bondwire Filename is: %s" % fName)
        eemAdfiBondWireWriter = bondWireWriter(fName,maskNameNbMap)
    except:
        eemWriteError("Problem creating bondwire file: need to exit")
        raise
    
    try:
        eemAdditionalParms = eemAdfiReadOptParmFile(os.path.splitext(iAdfiFilename)[0])
    except:
        eemAdditionalParms = None
        pass
    
    # process pins, ports and instances in components
    try:
        eemWriteDebug("ADFI Process Hierarchical Definition")
        eemAdfiProcessHDefEgsFile(iAdfiFilename, eemAdfiInfo,
                                  eemAdfiHdefWriter, eemAdfiEgsWriter,
                                  eemAdfiBondWireWriter, eemAdfiTechData,
                                  eemAdditionalParms, maskNameNbMap)
        eemAdfiHdefWriter.close()
        eemAdfiEgsWriter.close()
    except Exception, err:
        eemWriteError("Problem Hierarchical Definition output processing: need to exit")
        eemWriteError('ERROR: %s\n' % str(err))
        raise
    
    # process bondwires
    if (useSolderBalls or
        (useJedecBondwires and bwMap != None)):
        
        adfiDom=None
        
        try:
            eemAdfiDom = eemAdfiReadFile(iAdfiFilename)
        except:
            raise

        if useSolderBalls:
            try:
                eemAdfiBondWireWriter.writeSBDummyBondWires(eemAdfiDom,useSolderBalls,sbMap=sbMap)
            except Exception, err:
                eemWriteError("Problem processing definitions of bondwires: need to exit")
                eemWriteError('ERROR: %s\n' % str(err))
                raise
        if useJedecBondwires and bwMap != None:
            importer = bondwireImporter()
            importer.getBondwireMap(eemAdfiDom,bwComps=bwMap)
    
    eemAdfiBondWireWriter.close()
    eemWriteDebug("ADFI Hierarchical Definition File processed")

    return 1


                   
if __name__=="__main__":
   try:
       if len(sys.argv)==2:
           eemAdfiProcessFile( sys.argv[1] )
       elif len(sys.argv)==3:
           eemAdfiProcessFile( sys.argv[1],sys.argv[2] )
       elif len(sys.argv)==4:
           eemAdfiProcessFile( sys.argv[1], sys.argv[2], oaLibName=sys.argv[3] )
       else:
           print "usage: python $IMPORT_ADFI_ADD_ON/scripts/eemAdfiParse.py <file> [<targetDir> [<oalibName>]]"
           sys.exit(2)
       sys.exit(0)
   except Exception, err:
       eemWriteError('%s\n' % str(err))
       sys.exit(1)

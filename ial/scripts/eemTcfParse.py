#!python
# Copyright Keysight Technologies 2007 - 2018  
# Copyright Keysight Technologies 2007 - 2018  
# All rights reserved.
#
# Process an Allegro 16+ Technology file to extract layer information
#
 

import re
import os
import string
import sys

#enable new logging on recent versions
hversion=sys.hexversion
if hversion >= 0x20401F0:
    import logging

    #setup logging before loading other modules that use logging
    logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)-8s %(message)s',
                    datefmt='%a, %d %b %Y %H:%M:%S',
                    filename='./eemTcfParse.log',
                    filemode='w')
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('Allegro technology file parser: %(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)
    console.flush()

    eemTcfWriteError=logging.error
    eemTcfWriteWarn=logging.warn
    eemTcfWriteInfo=logging.info
    eemTcfWriteDebug=logging.debug
else:
    def eemTcfWriteLog(iType,iMessage):
        sys.stderr.write('%s: %s\n' % (iType,iMessage))
    def eemTcfWriteError(iMessage):
        eemTcfWriteLog('Error',iMessage)
    def eemTcfWriteWarn(iMessage):
        eemTcfWriteLog('Warning',iMessage)
    def eemTcfWriteInfo(iMessage):
        eemTcfWriteLog('Info',iMessage)
    def eemTcfWriteDebug(iMessage):
        eemTcfWriteLog('Debug',iMessage)
    eemTcfWriteWarn('Using stderr for log output')

if hversion < 0x20000F0:
    eemTcfWriteError('Python version not recent enough')
    sys.exit(1)

##############################################################################
# handle relevant properties/attributes of layers for for Allegro DFI 
#
class Layer:
    mapAttribute = { 'CDS_LAYER_IS_NAMED': 'layerIsNamed',
                     'CDS_LAYER_TYPE' : 'layerType',
                     'CDS_LAYER_MATERIAL' : 'layerMaterial',
                     'CDS_LAYER_IS_SHIELD' : 'layerIsShieldFlag',
                     'CDS_LAYER_NEGATIVE_ARTWORK': 'layerArtworkNegativeFlag',
                     'CDS_LAYER_ELECTRICAL_CONDUCTIVITY' : 'layerElectricalConductivity',
                     'uElectricalConductivity' : 'layerElectricalConductivityUnits',
                     'CDS_LAYER_ELECTRICAL_CONDUCTIVITY_UNITS_SCALING': 'layerElectricalConductivityUnitsScaling',
                     'CDS_LAYER_DIELECTRIC_CONSTANT': 'layerDielectricConstant',
                     'CDS_LAYER_LOSS_TANGENT': 'layerLossTangent',
                     'CDS_LAYER_THICKNESS': 'layerThickness',
                     'CDS_LAYER_THICKNESS_UNITS': 'layerThicknessUnits' }
    RequireStringOutput = ['layerMaterial','layerName','layerElectricalConductivityUnits']
    
    def __init__(self,iNumber=0,iName="Unknown"):
        self.layerNumber = iNumber
        self.layerName = iName
        self.attribute = {}
#         self.attribute['layerIsNamed'] = "0" 
#         self.attribute['layerType'] = ""
#         self.attribute['layerMaterial'] = ""
#         self.attribute['layerIsShieldFlag'] = "FALSE"
#         self.attribute['layerArtworkNegativeFlag'] = "FALSE"
#         self.attribute['layerElectricalConductivity'] = "0"
#         self.attribute['layerElectricalConductivityUnits'] = "mho/cm"
#         self.attribute['layerElectricalConductivityUnitsScaling'] = "1.0"
#         self.attribute['layerDielectricConstant'] = "1.0"
#         self.attribute['layerLossTangent'] = "0.0"
#         self.attribute['layerThickness'] = "0.0"
#         self.attribute['layerThicknessUnits'] = "m"
        
    def addAttribute(self,iKey,iValue):
        self.attribute[iKey] = iValue
        return 1

    def getAttribute(self,iKey):
        if iKey in self.attribute:
            return self.attribute[iKey]
        else:
            return None

    def skillListString(self):
        s = '(layer %d \n' % self.layerNumber
        s = s + ' (layerName "%s")\n' % self.layerName
        for key, value in self.attribute.iteritems():
            if key in Layer.RequireStringOutput:
                s = s + ' (%s "%s")\n' % (key,value)
            else:
                s = s + ' (%s %s)\n' % (key,value)
        s = s + ')\n'
        return s

##############################################################################
# parsing using Python's xml.dom.minidom module
#
import xml.dom.minidom 

def eemTcfGetNamedNode(iNamedNode,iTag='name'):
    if ((iNamedNode.tagName == iTag) and
        (iNamedNode.hasChildNodes()) and
        (iNamedNode.childNodes.length == 1) and
        (iNamedNode.firstChild.nodeType == xml.dom.minidom.Element.TEXT_NODE)):
        eemTcfWriteDebug("Process a %s node" % iTag)        
        return str(iNamedNode.firstChild.nodeValue)
    else:
        eemTcfWriteWarn("Expected %s node" % iTag )
        return None

def eemTcfGetAttribute(attribNode):
    if (( attribNode.tagName == 'attribute' ) and
        (attribNode.hasChildNodes())):
        eemTcfWriteDebug("Process attribute node")        
        attribName = ''
        attribValue =  ''
        attribUnits = ()
        for node in attribNode.childNodes:
            if node.tagName == 'name':
                attribName = eemTcfGetNamedNode(node)
            elif node.tagName == 'value':
                attribValue = eemTcfGetNamedNode(node,'value')
            elif node.tagName == 'Units':
                attribUnits = eemTcfGetUnits(node)
            else:
                pass
        return attribName, attribValue, attribUnits
    else:
        eemTcfWriteWarn("Expected Allegro Technology File attribute")
        return None

def eemTcfGetUnits(iUnitsNode):
    if ((iUnitsNode.tagName == 'Units') and
        (iUnitsNode.hasChildNodes()) and
        (iUnitsNode.childNodes.length == 3)):
        eemTcfWriteDebug("Process Units node")        
        node = iUnitsNode.firstChild
        unitType = eemTcfGetNamedNode(node,'type')
        node = node.nextSibling
        unitName = eemTcfGetNamedNode(node,'name')
        node = node.nextSibling
        unitScaling = eemTcfGetNamedNode(node,'scaling')
        return unitType,unitName,unitScaling
    else:
        eemTcfWriteWarn("Expected Allegro Technology File unit representation")        
        return None

def eemTcfProcessLayer(iLayerNum,iLayerNode):
    if not(iLayerNode.hasChildNodes()):
        return None
    else:
        node=iLayerNode.firstChild
        if node.tagName=='name':
            layerObj = Layer(iLayerNum,eemTcfGetNamedNode(node))
        else:
            eemTcfWriteWarn("Expected layer name first")
            return None
        for node in iLayerNode.childNodes[1:]:
            (cdsName, value, units) = eemTcfGetAttribute(node)
            aName=Layer.mapAttribute.get(cdsName,None)
            if aName != None:
                layerObj.addAttribute(aName,value)
                if units != ():
                    cdsType,cdsName,cdsScaling = units
                    uName= aName + 'Units'
                    layerObj.addAttribute(uName,cdsName)
                    uName= uName + 'Scaling'
                    layerObj.addAttribute(uName,cdsScaling)
        return layerObj

def eemTcfMiniDomParse(iContent):
    eemTcfWriteDebug("Use Python xml.dom.minidom parser")
    dom = xml.dom.minidom.parseString(iContent)

    eemTcfWriteDebug("Pick up cross section")
    crossSection = dom.getElementsByTagName("crossSection")
    if len(crossSection)!=1:
        eemTcfWriteWarn("Expect only one 1 crossSection tag")
        return None
    layerNodes = crossSection.item(0).getElementsByTagName("layer")
    eemTcfWriteDebug("Process the layer nodes in cross section definition")
    eemTcfLayers = []
    for layerNum,layerNode in enumerate(layerNodes):
        eemTcfLayers.append(eemTcfProcessLayer(layerNum, layerNode))
    dom.unlink()
    return eemTcfLayers

##############################################################################
# alternative parsing only using regular expressions 
#
def eemTcfNextElementByTagName(iContent,iTag='.*?',match=False):
    if ((iContent == None) or
        (len(iContent) == 0)):
       return (itag,None,None)
   
    reAnsw='<(?P<tag>' + iTag + ')>(?P<elem>.*?)</(?P=tag)>(?P<end>.*)|<(?P<etag>' + iTag + ')/>(?P<eend>.*)'
    regExp=re.compile(reAnsw)
    if match:
        reSearch=regExp.match(iContent)
    else:
        reSearch=regExp.search(iContent)
    if reSearch==None:
        return (iTag,None,None)
    if reSearch.group('etag'):
        return (reSearch.group('etag'),None,reSearch.group('eend'))
    if reSearch.group('tag'):
        return (reSearch.group('tag'),reSearch.group('elem'),reSearch.group('end'))
    
def eemTcfFindElementsByTagName(iContent,iTag='.*?'):
    if ((iContent == None) or
        (len(iContent) == 0)):
        return (itag,None)
    reList=[]
    try:
        reAnsw='<(?P<tag>' + iTag + ')>(?P<elem>.*?)</(?P=tag)>|<(?P<etag>' + iTag + ')/>'
        regExp=re.compile(reAnsw)
        reList=regExp.findall(iContent)
    except:
        eemTcfWriteDebug("Simple elements code failed: last resort use emergency regexp code\n")
        reAnsw='<(?P<stag>' + iTag + ')>|</(?P<ftag>' + iTag + ')>|<(?P<etag>' + iTag + ')/>'
        regExp=re.compile(reAnsw)
        reString=regExp.finditer(iContent)
        inside=-1
        startPos=0
        startTag=''
        for s in reString:
            if inside==-1:
                if s.group('stag'):
                    startTag=s.group('stag')
                    startpos=s.end()+2
                    inside=1
                elif s.group('etag'):
                    reList.append((s.group('etag'),'',None))
                    startPos=s.end('etag')+3
                elif s.group('ftag'):
                    eemTcfWriteDebug("Start tag %s not seen" % s.group('ftag'))
                    inside=-1
                    startTag=''
                    startPos=s.end('ftag')+2
                else:
                    eemTcfWriteDebug("Illegal data: empty match found")               
            elif inside==1:
                if ((s.group('ftag')) and
                    (s.group('ftag')==startTag)):
                    tupple=(startTag,iContent[startPos:(s.start('ftag')-2)],None)
                    reList.append(tupple)
                    startPos=s.end('ftag')+2
                    startTag=''
                    inside=-1
                elif s.group('stag') or  s.group('etag'):
                    eemTcfWriteDebug("Don't support nested tags")
                else:
                    eemTcfWriteDebug("Illegal data: empty match found")
    return reList

def eemTcfReGetAttribute(iAttrib):
    if iAttrib[0] == 'attribute':
        eemTcfWriteDebug("Process attribute node")        
        attribName = ''
        attribValue =  ''
        attribUnits = ()
        childNodes=eemTcfFindElementsByTagName(iAttrib[1],iTag=r'.*?')
        for node in childNodes:
            if node[0] == 'name':
                attribName = node[1]
            elif node[0] == 'value':
                attribValue = node[1]
            elif node[0] == 'Units':
                attribUnits = eemTcfReGetUnits(node)
            else:
                pass
        return attribName, attribValue, attribUnits
    else:
        eemTcfWriteWarn("Expected Allegro Technology File attribute")
        return None

def eemTcfReGetUnits(iUnitsNode):
    if iUnitsNode[0] == 'Units':
        eemTcfWriteDebug("Process Units node")        
        unitType = ''
        unitType =  ''
        attribUnits = ()
        childNodes=eemTcfFindElementsByTagName(iUnitsNode[1],iTag=r'.*?')
        for node in childNodes:
            if node[0] == 'type':
                unitType = node[1]
            elif node[0] == 'name':
                unitName = node[1]
            elif node[0] == 'scaling':
                unitScaling = node[1]
            else:
                pass
        return unitType,unitName,unitScaling
    else:
        eemTcfWriteWarn("Expected Allegro Technology File unit representation")        
        return None

def eemTcfReProcessLayer(iLayerNum,iLayerNode=('','','layer')):
    if iLayerNode[2]:
        return None
    else:
        element=iLayerNode[1]
        nameNode=eemTcfNextElementByTagName(element,iTag='name',match=True)
        if nameNode[0]=='name':
            layerObj = Layer(iLayerNum,nameNode[1])
        else:
            eemTcfWriteWarn("Expected layer name first")
            return None
        
        attributesNode=eemTcfFindElementsByTagName(nameNode[2],'attribute')
        for node in attributesNode:
            (cdsName, value, units) = eemTcfReGetAttribute(node)
            aName=Layer.mapAttribute.get(cdsName,None)
            if aName != None:
                layerObj.addAttribute(aName,value)
                if units != ():
                    cdsType,cdsName,cdsScaling = units
                    uName= aName + 'Units'
                    layerObj.addAttribute(uName,cdsName)
                    uName= uName + 'Scaling'
                    layerObj.addAttribute(uName,cdsScaling)
        return layerObj

def eemTcfRegExpParse(iContent):
    eemTcfWriteDebug("Process using simple regular expressions based parsing")    
    eemTcfWriteDebug("Pick up cross section")
    crossSection = eemTcfFindElementsByTagName(iContent,"crossSection")
    if len(crossSection)!=1:
        eemTcfWriteWarn("Expected 1 crossSection tag")
        return []
    if crossSection[0][2]:
        eemTcfWriteWarn("Expected 1 nonempty crossSection tag")
    layerNodes = eemTcfFindElementsByTagName(crossSection[0][1],"layer")
    eemTcfWriteDebug("Process the layer nodes in cross section definition")
    eemTcfLayers = []
    layerNum=0
    for layerNode in layerNodes:
        eemTcfLayers.append(eemTcfReProcessLayer(layerNum, layerNode))
        layerNum=layerNum+1
    return eemTcfLayers

##############################################################################
# Process an Allegro 16+ Technology file to extract layer information
#

def eemTcfProcessFile(iTcfFilename,iLayerFilename):

    try:
        eemTcfWriteDebug("filename is: %s" % iTcfFilename)
        f = open(iTcfFilename,"r")
    except:
        eemTcfWriteWarn("Can not read from Allegro Technology file: %s" % iTcfFilename)
        return 0
    # load content 
    content = ''.join(f.readlines())
    f.close()
    
    # remove unnecessary white space
    content = re.sub('>\s+<','><',content)
    
    eemTcfWriteDebug("Parse technology file document")
    try:
        eemTcfLayers=eemTcfMiniDomParse(content)
    except:
        eemTcfWriteWarn("Problem with xml.dom.minidom parser: try re only based parser")
        eemTcfLayers=eemTcfRegExpParse(content)

    if eemTcfLayers == None:
        eemTcfWriteWarn("Can not write to %s" % iLayerFilename)
        return 0
    eemTcfWriteDebug("Write output the layers file")
    try:
        eemTcfWriteDebug("filename is: %s" % iLayerFilename)
        f = open(iLayerFilename,"w")
    except:
        eemTcfWriteWarn("Can not write processed layers file %s" % iLayerFilename)
        return 0
    f.write('(crossSection \n')
    for l in eemTcfLayers:
        f.write(l.skillListString())
    f.write(')\n')
    f.close()
    return 1

if len(sys.argv)==3:
    if eemTcfProcessFile(sys.argv[1],sys.argv[2]) == 1:
        sys.exit(0)
    else:
        sys.exit(1)
else:
    print "usage: python eemTcfParse.py <file1> <file2>"
    sys.exit(2)

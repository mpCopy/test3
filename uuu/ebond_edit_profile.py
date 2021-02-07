# Copyright Keysight Technologies 2014 - 2017  
#
# This calls the EMPro bondwire profile editor to create or update an EBOND compatible bondwire shape for ADS. 
# The scripting capability of EMPro is used to serialize an EMPro bondwire definition and process it into
# a form that the AEL component creation code for an ADS EBOND profile can handle.
#
import empro
import sys
import os
import string
import math
import xml.dom.minidom

ebondShapeDefault_string = u'''
<!DOCTYPE BondwireDefinitionDoc>
<BondwireDefinitionDoc>
    <BondwireDefinition sname="Default JEDEC" TrueCircle="false">
    <Radius><Formula typeid="10" type="String" value="0.5 mil"/></Radius>
    <NumFaces><Formula typeid="2" type="Int" value="6"/></NumFaces>
    <Vertices>
      <Vertex tUnitClass="ANGLE" tReference="Begin" zUnitClass="SCALAR" zReference="Begin">
        <dt><Formula typeid="10" type="String" value="60 deg"/></dt>
        <dz><Formula typeid="10" type="String" value="0.30"/></dz>
      </Vertex>
      <Vertex tUnitClass="SCALAR" tReference="Previous" zUnitClass="SCALAR" zReference="Previous">
        <dt><Formula typeid="10" type="String" value="0.125"/></dt>
        <dz><Formula typeid="2" type="Int" value="0"/></dz>
      </Vertex>
      <Vertex tUnitClass="SCALAR" tReference="End" zUnitClass="ANGLE" zReference="End">
        <dt><Formula typeid="10" type="String" value="0.50"/></dt>
        <dz><Formula typeid="10" type="String" value="15 deg"/></dz>
      </Vertex>
    </Vertices>
    </BondwireDefinition>
<ADSBondDefinition>testtingtest</ADSBondDefinition>
</BondwireDefinitionDoc>\
'''

class adsVarNetlistWriter:
    def __init__(self, fname="netlist.nlog", shapename="JEDEC", bonddef_string=ebondShapeDefault_string):
        self.file = open( fname, "w" )
        self.shapename = str(shapename)
        self.dom = xml.dom.minidom.parseString(bonddef_string)
        
    def getValue(self, itag='Radius', iNode=None):
        attr = 'value'
        elTag=None
        if iNode:
            elTag = iNode.getElementsByTagName(itag)
        else:
            elTag = self.dom.getElementsByTagName(itag)
        elFormula = elTag[0].getElementsByTagName('Formula')
        if elFormula[0].hasAttribute(attr):
            return elFormula[0].getAttribute(attr)
        
    def write(self):
        rw=self.getValue('Radius')
        rw=rw.strip()
        if rw[-2:]==' m':
            rw=rw.replace(' m', ' meter')

        numFaces = self.getValue('NumFaces')
        netlist  = 'BWSHAPE|NAME=' + self.shapename + '|INSTANCE=Shape|MATERIAL=Gold|COND=4.1e7|RW=' + str(rw)
        netlist += '|ER=1.0|HEIGHT1=200 um|HEIGHT2=200 um|GNDHEIGHT=0 um|LENGTH=500 um|LAYER1=1|LAYER2=1|GNDLAYER=2|DRAWLAYER=6|VIEW=1'
        netlist += '|NUMFACES=' + str(numFaces) + '|ANNOTATELAYER=6|ANNOTATEHEIGHT=10'
        elVerts = self.dom.getElementsByTagName('Vertex')
        i=1
        for elVert in elVerts:
            tType = 'ST'
            tUnitClass = elVert.getAttribute('tUnitClass')
            dt = self.getValue('dt',elVert)
            dt = dt.strip()
            if tUnitClass=='LENGTH':
                tType = 'DL'
                if dt[-2:]==' m':
                    dt = dt.replace(' m', ' meter') # m is behaving as 1.e-3 in ADS, meter is used instead
            elif tUnitClass=='ANGLE':
                tType = 'AT'
                # need to be degrees for ADS without unit
                if dt[-4:]==' deg':
                    dt = dt.replace(' deg','')
                else:
                    try:
                        val = float(dt)
                        dt = val*180.0/math.pi
                    except:
                        pass
            elif tUnitClass=='SCALAR':
                if dt[-3:]=='pct':
                    dt = dt.replace('pct','') # pct is not a known unit in ADS
                    val = float(dt) * .01
                    dt = val
                
            tReference=elVert.getAttribute('tReference')[0]
            
            zType = 'ST'
            zUnitClass = elVert.getAttribute('zUnitClass')
            dz = self.getValue('dz',elVert)
            dz = dz.strip()
            if zUnitClass=='LENGTH':
                zType = 'DL'
                if dz[-2:]==' m':
                    dz = dz.replace(' m', ' meter')
            elif zUnitClass=='ANGLE':
                zType = 'AT'
                # need to be degrees for ADS without unit
                if dz[-4:]==' deg':
                    dz = dz.replace(' deg','')
                else:
                    try:
                        val = float(dz)
                        dz = val * 180.0/math.pi
                    except:
                        pass
            elif zUnitClass=='SCALAR':
                if dz[-3:]=='pct':
                    dz = dz.replace('pct','') # pct is not a known unit in ADS
                    val = float(dz) * .01
                    dz = val

            zReference = elVert.getAttribute('zReference')[0]
            netlist += '|PT='
            netlist += tReference + '=' + tType + '=' + str(dt)
            netlist += "=" + zReference + '=' + zType + '=' + str(dz)
            i += 1
        netlist += '|END'
        self.file.write(netlist)
            
    def close(self):
        self.file.close()

bonddef_string=''
shapeName=''
if len(sys.argv)!=3:
    exit(1)
    
shapename = sys.argv[1]
fname = sys.argv[2]
if os.path.isfile(fname):
    try:
        f=open(fname, 'r')
        bonddef_string = string.join(f.readlines())
        f.close()
    except:
        raise 
else:
    bonddef_string = ebondShapeDefault_string.replace("JEDEC", 'for ' + str(shapename))
        
bonddef = empro.geometry.BondwireDefinition.deserialize(bonddef_string)

app = empro.gui.BaseApp()
app.init(sys.argv)

dialog = empro.gui.SimpleDialog()
dialog.windowTitle = "Bondwire Profile Definition Editor"

editor = empro.gui.BondwireDefinitionEditor(bonddef, None)
dialog.layout.add(editor)

accepted = False
def onFinished(rc):
    global accepted
    accepted |= (rc == 1)
dialog.onFinished = onFinished

dialog.show(True)

adsFname=fname + '.nlog'
if accepted:
    bonddef_string = bonddef.serialize()
    try:
        f=open(fname, 'w')
        f.write(bonddef_string)
        f.close()
        netlistWriter = adsVarNetlistWriter(adsFname, shapename, bonddef_string)
        netlistWriter.write()
        netlistWriter.close()
    except:
        raise
    sys.exit(0)

if os.path.isfile(adsFname):
    os.remove(adsFname)
if os.path.isfile(fname):
    os.remove(fname)
sys.exit(1)

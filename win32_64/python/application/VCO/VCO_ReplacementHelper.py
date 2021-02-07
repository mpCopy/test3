# Copyright Keysight Technologies 2005 - 2015  
from Component import *
from Design import *
from VCO_Descriptor import *
from VCO import *

class VCO_ReplacementHelper:
    def __init__(self,modelExtractor):
        self.modelExtractor = modelExtractor
        self.parentNetwork    = self.modelExtractor.parentNetwork
        self.delayEqn   = None
        self.freqEqn    = None
        self.vtuneEqn   = None

        self.oscFreqEqn = None
        self.oscVpEqn   = None
        self.oscVnEqn   = None
        self.oscVEqn    = None

        self.aEqn       = None
        self.bEqn       = None
        self.iFundEqn   = None
        self.iTuneEqn   = None
        self.swonEqn    = None
        self.fswEqn     = None

        self.pn_dbEqn   = None 
        self.pn2Eqn     = None
        
    def setup(self):
        self.__setupEquations()
        self.__setupModel()
        return True
    
    def __setupEquations(self):
        data = self.modelExtractor.data        
        self.delayEqn = DesignEquation(None,"timestep")
        self.vtuneEqn = DesignEquation(None,"_sv(__fdd_v,1,0)")
        self.freqEqn  = DesignEquation(None,str(data[freqID]))
                
        self.parentNetwork.addEquation(self.delayEqn)
        self.parentNetwork.addEquation(self.freqEqn)
        self.parentNetwork.addEquation(self.vtuneEqn)
                
        self.oscFreqEqn = DesignEquation(None,"dsexpr('freq','"+self.modelExtractor.datasetName+"')")
        self.oscVpEqn   = DesignEquation(None,"dsexpr('"+self.modelExtractor.voutPlusNodeName+"','"+self.modelExtractor.datasetName+"')")
        self.oscVnEqn   = DesignEquation(None,"dsexpr('"+self.modelExtractor.voutMinusNodeName+"','"+self.modelExtractor.datasetName+"')")
         
        self.parentNetwork.addEquation(self.oscFreqEqn)
        self.parentNetwork.addEquation(self.oscVpEqn)
        self.parentNetwork.addEquation(self.oscVnEqn)

        expression = "access_data('Linear',"+self.oscFreqEqn.getName()+",'"+sweepName+"',"+self.vtuneEqn.getName() +",'harmindex',1)"
        self.oscFreqEqn = DesignEquation(None,expression)

        expression = "access_data('Linear',"+self.oscVpEqn.getName()+",'"+sweepName+"',"+self.vtuneEqn.getName() +",'harmindex',1)"
        self.oscVpEqn = DesignEquation(None,expression)

        expression = "access_data('Linear',"+self.oscVnEqn.getName()+",'"+sweepName+"',"+self.vtuneEqn.getName() +",'harmindex',1)"
        self.oscVnEqn = DesignEquation(None,expression)
        self.parentNetwork.addEquation(self.oscFreqEqn)
        self.parentNetwork.addEquation(self.oscVpEqn)
        self.parentNetwork.addEquation(self.oscVnEqn)
        self.oscVEqn = DesignEquation(None,self.oscVpEqn.getName()+"-"+self.oscVnEqn.getName())
        self.parentNetwork.addEquation(self.oscVEqn)
        
        
        if self.modelExtractor.data[noiseID]:
            pnmxName = self.modelExtractor.voutPlusNodeName+"_minus_"+self.modelExtractor.voutMinusNodeName+".pnmx"
            self.pnEqn      = DesignEquation(None,"dsexpr('"+pnmxName+"','"+self.modelExtractor.datasetName+"')")
            self.parentNetwork.addEquation(self.pnEqn)
            expression = "access_data('Cubic',"+self.pnEqn.getName()+",'"+sweepName+"',"+self.vtuneEqn.getName() +",'noisefreq',noisefreq)"
            self.pnEqn = DesignEquation(None,expression)
            self.parentNetwork.addEquation(self.pnEqn)
            expression = "sqrt(2)*10^("+self.pnEqn.getName()+"/20.0)"
            self.pn2Eqn = DesignEquation(None,expression)
        else:
            self.pnEqn      = 0
            self.pn2Eqn     = 0

        self.aEqn = DesignEquation(None,"-j*"+self.oscVEqn.getName())
        self.bEqn = DesignEquation(None,"1000*_sv_d(__fdd_v,3,"+self.delayEqn.getName()+",0)")
        self.parentNetwork.addEquation(self.aEqn)
        self.parentNetwork.addEquation(self.bEqn)
        expression = self.aEqn.getName()+"*exp(j*("+self.bEqn.getName()+"+_sv(__fdd_v,5,0)))/50.0"

        self.iFundEqn = DesignEquation(None,expression)
        expr = "if(time>0)then"
        expr += "(0.001*2*pi*timestep*("+self.freqEqn.getName()+"-"+self.oscFreqEqn.getName()+"))else"
        expr += "(tinyreal*"+self.vtuneEqn.getName()+")endif"
        self.iTuneEqn = DesignEquation(None,expr)

        self.swonEqn = DesignEquation(None,"if(time>0)then(1)else(0)endif")
        self.parentNetwork.addEquation(self.swonEqn)

        self.fswEqn = DesignEquation(None,"_v1*(1-"+self.swonEqn.getName()+")+_i1*"+self.swonEqn.getName())
        return True

    def __setupModel(self):
        n1 = self.modelExtractor.parentNetwork.getNumberOfNodes() + 1
        n2 = n1 + 1
        nodeVt = self.modelExtractor.nodes[0]
        nodeVp = self.modelExtractor.nodes[1]
        nodeVn = self.modelExtractor.nodes[2] 
        timeStepEqn = DesignEquation(None,"timestep")

        oscFreqRatioEqn = DesignEquation(None,"-"+self.oscFreqEqn.getName()+"/(1.0e9)")

        freq1Eqn = DesignEquation(None,self.freqEqn.getName())
        parameters = {"I[1,0]":0,
                      "I[2,-1]":self.iFundEqn,
                      "I[3,0]":self.iTuneEqn,
                      "I[4,0]":oscFreqRatioEqn,
                      "I[5,0]":0.0,
                      "Freq[1]":freq1Eqn}
        
        r1  = Device("R",[nodeVn,0],{"R":1,"Noise":False})
        r2  = Device("R",[nodeVp,0],{"R":50.0,"Noise":False})
        c1  = Device("C",[n1,0],{"C":timeStepEqn})
        fdd = Device("FDD",[nodeVt,0,nodeVp,0,n1,0,nodeVn,0,n2,0],parameters)
        sdd = Device("SDD",[n1,0],{"F[1,0]":self.fswEqn})
        vn  = Device("V_Source",[n2,0],{"V_Noise":self.pn2Eqn,"SaveCurrent":True})
         
        self.parentNetwork.addDevice(r1)
        self.parentNetwork.addDevice(r2)
        self.parentNetwork.addDevice(c1)
        self.parentNetwork.addDevice(fdd)
        self.parentNetwork.addDevice(sdd)
        self.parentNetwork.addDevice(vn)
        self.parentNetwork.setup()

        return True

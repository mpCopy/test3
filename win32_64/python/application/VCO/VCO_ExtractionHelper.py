# Copyright Keysight Technologies 2005 - 2015  
from Component import *
from Design import *
from VCO_Descriptor import *
from VCO import *
prefix            = "__BME__VCO__"
vtuneName         = prefix + "Vtune"
voutMinusNodeName = prefix + "Vm"
voutPlusNodeName  = prefix + "Vp"
hbAnalysisName    = prefix + "HB"
vsourceName       = prefix + "vsource"
sweepName         = vsourceName + ".Vdc"

class VCO_ExtractionHelper:
    def __init__(self,modelExtractor):
        self.modelExtractor = modelExtractor
        self.network        = self.modelExtractor.network
        self.vtuneEqn       = None
        self.vtuneStartEqn  = None
        self.vtuneStopEqn   = None
        self.vtuneStepEqn   = None
        self.freqEqn        = None
        self.orderEqn       = None
        self.vsource        = None
       

    def setup(self):
        self.__setupEquations()
        self.__setupExcitation()
        self.__setupAnalysis()
        return True
    
    def __setupEquations(self):
        data = self.modelExtractor.data
        self.freqEqn       = DesignEquation(None,str(data[freqID]))
        self.orderEqn      = DesignEquation(None,str(data[orderID]))
        self.vtuneEqn      = DesignEquation(vtuneName,str(data[vtune_StartID]))
        self.network.addEquation(self.vtuneEqn)
        self.vtuneStartEqn = DesignEquation(None,str(data[vtune_StartID]))
        self.vtuneStepEqn  = DesignEquation(None,str(data[vtune_StepID]))
        self.vtuneStopEqn  = DesignEquation(None,str(data[vtune_StopID]))

    def __setupNoiseController(self):
        parameters = {}
        parameters["Start"] = 10
        parameters["Stop"]  = 1e6
        parameters["Dec"]   = 3
        sweepPlan = Device("SweepPlan",None,parameters)
        self.network.addDevice(sweepPlan)
        noiseNodes = voutPlusNodeName + " " + voutMinusNodeName
        parameters = {}
        parameters["InputFreq"]         = DesignEquation(None,"noisefreq")
        parameters["NoiseFreqPlan"]     = sweepPlan.getInstanceName()
        parameters["CarrierIndex[1]"]   = 1
        parameters["NoiseInputPort"]    = 1
        parameters["NoiseOutputPort"]   = 2
        parameters["PhaseNoise"]        = 1
        parameters["NoiseNode[1]"]      = noiseNodes
        parameters["SortNoise"]         = 0
        parameters["IncludePortNoise"]  = True
        parameters["BandwidthForNoise"] = 1.0
        noiseCon = Device("Noisecon",None,parameters)
        self.network.addDevice(noiseCon)
        return noiseCon

    def __setupAnalysis(self):
        parameters = {}
        parameters["Start"] = self.vtuneStartEqn
        parameters["Stop"]  = self.vtuneStopEqn
        parameters["Step"]  = self.vtuneStepEqn
        sweepPlan = Device("SweepPlan",None,parameters)
        self.network.addDevice(sweepPlan)

        parameters = {}
        parameters["MaxOrder"]        = 4
        parameters["Freq[1]"]         = self.freqEqn
        parameters["Order[1]"]        = self.orderEqn
        parameters["StatusLevel"]     = 3
        parameters["FundOversample"]  = 4
        parameters["Restart"]         = False
        parameters["UseAllSS_Freqs"]  = True
        parameters["OutputBudgetIV"]  = False
        hbInitialGuessFile = prefix + self.modelExtractor.instance.getInstanceName(True) + ".hbs"
        try:
            mode = os.stat(hbInitialGuessFile)
        except:
            mode = None
        if mode:
            parameters["UseInFile"]   = True
            parameters["InFile"]      = hbInitialGuessFile
        else:
            parameters["UseInFile"]     = False
        parameters["UseOutFile"]        = True
        parameters["OutFile"]           = prefix + self.modelExtractor.instance.getInstanceName(True) + ".hbs"
        oscPort = self.__setupOscPort()
        parameters["OscPortName"]       = oscPort.getInstanceName(True)
        parameters["SweepVar"]          = self.vsource.getInstanceName(True) + ".Vdc"
        parameters["SweepPlan"]         = sweepPlan.getInstanceName()
        parameters["UseKrylov"]         = False
        parameters["SamanskiiConstant"] = 2
        if self.modelExtractor.data[noiseID]:
            noiseCon = self. __setupNoiseController()
            parameters["Noisecon[1]"] = noiseCon.getInstanceName()
        self.hbAnalysis = Analysis("HB",parameters)
        self.hbAnalysis.setInstanceName(hbAnalysisName)
        self.network.attachAnalysis(self.hbAnalysis)


    def __setupExcitation(self):
        parameters = {}
        parameters["Vdc"]         = DesignEquation(None,self.vtuneEqn.getName())
        parameters["SaveCurrent"] = True
        self.vsource = Device("V_Source",[self.modelExtractor.nodes[0],0],parameters)
        self.vsource.setInstanceName(vsourceName)
        self.network.addDevice(self.vsource)

    def __setupOscPort(self):
        parameters = {}
        parameters["Node[1]"]    = self.modelExtractor.voutPlusNodeName
        if self.modelExtractor.voutMinusNodeName:
            parameters["Node[2]"]    = self.modelExtractor.voutMinusNodeName
        parameters["FundIndex"]  = 1
        parameters["Harm"]       = 1
        parameters["NumOctaves"] = 2.0
        parameters["Steps"]      = 20.0
        oscPort = Device("OscProbe",None,parameters)
        self.network.addDevice(oscPort)
        return oscPort
















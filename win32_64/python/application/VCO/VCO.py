# Copyright Keysight Technologies 2005 - 2015  
from ADSSim_Modules import *
from Design import *
from Component import *

from Design import *
from Output import *

from VCO_Descriptor import *
from VCO_ExtractionHelper import *
from VCO_ReplacementHelper import *
import sys
import os

class VCO(ModelExtractor):
    descriptor = VCO_Descriptor
    
    def __init__(self,instance):
	ModelExtractor.__init__(self,instance)
	self.simulation  = Simulation.getInstance()
        self.instance    = instance
        self.extractionHelper = None
        self.replacementHelper = None
        self.modelEquations   = None
        self.network          = None
        self.parentNetwork    = None
        self.requiresCharacterization = True
        self.nodes = None
        self.datasetName   = None
        self.outputDataset = None
        self.voutMinusNodeName = None
        self.voutPlusNodeName = None
	
    def setup(self,parentNetwork):
        if not self.data[activateID]:
            return True
        mode   = self.data[modeID]
        if mode == 0:
            return self.setupImplicit(parentNetwork)
        elif mode == 1:
            return self.setupExplicit(parentNetwork)
        else:
            return False
        
    def setupExplicit(self,parentNetwork):
        self.parentNetwork = parentNetwork
        subCircuit        = self.instance.getSubCircuit()
        subCircuitName    = self.data[networkNameID]
        subCircuit = subCircuit.getSubCircuitByInstanceName(subCircuitName)
        assert (subCircuit != None) , "Cannot find sub-circuit."
        self.vTuneNodeName  = self.data[nodeVtuneID]
        self.vOscpNodeName  = self.data[nodeVoscpID]
        self.vOscmNodeName  = self.data[nodeVoscmID]
        self.nodes = subCircuit.getNodes()
        assert (len(self.nodes) <= 3),"Len of nodes is greater than 3."
        vTuneNode = vOscNodep = vOscNodem = 0
        nodeNames = []
        for i in self.nodes:
            nodeNames.append(self.parentNetwork.getNodeName(i))
       
        tempNode = [0,0]
        for i in range(len(nodeNames)):
            if nodeNames[i] == self.vTuneNodeName:
                assert tempNode[0] == 0,"Reassigning vTune."
                tempNode[0] = self.nodes[i]
            elif nodeNames[i] == self.vOscpNodeName:
                assert tempNode[1] == 0,"Reassigning vOscp."
                tempNode[1] = self.nodes[i]
            elif nodeNames[i] == self.vOscmNodeName:
                assert len(tempNode) == 2,"Reassigning vOscm."
                tempNode.append(self.nodes[i])
        self.nodes = tempNode
        self.parentNetwork.removeSubCircuit(subCircuit)
        self.network = self.simulation.createNetwork(self.parentNetwork)
        	
        self.network.setRootSubCircuit(subCircuit)
        if len(self.nodes) == 3:
            self.voutMinusNodeName = subCircuit.getInstanceName(True)+"."+voutMinusNodeName
            self.network.setNodeName(self.nodes[2],self.voutMinusNodeName)
        self.voutPlusNodeName = subCircuit.getInstanceName(True)+"."+voutPlusNodeName
        self.network.setNodeName(self.nodes[1],self.voutPlusNodeName)
        self.datasetName = self.data[outputDatasetNameID]
        instanceName     = subCircuitName
        instanceName     = instanceName.replace('.','_')
        if not self.datasetName:
            self.datasetName = prefix + instanceName
        dslen = len(self.datasetName)
        i = self.datasetName.rfind(".ds")
        if i and (i+3 == dslen):
            None
        else:
            self.datasetName += ".ds"
        
        self.reUseData = False
        if self.data[reusePreviousDataID]:
            try:
                mode = os.stat(self.datasetName)
                if mode:
                    self.reUseData = True
            except:
                None
            
        self.__setupExtractionNetwork(subCircuit)
        self.network.setup()

        if not self.reUseData:
            self.setupDataset()
            self.extractionHelper.hbAnalysis.analyze()
            self.outputDataset.flush()
        self.requiresCharacterization = False
        self.__setupModelNetwork()
        return True

    def setupDataset(self):
        if not self.outputDataset:
            self.outputDataset = DatasetOutput(self.datasetName)
            self.network.setOutput(self.outputDataset)
        
    def setupImplicit(self,parentNetwork):
        self.parentNetwork = parentNetwork
        subCircuit         = self.instance.getSubCircuit()
        self.nodes         = subCircuit.getNodes()
        if len(self.nodes) is not 3:
            assert 0,"len(nodes) != 3"

        self.parentNetwork.removeSubCircuit(subCircuit)
        self.network = self.simulation.createNetwork(self.parentNetwork)

        self.voutMinusNodeName = subCircuit.getInstanceName(True)+"."+voutMinusNodeName
        self.voutPlusNodeName = subCircuit.getInstanceName(True)+"."+voutPlusNodeName
	
        self.network.setRootSubCircuit(subCircuit)
        self.network.setNodeName(self.nodes[2],self.voutMinusNodeName)
        self.network.setNodeName(self.nodes[1],self.voutPlusNodeName)

        self.datasetName = self.data[outputDatasetNameID]
        instanceName     = self.instance.getSubCircuit().getInstanceName(True)
        instanceName     = instanceName.replace('.','_')
        try:
            mode = os.stat(hbInitialGuessFile)
        except:
            mode = None
        
        if not self.datasetName:
            self.datasetName = prefix + instanceName
      
        self.outputDataset = DatasetOutput(self.datasetName)
        self.network.setOutput(self.outputDataset)
        self.__setupExtractionNetwork(subCircuit)
        self.network.setup()
        self.extractionHelper.hbAnalysis.analyze()
        self.outputDataset.flush()
        self.requiresCharacterization = False
        return True


    def characterize(self):
        return True

    def __setupModelNetwork(self):
        self.replacementHelper = VCO_ReplacementHelper(self)
        return self.replacementHelper.setup()

    def __setupExtractionNetwork(self,subCircuit):
        self.extractionHelper = VCO_ExtractionHelper(self)
        return self.extractionHelper.setup()
        

GlobalLoaders.getComponentLoader().register(VCO)








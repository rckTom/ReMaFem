classdef feObjClass < handle
    properties
        e
        n
        material
        nodeSet
        elementSet
        elementData
        nodeData
        fieldData
        boundaryConditions
        control
    end 
    methods
        function obj = feObjClass()
           obj.e = [];
           obj.n = [];
           obj.nodeSet = struct([]);
           obj.elementSet = struct([]);
           obj.elementData = struct();
           obj.nodeData = struct();
           obj.fieldData = struct();
           obj.boundaryConditions = [];
           obj.material = [];
           obj.control = controlClass();
        end
        
        function val = isStatic(obj)
            if obj.control.timeControl.tEnd > 0
                val = false;
            else
                val = true;
            end
        end
        
        function val = isLowerSolutionNeeded(obj)
            if obj.control.timeControl.tEnd == 0 && obj.control.outputControl.force == false
                val = false;
            else
                val = true;
            end 
        end
    end
end



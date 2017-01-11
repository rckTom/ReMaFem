classdef controlClass
   properties
      timeControl
      solutionControl
      shellControl
      outputControl
      interpolationControl
   end
   methods
       function obj = controlClass()
           obj.solutionControl = solutionControlClass();
           obj.outputControl = outputControlClass();
           obj.interpolationControl = interpolationControlClass();
       end
   end
end
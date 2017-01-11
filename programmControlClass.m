classdef programmControlClass < handle
   properties
      numProc;
   end
    
   methods
       function obj =  programmControlClass(varargin)
        p = inputParser();
        addParameter(p,'numProc',1);
        
        p.parse(varargin{:});
        obj.numProc = p.Results.numProc;
       end
   end
end
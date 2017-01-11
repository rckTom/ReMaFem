classdef solutionControlClass < handle
   properties
      startAtEquilibrium
      timeIntegrationRule
      
   end
   methods
       function obj = solutionControlClass(varargin)
           p = inputParser();
           addParameter(p,'startAtEquilibrium',true);
           addParameter(p,'timeIntegrationRule','central');
           
           parse(p,varargin{:});
           obj.startAtEquilibrium = p.Results.startAtEquilibrium;
           obj.timeIntegrationRule = p.Results.timeIntegrationRule;
       end
   end
end
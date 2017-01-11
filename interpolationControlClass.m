classdef interpolationControlClass
   properties
      method = 0 %0:linear 1:spline 
   end
   methods
       function obj = interpolationControlClass(varargin)
           p = inputParser();
           addParameter(p,'method',0);
           parse(p,varargin{:})
           
           obj.method = p.Results.method;
       end
       function valid = validate(obj)
          if obj.method == 0 || obj.method == 1
              valid = true;
          else
              valid = false;
          end
       end
   end
end
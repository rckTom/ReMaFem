classdef timeControlClass
   properties
       tEnd
       dt
       autoTimestep;
       dtFactor;
   end
   methods
       function obj = timeControlClass(tEnd,varargin)
            p = inputParser();
            addRequired(p,'tEnd')
            addParameter(p,'dt',0.001)
            addParameter(p,'autoTimestep',true);
            addParameter(p,'dtFactor',0.9);
            parse(p,tEnd,varargin{:});
            obj.tEnd = p.Results.tEnd;
            obj.dt = p.Results.dt;
            obj.autoTimestep = p.Results.autoTimestep;
            obj.dtFactor = p.Results.dtFactor;
       end
       
       function valid = validate(obj)
          if(isnumeric(obj.tEnd) && isnumeric(obj.dt))
              valid = true;
          else
              valid = false;
          end
       end
   end
end
classdef outputControlClass
   properties
      stress
      vonMisesStress
      displacement
      acceleration
      velocity
      force
      meshSkew
      meshAspectRatio
      numberOfPlots
      energy
      workingDir
      fileName
      writeFormat
   end
   methods
       function obj = outputControlClass(varargin)
          p = inputParser();
          addParameter(p,'stress',false);
          addParameter(p,'vonMisesStress',false);
          addParameter(p,'displacement',true);
          addParameter(p,'acceleration',false);
          addParameter(p,'velocity',false);
          addParameter(p,'force',false);
          addParameter(p,'meshSkew',false);
          addParameter(p,'meshAspectRatio',false);
          addParameter(p,'energy',false);
          addParameter(p,'numberOfPlots',2);
          addParameter(p,'workingDir','C:temp');
          addParameter(p,'fileName','run');
          addParameter(p,'writeFormat','binary');
          
          parse(p,varargin{:});
          
          obj.stress = p.Results.stress;
          obj.vonMisesStress = p.Results.vonMisesStress;
          obj.displacement = p.Results.displacement;
          obj.acceleration = p.Results.acceleration;
          obj.velocity = p.Results.velocity;
          obj.force = p.Results.force;
          obj.meshSkew = p.Results.meshSkew;
          obj.meshAspectRatio = p.Results.meshAspectRatio;
          obj.energy = p.Results.energy;
          obj.numberOfPlots = p.Results.numberOfPlots;
          obj.workingDir = p.Results.workingDir;
          obj.fileName = p.Results.fileName;
          obj.writeFormat = p.Results.writeFormat;
       end
       
       function valid = validate(obj)
           valid = true;
       end
   end
end
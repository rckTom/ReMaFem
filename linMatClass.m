classdef linMatClass
   properties
      E
      nu
      rho
      C
   end
   methods
       function obj = linMatClass(E,nu,rho)
          obj.E = E;
          obj.nu = nu;
          obj.rho = rho;
       end
       
       function c = speedOfSound(obj)
           c = sqrt((obj.E)/(obj.rho*(1-obj.nu^2)));
       end
       
       function C = getC(obj)
           obj.C = obj.E/(1-obj.nu^2)*[1 ,obj.nu,               0;
                               obj.nu,     1,               0;
                                    0,     0, 1/2*(1-obj.nu)];
           C = obj.C;
       end
   end
end
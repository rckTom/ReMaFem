function C = linearElasticMaterial(E,nu)
    C = E/(1-nu^2)*[1 ,nu,        0;
                    nu, 1,        0;
                     0, 0,1/2*(1-nu)];
end
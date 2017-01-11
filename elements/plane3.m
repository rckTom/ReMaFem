function [out] = plane3(x,C,t,b,u,rho,outputType)
    switch outputType
        case 'Ke'
            out = sparse(t*quadratur(@integrandKe,[6,6]));  
        case 'f'
            out = t*quadratur(@integrandFb,[6,1]); 
        case 'sigma'
            xi = [0,0];
            dNl = zeros(2,3);
            dNl(1,1) = -(1-xi(2))/4;
            dNl(1,2) = (1-xi(2))/4;
            dNl(2,1) = -(1-xi(1))/4;
            dNl(2,2) = -(xi(1)+1)/4;
            dNl(2,3) = 1/2;
            J = Jacobian(xi);
            dNg = J\dNl;
            B = [dNg(1,1)        0 dNg(1,2)        0 dNg(1,3)        0;
                        0 dNg(2,1)        0 dNg(2,2)        0 dNg(2,3);
                 dNg(2,1) dNg(1,1) dNg(2,2) dNg(1,2) dNg(2,3) dNg(1,3)];
            sig = C*B*u;
            out = [sig(1) sig(2) 0 sig(3) 0 0];
        case 'Mass'
            out = sparse(t*quadratur(@integrandM,[6,6]));
    end
    
    
%----Nested Functions----%
%nested functions tested arround 10% faster than subfunctions
    function val = integrandKe(xi)
        dNl = zeros(2,3);
        dNl(1,1) = -(1-xi(2))/4;
        dNl(1,2) = (1-xi(2))/4;
        dNl(2,1) = -(1-xi(1))/4;
        dNl(2,2) = -(xi(1)+1)/4;
        dNl(2,3) = 1/2;
        J = Jacobian(xi);
        dNg = J\dNl;
        B = [dNg(1,1)        0 dNg(1,2)        0 dNg(1,3)        0;
                    0 dNg(2,1)        0 dNg(2,2)        0 dNg(2,3);
             dNg(2,1) dNg(1,1) dNg(2,2) dNg(1,2) dNg(2,3) dNg(1,3)];

        val = B'*C*B*det(J); 
    end

    function val = integrandFb(xi)
        N = 1/4*[(1-xi(1))*(1-xi(2));(1+xi(1))*(1-xi(2));2*(1+xi(2))];
        Nv = [N(1)      0   N(2)        0   N(3)        0;
                0   N(1)      0     N(2)      0     N(3)];
        val = Nv'*b*det(Jacobian(xi));
    end

    function val = integrandM(xi)
        N = 1/4*[(1-xi(1))*(1-xi(2));(1+xi(1))*(1-xi(2));2*(1+xi(2))];
        Nv = [N(1)      0   N(2)        0   N(3)        0;
                0   N(1)      0     N(2)      0     N(3)];
        val = Nv'*rho*Nv*det(Jacobian(xi));
    end
    function val = Jacobian(xi)
        dNl = zeros(2,3);
        dNl(1,1) = -(1-xi(2))/4;
        dNl(1,2) = (1-xi(2))/4;
        dNl(2,1) = -(1-xi(1))/4;
        dNl(2,2) = -(xi(1)+1)/4;
        dNl(2,3) = 1/2;

        val = [dNl(1,:)*x(:,1),dNl(1,:)*x(:,2);
               dNl(2,:)*x(:,1),dNl(2,:)*x(:,2)];
    end
end


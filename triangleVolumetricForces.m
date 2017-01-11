syms t  xi eta bx by x_i y_i x_j y_j x_k y_k real

x = [x_i y_i;x_j y_j; x_k y_k];
b = [bx;by];

%Ansatzfunktion
N = 1/4*[(1-xi)*(1-eta);(1+xi)*(1-eta);2*(1+eta)];
dNloc = jacobian(N,[xi eta])';
J = [dot(dNloc(1,:),x(:,1)),dot(dNloc(1,:),x(:,2));dot(dNloc(2,:),x(:,1)),dot(dNloc(2,:),x(:,2))];
Nmat = [N(1)       0    N(2)       0    N(3)       0;
           0    N(1)       0    N(2)       0    N(3)];
fb = t*int(int(Nmat'*b*det(J),xi,-1,1),eta,-1,1);
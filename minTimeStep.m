function [dt,dtE] = minTimeStep(feObj)
    dtE = zeros(length(feObj.e),1);
    c = feObj.material.speedOfSound();
    Ls =[];
    
    for i = 1:length(feObj.e)
       l(1) = norm(feObj.n(feObj.e(i,2),:)-feObj.n(feObj.e(i,1),:));
       l(2) = norm(feObj.n(feObj.e(i,3),:)-feObj.n(feObj.e(i,2),:));
       l(3) = norm(feObj.n(feObj.e(i,1),:)-feObj.n(feObj.e(i,3),:)); 
       s = sum(l)/2;
       A = sqrt(s*(s-l(1))*(s-l(2))*(s-l(3)));
       Ls(i) = 2*A/max(l);
       
       dtE(i) = Ls(i)/c;
    end
    
    dt = min(dtE);
end
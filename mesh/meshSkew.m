function skew = meshSkew(mesh,u)
    skew = zeros(length(mesh.e),1);
    n = zeros(size(mesh.n));
    if nargin == 1
        n = mesh.n;
    elseif nargin == 2
        n = mesh.n+u;
    end
    for i = 1:length(skew)
       vec1 = n(mesh.e(i,2),:)-n(mesh.e(i,1),:);
       vec2 = n(mesh.e(i,3),:)-n(mesh.e(i,2),:);
       vec3 = n(mesh.e(i,1),:)-n(mesh.e(i,3),:);
       
       ang(1) = acos((dot(-vec1,vec2))/(norm(vec1)*norm(vec2)));
       ang(2) = acos((dot(-vec2,vec3))/(norm(vec2)*norm(vec3)));
       ang(3) = acos((dot(-vec3,vec1))/(norm(vec3)*norm(vec1)));
       
       skew(i) = max([(max(ang)-60*pi/180)/(pi-60*pi/180),(60*pi/180-min(ang))/(60*pi/180)]);
    end
end
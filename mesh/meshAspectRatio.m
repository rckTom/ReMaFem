function aspectRatio = meshAspectRatio(mesh,u)
    aspectRatio = zeros(length(mesh.e),1);
    n = zeros(size(mesh.n));
    if nargin == 1
        n = mesh.n;
    elseif nargin == 2
        n = mesh.n+u;
    end
   for i = 1:length(aspectRatio)
       vec(1) = norm(n(mesh.e(i,2),:)-n(mesh.e(i,1),:));
       vec(2) = norm(n(mesh.e(i,3),:)-n(mesh.e(i,2),:));
       vec(3) = norm(n(mesh.e(i,1),:)-n(mesh.e(i,3),:)); 
       
       aspectRatio(i) = max(vec)/min(vec);
   end
end
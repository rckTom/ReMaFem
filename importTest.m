figure
mesh = keyWordImport('sampleData/winkel30x5.k');
p0 = trisurf(mesh.e,mesh.n(:,1),mesh.n(:,2),mesh.n(:,3),meshSkew(mesh),'FaceColor','flat','EdgeColor','k');
view(2)
hold on
p1 = scatter3(mesh.n(mesh.nodeSet(1).nodes,1),mesh.n(mesh.nodeSet(1).nodes,2),mesh.n(mesh.nodeSet(1).nodes,3),'FaceColor','g');
p2 = scatter3(mesh.n(mesh.nodeSet(2).nodes,1),mesh.n(mesh.nodeSet(2).nodes,2),mesh.n(mesh.nodeSet(2).nodes,3),'FaceColor','r');
legend([p1 p2],mesh.nodeSet(1).name,mesh.nodeSet(2).name);
axis equal


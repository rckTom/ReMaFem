clear all;close all
setup;

%% Pre-Processing
    tic
    feObj = keyWordImport('sampleData/balken2.k');
    feObj = createBoundaryCondition(feObj,'Festlager',1,BoundaryConditions.displacement,[0,0,0],0);
    feObj = createBoundaryCondition(feObj,'Loslager',2,BoundaryConditions.displacementY,0,0);
    feObj = createBoundaryCondition(feObj,'Krafteinleitung',4,BoundaryConditions.nodeForce,[0,-0.5,0],0);
    feObj.C = linearElasticMaterial(210000,0.3);
    
%% Processing
    feObj = feSolve(feObj,0);
    pt = toc;
    
%% Post-Processing
    tic
    feObj = vonMisesStress(feObj);
    vtuExport('C:/temp/balken2.vtu',feObj);
    ppt = toc;
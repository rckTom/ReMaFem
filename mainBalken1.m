clear all ;close all
setup;

%% Pre-Processing
    tic
    feObj = keyWordImport('sampleData/balken3.k');
    feObj = createBoundaryCondition(feObj,'Fest',1,BoundaryConditions.displacement,[0,0,0;0,0,0],[0 1]);
    feObj = createBoundaryCondition(feObj,'Krafteinleitung',2,BoundaryConditions.nodeForce,[0,-0.5,0;0,0,0;0,0,0],[0,0.00001,1]);
    feObj.material = linMatClass(210000,0.3,7.85e-6);
    
    feObj.control.timeControl = timeControlClass(0.01);
    feObj.control.outputControl = outputControlClass('numberOfPlots',500,...
                                                     'workingDir','C:/temp/balken',...
                                                     'fileName','balkenSchwingung',...
                                                     'stress',true,...
                                                     'numberOfPlots',100);
    feObj.control.shellControl = shellControlClass(1,'elementForm',0);
    feObj.control.interpolationControl = interpolationControlClass();
    
%% Processing
    feObj = feSolve(feObj);
    pt = toc;
    
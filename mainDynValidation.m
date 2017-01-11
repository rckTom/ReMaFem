clear all;
close all;
tic;

setup;
%Mesh import
feObj = keyWordImport('sampleData/balken.k');

%Create boundary conditions
feObj = createBoundaryCondition(feObj,'Einspannung',1,BoundaryConditions.displacement,[0 0 0; 0 0 0],[0 100]);
feObj = createBoundaryCondition(feObj,'Kraft',2,BoundaryConditions.nodeForce,[0 -1 0; 0 0 0; 0 0 0],[0 1e-10 100]);

%Material definition
feObj.material = linMatClass(210000,0.3,7.85e-3);

%Options and Settings
feObj.control.timeControl = timeControlClass(10,'autoTimestep',true);
feObj.control.shellControl = shellControlClass(1,'elementForm',0);
feObj.control.solutionControl = solutionControlClass('startAtEquilibrium',true);
feObj.control.outputControl = outputControlClass('workingDir','C:/temp/dynValidation',...
                                                 'fileName','dynValidation',...
                                                 'writeFormat','binary',...
                                                 'numberOfPlots',4000,...
                                                 'displacement',true,...
                                                 'velocity',true,...
                                                 'energy',true);

%solve
feObj = feSolve(feObj);


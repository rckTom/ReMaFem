clear vars; close all
setup;
tic

%Einheiten
%Kraft: N
%Länge: mm
%Gewicht: g
%Zeit: ms
%Spannung: N/mm^2

%% Pre-Processing
    feObj = keyWordImport('sampleData/winkel30x5.k');
    feObj = createBoundaryCondition(feObj,'Fest',1,BoundaryConditions.displacement,[0,0,0;0,0,0],[0 100]);
    feObj = createBoundaryCondition(feObj,'Krafteinleitung',2,BoundaryConditions.nodeForce,[0,0,0;1,0,0;1,0,0],[0 0.0000001 100]);
    feObj.material = linMatClass(210000,0.3,7.85e-3);
    
%% Options
    feObj.control.timeControl =  timeControlClass(2,'dtFactor',1.1);
    feObj.control.shellControl = shellControlClass(1,'elementForm',0,'nip',4);
    feObj.control.interpolationControl = interpolationControlClass();
    feObj.control.outputControl = outputControlClass('force',true,...
                                                     'numberOfPlots',500, ...
                                                     'workingDir','C:/temp',...
                                                     'stress',true,...
                                                     'fileName','winkel30x5_unstable',...
                                                     'writeFormat','binary');

%% Processing
    [feObj] = feSolve(feObj);

    toc
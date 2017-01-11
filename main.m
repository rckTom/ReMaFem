clear vars; close all
setup;
tic

%hier gewähltes Einheitensystem
%Kraft: N
%Länge: mm
%Gewicht: g
%Zeit: ms
%Spannung: N/mm^2

%% Pre-Processing
    feObj = keyWordImport('sampleData/winkel30x5.k');
    %Funny looking
%         f = 50;
%         a = 0.1;
%         t = 0:0.0001:0.1;
%         v = [a*sin(2*pi*f*t'),0*t',0*t'];
%         feObj = createBoundaryCondition(feObj,'Verschiebung',1,BoundaryConditions.displacement,v,t);
%         %feObj = createBoundaryCondition(feObj,'Verschiebung',1,BoundaryConditions.displacement,[0,0,0;2,0,0;2,0,0],[0 0.09 0.1]);
    %More realistic use case
        feObj = createBoundaryCondition(feObj,'Fest',1,BoundaryConditions.displacement,[0,0,0;0,0,0],[0 100]);
    %Forcecurve
        t_fc = [0 0.1 0.1+1.8214e-5 1];
        v_fc = [0 0 0; 1 0 0; 0 0 0 ; 0 0 0];
        feObj = createBoundaryCondition(feObj,'Krafteinleitung',2,BoundaryConditions.nodeForce,v_fc,t_fc);
    feObj.material = linMatClass(210000,0.3,7.85e-3);
    
%% Options
    feObj.control.solutionControl = solutionControlClass('startAtEquilibrium',true);
    feObj.control.timeControl =  timeControlClass(1,'dtFactor',0.9);
    feObj.control.shellControl = shellControlClass(1,'elementForm',0,'nip',4);
    feObj.control.interpolationControl = interpolationControlClass();
    feObj.control.outputControl = outputControlClass('numberOfPlots',2000, ...
                                                     'workingDir','C:/temp',...
                                                     'fileName','test',...
                                                     'energy',true,...
                                                     'velocity',true,...
                                                     'displacement',true,...
                                                     'acceleration',true,...
                                                     'writeFormat','binary');
    

%% Processing
    [feObj] = feSolve(feObj);

    toc
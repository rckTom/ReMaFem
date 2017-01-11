function [feObj] = feSolve(feObj)
    %flags for computation puposes
    flags.computeVolumetricLoads = false;
    flags.isStatic = feObj.isStatic();
    flags.isLowerSolutionNeeded = feObj.isLowerSolutionNeeded();
    
    %
    [fcN,dpcN,lnIdx] = indexMapping(feObj);
    [u_b,f_a,b] = processBoundaryConditions(feObj,fcN,dpcN,lnIdx,0,flags);

    %Upper-Left and Upper-right Elements. K = [UL UR
    %                                          LL LR]
    eUL = findElementsByNode(feObj.e,fcN);
    eUR = findElementsByNode(feObj.e(eUL),dpcN);
    eLR = findElementsByNode(feObj.e,dpcN);
    eLL = findElementsByNode(feObj.e(eLR),fcN);
    
    if flags.isLowerSolutionNeeded
        el = 1:length(feObj.e);
    else
        el = union(eUR,eUL,'rows');
    end
    
    %% System matrices allocation
    K1 = spalloc(length(fcN)*2,length(fcN)*2+length(dpcN)*2,(length(eUL)+length(eUR))*36);
    K2 = [];
    M1 = [];
    M2 = [];
    
    if ~flags.isStatic
        M1 = spalloc(length(fcN)*2,length(fcN)*2+length(dpcN)*2,(length(eUL)+length(eUR))*36);
    end
    
    if flags.isLowerSolutionNeeded
        K2 = spalloc(length(dpcN)*2,length(fcN)*2+length(dpcN)*2,(length(eLL)+length(eLR))*36);
        if ~flags.isStatic
            M2 = spalloc(length(dpcN)*2,length(fcN)*2+length(dpcN)*2,(length(eLL)+length(eLR))*36);
        end
    end
    
    sizeK1 = [length(fcN)*2,length(fcN)*2+length(dpcN)*2];
    
    fprintf('\nStart assembly ... ');
    %Assemble stiffness Matrix
    C = feObj.material.getC();
    
    %% Assembly of system matrices
    for i = 1:length(el)
        nIdx = feObj.e(el(i),:);
        nodes = feObj.n(nIdx,:);

        %Local Node Index
        localNIdx = lnIdx(nIdx);

        %Index of Local Nodes in K
        localKIdx =[(localNIdx(1)-1)*2+1,(localNIdx(1)-1)*2+2, ...
                     (localNIdx(2)-1)*2+1,(localNIdx(2)-1)*2+2, ...
                     (localNIdx(3)-1)*2+1,(localNIdx(3)-1)*2+2];

        %Check for bound overflow         
        logicIdx1 = localKIdx<=sizeK1(1);
        logicIdx2_1 = ~logicIdx1;
        
        
        if(feObj.control.shellControl.elemForm == 0 )
            Ke = plane3Analytical(nodes,C,feObj.control.shellControl.t);
            Me = plane3AnalyticalMass(feObj.material.rho,feObj.control.shellControl.t,nodes);
        else
            Ke = plane3(nodes,C,feObj.control.shellControl.t,b,0,feObj.material.rho,'Ke');
            Me = plane3(nodes,C,feObj.control.shellControl.t,0,0,feObj.material.rho,'Mass');
        end
        
        if flags.computeVolumetricLoads
            fe = plane3(nodes,C,feObj.control.shellControl.t,b(i,1:2)',0,'f');
            f_a(localKIdx(logicIdx1)) = f_a(localKIdx(logicIdx1))+fe(logicIdx1);
        end

        %Stiffness Matrix
        K1(localKIdx(logicIdx1),localKIdx) = K1(localKIdx(logicIdx1),localKIdx)+Ke(logicIdx1,1:6); 
        if flags.isLowerSolutionNeeded
            K2(localKIdx(logicIdx2_1)-sizeK1(1),localKIdx) = K2(localKIdx(logicIdx2_1)-sizeK1(1),localKIdx)+Ke(logicIdx2_1,1:6);
        end
        
        %Mass Matrix
        if ~flags.isStatic
            M1(localKIdx(logicIdx1),localKIdx) = M1(localKIdx(logicIdx1),localKIdx)+Me(logicIdx1,1:6);
            if flags.isLowerSolutionNeeded
                M2(localKIdx(logicIdx2_1)-sizeK1(1),localKIdx) = M2(localKIdx(logicIdx2_1)-sizeK1(1),localKIdx)+Me(logicIdx2_1,1:6);
            end
        end
    end
    
    %[K1,K2,M1,M2] = assemble(feObj,fcN,dpcN,lnIdx,flags);
    
    M_aa = toPointMassMatrix(M1);
    M_bb = toPointMassMatrix(M2);

    fprintf('End assembly \n');
    

    
    
    %% Static solution
    fprintf('Start solving ... \n');
    f = [];
    v_a = [];
    
    if(flags.isStatic || feObj.control.solutionControl.startAtEquilibrium)
        u_a = K1(1:length(fcN)*2,1:length(fcN)*2)\(f_a-K1(1:length(fcN)*2,(length(fcN)*2+1):end)*u_b); 
        v_a = zeros(length(u_a),1);
        if flags.isLowerSolutionNeeded
            f = [K1;K2]*[u_a;u_b];
        end
    end
    
    %% Transient solution
    if feObj.control.timeControl.autoTimestep
        feObj.control.timeControl.dt =  minTimeStep(feObj);
    end
    
    dt = feObj.control.timeControl.dt * feObj.control.timeControl.dtFactor;
    dtLog = feObj.control.timeControl.tEnd/feObj.control.outputControl.numberOfPlots;
    nPlots = 0;
    outputWriter = paraviewXmlWriter(feObj.control.outputControl.workingDir,...
                                        'floatPrecision',uint32(18),...
                                        'fileName',feObj.control.outputControl.fileName,...
                                        'writeFormat',feObj.control.outputControl.writeFormat);
    [u_b,f_a] = processBoundaryConditions(feObj,fcN,dpcN,lnIdx,0,flags);
    
    %Inverse mass matrix
    iMaa = inv(M_aa);
    a_a = iMaa*(f_a-K1(1:length(fcN)*2,1:length(fcN)*2)*u_a-K1(1:length(fcN)*2,(length(fcN)*2+1):end)*u_b);
    u_am1 = u_a-v_a*dt+a_a*dt^2/2;
    u_bm1 = u_b;
    
    intEnergy = zeros(feObj.control.outputControl.numberOfPlots,1);
    kinEnergy = zeros(feObj.control.outputControl.numberOfPlots,1);
    tplot = zeros(feObj.control.outputControl.numberOfPlots,1);
    
    outputWriter.createPVD();
    lastTime = 0;
    cpuTime = 0;
    for i = 0:(floor(feObj.control.timeControl.tEnd/dt)-1)
        t = i*dt;
        [u_bp1,f_a] = processBoundaryConditions(feObj,fcN,dpcN,lnIdx,t+dt,flags);
        u_ap1 = iMaa*(f_a-K1(1:length(fcN)*2,1:length(fcN)*2)*u_a-K1(1:length(fcN)*2,(length(fcN)*2+1):end)*u_b)*dt^2+2*u_a-u_am1;
        if nPlots*dtLog-dt <= t
           tplot(nPlots+1) = t;
           cpuTime = toc;
           fprintf(['PLOT ' num2str(nPlots) '\t' ...
                    'STEP ' num2str(uint64(t/feObj.control.timeControl.dt)) ...
                    '\tt = ' num2str(t,'%.10f') ...
                    '; dt = ' num2str(feObj.control.timeControl.dt) ...
                    '; CPUclock = ' num2str(cpuTime,'%.3f') 's' ...
                    '; deltaCPU = ' num2str(cpuTime-lastTime,'%.3f') 's\n']);
           lastTime = cpuTime;
           u = [reshape(u_a,2,[])';reshape(u_b,2,[])'];
           um1 = [reshape(u_am1,2,[])';reshape(u_bm1,2,[])'];
           up1 = [reshape(u_ap1,2,[])';reshape(u_bp1,2,[])'];
           v = (up1-um1)./(2*dt);
           if feObj.control.outputControl.displacement
                feObj.nodeData.displacement = [u(lnIdx',:), zeros(length(u),1)];
           end
           if feObj.control.outputControl.acceleration
                a = (um1-2*u+up1)./(dt^2);
                feObj.nodeData.acceleration = [a(lnIdx',:), zeros(length(a),1)];
           end
           if feObj.control.outputControl.stress
                stress = zeros(length(feObj.e),6);
                for j = 1:length(feObj.e)
                    nIdx = feObj.e(j,:);
                    stress(j,:) = plane3AnalyticalSigma(C,reshape(feObj.nodeData.displacement(nIdx,1:2)',[],1),feObj.n(nIdx,:));
                end
                feObj.elementData.stress = stress;
                if feObj.control.outputControl.vonMisesStress
                    vmStress =  sqrt(stress(:,1).^2+stress(:,2).^2-stress(:,1).*stress(:,2)+3.*stress(:,4).^2);
                    feObj.elementData.vonMisesStress = vmStress;
                end
           end
           if feObj.control.outputControl.force
                f_b = 1/(dt^2)*M_bb*(u_bp1-2*u_b+u_bm1)+ K2(:,1:length(fcN)*2)*u_a + K2(:,(length(fcN)*2+1):end)*u_b;
                f = reshape([f_a;f_b],2,[])';
                feObj.nodeData.force = [f(lnIdx',:), zeros(length(f),1)];               
           end
           if feObj.control.outputControl.velocity
                v = (up1-um1)./(2*dt);
                feObj.nodeData.velocity = [v(lnIdx',:), zeros(length(v),1)];
           end
           if feObj.control.outputControl.meshSkew
                feObj.elementData.meshSkew = meshSkew(feObj,feObj.nodeData.displacement);
           end
           if feObj.control.outputControl.meshAspectRatio
                feObj.elementData.meshAspectRatio = meshAspectRatio(feObj,feObj.nodeData.displacement);
           end
           if feObj.control.outputControl.energy
              intEnergy(nPlots+1) = 0.5*([u_a;u_b]'*[K1;K2]*[u_a;u_b]);
              v = v(:);
              kinEnergy(nPlots+1) = 0.5*(v'*diag([diag(M_aa);diag(M_bb)])*v);
           end

           outputWriter.addTimestep(feObj,t,nPlots);
           nPlots = nPlots +1;
        end
        
        u_am1 = u_a;
        u_a = u_ap1;
        
        u_bm1 = u_b;
        u_b = u_bp1;
    end
    
    
    %% IO, needs to be encapsuled in a function
%     %correct vector notation
%     u_a = [reshape(u_a,2,[])';reshape(u_b,2,[])'];
%     f_b = reshape(f_b,2,[])';
% 
%     feObj.nodeData.u = [u_a(lnIdx',:), zeros(length(u_a),1)];
%     feObj.nodeData.f = [f_b(lnIdx',:), zeros(length(f_b),1)];
%     
%     stress = zeros(length(feObj.e),6);
%     for i = 1:length(feObj.e)
%         nIdx = feObj.e(i,:);
%        stress(i,:) = plane3(feObj.n(nIdx,:),C,0,0,reshape(feObj.nodeData.u(nIdx,1:2)',[],1),0,'sigma');
%     end
%     feObj.elementData.stress = stress;
    fid = fopen([feObj.control.outputControl.workingDir '/scalarOut.csv'],'w');
    fprintf(fid,'Time,Internal Energy, Kinetic Energy\n');
    fclose(fid);
    dlmwrite([feObj.control.outputControl.workingDir '/scalarOut.csv'],[tplot,intEnergy,kinEnergy],'-append','precision','%.16f','delimiter',',');
    fprintf('End solving \n\n');
    end
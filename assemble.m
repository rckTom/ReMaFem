function [K1,K2,M1,M2] = assemble(feObj,fcN,dpcN,lnIdx,flags)

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
end

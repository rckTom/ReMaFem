function [fcN,dpcN,lnIdx] = indexMapping(feObj)
    %Displacement- ans forceconstrained Boundary Conditions
    dpcBC = feObj.boundaryConditions([feObj.boundaryConditions.condition] == BoundaryConditions.displacement);
    
    %Displacement- ans forceconstrained nodes
    dpcN = [];
    for i = 1:length(dpcBC)
       ns = feObj.nodeSet([feObj.nodeSet.id]==dpcBC.setID);
       dpcN(end+1:end+length(ns.nodes)) = ns.nodes;
    end
    fcN = setdiff(1:length(feObj.n),dpcN);

    %Index mapping
    sN = [fcN dpcN]; %sorted nodes
    [~,lnIdx] = ismember(1:length(feObj.n),sN,'R2012a'); %global node Index in local Nodevector; lokaleIdx = lnIdx(globaleIdx)
end
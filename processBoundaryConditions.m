function [u_b,f_a,b] = processBoundaryConditions(feObj,fcN,dpcN,lnIdx,time,flags)
        f_a = zeros(length(fcN)*2,1);     %force Vector
        u_b = zeros(length(dpcN)*2,1);   %known displacements
        b = zeros(length(feObj.e),3);   %volumentric forces
        BC = feObj.boundaryConditions;
        
        for i = 1:length(BC)
                    valueVec = BC(i).value;
                    timeVec = BC(i).time;
                    
                    nodeIdx = feObj.nodeSet(BC(i).setID).nodes;
                    localNIdx = lnIdx(nodeIdx);
                    
                    if feObj.control.interpolationControl.method == 0
                        value = interp1q(timeVec,valueVec,time);
                        %value = interp1(timeVec,valueVec,time,'linear',0);
                    else
                        value = interp1(timeVec,valueVec,time,'spline',0);
                    end

                    switch BC(i).condition
                        case BoundaryConditions.nodeForce
                            for j = 1:length(localNIdx)
                                 localDofIdx = [(localNIdx(j)-1)*2+1,(localNIdx(j)-1)*2+2];
                                 f_a(localDofIdx) = f_a(localDofIdx)+[value(1);value(2)];
                            end
                        case BoundaryConditions.acceleration
                             flags.computeVolumetricLoads = true;
                             acceleration = BC(i).value;
                             elements = getElementsBySetId(feObj,BC(i).setID);
                             b(elements,:) = b(elements,:)+repmat(acceleration(:,:),length(elements),1);
                        case BoundaryConditions.displacement
                            local2DofIdx = [(localNIdx-1)*2.+1;(localNIdx-1)*2.+2]-length(fcN)*2;
                            u_int = [repmat(value(1),length(localNIdx),1)';repmat(value(2),length(localNIdx),1)'];
                            u_b(local2DofIdx) = u_int(:);
%                             for j = 1:length(localNIdx)
%                                localDofIdx(j,:) = [(localNIdx(j)-1)*2+1,(localNIdx(j)-1)*2+2];
%                                u_b(localDofIdx(j,:)-length(fcN)*2) = u_b(localDofIdx(j,:)-length(fcN)*2)+[value(1);value(2)];
%                             end
                    end
        end
end
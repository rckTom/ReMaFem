function feObj = vonMisesStress(feObj)
        vm = zeros(length(feObj.e),1);
        C = feObj.material.getC();
        for i =  1:length(feObj.e)
            nIdx = feObj.e(i,:);
            sigT = plane3(feObj.n(nIdx,:),C,0,0,reshape(feObj.nodeData.u(nIdx,1:2)',[],1),0,'sigma');
            vm(i) = sqrt(sigT(1)^2+sigT(2)^2-sigT(1)*sigT(2)+3*sigT(3)^2);
        end
        
        feObj.elementData.vonMisesStress = vm;
end
function bn = findBoundaryEdges(el)
    E = sort(el,2);
    [u,~,n] = unique(E,'rows');
    cnt = accumarray(n(:),1);
    bn = u(cnt==1,:);
end
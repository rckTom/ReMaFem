function e = findElementsByNode(e,n)
    e = find(any(ismember(e,n),2));
end
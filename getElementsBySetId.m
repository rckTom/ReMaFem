function elements = getElementsBySetId(feObj,id)
    if id == -1
        elements = 1:length(feObj.e);
    else
        elements = feObj.elementSet([feObj.elemenSet.id] == id);
    end
end
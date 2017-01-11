function val = createBoundaryCondition(feObj,name,setID,condition,value,time)
    feObj.boundaryConditions(end+1).setID = setID;
    feObj.boundaryConditions(end).condition = condition;
    feObj.boundaryConditions(end).value = value;
    feObj.boundaryConditions(end).time = time;
    feObj.boundaryConditions(end).name = name;
    val = feObj;
end

function set = getSetByName(setList,name)
   set= setList(ismember({setList.name},name));
end
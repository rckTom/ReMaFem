function feObj = keyWordImport(path)
    %Read whole file
    text = fileread(path);
    %remove all \r to consider unconcistent line endings
    text = regexprep(text,'\r','');
    %remove comments
    text = regexprep(text,'^\$.*$\n','','lineanchors','dotexceptnewline');
    %split into sections
    sections = strsplit(text,'*');
    %remove all empty sections
    sections = sections(~cellfun(@isempty,sections));
    %create a empty mesh instance
    feObj = feObjClass();
    for i=1:length(sections)
        [key,payload] = strtok(sections{i},char(10));
        key = strrep(key,' ','');
        switch key
            case 'ELEMENT_SHELL'
                data = textscan(payload,['%d%d',repmat('%d',[1,3]),'%d%d%d%d%d'],'MultipleDelimsAsOne',1,'Delimiter',' ','CollectOutput',1);
                feObj.e = data{1}(:,3:5);
            case 'NODE'
                data = textscan(payload,['%d',repmat('%f',[1,3]),'%d%d'],'MultipleDelimsAsOne',1,'Delimiter',' ','CollectOutput',1);
                feObj.n = data{2};
            case 'SET_NODE_LIST_TITLE'
                [name,payload] = strtok(payload,char(10));
                [nodes,sid] =  parseNodeSetList(payload(2:end));
                feObj.nodeSet(end+1).nodes = nodes;
                feObj.nodeSet(end).id = sid;
                feObj.nodeSet(end).name = name;
            case 'SET_NODE_LIST'
                [nodes,sid] = parseNodeSetList(payload);
                feObj.nodeSet(end+1).nodes = nodes;
                feObj.nodeSet(end).id = sid;
                feObj.nodeSet(end).name = num2str(sid);
        end
    end
end

function [nodeList,sid] = parseNodeSetList(payload)
    [sidString,payload] = strtok(payload,char(10));
    var = sscanf(sidString,'%d');
    sid = var(1);
    nodes = textscan(payload(2:end),'%f%f%f%f%f%f%f%f','MultipleDelimsAsOne',1,'CollectOutput',1);
    nodes = nodes{1};
    %Remove all zero elements
    nodes = nodes(nodes~=0);
    %Convert matrix to vector
    nodeList = nodes(:);
end

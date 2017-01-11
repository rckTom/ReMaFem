%Work in progress!!!

function [mesh,geometry,fileInfo] = gmshImport(path)
    %Read whole file
    text = fileread(path);
    %remove all \r to consider unconcistent line endings
    text = regexprep(text,'\r','');
    sections = regexp(text,'^\$(?<key>\w+$)\n(?<payload>.*?)^\$End\k<key>','lineanchors','names');
    
    mesh.n = [];
    mesh.e = [];
    mesh.nodeSet = {};
    fileInfo = struct();
    for i=1:length(sections)
       switch sections(i).key
           case 'MeshFormat'
               data = textscan(sections(i).payload,'%f%d%d','Delimiter',' ','MultipleDelimsAsOne',1);
               fileInfo.version = data{1};
               fileInfo.type = data{2};
               fileInfo.size = data{3};
           case 'Nodes'
               if(fileInfo.type == 0) %ASCII File format
                   data = textscan(sections(i).payload,['%d',repmat('%f',[1,3])],'MultipleDelimsAsOne',1,'Delimiter',' ','CollectOutput',1);
                   mesh.n = data{2};
               else
                   error('gmsh Binary Mesh formats are not supported');
               end
           case 'Elements'
               if(fileInfo.type == 0)
                   
               else
                   error('gmsh Binary Mesh formats are not supported');
               end
           case 'PhysicalNames'
               
       end
    end
end


function [] = vtuExport(filename,feObj,writeFormat,varargin)
    p = inputParser;
    addParameter(p,'FloatPrecision',6,@isinteger)
    parse(p,varargin{:});

    isBinary = [];
    if strcmp(writeFormat,'binary')
        isBinary = true;
    else
        isBinary = false;
    end
    
    doc = com.mathworks.xml.XMLUtils.createDocument('VTKFile');
    rootElement = doc.getDocumentElement();
    rootElement.setAttribute('type','UnstructuredGrid');
    rootElement.setAttribute('version','1.0');
    rootElement.setAttribute('byteOrder','LittleEndian');
    gridElement = doc.createElement('UnstructuredGrid');
    pieceElement = doc.createElement('Piece');
    pointsElement = doc.createElement('Points');
    cellsElement = doc.createElement('Cells');
    
   
    rootElement.appendChild(gridElement);
    gridElement.appendChild(pieceElement);
    pieceElement.appendChild(pointsElement);
    pieceElement.appendChild(cellsElement);
    pieceElement.setAttribute('NumberOfPoints',num2str(length(feObj.n)));
    pieceElement.setAttribute('NumberOfCells',num2str(length(feObj.e)));
    
    %Point Data Array
    pointsDataArray = doc.createElement('DataArray');
    pointsDataArray.setAttribute('Name','Points');
    pointsDataArray.setAttribute('type','Float64');
    pointsDataArray.setAttribute('NumberOfComponents','3');
    if isBinary
        pointsDataArray.setAttribute('format','binary');
        pointData = doc.createTextNode(base64DataArray(reshape(feObj.n',1,[]),'double'));
    else
        pointsDataArray.setAttribute('format','ascii');
        pointData = doc.createTextNode(sprintf('%f %f %f\n',reshape(feObj.n',1,[])));
    end
    
    pointsDataArray.appendChild(pointData);
    pointsElement.appendChild(pointsDataArray);
    
    %Cell Connectivity Array
    connectivityDataArray = doc.createElement('DataArray');
    connectivityDataArray.setAttribute('Name','connectivity');
    connectivityDataArray.setAttribute('type','Int64');
    
    if isBinary
        connectivityDataArray.setAttribute('format','binary');
        conData = doc.createTextNode(base64DataArray(reshape((feObj.e-1)',1,[]),'int64'));
    else
        connectivityDataArray.setAttribute('format','ascii');
        conData = doc.createTextNode(sprintf('%d %d %d %d %d %d %d %d %d %d\n',reshape((feObj.e-1)',1,[])));
    end
    connectivityDataArray.appendChild(conData);
    cellsElement.appendChild(connectivityDataArray);
    
    %Cell Type Array
    typeDataArray = doc.createElement('DataArray');
    typeDataArray.setAttribute('Name','types');
    typeDataArray.setAttribute('type','UInt8');
    
    if isBinary
        typeDataArray.setAttribute('format','binary');
        typeData = doc.createTextNode(base64DataArray(5*ones(length(feObj.e),1),'uint8'));
    else
        typeDataArray.setAttribute('format','ascii');
        typeData = doc.createTextNode(sprintf('%d %d %d %d %d %d %d %d %d %d\n',5*ones(length(feObj.e),1)));
    end
    typeDataArray.appendChild(typeData);
    cellsElement.appendChild(typeDataArray);
    
    %Cell Offset Array
    offsetDataArray = doc.createElement('DataArray');
    offsetDataArray.setAttribute('Name','offsets');
    offsetDataArray.setAttribute('type','Int64');   
    offset = zeros(length(feObj.e),1);
    last = 0;
    for i = 1:length(feObj.e)
        offset(i) = last + length(feObj.e(i,:));
        last = offset(i);
    end
    if isBinary
        offsetDataArray.setAttribute('format','binary');
        offsetData = doc.createTextNode(base64DataArray(offset,'int64'));
    else
        offsetDataArray.setAttribute('format','ascii');
        offsetData = doc.createTextNode(sprintf('%d %d %d %d %d %d %d %d %d %d\n',offset));
    end
    
    offsetDataArray.appendChild(offsetData);
    cellsElement.appendChild(offsetDataArray);
    
    %Element Data
    cellDataElement = doc.createElement('CellData');
    pieceElement.appendChild(cellDataElement);
    
    fields = fieldnames(feObj.elementData);
    for i = 1:length(fields)
        data = feObj.elementData.(fields{i});
        dataArray = doc.createElement('DataArray');
        dataArray.setAttribute('type','Float64');
        dataArray.setAttribute('Name',fields{i});
        format = ['%.' num2str(p.Results.FloatPrecision) 'f '];
        dataSize = size(data);
        if dataSize(2) == 3 %vector
            dataArray.setAttribute('NumberOfComponents','3');
            format = repmat(format,1,3);
        elseif dataSize(2) == 1 %scalar
            format = repmat(format,1,5);
        elseif dataSize(2) == 6 %tensor
            dataArray.setAttribute('NumberOfComponents','6');
            format = repmat(format,1,6);
            data = reshape(data',[],1);
        end
        
        if isBinary
            dataArray.setAttribute('format','binary');
            dataNode = doc.createTextNode(base64DataArray(data,'double'));
        else
            dataArray.setAttribute('format','ascii');
            dataNode = doc.createTextNode(sprintf([format '\n'],data));
        end
        
        dataArray.appendChild(dataNode);
        cellDataElement.appendChild(dataArray);
    end

    %Node Data
    pointDataElement = doc.createElement('PointData');
    pieceElement.appendChild(pointDataElement);
    
    fields = fieldnames(feObj.nodeData);
    for i = 1:length(fields)
        data = feObj.nodeData.(fields{i});
        dataArray = doc.createElement('DataArray');
        dataArray.setAttribute('type','Float64');
        dataArray.setAttribute('Name',fields{i});
        format = ['%.' num2str(p.Results.FloatPrecision) 'f ' ];
        dataSize = size(data);
        if dataSize(2) == 3 %vector
            dataArray.setAttribute('NumberOfComponents','3');
            format = repmat(format,1,3);
            data = reshape(data',[],1);
        elseif dataSize(2) == 1 %scalar
            format = repmat(format,1,5); 
        elseif dataSize(2) == 6 %tensor
            dataArray.setAttribute('NumberOfComponents','6');
            format = repmat(format,1,6);
            data = reshape(data',[],1);
        end
        
        if isBinary
            dataArray.setAttribute('format','binary');
            dataNode = doc.createTextNode(base64DataArray(data,'double'));
        else
            dataArray.setAttribute('format','ascii');
            dataNode = doc.createTextNode(sprintf([format '\n'],data));
        end

        dataArray.appendChild(dataNode);
        pointDataElement.appendChild(dataArray);
    end
    
    xmlwrite(filename,doc);
    
    function encString =  base64DataArray(data,type)
        data = data(:);
        data = cast(data,type);
        ele = data(1);
        whoData = whos('ele');
        dSize = numel(data)*whoData.bytes;
        data = typecast(data,'uint8');
        
        dSize = cast(dSize,'uint32');
        dSize = typecast(dSize,'uint8');
        
        encString = base64encode(char([dSize data']),'matlab',false,false);
    end
end
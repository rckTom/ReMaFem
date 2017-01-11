classdef paraviewXmlWriter < handle
   properties
       workingDir
       floatPrecision
       name
       writeFormat
       doc
       collectionElement
   end
   
   methods
       function obj = paraviewXmlWriter(workingDir,varargin)
          p = inputParser();
          addRequired(p,'workingDir');
          addParameter(p,'floatPrecision',uint32(6));
          addParameter(p,'fileName','run');
          addParameter(p,'writeFormat','binary');
          
          parse(p,workingDir,varargin{:});
          
          obj.workingDir = p.Results.workingDir;
          obj.floatPrecision = p.Results.floatPrecision;
          obj.name = p.Results.fileName;
          obj.writeFormat = p.Results.writeFormat;
       end
       
       function addTimestep(obj,feObj,t,nPlot)
           vtuExport([obj.workingDir '/' obj.name '/' num2str(nPlot,'%d') '.vtu'],...
                        feObj,...
                        feObj.control.outputControl.writeFormat,...
                        'FloatPrecision',obj.floatPrecision);
           dataFileName = [num2str(nPlot,'%d') '.vtu'];
           dataSet = obj.doc.createElement('DataSet');
           dataSet.setAttribute('timestep',num2str(t,obj.floatPrecision));
           dataSet.setAttribute('file',[obj.name '/' dataFileName]);
           obj.collectionElement.appendChild(dataSet);
           xmlwrite([obj.workingDir '/' obj.name '.pvd'],obj.doc);
       end
       
       function obj = createPVD(obj)
          obj.doc = com.mathworks.xml.XMLUtils.createDocument('VTKFile');
          rootElement = obj.doc.getDocumentElement();
          rootElement.setAttribute('type','Collection');
          obj.collectionElement = obj.doc.createElement('Collection');
          rootElement.appendChild(obj.collectionElement);
          xmlwrite([obj.workingDir '/' obj.name '.pvd'],obj.doc);
       end
   end
end

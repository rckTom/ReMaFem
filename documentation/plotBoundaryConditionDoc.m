% this function needs an feObj in memory to work on

function plotBoundaryConditionDoc(feObj)
%plot the mesh
h = figure();
trisurf(feObj.e,feObj.n(:,1),feObj.n(:,2),feObj.n(:,3),'FaceColor','none','LineWidth',0.1);
view(2);
axis equal
axis off
grid off
hold on

plot([0,0],[-0.5,1.5],'Color','b','LineWidth',1.5);
y = linspace(-0.5,1.5,6);
l = 0.6;
for i = 1:length(y)
   plot([0 ,-l*cos(45*pi/180)],[y(i) y(i)-l*cos(45*pi/180)],'Color','b','LineWidth',1.5);
end



for i = 1:length(feObj.boundaryConditions)
    bc = feObj.boundaryConditions(i);
    nIdx = feObj.nodeSet(bc.setID).nodes;
    nodeCoords = feObj.n(nIdx,:);
    nodeCoords = sort(nodeCoords,1);
    if(bc.condition == BoundaryConditions.displacement)
      % plot(nodeCoords(:,1),nodeCoords(:,2),'Color','b','LineWidth',1.5);
       
%        for j=1:7:length(nodeCoords)
%           plotAnchor(nodeCoords(j,1),nodeCoords(j,2),1); 
%        end
    elseif(bc.condition == BoundaryConditions.nodeForce)
        plot(nodeCoords(:,1),nodeCoords(:,2),'Color','r','LineWidth',1.5);
        for j=1:3:length(nodeCoords)
        plotArrow(nodeCoords(j,1),nodeCoords(j,2)+3,1,-pi/2); 
        end
    end
end

function plotAnchor(x,y,scale)
    lTriangle = 1;
    phiTriangle = 30*pi/180;
    rCircle = 0.1;
    numLines = 3;
    lLine = 0.6;
    phiLine = 30*pi/180;
    
    xTriangle = [0; -sin(phiTriangle)*lTriangle;sin(phiTriangle)*lTriangle;0];
    yTriangle = [0; -cos(phiTriangle)*lTriangle;-cos(phiTriangle)*lTriangle;0];
    
    xTriangle = xTriangle*scale + x;
    yTriangle = yTriangle*scale + y;
    
    plot(xTriangle,yTriangle,'Color','b','LineWidth',1.5);
    hold on
    rectangle('Position',[x-rCircle*scale,y-rCircle*scale,2*rCircle*scale,2*rCircle*scale],'Curvature',1 ,'EdgeColor','b','FaceColor','b','LineWidth',1.5);
    
    xLines = linspace(xTriangle(2),xTriangle(3),numLines);
    yLines = repmat(yTriangle(2),numLines,1);
    for k = 1:numLines
        x2 = xLines(k)-sin(phiLine)*lLine;
        y2 = yLines(k)-cos(phiLine)*lLine;
        plot([xLines(k);x2],[yLines(k);y2],'Color','b','LineWidth',1.5);
    end
end

function plotArrow(x,y,scale,rotate)
    lArrow = 3;
    phiHead = 30*pi/180;
    lHead = 0.5;
    
    arrowLineX = [0,lArrow]*scale;
    arrowLineY = [0,0]*scale;
    arrowHeadX = [lArrow-cos(0.5*phiHead)*lHead,lArrow,lArrow-cos(0.5*phiHead)*lHead]*scale;
    arrowHeadY = [sin(0.5*phiHead)*lHead,0,-sin(0.5*phiHead)*lHead]*scale;
    
    plot(arrowLineX*cos(rotate)+arrowLineY*sin(rotate)+x,arrowLineY*cos(rotate)+arrowLineX*sin(rotate)+y,'Color','r','LineWidth',1.5);
    fill(arrowHeadX*cos(rotate)+arrowHeadY*sin(rotate)+x,arrowHeadY*cos(rotate)+arrowHeadX*sin(rotate)+y,'r','EdgeColor','r','LineWidth',1.5);
end
   
end


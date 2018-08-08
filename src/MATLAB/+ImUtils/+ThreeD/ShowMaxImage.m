function imageHandle = ShowMaxImage(im,axisTitle,newFigure,maxAcross,axesHandle,fullscreen)
%imageHandle = ShowMaxImage(im,newFigure,maxAcross,axesHandle,fullscreen)
if (~exist('newFigure','var') || ~isempty(newFigure) || newFigure==true)
    figHandle = figure;
    axesHandle = axes('Parent',figHandle);
end

if (~exist('maxAcross','var') || isempty(maxAcross))
    maxAcross = 3;
end

if ((~exist('axesHandle','var') || isempty(axesHandle)) && newFigure==false)
    axesHandle = gca;
end

figHandle = get(axesHandle,'Parent');

if (~exist('fullscreen','var') || isempty(fullscreen))
    fullscreen = false;
end

if (fullscreen)
    set(figHandle,'unit','normalized','OuterPosition',[0,0,1,1]);
end

oldUnit = get(axesHandle,'unit');
if (fullscreen)
    set(axesHandle,'unit','normalized','Position',[0,0,1,1]);
end
set(axesHandle,'unit',oldUnit);

viewIm = squeeze(max(im,[],maxAcross));

if (ndims(viewIm)>2)
    error('ShowMaxImage can only display 3D images, this image has %d!',ndims(im));
end

if (islogical(viewIm))
    viewIm = im2uint8(viewIm);
end

%get axes limits
xl=xlim(axesHandle);
yl=ylim(axesHandle);
imDims = size(viewIm);
if ( all(xl == [0 1]) )
    xl = [1 imDims(2)];
    yl = [1 imDims(1)];
end

imageHandle = imagesc(viewIm,'Parent',axesHandle);

zoom(axesHandle, 'reset');

xlim(axesHandle, xl);
ylim(axesHandle, yl);

% set(get(axesHandle,'Parent'),'SizeChangedFcn',@KeepPlotEqual);
% set(zoom(axesHandle),'ActionPostCallback',@KeepPlotEqual);
% set(get(axesHandle,'Parent'),'CloseRequestFcn',@CleanUp);
% 
% KeepPlotEqual([],[],axesHandle);

colormap(axesHandle,gray(256));
if (exist('axisTitle','var'))
    title(axisTitle);
end
end

function KeepPlotEqual(hObject, eventdata,axesHandle)
global MIPaxisHandles

% add this handle to the list of resizeable axes
if (exist('axesHandle','var') && ~isempty(axesHandle))
    if (isempty(intersect(MIPaxisHandles,axesHandle)))
        MIPaxisHandles = vertcat(MIPaxisHandles,axesHandle);
    end
end

% if there are no resizable axes, get out
if (isempty(MIPaxisHandles))
    return
end

% check to see if this event was from initalization or from an event
if (~exist('hObject','var') || isempty(hObject))
    if (~exist('axesHandle','var') || isempty(axesHandle))
        error('Cannot determine which axis needs to be set!');
    end
end

if (~isempty(hObject))
    c = get(hObject,'Children');
    hs = intersect(MIPaxisHandles,c);
else
    hs = axesHandle;
end

% set each of the axes in this figure
for i=1:length(hs)
    xl = get(hs(i),'Xlim');
    yl = get(hs(i),'Ylim');
    op = get(hs(i),'Position');
    
    imH = get(hs(i),'children');
    imSize = [0,0];
    for j=1:length(imH)
        if (strcmpi(get(imH,'type'),'image'))
            imSize = size(imH(j).CData);
        end
    end
    xl(1) = max(xl(1),0);
    xl(2) = min(xl(2),imSize(2));
    yl(1) = max(yl(1),0);
    yl(2) = min(yl(2),imSize(1));
    
    op([1,2]) = max(op([1,2]),[0,0]);
    op([3,4]) = min(op([3,4]),[1,1]);
    set(hs(i),'Position',op);
    set(hs(i),'Color', [1 1 1] * 95/255);
    if (xl(1)<xl(2) && yl(1)<yl(2))
        set(hs(i),'XLim',xl,'YLim',yl);
    end
    axis(hs(i),'equal');    
end
end 

function CleanUp(hObject,eventdata)
global MIPaxisHandles

c = get(hObject,'Children');
hs = intersect(MIPaxisHandles,c);

MIPaxisHandles = setdiff(MIPaxisHandles,hs);
delete(hObject);
end

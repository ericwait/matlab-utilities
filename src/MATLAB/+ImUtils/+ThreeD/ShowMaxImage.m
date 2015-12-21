function imageHandle = ShowMaxImage(im,newFigure,maxAcross,axesHandle,fullscreen)
if (exist('newFigure','var') && ~isempty(newFigure) && newFigure==true)
    figHandle = figure;
    axesHandle = axes('Parent',figHandle);
end

if (~exist('maxAcross','var') || isempty(maxAcross))
    maxAcross = 3;
end

if (~exist('axesHandle','var') || isempty(axesHandle))
    axesHandle = gca;
end
if (~exist('fullscreen','var') || isempty(fullscreen))
    fullscreen = false;
end

if (fullscreen)
    set(figHandle,'unit','normalized','Position',[0,0,1,1]);
end

oldUnit = get(axesHandle,'unit');
set(axesHandle,'unit','normalized','Position',[0,0,1,1]);
set(axesHandle,'unit','pixel');

axisSize_xy = get(axesHandle,'Position');
set(axesHandle,'unit',oldUnit);
ar = axisSize_xy(4)/axisSize_xy(3);

viewIm = squeeze(max(im,[],maxAcross));

vwSize_rc = size(viewIm);

scale = [ar,1/ar];
scaledImSides_rc = scale .* Utils.SwapXY_RC(vwSize_rc);
[minVal,i] = max(scaledImSides_rc-vwSize_rc);

pad_rc = zeros(1,2);
pad_rc(i) = round(minVal);

newSize_rc = size(viewIm) + pad_rc;
padImage = ones(newSize_rc,'like',viewIm)*95/255;

padOffset_rc = round(pad_rc/2);

padImage(padOffset_rc(1)+1:vwSize_rc(1)+padOffset_rc(1),padOffset_rc(2)+1:vwSize_rc(2)+padOffset_rc(2)) = viewIm;

imageHandle = imagesc(-padOffset_rc(2)+1,-padOffset_rc(1)+1,padImage,'Parent',axesHandle);

colormap(axesHandle,'gray');
end
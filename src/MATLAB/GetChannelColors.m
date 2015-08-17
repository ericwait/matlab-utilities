function [ colors ] = GetChannelColors( imageData )
%GETCHANNELCOLORS Summary of this function goes here
%   Detailed explanation goes here

defaultColors = struct('str','','color',[]);
defaultColors(1).str = 'r';
defaultColors(1).color = [1.00 0.00 0.00];
defaultColors(2).str = 'g';
defaultColors(2).color = [0.00 1.00 0.00];
defaultColors(3).str = 'b';
defaultColors(3).color = [0.00 0.00 1.00];
defaultColors(4).str = 'c';
defaultColors(4).color = [0.00 1.00 1.00];
defaultColors(5).str = 'm';
defaultColors(5).color = [1.00 0.00 1.00];
defaultColors(6).str = 'y';
defaultColors(6).color = [1.00 1.00 0.00];

stains = setColors();

starts = zeros(1,length(stains));
for i=1:length(stains)
    idx = strfind(fullfile(imageData.imageDir,imageData.DatasetName),stains(i).stain);
    if (~isempty(idx))
        starts(i) = idx(1);
    end
end

[b, idx] = sort(starts);
stainOrder = idx(b>0);
if (isempty(stainOrder) || length(stainOrder)~=imageData.NumberOfChannels)
    dbstop in GetChannelColors at 34
    msgbox('Choose stains manually');
    disp([stains(stainOrder).stain]);
end

chanList = 1:imageData.NumberOfChannels;

[unusedColors, idx] = setdiff([defaultColors.str],[stains(stainOrder(chanList)).strColor]);
if (~isempty(unusedColors) && length(unusedColors)>6-imageData.NumberOfChannels)
    unused = 1;
    for c=1:length(chanList)-1
        for i=c+1:length(chanList)
            if (strcmp(stains(stainOrder(chanList(c))).strColor,stains(stainOrder(chanList(i))).strColor)~=0)
                stains(stainOrder(chanList(i))).strColor = defaultColors(idx(unused)).str;
                stains(stainOrder(chanList(i))).color = defaultColors(idx(unused)).color;
                unused = unused + 1;
            end
        end
    end
end

colors = zeros(length(chanList),3);
for c=1:length(chanList)
    colors(c,:) = stains(stainOrder(chanList(c))).color;
end

end

function stains = setColors()
stains = struct('stain','','color',[],'strColor','');

%% blue
stains(1).stain = 'DAPI';
stains(end).color = [0.00, 0.00, 0.50];
stains(end).strColor = 'b';

%% red
lclColor = [1.00 0.00 0.00];
lclStr = 'r';
stains = setNextColor(stains, 'Laminin', lclColor, lclStr);
stains = setNextColor(stains, 'laminin', lclColor, lclStr);
stains = setNextColor(stains, 'Tomato', lclColor, lclStr);
stains = setNextColor(stains, 'Bcat', lclColor, lclStr);
stains = setNextColor(stains, 'Mash', lclColor, lclStr);
stains = setNextColor(stains, 'Msh', lclColor, lclStr);
stains = setNextColor(stains, 'lectin', lclColor, lclStr);
stains = setNextColor(stains, 'Lectin', lclColor, lclStr);
stains = setNextColor(stains, 'EdU', lclColor, lclStr);
stains = setNextColor(stains, 'EDU', lclColor, lclStr);

%% green
lclColor = [0.00 1.00 0.00];
lclStr = 'g';
stains = setNextColor(stains, 'GFAP', lclColor, lclStr);
stains = setNextColor(stains, 'NCAM', lclColor, lclStr);
stains = setNextColor(stains, 'VCAM', lclColor, lclStr);

%% cyan
lclColor = [0.00 1.00 1.00];
lclStr = 'c';
stains = setNextColor(stains, 'DCX', lclColor, lclStr);
stains = setNextColor(stains, 'Dcx', lclColor, lclStr);
stains = setNextColor(stains, 'Itga', lclColor, lclStr);
%stains = setNextColor(stains, 'NCAM', lclColor, lclStr);

%% yellow
lclColor = [1.00 1.00 0.00];
lclStr = 'y';
stains = setNextColor(stains, 'Olig2', lclColor, lclStr);
stains = setNextColor(stains, 'Olg2', lclColor, lclStr);
stains = setNextColor(stains, 'EGFR', lclColor, lclStr);
% stains = setNextColor(stains, 'AcTub', lclColor, lclStr);
% stains = setNextColor(stains, 'Bcatenin', lclColor, lclStr);

%% magenta
lclColor = [1.00 0.00 1.00];
lclStr = 'm';
stains = setNextColor(stains, 'AcTub', lclColor, lclStr);
% stains = setNextColor(stains, 'VCAM', lclColor, lclStr);
% stains = setNextColor(stains, 'Mash', lclColor, lclStr);
end

function stains = setNextColor(stains, stainName, val, strC)
stains(end+1).stain = stainName;
stains(end).color = val;
stains(end).strColor = strC;
end


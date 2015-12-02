function [ colors, varargout ] = GetChannelColors( imageData, prompt )
%GETCHANNELCOLORS Summary of this function goes here
%   Detailed explanation goes here

if (~exist('prompt','var') || isempty(prompt))
    prompt = true;
end

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
defaultColors(7).str = 'w';
defaultColors(7).color = [1.00 1.00 1.00];

stains = MicroscopeData.Colors.SetList();

starts = zeros(1,length(stains));
for i=1:length(stains)
    idx = strfind(fullfile(imageData.imageDir,imageData.DatasetName),stains(i).stain);
    if (~isempty(idx))
        starts(i) = idx(1);
    end
end

[b, idx] = sort(starts);
stainOrder = idx(b>0);
if ((isempty(stainOrder) || length(stainOrder)~=imageData.NumberOfChannels) && prompt)
    dbstop in MicroscopeData.Colors.GetChannelColors at 42
    %%%%%%%%%%%%%%%%% FIX the stainOrder to what it really should be %%%%%%%%%%%
    disp(imageData.imageDir);
    disp(imageData.DatasetName);
    disp({stains(stainOrder).stain});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if (length(stainOrder)~=imageData.NumberOfChannels)
    colors = [];
    if (nargout>0)
        varargout{1} = '';
    end
    return
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

if (nargout>0)
    varargout{1} = {stains(stainOrder).stain};
end

end

function [ colors, stainNames ] = GetChannelColors( imageData, prompt )
%[ colors, stainNames ] = MicroscopeData.Colors.GetChannelColors( imageData, prompt )
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

expres = stains(1).name;
for i=2:length(stains)
    expres = [expres,'|',stains(i).name];
end

fullPath = fullfile(imageData.imageDir,imageData.DatasetName);
[startInds,endInds] = regexpi(fullPath,expres);

stainNames = cell(length(startInds),1);
for i=1:length(startInds)
    stainNames{i} = fullPath(startInds(i):endInds(i));
end

[~,order] = unique(stainNames);
stainNames = stainNames(sort(order));

stainOrder = zeros(length(stainNames),1);
for i=1:length(stainNames)
    for j=1:length(stains)
        if (strcmpi(stains(j).name,stainNames(i)))
            stainOrder(i) = j;
            break
        end
    end
end

if ((isempty(stainOrder) || length(stainOrder)~=imageData.NumberOfChannels) && prompt)
    dbstop in MicroscopeData.Colors.GetChannelColors at 58
    %%%%%%%%%%%%%%%%% FIX the stainOrder to what it really should be %%%%%%%%%%%
    disp(imageData.imageDir);
    disp(imageData.DatasetName);
    disp({stains(stainOrder).name});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if (length(stainOrder)~=imageData.NumberOfChannels)
    if (imageData.NumberOfChannels==1)
        colors = [1,1,1];
    else
        colors = [];
    end
    stainNames = '';
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
end

function readMicroscopeData()
[orgFileName,orgPathName,~] = uigetfile('*.*','Select Microscope Data');
if (orgFileName==0), return, end
ind = strfind(orgFileName,'.');
orgName = orgFileName(1:ind-1);

disp('Select output directory...');
outDir = uigetdir('.','Select Output Directory');
if (outDir==0), return, end

data = bfopen(fullfile(orgPathName,orgFileName));
if (isempty(data)), error('Could not read file!'), end

mkdir(fullfile(outDir,orgName));

for series=1:size(data,1)
%     labels = data{series,1}{1,2};
%     labelsParsed = strsplit(labels,';');
%     if (numel(labelsParsed)<2), continue, end
%     imageData.DatasetName = labelsParsed{2};
    metadata = data{series,4};
    imageData.DatasetName = char(metadata.getImageName(series-1));
    imageData.XDimension = safeGetValue(metadata.getPixelsSizeX(series-1));
    imageData.YDimension = safeGetValue(metadata.getPixelsSizeY(series-1));
    imageData.ZDimension = safeGetValue(metadata.getPixelsSizeZ(series-1));
    imageData.NumberOfChannels = safeGetValue(metadata.getPixelsSizeC(series-1));
    imageData.NumberOfFrames = safeGetValue(metadata.getPixelsSizeT(series-1));
    imageData.XPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeX(series-1));
    imageData.YPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeY(series-1));
    imageData.ZPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeZ(series-1));
    imageData.XPosition = double(metadata.getPlanePositionX(series-1,0));
    imageData.YPosition = double(metadata.getPlanePositionY(series-1,0));
    imageData.ZPosition = double(metadata.getPlanePositionZ(series-1,0));
    
    imageData.ChannelColors = char(metadata.getChannelName(series-1,0));
    for c=1:imageData.NumberOfChannels-1
        imageData.ChannelColors = [imageData.ChannelColors; {char(metadata.getChannelName(series-1,c))}];
    end
    
    im = zeros(imageData.XDimension,imageData.YDimension,imageData.ZDimension,imageData.NumberOfChannels,...
        imageData.NumberOfFrames,char(metadata.getPixelsType(series-1)));
    
    order = char(metadata.getPixelsDimensionOrder(series-1));
    imData = data{series,1};
    for t=1:imageData.NumberOfFrames
        for z=1:imageData.ZDimension
            for c=1:imageData.NumberOfChannels
                im(:,:,z,c,t) = imData{calcPlaneInd(order,z,c,t,imageData),1};
            end
        end
    end
    
    tiffWriter(im,fullfile(outDir,orgName,imageData.DatasetName,imageData.DatasetName),imageData)
    clear im
end
end

function ind = calcPlaneInd(order,z,c,t,imageData)
switch order(3)
    case 'Z'
        ind = z-1;
        mul = imageData.ZDimension;
    case 'C'
        ind = c-1;
        mul = imageData.NumberOfChannels;
    case 'T'
        ind = t-1;
        mul = imageData.NumberOfFrames;
end

switch order(4)
    case 'Z'
        ind = ind + (z-1)*mul;
        mul = imageData.ZDimension;
    case 'C'
        ind = ind + (c-1)*mul;
        mul = imageData.NumberOfChannels;
    case 'T'
        ind = ind + (t-1)*mul;
        mul = imageData.NumberOfFrames;
end

switch order(5)
    case 'Z'
        ind = ind + (z-1)*mul;
    case 'C'
        ind = ind + (c-1)*mul;
    case 'T'
        ind = ind + (t-1)*mul;
end

ind = ind +1;
end

function val = safeGetValue(varIn)
if (isempty(varIn))
    val = 0;
    return
end
val = varIn.getValue();
end
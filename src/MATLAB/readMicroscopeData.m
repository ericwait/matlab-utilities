function readMicroscopeData(dirIn, fileNameIn, dirOut,overwrite)
if (~exist('dirIn','var') || ~exist('fileNameIn','var') || isempty(dirIn) || isempty(fileNameIn))
    [orgFileName,orgPathName,~] = uigetfile('*.*','Select Microscope Data');
    if (orgFileName==0), return, end
else
    orgPathName = dirIn;
    orgFileName = fileNameIn;
end
ind = strfind(orgFileName,'.');
orgName = orgFileName(1:ind-1);

if (~exist('dirOut','var') || isempty(dirOut))
    disp('Select output directory...');
    outDir = uigetdir('.','Select Output Directory');
    if (outDir==0), return, end
else
    outDir = dirOut;
end

if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = 0;
end

[~,~,id] = mkdir(fullfile(outDir,orgName));
if (strcmp(id,'MATLAB:MKDIR:DirectoryExists') && overwrite==0)
    disp('exists');
    return;
end

fprintf('%s\n-->%s\n',fullfile(orgPathName,orgFileName),fullfile(outDir,orgName));

try
    data = bfopen(fullfile(orgPathName,orgFileName));
catch err
    disp(err.message);
    return
end

if (isempty(data)), error('Could not read file!'), end

for series=1:size(data,1)
    metadata = data{series,4};
    imageData.DatasetName = char(metadata.getImageName(series-1));
    imageData.XDimension = safeGetValue(metadata.getPixelsSizeX(series-1));
    imageData.YDimension = safeGetValue(metadata.getPixelsSizeY(series-1));
    imageData.ZDimension = safeGetValue(metadata.getPixelsSizeZ(series-1));
    imageData.NumberOfChannels = metadata.getChannelCount(series-1);
    imageData.NumberOfFrames = safeGetValue(metadata.getPixelsSizeT(series-1));
    
    imageData.XPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeX(series-1));
    if imageData.XPixelPhysicalSize==0
        imageData.XPixelPhysicalSize = 1;
    end
    
    imageData.YPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeY(series-1));
    if imageData.YPixelPhysicalSize==0
        imageData.YPixelPhysicalSize = 1;
    end
    
    imageData.ZPixelPhysicalSize = safeGetValue(metadata.getPixelsPhysicalSizeZ(series-1));
    if imageData.ZPixelPhysicalSize==0
        imageData.ZPixelPhysicalSize = 1;
    end
    if (metadata.getPlaneCount(series-1)>0)
        imageData.XPosition = double(metadata.getPlanePositionX(series-1,0));
        imageData.YPosition = double(metadata.getPlanePositionY(series-1,0));
        imageData.ZPosition = double(metadata.getPlanePositionZ(series-1,0));
    end
    
    imageData.ChannelColors = char(metadata.getChannelName(series-1,0));
    for c=1:imageData.NumberOfChannels-1
        imageData.ChannelColors = [imageData.ChannelColors; {char(metadata.getChannelName(series-1,c))}];
    end
    
    imageData.TimeStampDeltas = zeros(imageData.ZDimension,imageData.NumberOfChannels,imageData.NumberOfFrames);
    
    im = zeros(imageData.YDimension,imageData.XDimension,imageData.ZDimension,imageData.NumberOfChannels,...
        imageData.NumberOfFrames,char(metadata.getPixelsType(series-1)));
    
    order = char(metadata.getPixelsDimensionOrder(series-1));
    imData = data{series,1};
    for t=1:imageData.NumberOfFrames
        for z=1:imageData.ZDimension
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                im(:,:,z,c,t) = imData{ind,1};
                delta = metadata.getPlaneDeltaT(series-1,ind-1);
                if (~isempty(delta)) %hack for lsm
                    imageData.TimeStampDeltas(z,c,t) = delta;
                end
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
        mul = imageData.ZDimension*mul;
    case 'C'
        ind = ind + (c-1)*mul;
        mul = imageData.NumberOfChannels*mul;
    case 'T'
        ind = ind + (t-1)*mul;
        mul = imageData.NumberOfFrames*mul;
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
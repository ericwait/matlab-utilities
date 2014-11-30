function readMicroscopeData(dirIn, fileNameIn, dirOut, overwrite)
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
    
    imageData.ChannelColors = {};
    for c=0:imageData.NumberOfChannels-1
        if (~isempty(char(metadata.getChannelName(series-1,c))))
            imageData.ChannelColors = [imageData.ChannelColors; {char(metadata.getChannelName(series-1,c))}];
        end
    end
    
    imageData.StartCaptureDate = safeGetValue(metadata.getImageAcquisitionDate(series-1));
    ind = find(imageData.StartCaptureDate,':');
    if (~isempty(ind))
        imageData.StartCaptureDate(ind) = '.';
    end
    imageData.TimeStampDeltas = zeros(imageData.ZDimension,imageData.NumberOfChannels,imageData.NumberOfFrames);
    
    switch char(metadata.getPixelsType(series-1))
        case 'uint8'
            bit = 8;
        case 'uint16'
            bit = 16;
        case 'uint32'
            bit = 32;
        case 'int32'
            bit = 32;
        case 'single'
            bit = 32;
        case 'double'
            bit = 64;
        otherwise
            error('Unknown bit depth!');
    end
    
%     bitsNeeded = imageData.YDimension*imageData.XDimension*imageData.ZDimension*imageData.NumberOfChannels*...
%         imageData.NumberOfFrames*bit;
%     [~, systemview] = memory;
%     if (systemview.PhysicalMemory.Available - bitsNeeded < 0)
%         perPlane = 1;
%     else
        perPlane = 0;
%     end
%     
%     if (perPlane)
%         createMetadata(fullfile(outDir,orgName,imageData.DatasetName),imageData);
        im = zeros(imageData.YDimension,imageData.XDimension,char(metadata.getPixelsType(series-1)));
%     else
%         im = zeros(imageData.YDimension,imageData.XDimension,imageData.ZDimension,imageData.NumberOfChannels,...
%             imageData.NumberOfFrames,char(metadata.getPixelsType(series-1)));
%     end
%     
    order = char(metadata.getPixelsDimensionOrder(series-1));
    imData = data{series,1};
    for t=1:imageData.NumberOfFrames
        for z=1:imageData.ZDimension
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                if perPlane
                    fileName = sprintf('%s_c%02d_t%04d_z%04d.tif',fullfile(outDir,orgName,imageData.DatasetName,...
                        imageData.DatasetName),c,t,z);
                    imwrite(image2uint(imData{ind,1}),fileName,'tif','Compression','lzw');
                else
                    im(:,:,z,c,t) = imData{ind,1};
                    delta = metadata.getPlaneDeltaT(series-1,ind-1);
                    if (~isempty(delta)) %hack for lsm
                        imageData.TimeStampDeltas(z,c,t) = delta;
                    end
                end
            end
        end
    end
    
    if ~perPlane
        tiffWriter(im,fullfile(outDir,orgName,imageData.DatasetName,imageData.DatasetName),imageData)
        clear im
    end
end
system(sprintf('dir /B /O:N %s > %s',fullfile(outDir,orgName),fullfile(outDir,orgName,'list.txt')));
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
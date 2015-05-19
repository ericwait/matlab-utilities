function readMicroscopeData(dirIn, fileNameIn, dirOut, overwrite)
if (~exist('dirIn','var') || ~exist('fileNameIn','var') || isempty(dirIn) || isempty(fileNameIn))
    [fileNameIn,dirIn,~] = uigetfile('*.*','Select Microscope Data');
    if (fileNameIn==0), return, end
end
[datasetPath,datasetName,datasetExt] = fileparts(fullfile(dirIn,fileNameIn));
% ind = strfind(orgFileName,'.');
% orgName = orgFileName(1:ind-1);

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

if (strcmp(datasetExt,'.czi'))
    ind = strfind(datasetPath,'\');
    datasetParentFolder = datasetPath(ind(end)+1:end);
    outDir = fullfile(outDir,datasetParentFolder);
end

if (~exist(fullfile(outDir,datasetName),'dir'))
    mkdir(fullfile(outDir,datasetName));
elseif (~overwrite)
    disp('exists');
    return;
end

fprintf('%s\n-->%s\n',fullfile(datasetPath,[datasetName,datasetExt]),fullfile(outDir,datasetName));

try
    data = bfopen(fullfile(datasetPath,[datasetName,datasetExt]));
catch err
    disp(err.message);
    return
end

if (isempty(data)), error('Could not read file!'), end

for series=1:size(data,1)
    orgMetadata = data{series,2};
    omeMetadata = data{series,4};
    imageData.DatasetName = char(omeMetadata.getImageName(series-1));
    imageData.XDimension = safeGetValue(omeMetadata.getPixelsSizeX(series-1));
    imageData.YDimension = safeGetValue(omeMetadata.getPixelsSizeY(series-1));
    imageData.ZDimension = safeGetValue(omeMetadata.getPixelsSizeZ(series-1));
    imageData.NumberOfChannels = omeMetadata.getChannelCount(series-1);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series-1));
    
    imageData.XPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeX(series-1));
    if imageData.XPixelPhysicalSize==0
        imageData.XPixelPhysicalSize = 1;
    end
    
    imageData.YPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeY(series-1));
    if imageData.YPixelPhysicalSize==0
        imageData.YPixelPhysicalSize = 1;
    end
    
    imageData.ZPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeZ(series-1));
    if imageData.ZPixelPhysicalSize==0
        imageData.ZPixelPhysicalSize = 1;
    end
    
    if (strcmp(datasetExt,'.czi'))
        imageData.XPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|X #1');
        imageData.YPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|Y #1');
        imageData.ZPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|Z #1');
    elseif (omeMetadata.getPlaneCount(series-1)>0)
        imageData.XPosition = double(omeMetadata.getPlanePositionX(series-1,0));
        imageData.YPosition = double(omeMetadata.getPlanePositionY(series-1,0));
        imageData.ZPosition = double(omeMetadata.getPlanePositionZ(series-1,0));
    end
    
    imageData.ChannelColors = {};
    for c=0:imageData.NumberOfChannels-1
        if (strcmp(datasetExt,'.czi'))
            imageData.ChannelColors = [imageData.ChannelColors; {char(orgMetadata.get(['Global Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|Detector|Dye #' num2str(c+1)]))}];
        elseif (~isempty(char(omeMetadata.getChannelName(series-1,c))))
            imageData.ChannelColors = [imageData.ChannelColors; {char(omeMetadata.getChannelName(series-1,c))}];
        end
    end
    
    imageData.StartCaptureDate = safeGetValue(omeMetadata.getImageAcquisitionDate(series-1));
    ind = strfind(imageData.StartCaptureDate,':');
    if (~isempty(ind))
        imageData.StartCaptureDate(ind) = '.';
    end
    
    im = zeros(imageData.YDimension,imageData.XDimension,imageData.ZDimension,imageData.NumberOfChannels,imageData.NumberOfFrames,char(omeMetadata.getPixelsType(series-1)));
    imageData.TimeStampDeltas = 0;
  
    order = char(omeMetadata.getPixelsDimensionOrder(series-1));
    imData = data{series,1};
    for t=1:imageData.NumberOfFrames
        for z=1:imageData.ZDimension
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                im(:,:,z,c,t) = imData{ind,1};
                try
                    delta = omeMetadata.getPlaneDeltaT(series-1,ind-1);
                catch er
                    delta = [];
                end
                if (~isempty(delta))
                    imageData.TimeStampDeltas(z,c,t) = delta.floatValue;
                end
            end
        end
    end
    
    if (size(imageData.TimeStampDeltas,1)~=imageData.ZDimension ||...
            size(imageData.TimeStampDeltas,2)~=imageData.NumberOfChannels || ...
            size(imageData.TimeStampDeltas,3)~=imageData.NumberOfFrames)
        imageData = rmfield(imageData,'TimeStampDeltas');
    end
    
    tiffWriter(im,fullfile(outDir,datasetName),imageData);
    clear im
end
%system(sprintf('dir /B /ON "%s" > "%s"',fullfile(outDir,orgName),fullfile(outDir,orgName,'list.txt')));
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
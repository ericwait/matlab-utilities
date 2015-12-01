function [seriesMetadata, varargout] = GetMetadata( bfReader, datasetExt )
%GETMETADATA Summary of this function goes here
%   Detailed explanation goes here

seriesMetadata = {};

if (~exist('datasetExt','var') || isempty(datasetExt))
    datasetExt = '';
end

orgMetadata = bfReader.getSeriesMetadata();
omeMetadata = bfReader.getMetadataStore();

onlyOneSeries = true;
if (bfReader.getSeriesCount()>1)
    prgs = Utils.CmdlnProgress(bfReader.getSeriesCount(),true);
    onlyOneSeries = false;
end

for series=0:bfReader.getSeriesCount()-1;
    bfReader.setSeries(series);

    imageData = [];

    [~,imageData.DatasetName,~] = fileparts(char(omeMetadata.getImageName(series)));

    imageData.Dimensions = [safeGetValue(omeMetadata.getPixelsSizeX(series));...
                            safeGetValue(omeMetadata.getPixelsSizeY(series));...
                            safeGetValue(omeMetadata.getPixelsSizeZ(series))];

    imageData.NumberOfChannels = omeMetadata.getChannelCount(series);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series));

    xPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeX(series));
    if xPixelPhysicalSize==0
        xPixelPhysicalSize = 1;
    end

    yPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeY(series));
    if yPixelPhysicalSize==0
        yPixelPhysicalSize = 1;
    end

    zPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeZ(series));
    if zPixelPhysicalSize==0
        zPixelPhysicalSize = 1;
    end

    imageData.PixelPhysicalSize = [xPixelPhysicalSize; yPixelPhysicalSize; zPixelPhysicalSize];

    if (strcmp(datasetExt,'.czi'))
        imageData.Position = [orgMetadata.get('Global Information|Image|S|Scene|Position|X #1');...
                              orgMetadata.get('Global Information|Image|S|Scene|Position|Y #1');...
                              orgMetadata.get('Global Information|Image|S|Scene|Position|Z #1')];
    elseif (omeMetadata.getPlaneCount(series)>0)
        imageData.Position = [double(omeMetadata.getPlanePositionX(series,0));...
                              double(omeMetadata.getPlanePositionY(series,0));...
                              double(omeMetadata.getPlanePositionZ(series,0))];
    end

    imageData.ChannelColors = cell(imageData.NumberOfChannels,1);
    for c=1:imageData.NumberOfChannels
        colr = '';

        if (strcmp(datasetExt,'.czi'))
            colr = char(orgMetadata.get(['Global Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|Detector|Dye #' num2str(c)]));
        elseif (~isempty(char(omeMetadata.getChannelName(series,c-1))))
            colr = char(omeMetadata.getChannelName(series,c-1));
        end

        if (isempty(colr))
            colr = '';
        end

        imageData.ChannelColors{c} = colr;
    end

    imageData.StartCaptureDate = safeGetValue(omeMetadata.getImageAcquisitionDate(series));
    ind = strfind(imageData.StartCaptureDate,'T');
    if (~isempty(ind))
        imageData.StartCaptureDate(ind) = ' ';
    end

    imageData.TimeStampDelta = 0;

    order = char(omeMetadata.getPixelsDimensionOrder(series));

    if (onlyOneSeries)
        prgs = Utils.CmdlnProgress(imageData.NumberOfFrames*imageData.NumberOfChannels*imageData.Dimensions(3),true);
        i = 1;
    end

    for t=1:imageData.NumberOfFrames
        for z=1:imageData.Dimensions(3)
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                try
                    delta = omeMetadata.getPlaneDeltaT(series,ind-1);
                catch er
                    delta = [];
                end
                if (~isempty(delta))
                    imageData.TimeStampDelta(z,c,t) = delta.floatValue;
                end
                if (onlyOneSeries)
                    prgs.PrintProgress(i);
                    i = i+1;
                end
            end
        end
    end

    if (size(imageData.TimeStampDelta,1)~=imageData.Dimensions(3) ||...
            size(imageData.TimeStampDelta,2)~=imageData.NumberOfChannels || ...
            size(imageData.TimeStampDelta,3)~=imageData.NumberOfFrames)
        imageData = rmfield(imageData,'TimeStampDelta');
    end

    seriesMetadata{series+1} = imageData;

    prgs.PrintProgress(series+1);
end

prgs.ClearProgress();

if (nargout>1)
    varargout{1} = omeMetadata;
end
if (nargout>2)
    varargout{2} = orgMetadata;
end
end

function ind = calcPlaneInd(order,z,c,t,imageData)
switch order(3)
    case 'Z'
        ind = z-1;
        mul = imageData.Dimensions(3);
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
        mul = imageData.Dimensions(3)*mul;
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

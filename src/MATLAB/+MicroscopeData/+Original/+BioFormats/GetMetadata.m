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

refPosition = zeros(1,3);
for series=0:bfReader.getSeriesCount()-1
    imageData = [];
    
    imageData.DatasetName = parseImageName(char(omeMetadata.getImageName(series)), datasetExt, bfReader.getSeriesCount());

    imageData.Dimensions = [safeGetValue(omeMetadata.getPixelsSizeX(series)),...
                            safeGetValue(omeMetadata.getPixelsSizeY(series)),...
                            safeGetValue(omeMetadata.getPixelsSizeZ(series))];

    imageData.NumberOfChannels = omeMetadata.getChannelCount(series);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series));

    xPixelPhysicalSize = omeMetadata.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER).doubleValue();
    yPixelPhysicalSize = omeMetadata.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER).doubleValue();
    if (isempty(omeMetadata.getPixelsPhysicalSizeZ(0)))
        zPixelPhysicalSize = 1;
    else
        zPixelPhysicalSize = omeMetadata.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER).doubleValue();
    end

    imageData.PixelPhysicalSize = [xPixelPhysicalSize, yPixelPhysicalSize, zPixelPhysicalSize];

    try
    if (~isempty(omeMetadata.getPlanePositionX(series,0)))
        positionType = omeMetadata.getPlanePositionX(series,0).unit.getSymbol();
        if (strcmp(positionType,'reference frame'))
            imageData.Position = [safeGetValue(omeMetadata.getPlanePositionX(series,0)),...
                safeGetValue(omeMetadata.getPlanePositionY(series,0)),...
                safeGetValue(omeMetadata.getPlanePositionZ(series,0))];
            if (series>0)
                imageData.Position = refPosition + imageData.Position;
            else
                refPosition = imageData.Position;
            end
        else
            imageData.Position = [double(omeMetadata.getPlanePositionX(series,0).value(ome.units.UNITS.MICROMETER)),...
                double(omeMetadata.getPlanePositionY(series,0).value(ome.units.UNITS.MICROMETER)),...
                double(omeMetadata.getPlanePositionZ(series,0).value(ome.units.UNITS.MICROMETER))];
            
            if (series==0)
                refPosition = imageData.Position;
            end
        end
    else
        imageData.Position = [0,0,0];
    end
    catch err
        imageData.Position = [0,0,0];
    end
                          
    imageData.ChannelNames = cell(imageData.NumberOfChannels,1);
    for c=1:imageData.NumberOfChannels
        colr = deblank(char(omeMetadata.getChannelName(series,c-1)));

        if (isempty(colr))
            colr = sprintf('Channel:%d',c);
        end

        imageData.ChannelNames{c} = colr;
    end

    imageData.StartCaptureDate = char(omeMetadata.getImageAcquisitionDate(series));
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
                    imageData.TimeStampDelta(z,c,t) = safeGetValue(delta);
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
    
    imageData.imageDir = fileparts(char(bfReader.getCurrentFile));

    seriesMetadata{series+1} = imageData;

    prgs.PrintProgress(series+1);
end

prgs.ClearProgress();

if (length(seriesMetadata)==1)
    seriesMetadata = seriesMetadata{1};
end

if (nargout>1)
    varargout{1} = omeMetadata;
end
if (nargout>2)
    varargout{2} = orgMetadata;
end
end

% Remove extension from image names while maintaining series information
function datasetName = parseImageName(imageName, datasetExt, numSeries)
    datasetName = imageName;

    extPattern = '(\.\w+?)';
    if ( ~isempty(datasetExt) )
        extPattern = ['(' regexptranslate('escape', datasetExt) ')'];
    end
    
    tokMatch = regexp(imageName,['(.+?)' extPattern '\s*(.*)'], 'tokens','once');
    if ( isempty(tokMatch) )
        return;
    end
    
    % Drop the series suffix if there's only one
    if ( numSeries == 1 )
        datasetName = tokMatch{1};
        return;
    end
    
    datasetName = [tokMatch{1} '_' parseSuffix(tokMatch{3})];
end

function seriesSuffix = parseSuffix(suffixString)
    seriesSuffix = suffixString;
    
    % Strip leading spaces and surrounding parens
    tokMatch = regexp(suffixString,'^\s*\(?(.+?)\)?\s*$','tokens','once');
    if ( isempty(tokMatch) )
        return;
    end
    
    seriesSuffix = tokMatch{1};
    
    abbrev = {'series','s'; 'position','p'};
    for i=1:size(abbrev,1)
        seriesSuffix = regexprep(seriesSuffix,[abbrev{i,1} '\s*' '(\d+)'], [abbrev{i,2} '$1']);
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
    try
        val = varIn.value;
    catch err
        try
            val = varIn.getValue();
        catch err
            error(err.message);
        end
    end
    val = double(val);
end

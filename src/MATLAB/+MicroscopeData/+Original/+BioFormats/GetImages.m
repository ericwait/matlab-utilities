function [ seriesImages ] = GetImages( bfReader, seriesNum, varargin )
%GETIMAGES Summary of this function goes here
%   Detailed explanation goes here

numSeries = bfReader.getSeriesCount();

omeMetadata = bfReader.getMetadataStore();
prgs = Utils.CmdlnProgress(1,true, 'Reading Images');

p = inputParser();
p.StructExpand = false;

addParameter(p,'zList',[], @(x)(validOrEmpty(@isvector,x)));
addParameter(p,'cList',[], @(x)(validOrEmpty(@isvector,x)));
addParameter(p,'timeRange',[], @(x)(validOrEmpty(@isvector,x)));

parse(p,varargin{:});
argStruct = p.Results;

if (exist('seriesNum','var') && ~isempty(seriesNum) && numSeries>=seriesNum)
    seriesImages = readSeriesImage(bfReader, seriesNum-1, omeMetadata, true, prgs, argStruct);
else
    if (bfReader.getSeriesCount()>1)
        prgs.SetMaxIterations(bfReader.getSeriesCount());

        onlyOneSeries = false;
    else
        prgs.SetMaxIterations(numSeries);
        onlyOneSeries = true;
    end

    for series=0:numSeries-1
        im = readSeriesImage(bfReader, series, omeMetadata, onlyOneSeries, prgs, argStruct);

        seriesImages{series+1} = im;

        prgs.PrintProgress(series+1);
    end
end

if (length(seriesImages)==1)
    seriesImages = seriesImages{1};
end

prgs.ClearProgress(true);
end

% Inputs are valid if they are empty or if they satisfy their validity function
function bValid = validOrEmpty(validFunc,x)
    bValid = (isempty(x) || validFunc(x));
end

function im = readSeriesImage(bfReader, series, omeMetadata, onlyOneSeries, prgs, argStruct)
    bfReader.setSeries(series);

    imageData = [];
    
    imageData.Dimensions = [safeGetValue(omeMetadata.getPixelsSizeX(series));...
                            safeGetValue(omeMetadata.getPixelsSizeY(series));...
                            safeGetValue(omeMetadata.getPixelsSizeZ(series))];

    imageData.NumberOfChannels = omeMetadata.getChannelCount(series);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series));
    
    pixelType = char(omeMetadata.getPixelsType(series));
    if (strcmpi(pixelType,'float'))
        pixelType = 'single';
    end
    
    %% Support selecting channels
    if ( isempty(argStruct.cList) )
        argStruct.cList = 1:imageData.NumberOfChannels;
    end
    
    %% Support selecting z
    if ( isempty(argStruct.zList) )
        argStruct.zList = 1:imageData.Dimensions(3);
    end
    
    %% Support selecting time range
    if ( isempty(argStruct.timeRange) )
        argStruct.timeRante = [1,imageData.NumberOfFrames];
    end
    
    imageData.Dimensions(3) = length(argStruct.zList);
    imageData.NumberOfChannels = length(argStruct.cList);
    imageData.NumberOfFrames = argStruct.timeRange(2)-argStruct.timeRange(1)+1;
    
    im = zeros([Utils.SwapXY_RC(imageData.Dimensions'),imageData.NumberOfChannels,imageData.NumberOfFrames],pixelType);

    order = char(omeMetadata.getPixelsDimensionOrder(series));

    if (onlyOneSeries)
        prgs.SetMaxIterations(imageData.NumberOfFrames*imageData.NumberOfChannels*imageData.Dimensions(3));
        i = 1;
    end

    for tidx=1:imageData.NumberOfFrames
        for zidx=1:length(argStruct.zList)
            for cidx=1:length(argStruct.cList)
                c = argStruct.cList(cidx);
                z = argStruct.zList(zidx);
                
                t = argStruct.timeRange(1) + tidx - 1;
                
                ind = calcPlaneInd(order,z,c,t,imageData);
                im(:,:,zidx,cidx,tidx) = MicroscopeData.Original.BioFormats.GetPlane(bfReader,ind);

                if (onlyOneSeries)
                    prgs.PrintProgress(i);
                    i = i+1;
                end
            end
        end
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

function [ seriesImages ] = GetImages( bfReader, seriesNum )
%GETIMAGES Summary of this function goes here
%   Detailed explanation goes here

numSeries = bfReader.getSeriesCount();

omeMetadata = bfReader.getMetadataStore();
prgs = Utils.CmdlnProgress(1,true);

if (exist('seriesNum','var') && ~isempty(seriesNum) && numSeries>=seriesNum)
    seriesImages = readSeriesImage(bfReader, seriesNum-1, omeMetadata, true, prgs);
else
    if (bfReader.getSeriesCount()>1)
        prgs.SetMaxIterations(bfReader.getSeriesCount());

        onlyOneSeries = false;
    else
        prgs.SetMaxIterations(numSeries);
        onlyOneSeries = true;
    end

    for series=0:numSeries-1;
        im = readSeriesImage(bfReader, series, omeMetadata, onlyOneSeries, prgs);

        seriesImages{series+1} = im;

        prgs.PrintProgress(series+1);
    end
end

if (length(seriesImages)==1)
    seriesImages = seriesImages{1};
end

prgs.ClearProgress();
end

function im = readSeriesImage(bfReader, series, omeMetadata, onlyOneSeries, prgs)
    bfReader.setSeries(series);

    imageData = [];

    imageData.Dimensions = [safeGetValue(omeMetadata.getPixelsSizeX(series));...
                            safeGetValue(omeMetadata.getPixelsSizeY(series));...
                            safeGetValue(omeMetadata.getPixelsSizeZ(series))];

    imageData.NumberOfChannels = omeMetadata.getChannelCount(series);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series));

    clss = char(omeMetadata.getPixelsType(series));
    if (strcmpi(clss,'float'))
        clss = 'single';
    end
    im = zeros([Utils.SwapXY_RC(imageData.Dimensions'),imageData.NumberOfChannels,imageData.NumberOfFrames],clss);

    order = char(omeMetadata.getPixelsDimensionOrder(series));

    if (onlyOneSeries)
        prgs.SetMaxIterations(imageData.NumberOfFrames*imageData.NumberOfChannels*imageData.Dimensions(3));
        i = 1;
    end

    for t=1:imageData.NumberOfFrames
        for z=1:imageData.Dimensions(3)
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                im(:,:,z,c,t) = MicroscopeData.Original.BioFormats.GetPlane(bfReader,ind);

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

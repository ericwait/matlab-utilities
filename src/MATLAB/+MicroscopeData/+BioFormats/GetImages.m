function [ im ] = GetImages( bfReader )
%GETIMAGES Summary of this function goes here
%   Detailed explanation goes here

onlyOneSeries = true;
if (bfReader.getSeriesCount()>1)
    prgs = Utils.CmdlnProgress(bfReader.getSeriesCount(),true);
    onlyOneSeries = false;
end

for series=0:bfReader.getSeriesCount()-1;
    bfReader.setSeries(series);

    im = zeros(imageData.YDimension,imageData.XDimension,imageData.ZDimension,imageData.NumberOfChannels,imageData.NumberOfFrames,char(omeMetadata.getPixelsType(series)));

    order = char(omeMetadata.getPixelsDimensionOrder(series));
    
    if (onlyOneSeries)
        prgs = Utils.CmdlnProgress(imageData.NumberOfFrames*imageData.NumberOfChannels*imageData.ZDimension,true);
        i = 1;
    end
    
    for t=1:imageData.NumberOfFrames
        for z=1:imageData.ZDimension
            for c=1:imageData.NumberOfChannels
                ind = calcPlaneInd(order,z,c,t,imageData);
                im(:,:,z,c,t) = MicroscopeData.BioFormats.GetPlane(bfReader,ind);

                if (onlyOneSeries)
                    prgs.PrintProgress(i);
                    i = i+1;
                end
            end
        end
    end


    seriesImages{series+1} = im;
    
    prgs.PrintProgress(series+1);
end

prgs.ClearProgress();

bfReader.close();
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

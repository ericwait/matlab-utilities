function [seriesImages, seriesMetadata] = ReadMicroscopeData(dirIn, fileNameIn)
%READMICROSCOPEDATA [seriesImages, seriesMetadata] = ReadMicroscopeData(dirIn, fileNameIn)
%This function will read in data generated by a microscope and return the
%image data along with the metadata associated with each of the images.
%   dirIn and fileNameIn are both optional arguments where if either are
%   empty, a get file dialog will appear.
%
%   Microscope data may contain more than one set of images thus the output
%   of this function will each be cells. Each cell will contain the image
%   data and associated metadata for each microscope run.  There are more
%   than one "series" typically when there are multiple stage positions that
%   are being captured over an experiment.

seriesImages = {};
seriesMetadata = {};


%% get file and properties
if (~exist('dirIn','var') || ~exist('fileNameIn','var') || isempty(dirIn) || isempty(fileNameIn))
    [fileNameIn,dirIn,~] = uigetfile('*.*','Select Microscope Data');
    if (fileNameIn==0)
        warning('No images read');
        return
    end
end

[datasetPath,datasetName,datasetExt] = fileparts(fullfile(dirIn,fileNameIn));

%% ensure that the bioformats jar file is on the path
dynamicPaths = javaclasspath('-dynamic');
bfIsLoaded = false;
if (~isempty(dynamicPaths))
    for i=1:length(dynamicPaths)
        [~,name,~] = fileparts(dynamicPaths{i});
        if (strcmpi('bioformats_package',name))
            bfIsLoaded = true;
            break
        end
    end
end

if (~bfIsLoaded)
    curPath = mfilename('fullpath');
    [pathstr,~,~] = fileparts(curPath);
    javaaddpath(fullfile(pathstr,'+BioFormats','bioformats_package.jar'),'-end');
end

%% read data using bioformats
MicroscopeData.BioFormats.CheckJavaMemory();

bfReader = loci.formats.ChannelFiller();
bfReader = loci.formats.ChannelSeparator(bfReader);
OMEXMLService = loci.formats.services.OMEXMLServiceImpl();
bfReader.setMetadataStore(OMEXMLService.createOMEXMLMetadata());
bfReader.setId(fullfile(datasetPath,[datasetName,datasetExt]));

orgMetadata = bfReader.getSeriesMetadata();
omeMetadata = bfReader.getMetadataStore();

onlyOneSeries = true;
if (bfReader.getSeriesCount()>1)
    prgs = Utils.CmdlnProgress(bfReader.getSeriesCount(),true);
    onlyOneSeries = false;
end

for series=0:bfReader.getSeriesCount()-1;
    bfReader.setSeries(series);

    seriesDatasetName = char(omeMetadata.getImageName(series));
    if ( strcmpi(seriesDatasetName,[datasetName,datasetExt]) )
        imageData.DatasetName = datasetName;
    else
        imageData.DatasetName = seriesDatasetName;
    end

    imageData.XDimension = safeGetValue(omeMetadata.getPixelsSizeX(series));
    imageData.YDimension = safeGetValue(omeMetadata.getPixelsSizeY(series));
    imageData.ZDimension = safeGetValue(omeMetadata.getPixelsSizeZ(series));
    imageData.NumberOfChannels = omeMetadata.getChannelCount(series);
    imageData.NumberOfFrames = safeGetValue(omeMetadata.getPixelsSizeT(series));

    imageData.XPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeX(series));
    if imageData.XPixelPhysicalSize==0
        imageData.XPixelPhysicalSize = 1;
    end

    imageData.YPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeY(series));
    if imageData.YPixelPhysicalSize==0
        imageData.YPixelPhysicalSize = 1;
    end

    imageData.ZPixelPhysicalSize = safeGetValue(omeMetadata.getPixelsPhysicalSizeZ(series));
    if imageData.ZPixelPhysicalSize==0
        imageData.ZPixelPhysicalSize = 1;
    end

    if (strcmp(datasetExt,'.czi'))
        imageData.XPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|X #1');
        imageData.YPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|Y #1');
        imageData.ZPosition = orgMetadata.get('Global Information|Image|S|Scene|Position|Z #1');
    elseif (omeMetadata.getPlaneCount(series)>0)
        imageData.XPosition = double(omeMetadata.getPlanePositionX(series,0));
        imageData.YPosition = double(omeMetadata.getPlanePositionY(series,0));
        imageData.ZPosition = double(omeMetadata.getPlanePositionZ(series,0));
    end

    imageData.ChannelColors = cell(1,imageData.NumberOfChannels);
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

    im = zeros(imageData.YDimension,imageData.XDimension,imageData.ZDimension,imageData.NumberOfChannels,imageData.NumberOfFrames,char(omeMetadata.getPixelsType(series)));
    imageData.TimeStampDelta = 0;

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

    if (size(imageData.TimeStampDelta,1)~=imageData.ZDimension ||...
            size(imageData.TimeStampDelta,2)~=imageData.NumberOfChannels || ...
            size(imageData.TimeStampDelta,3)~=imageData.NumberOfFrames)
        imageData = rmfield(imageData,'TimeStampDelta');
    end

    seriesImages{series+1} = im;
    seriesMetadata{series+1} = imageData;
    
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
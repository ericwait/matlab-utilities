function [unmixedIm,factors,unmixFactors] = Image(im, imMetaDataOrJsonPath, showPlots, removeChannels, factors, unmixFactors )

if (~exist('im','var') || isempty(im))
    if (isfield(imMetaDataOrJsonPath,'DatasetName'))
        imD = imMetaDataOrJsonPath;
    elseif (~exist('imMetaDataOrJsonPath','var') || isempty(imMetaDataOrJsonPath))
        imD = MicroscopeData.ReadMetadata();
    elseif (~isfield(imMetaDataOrJsonPath,'DatasetName') || exist(imMetaDataOrJsonPath,'file') || exist(imMetaDataOrJsonPath,'dir'))
        imD = MicroscopeData.ReadMetadata(imMetaDataOrJsonPath);
    else
        error('No image read!');
    end
    im = MicroscopeData.Reader(imD);
end
if ~exist('showPlots','var') || isempty(showPlots)
    showPlots = 0;
end
if ~exist('removeChannels','var')
    removeChannels = [];
end

if (~exist('factors','var') || ~exist('unmixFactors','var') || isempty(factors) || isempty(unmixFactors))
    [ factors, unmixFactors ] = Unmix.LinearUnmixSignals(showPlots,removeChannels);
end
if isempty(factors)
    warning('Mixed factors are empty!');
    return
end

[~,~,maxVal] = Utils.GetClassBits(im);

if (max(im(:)) > 0.28*maxVal)
    unmixedIm = Cuda.Mex('LinearUnmixing',im,unmixFactors);
else
    unmixedIm = im;
end
end

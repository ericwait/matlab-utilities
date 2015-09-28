function [seriesImages, seriesMetaData] = ReadOriginalData(dirIn, fileNameIn)
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

%% get file and properties
if (~exist('dirIn','var') || ~exist('fileNameIn','var') || isempty(dirIn) || isempty(fileNameIn))
    [fileNameIn,dirIn,~] = uigetfile('*.*','Select Microscope Data');
    if (fileNameIn==0)
        warning('No images read');
        return
    end
end

[datasetPath,datasetName,datasetExt] = fileparts(fullfile(dirIn,fileNameIn));

MicroscopeData.BioFormats.CheckJarPath();

bfReader = MicroscopeData.BioFormats.GetReader(fullfile(datasetPath,[datasetName,datasetExt]));

seriesMetaData = MicroscopeData.BioFormats.GetMetadata(bfReader,datasetExt);
seriesImages = MicroscopeData.BioFormats.GetImages(bfReader);

bfReader.close();

end

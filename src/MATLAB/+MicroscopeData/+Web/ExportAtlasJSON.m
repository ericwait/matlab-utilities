function [] = ExportAtlasJSON(outputPath, imData)

imData.NumberOfPartitions = 1;

if(imData.isEmpty ~= 1)
    imData.NumberOfImagesWide = imData.numImIn(1);
    imData.NumberOfImagesHigh = imData.numImIn(2);
end

imData = rmfield(imData,'NumberOfChannels');
imData = rmfield(imData,'NumberOfFrames');
imData = rmfield(imData,'ChannelNames');
imData = rmfield(imData,'ChannelColors');
imData = rmfield(imData,'StartCaptureDate');
if isfield(imData,'TimeStampDelta')
imData = rmfield(imData,'TimeStampDelta');
end
imData = rmfield(imData,'imageDir');

MicroscopeData.CreateMetadata(outputPath, imData,1);

end
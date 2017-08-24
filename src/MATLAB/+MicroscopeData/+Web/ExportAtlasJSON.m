function [] = ExportAtlasJSON(outputPath, imData)

imData.NumberOfPartitions = 1;

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
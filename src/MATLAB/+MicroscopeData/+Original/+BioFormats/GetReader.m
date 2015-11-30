function [ bfReader ] = GetReader( fullPath )
%GETSERIESDATA Summary of this function goes here
%   Detailed explanation goes here

%% read data using bioformats
MicroscopeData.Original.BioFormats.CheckJavaMemory();
loci.common.DebugTools.enableLogging('INFO');

bfReader = loci.formats.ChannelFiller();
bfReader = loci.formats.ChannelSeparator(bfReader);
OMEXMLService = loci.formats.services.OMEXMLServiceImpl();
bfReader.setMetadataStore(OMEXMLService.createOMEXMLMetadata());

try
    bfReader.setId(fullPath);
catch err
    warning(err.message);
    bfReader = [];
end

end


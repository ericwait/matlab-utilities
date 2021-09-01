function metadata = GetMetadata(ims_file_path)
    metadata = MicroscopeData.GetEmptyMetadata();
    
    metadata.DatasetName = Ims.GetDatasetName(ims_file_path);
    
    metadata.Dimensions = Ims.GetImDims(ims_file_path);
    
    [metadata.NumberOfChannels, metadata.ChannelNames, metadata.ChannelColors] = Ims.GetNumberOfChannels(ims_file_path);
    
    metadata.NumberOfFrames = Ims.GetNumberOfImages(ims_file_path);
    
    metadata.PixelPhysicalSize = Ims.GetVoxelSize(ims_file_path);
    
    metadata.PixelFormat = Ims.GetImValueType(ims_file_path);
    
    metadata.imageDir = fileparts(ims_file_path);
end

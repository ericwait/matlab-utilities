function images = ReadAllImages(ims_file_path)
    max_frame = Ims.GetNumberOfImages(ims_file_path);
    max_channel = Ims.GetNumberOfChannels(ims_file_path);
    
    dims = Ims.GetImDims(ims_file_path);
    images = zeros([dims([2, 1, 3]), max_channel, max_frame], Ims.GetImValueType(ims_file_path));
    for t=1:max_frame
        for c=1:max_channel
            images(:,:,:,c,t) = Ims.ReadIm(ims_file_path,t,c,false);
        end
    end
end
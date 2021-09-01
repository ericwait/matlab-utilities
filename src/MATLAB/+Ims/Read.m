function [images, metadata] = Read(ims_file_path)
    metadata = Ims.GetMetadata(ims_file_path);
    images = Ims.ReadAllImages(ims_file_path);
end

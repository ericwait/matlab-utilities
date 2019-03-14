function Write3Dtif(im,fileName,outDir)
    if (ndims(im)>3)
        error('Function can only write 3D tiffs');
    end
    tags.ImageLength = size(im,1);
    tags.ImageWidth = size(im,2);
    tags.RowsPerStrip = size(im,2);
    tags.Photometric = Tiff.Photometric.MinIsBlack;
    tags.ExtraSamples = Tiff.ExtraSamples.Unspecified;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tags.SamplesPerPixel = 1;
    tags.Compression = Tiff.Compression.LZW;
    tags.Software = 'MATLAB';
    [bits,~,~,clss] = Utils.GetClassBits(im,false);
    tags.BitsPerSample = bits;
    
    switch clss
        case 'uint8'
            frmt = Tiff.SampleFormat.UInt;
        case 'uint16'
            frmt = Tiff.SampleFormat.UInt;
        case 'uint32'
            frmt = Tiff.SampleFormat.UInt;
        case 'int32'
            frmt = Tiff.SampleFormat.Int;
        case 'single'
            frmt = Tiff.SampleFormat.IEEEFP;
        case 'double'
            frmt = Tiff.SampleFormat.IEEEFP;
        otherwise
            error('Unknown type');
    end
    tags.SampleFormat = frmt;
    
    tiffObj = Tiff(fullfile(outDir,[fileName,'.tif']),'w');
    for z=1:size(im,3)
        tiffObj.setTag(tags);
        tiffObj.write(im(:,:,z),tags);
        tiffObj.writeDirectory();
    end
    tiffObj.close();
end

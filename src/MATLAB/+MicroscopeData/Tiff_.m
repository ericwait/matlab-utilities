function Tiff_(im,datasetName,outDir,chanList,timeRange,filePerZ,verbose)
    tags.ImageLength = size(im,1);
    tags.ImageWidth = size(im,2);
    tags.RowsPerStrip = size(im,1);
    tags.Photometric = Tiff.Photometric.MinIsBlack;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tags.SamplesPerPixel = 1;
    tags.Compression = Tiff.Compression.LZW;
    tags.Software = 'MATLAB';
    [bits,~,~,clss] = Utils.GetClassBits(im,false);
    tags.BitsPerSample = bits;
    frmt = 0;
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
    
    prgs = Utils.CmdlnProgress(size(im,4)*size(im,5),true,['Writing ', datasetName]);
    for t=1:length(timeRange(1):timeRange(2))
        for c=1:length(chanList)
            if (filePerZ)
                for z=1:size(im,3)
                    tiffObj = Tiff(fullfile(outDir,[datasetName,sprintf('_c%02d_t%04d_z%04d.tif',chanList(c),timeRange(1)+t-1,z)]),'w');
                    tiffObj.setTag(tags);
                    tiffObj.write(im(:,:,z,c,t),tags);
                    tiffObj.close();
                end
            else
                tiffObj = Tiff(fullfile(outDir,[datasetName,sprintf('_c%02d_t%04d.tif',chanList(c),timeRange(1)+t-1)]),'w');
                for z=1:size(im,3)
                    tiffObj.setTag(tags);
                    tiffObj.write(im(:,:,z,c,t),tags);
                    tiffObj.writeDirectory();
                end
                tiffObj.close();
            end
            if (verbose)
                prgs.PrintProgress(c+(t-1)*size(im,4));
            end
        end
    end
    if (verbose)
        prgs.ClearProgress(true);
    end
end

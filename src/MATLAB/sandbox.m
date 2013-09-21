im = zeros(imageDatasets(20).xDim,imageDatasets(20).yDim,imageDatasets(20).zDim,imageDatasets(20).NumberOfChannels,'uint8');

for c=1:4
    for z=1:61
        fileName = sprintf('%s_c%d_t%04d_z%04d.tif',imageDatasets(20).DatasetName,c,1,z);
        im(:,:,z,c) = imread(fullfile(rootDir,imageDatasets(20).DatasetName,fileName));
    end
end
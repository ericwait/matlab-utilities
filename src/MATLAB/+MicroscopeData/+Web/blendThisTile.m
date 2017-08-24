%% This function composes the CloneView3D single channel atlases into colored atlas
%   @tilePath - the path of the single channel atlas, for example, 3mon_SVZ/3mon_SVZ/4/0810
%   @atlasDimension - the dimension of the atlas, usually it's 4096
%   @outputFormat - the output atlas image format, you may have jpg, png or
%   tiff

function [] = blendThisTile(imData,tilePath, outputFormat)
% read the _images.json file the folder
[TileData,~,~] = MicroscopeData.ReadMetadata(tilePath);
imData.DatasetName = MicroscopeData.Helper.SanitizeString(imData.DatasetName);

if(TileData.isEmpty)
    return;
end

% set the input single channel atlas format
imInFormat = '%s_c%02d_t%04d.png';

% check output texture format
if(strcmp(outputFormat, 'png'))
    imOutFormat = '%s_c%02d_t%04d.png';
elseif(strcmp(outputFormat, 'tif'))
    imOutFormat = '%s_c%02d_t%04d.tif';
else
    imOutFormat = '%s_c%02d_t%04d.jpg';
end


if(imData.NumberOfChannels == 1)
    for t = 1:imData.NumberOfFrames
        imOrgName = fullfile(tilePath, sprintf(imInFormat, imData.DatasetName, 1, t));
        imOutName = fullfile(tilePath, sprintf(imOutFormat, [imData.DatasetName, '_blend'], 1, t));
        %movefile(imOrgName,imOutName,'f');
        imwrite(imread(imOrgName),imOutName)
    end
    
    %% has more than one channel
else
    
    
    imTemp = imread(fullfile(tilePath, sprintf(imInFormat,imData.DatasetName,1,1)));
    [DimX, DimY] = size(imTemp);
    im = zeros(DimX,DimY,imData.NumberOfChannels, imData.NumberOfFrames,'uint8');
    
    %%  read all the atlas into 4D data structure
    for c = 1:imData.NumberOfChannels
        for t = 1:imData.NumberOfFrames
            imName = fullfile(tilePath, sprintf(imInFormat,imData.DatasetName,c,t));
            im(:,:,c,t) = imread(imName);
        end
    end
    
    numText = ceil(imData.NumberOfChannels / 3);
    for t = 1:imData.NumberOfFrames
        for j = 1:numText
            imMix = zeros(size(im,1), size(im,2), 3,'uint8');
            
            startChan = 3*(numText-1)+1;
            endChan = min(3*numText,imData.NumberOfChannels);
            chanList =  startChan:endChan;
            for c = 1:length(chanList)
                imMix(:,:,c) = im(:,:,chanList(c),t);
            end
            imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'],j,t));
            imwrite(imMix, imOutName);
        end
    end
end
end
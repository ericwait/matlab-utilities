%% This function composes the CloneView3D single channel atlases into colored atlas
%   @tilePath - the path of the single channel atlas, for example, 3mon_SVZ/3mon_SVZ/4/0810
%   @atlasDimension - the dimension of the atlas, usually it's 4096
%   @outputFormat - the output atlas image format, you may have jpg, png or
%   tiff

function [] = blendThisTile(tilePath, outputFormat)
% read the _images.json file the folder
[imData,~,~] = MicroscopeData.ReadMetadata(tilePath);
imData.DatasetName = MicroscopeData.Helper.SanitizeString(imData.DatasetName);

%     if(imData.isEmpty)
%         return;
%     end

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

%% only one channel, just rename it
if(imData.NumberOfChannels == 1)
    parfor t = 1:imData.NumberOfFrames
        imOrgName = fullfile(tilePath, sprintf(imInFormat, imData.DatasetName, 1, t));
        imOutName = fullfile(tilePath, sprintf(imOutFormat, [imData.DatasetName, '_blend'], 1, t));
        movefile(imOrgName,imOutName,'f');
    end
    
%% has more than one channel    
else
    imTemp = imread(fullfile(tilePath, sprintf(imInFormat,imData.DatasetName,1,1)));
    [DimX, DimY] = size(imTemp);
    im = zeros(DimX,DimY,imData.NumberOfChannels, imData.NumberOfFrames,'uint8');
    
    % read all the atlas into 4D data structure
    for c = 1:imData.NumberOfChannels
        for t = 1:imData.NumberOfFrames
            imName = fullfile(tilePath, sprintf(imInFormat,imData.DatasetName,c,t));
            %                 convertToGray(imName);
            im(:,:,c,t) = imread(imName);
        end
    end
    
    % TODO: maybe use intensity threshold to identify empty space?
    if(nnz(im) <= imData.NumberOfChannels)
        imData.isEmpty = 1;
        MicroscopeData.Web.ExportAtlasJSON(tilePath, imData);
        return;
    else
        %% has 2 channels
        if(imData.NumberOfChannels == 2)
            atlasSize = size(im);
            imEmpty = zeros(atlasSize(1), atlasSize(2), 'uint8');
            for t = 1:imData.NumberOfFrames
                imMix = cat(3,im(:,:,1,t), im(:,:,2,t), imEmpty);
                imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'], 1, t));
                imwrite(imMix, imOutName);
            end
        else
            %% has more than 2 channels
            numMix = ceil(imData.NumberOfChannels / 3);
            remainMix = mod(imData.NumberOfChannels, 3);
            for t = 1:imData.NumberOfFrames
                if(remainMix > 0)
                    for j = 1:numMix -1
                        imMix = cat(3,im(:,:,3*j -2,t),im(:,:,3*j -1,t),im(:,:,3*j,t));
                        imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'],j,t));
                        imwrite(imMix, imOutName);
                    end
                    
                    if(remainMix == 2)
                        imMix = cat(3,im(:,:,3*numMix -2,t),im(:,:,3*numMix - 1,t));
                        imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'],numMix,t));
                        imwrite(imMix, imOutName);
                    end
                    
                    if(remainMix == 1)
                        imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'],numMix,t));
                        imwrite(im(:,:,end,t), imOutName);
                    end
                else
                    for j = 1:numMix
                        imMix = cat(3,im(:,:,3*j -2,t),im(:,:,3*j -1,t),im(:,:,3*j,t));
                        imOutName = fullfile(tilePath, sprintf(imOutFormat,[imData.DatasetName, '_blend'],j,t));
                        imwrite(imMix, imOutName);
                    end
                end
            end
        end
    end
end
end



function convertToGray(imName)

temp = imread(imName);
sizeTemp = size(temp);
if(length(sizeTemp)>2)
    if(sizeTemp(3) == 3)
        temp = rgb2gray(temp);
        imwrite(temp, imName);
    end
end

end
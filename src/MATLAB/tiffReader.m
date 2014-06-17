function [im, imageData] = tiffReader(type,chanList,timeList,zList,path)

if (~exist('path','var') || ~exist(path,'file'))
    path = [];
end

[imageData,path] = readMetaData(path);
if (isempty(imageData))
    return
end

if (~exist('chanList','var') || isempty(chanList))
    chanList = 1:imageData.NumberOfChannels;
end
if (~exist('timeList','var') || isempty(timeList))
    timeList = 1:imageData.NumberOfFrames;
end
if (~exist('zList','var') || isempty(zList))
    zList = 1:imageData.ZDimension;
end

if (~exist('type','var') || isempty(type))
    imInfo = imfinfo(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'tif');
    bytes = imInfo.BitDepth/8;
    if (imInfo.BitDepth==8)
        type = 'uint8';
    elseif (imInfo.BitDepth==16)
        type = 'uint16';
    elseif (imInfo.BitDepth==32)
        type = 'uint32';
    else
        type = 'double';
    end
elseif (strcmp(type,'double'))
    bytes=8;
    type = 'double';
elseif (strcmp(type,'uint32') || strcmp(type,'int32') || strcmp(type,'single'))
    bytes=4;
elseif (strcmp(type,'uint16') || strcmp(type,'int16'))
    bytes=2;
elseif (strcmp(type,'uint8'))
    bytes=1;
else
    error('Unsupported Type');
end

imType = imread(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,chanList(1),timeList(1),zList(1))),'tif');
typ = whos('imType');
clear imType

imtemp = zeros(imageData.YDimension,imageData.XDimension,length(zList),typ.class);
im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(chanList),length(timeList),type);

fprintf('Type:%s ',type);
fprintf('(');
fprintf('%d',size(im,2));
fprintf(',%d',size(im,1));
for i=3:length(size(im))
    fprintf(',%d',size(im,i));
end

fprintf(') %5.2fMB\n', (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024));

for t=1:length(timeList)
    for c=1:length(chanList)
        for z=1:length(zList)
            try
                imtemp(:,:,z) = imread(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif');
            catch err
                fprintf('\n****%s: %s\n',fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),err.identifier);
            end
        end
        im(:,:,:,c,t) = imageConvert(imtemp,type);
    end
end

clear imtemp
end

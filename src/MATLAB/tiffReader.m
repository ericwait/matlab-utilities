function [im, imageData] = tiffReader(type,chanList,timeList,zList,path)

if (~exist('path','var'))
    path = [];
end

[imageData,path] = readMetaData(path);
if (isempty(imageData))
    return
end

if (~exist('type','var') || isempty(type))
    bytes=8;
    type = 'double';
elseif (strcmp(type,'uint32') || strcmp(type,'int32') || strcmp(type,'double'))
    bytes=8;
elseif (strcmp(type,'uint16') || strcmp(type,'int16') || strcmp(type,'single'))
    bytes=4;
elseif (strcmp(type,'uint8'))
    bytes=1;
else
    error('Unsupported Type');
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

if (bytes==1)
    im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(timeList),length(chanList),'uint8');
elseif (bytes==4)
    im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(timeList),length(chanList),'single');
elseif (bytes==8)
    im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(timeList),length(chanList));
end

fprintf('(');
fprintf('%d',size(im,2));
fprintf(',%d',size(im,1));
for i=3:length(size(im))
    fprintf(',%d',size(im,i));
end

fprintf(') %5.2fMB\n', (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024));

for c=1:length(chanList)
    for t=1:length(timeList)
        for z=1:length(zList)
            try
            if (strcmp(type,'uint8'))
                im(:,:,z,t,c) = uint8(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (strcmp(type,'uint16'))
                im(:,:,z,t,c) = uint16(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (strcmp(type,'int16'))
                im(:,:,z,t,c) = int16(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (strcmp(type,'uint32'))
                im(:,:,z,t,c) = uint32(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (strcmp(type,'int32'))
                im(:,:,z,t,c) = int32(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (strcmp(type,'single'))
                im(:,:,z,t,c) = single(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (bytes==8)
                im(:,:,z,t,c) = imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif');
            end
            catch err
                fprintf('\n****%s: %s\n',fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),err.identifier);
            end
        end
        %fprintf('\n');
    end
end
end

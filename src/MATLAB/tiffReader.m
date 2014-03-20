function [im, imageData] = tiffReader(type,chanList,timeList,zList,path)
if (~exist('path','var') || isempty(path))
    path = uigetdir();
end

imageData = readMetaData(path);
if (isempty(imageData))
    return
end

if (~exist('type','var') || isempty(type))
    bytes=8;
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
            if (bytes==1)
                im(:,:,z,t,c) = uint8(imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif'));
            elseif (bytes==8)
                im(:,:,z,t,c) = imread(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),'tif');
            end
            catch err
                fprintf('\n****%s: %s\n',fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,chanList(c),timeList(t),zList(z))),err.identifier);
            end
        end
        fprintf('\n');
    end
end
end

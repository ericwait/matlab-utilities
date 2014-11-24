% TIFFREADER takes the optional arguments of:
% outType = the data type of image that you would like
% chanList = a list of the channels you would like to recive
% timeList = a list of frames that you would like to recive
% zList = a list of the stacks that you would like to recive
% path = the path to the meta data file
% quite = if set to 1 then size stats will not be printed
% im = image created from reading in all of the data and can be indexed as
% (Y,X,Z,C,T) : c = channel, t = frame
function [im, imageData] = tiffReader(outType,chanList,timeList,zList,path,quite)
im = [];
imageData = [];

if (~exist('path','var') || ~exist(path,'file'))
    path = [];
end

if (~exist('quite','var') || isempty(quite))
    quite = 0;
end

[imageData,path] = readMetaData(path);
if (isempty(imageData))
    warning('No image read!');
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

if (~exist(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'file'))
    if (exist(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'file'))
        answer = questdlg('Files need a zero padded channel, rename?','Rename','Yes','No','Yes');
        switch answer
            case 'Yes'
                for c=1:imageData.NumberOfChannels
                    for t=1:imageData.NumberOfFrames
                        for z=1:imageData.ZDimension
                            movefile(fullfile(path,sprintf('%s_c%d_t%04d_z%04d.tif',imageData.DatasetName,c,t,z)),...
                                fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,c,t,z)));
                        end
                    end
                end
            case 'No'
                warning('Unable to read images');
                return
        end
    else
        error('Unable to read images');
    end
end

if (~exist('outType','var') || isempty(outType))
    imInfo = imfinfo(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,1,1,1)),'tif');
    bytes = imInfo.BitDepth/8;
    if (imInfo.BitDepth==8)
        outType = 'uint8';
    elseif (imInfo.BitDepth==16)
        outType = 'uint16';
    elseif (imInfo.BitDepth==32)
        outType = 'uint32';
    else
        outType = 'double';
    end
elseif (strcmp(outType,'double'))
    bytes=8;
    outType = 'double';
elseif (strcmp(outType,'uint32') || strcmp(outType,'int32') || strcmp(outType,'single'))
    bytes=4;
elseif (strcmp(outType,'uint16') || strcmp(outType,'int16'))
    bytes=2;
elseif (strcmp(outType,'uint8'))
    bytes=1;
else
    error('Unsupported Type');
end

imType = imread(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',imageData.DatasetName,chanList(1),timeList(1),zList(1))),'tif');
typ = whos('imType');
clear imType
inType = typ.class;

im = zeros(imageData.YDimension,imageData.XDimension,length(zList),length(chanList),length(timeList),outType);

if (quite~=1)
    fprintf('Type:%s ',outType);
    fprintf('(');
    fprintf('%d',size(im,2));
    fprintf(',%d',size(im,1));
    for i=3:length(size(im))
        fprintf(',%d',size(im,i));
    end
    
    fprintf(') %5.2fMB\n', (imageData.XDimension*imageData.YDimension*length(zList)*length(chanList)*length(timeList)*bytes)/(1024*1024));
end

datasetName = imageData.DatasetName;
for t=1:length(timeList)
    frame = timeList(t);
    for c=1:length(chanList)
        chan = chanList(c);
        
        for z=1:length(zList)
            try
                if (strcmpi(inType,outType))
                    im(:,:,z,c,t) = imread(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',datasetName,chan,frame,zList(z))),'tif');
                else
                    im(:,:,z,c,t) = imageConvert(imread(fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',datasetName,chan,frame,zList(z))),'tif'),outType);
                end
            catch err
                fprintf('\n****%s: %s\n',fullfile(path,sprintf('%s_c%02d_t%04d_z%04d.tif',datasetName,chan,frame,zList(z))),err.identifier);
            end
        end
    end
end

clear imtemp
end

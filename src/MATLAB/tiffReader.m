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

 if (exist('tifflib') ~= 3)
     tifflibLocation = which('/private/tifflib');
     if (isempty(tifflibLocation))
         error('tifflib does not exits on this machine!');
     end
     copyfile(tifflibLocation,'.');
 end

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

imInfo = imfinfo(fullfile(path,sprintf('%s.tif',imageData.DatasetName)),'tif');
if (~exist('outType','var') || isempty(outType))
    bytes = imInfo(1).BitDepth/8;
    if (imInfo(1).BitDepth==8)
        outType = 'uint8';
    elseif (imInfo(1).BitDepth==16)
        outType = 'uint16';
    elseif (imInfo(1).BitDepth==32)
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
    error('Unsupported output type!');
end

switch imInfo(1).SampleFormat
    case 'Unsigned integer'
        frmt = 1;
    case 'Integer'
        frmt = 2;
    case 'IEEEFP'
        frmt = 3;
    otherwise
        error('Unsupported input type!');
end
switch imInfo(1).BitDepth
    case 8
        if (frmt==1)
            inType = 'uint8';
        elseif (frmt==2)
            inType = 'int8';
        else
            error('Unsupported input type!');
        end
    case 16
        if (frmt==1)
            inType = 'uint16';
        elseif (frmt==2)
            inType = 'int16';
        else
            error('Unsupported input type!');
        end
    case 32
        if (frmt==1)
            inType = 'uint32';
        elseif (frmt==2)
            inType = 'int32';
        elseif (frmt==3)
            inType = 'single';
        else
            error('Unsupported input type!');
        end
    case 64
        if (frmt==3)
            inType = 'double';
        else
            error('Unsupported input type!');
        end
    otherwise
        error('Unsupported input type!');
end

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

% fHand = tifflib('open',fullfile(path,sprintf('%s.tif',imageData.DatasetName)),'r');
% rowsPerStrip = tifflib('getField',fHand,Tiff.TagID.RowsPerStrip);
tiffObj = Tiff(fullfile(path,sprintf('%s.tif',imageData.DatasetName)),'r');

for t=1:imageData.NumberOfFrames
    frame = find(timeList==t);
    if (isempty(frame)), continue, end
    for c=1:imageData.NumberOfChannels
        chan = find(chanList==c);
        if (isempty(chan)), continue, end
        
        for z=1:imageData.ZDimension
            stack = find(zList==z);
            if (isempty(stack)), continue, end
            
%             tifflib('setDirectory',fHand,z + (c-1)*imageData.ZDimension + (t-1)*imageData.NumberOfChannels*imageData.ZDimension);
%             rowsPerStrip = min(rowsPerStrip,imageData.YDimension);
%             for r = 1:rowsPerStrip:imageData.YDimension
%                 rowIdx = r:min(imageData.YDimension,r+rowsPerStrip-1);
%                 stripNum = tifflib('computeStrip',fHand,r);
%                 im(rowIdx,:,stack,chan,frame) = tifflib('readEncodedStrip',stripNum,fHand);
%             end
            curDir = z + (c-1)*imageData.ZDimension + (t-1)*imageData.NumberOfChannels*imageData.ZDimension;
            tiffObj.setDirectory(curDir);
            im(:,:,stack,chan,frame) = tiffObj.read();
        end
    end
end
tiffObj.close();
end

function [imageData,rootDir] = readMetaData(root)

imageData = [];
rootDir = [];

if (~exist('root','var') || isempty(root))
    root = [];
end

if (isempty(strfind(root,'.txt')))
    [fileName,rootDir,filterIndex] = uigetfile(fullfile(root,'.txt'));
    if (filterIndex==0)
        return
    end
    root = fullfile(rootDir,fileName);
end

fileHandle = fopen(root);
imageData = readfile(fileHandle);
if (isempty(rootDir))
    pos = strfind(root,'\');
    rootDir = root(1:pos(end));
end

imageData.imageDir = rootDir;
end

function imageDatum = readfile(fileHandle)
imageDatum = {};

if fileHandle<=0, return, end

data = textscan(fileHandle,'%s %s', 'delimiter',':','whitespace','\n');
fclose(fileHandle);

if isempty(data), return, end

for k=1:length(data{1})
    val = str2double(data{2}{k});
    if (isnan(val))
        val = data{2}{k};
    end
    if (any(strfind(data{1}{k},'TimeStampDelta')))
        if (~isfield(imageDatum,'TimeStampDelta'))
            imageDatum.TimeStampDelta = zeros(imageDatum.ZDimension,imageDatum.NumberOfChannels,imageDatum.NumberOfFrames);
        end
        plane = textscan(data{1}{k},'TimeStampDelta(%d,%d,%d)%s');
        imageDatum.TimeStampDelta(plane{1},plane{2},plane{3}) = val;
    elseif (~isempty(val))
        imageDatum.(data{1}{k}) = val;
    end
end
imageDatum.imageDir = '.';
end

function [imageData,rootDir] = readMetadata(root)

imageData = [];
rootDir = [];

if (~exist('root','var') || isempty(root))
    root = [];
end

[~,~,ext] = fileparts(root);

if (~strcmp(ext,'.json') && ~strcmp(ext,'.txt'))
    [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt','Metadata files'},[],root);
    if (filterIndex==0)
        return
    end
    root = fullfile(rootDir,fileName);
end

fileHandle = fopen(root);

% Load and fixup txt metadata to be json-formatted for next time.
[~,~,chkExt] = fileparts(root);
if ( strcmpi(chkExt,'.txt') )
    imageData = readfile(fileHandle);
    if ( ~isempty(imageData.StartCaptureDate) )
        imageData.StartCaptureDate = strrep(imageData.StartCaptureDate,'.',':');
        imageData.StartCaptureDate = strrep(imageData.StartCaptureDate,'T',' ');
    end
else
    jsonData = fread(fileHandle,'*char').';
    imageData = parseJSON(jsonData);
end

fclose(fileHandle);

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

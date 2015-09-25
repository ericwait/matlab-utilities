function [imageData,rootDir] = ReadMetadata(root,prompt)

imageData = [];

if (~exist('prompt','var') || isempty(prompt))
    prompt = false;
end

if (~exist('root','var') || isempty(root))
    root = '';
end

% This is to help when the filename might have '.' whithin them
% TODO rework this logic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist([root,'.json'],'file'))
    root = [root,'.json'];
elseif (exist([root,'.txt'],'file'))
    root = [root,'.txt'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rootDir,fileName,ext] = fileparts(root);

if (~isempty(ext))
    % case root has an extension
    if (~strcmp(ext,'.json') && ~strcmp(ext,'.txt'))
        if (prompt)
            [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt','Metadata files'},[],root);
            if (filterIndex==0)
                return
            end
            root = fullfile(rootDir,fileName);
        else
            return
        end
    end
elseif (~isempty(fileName))
    % case root has a file name
    if (exist(fullfile(rootDir,[fileName,'.json']),'file'))
        root = fullfile(rootDir,[fileName,'.json']);
    elseif (exist(fullfile(rootDir,[fileName,'.txt']),'file'));
        root = fullfile(rootDir,[fileName,'.txt']);
    elseif (prompt)
        [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt','Metadata files'},[],root);
        if (filterIndex==0)
            return
        end
        root = fullfile(rootDir,fileName);
    else
        return
    end
elseif (~isempty(rootDir))
    % case root is a path (e.g. \ terminated)
    dirList = dir(fullfile(rootDir,'*.json'));
    if (isempty(dirList))
        dirList = dir(fullfile(rootDir,'*.txt'));
        if (isempty(dirList))
            return
        end
    end
    root = fullfile(rootDir,dirList(1).name);
elseif (prompt)
    % case where root is empty
    [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt','Metadata files'},[],root);
    if (filterIndex==0)
        return
    end
    root = fullfile(rootDir,fileName);
else
    return
end

if (~exist(root,'file'))
    return
end

fileHandle = fopen(root);

% Load and fixup txt metadata to be json-formatted for next time.
[~,~,chkExt] = fileparts(root);
if ( strcmpi(chkExt,'.txt') )
    imageData = readfile(fileHandle);
    if (isfield(imageData,'StartCaptureDate') && ~isempty(imageData.StartCaptureDate) )
        imageData.StartCaptureDate = strrep(imageData.StartCaptureDate,'.',':');
        imageData.StartCaptureDate = strrep(imageData.StartCaptureDate,'T',' ');
    end
else
    jsonData = fread(fileHandle,'*char').';
    imageData = Utils.ParseJSON(jsonData);
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

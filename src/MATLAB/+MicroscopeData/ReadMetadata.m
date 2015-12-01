function [imageData,rootDir,varargout] = ReadMetadata(root,prompt)

imageData = [];

if (~exist('prompt','var') || isempty(prompt))
    prompt = true;
end

if (~exist('root','var') || isempty(root))
    root = '';
end

if (nargout>0)
    varargout{1} = [];
end
if (nargout>1)
    varargout{2} = [];
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
        seriesMetaData =  MicroscopeData.Original.ReadMetadata(rootDir,[fileName,'.',ext]);
        if (~isempty(seriesMetaData))
            if (length(seriesMetaData)>1)
                prompt={sprintf('Enter the dataset number desired 1-%d',length(seriesMetaData))};
                name = 'Dataset Number';
                defaultans = {'1'};
                options.Interpreter = 'tex';
                answer = inputdlg(prompt,name,[1 40],defaultans,options);
                n = str2double(answer{1});
                imageData = seriesMetaData{n};
                if (nargout>0)
                    varargout{1} = n;
                end
            else
                imageData = seriesMetaData{1};
                if (nargout>0)
                    varargout{1} = 1;
                end
            end

            if (nargout>1)
                varargout{2} = fullfile(rootDir,[fileName,ext]);
            end
            return
        elseif (prompt)
            [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt;','Metadata files (*.json, *.txt)';'*.*','All Files (*.*)'},[],root);
            if (filterIndex==0)
                return
            end
            root = fullfile(rootDir,fileName);
        else
            return
        end
    else
        %do nothing becasue root should be a well formed path to our
        %metadata file
    end
elseif (~isempty(fileName))
    % case root has a file name
    if (exist(fullfile(rootDir,fileName,[fileName,'.json']),'file'))
        root = fullfile(rootDir,fileName,[fileName,'.json']);
    elseif (exist(fullfile(rootDir,fileName,[fileName,'.txt']),'file'));
        root = fullfile(rootDir,fileName,[fileName,'.txt']);
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
    [fileName,rootDir,filterIndex] = uigetfile({'*.json;*.txt;','Metadata files (*.json, *.txt)';'*.*','All Files (*.*)'},[],root);
    if (filterIndex==0)
        return
    end

    [~,~,ext] = fileparts(fileName);

    if (~strcmp(ext,'.txt') && ~strcmp(ext,'.json'))
        seriesMetaData =  MicroscopeData.Original.ReadMetadata(rootDir,fileName);
        if (length(seriesMetaData)>1)
            prompt={sprintf('Enter the dataset number desired 1-%d',length(seriesMetaData))};
            name = 'Dataset Number';
            defaultans = {'1'};
            options.Interpreter = 'tex';
            answer = inputdlg(prompt,name,[1 40],defaultans,options);
            n = str2double(answer{1});
            imageData = seriesMetaData{n};
            if (nargout>0)
                varargout{1} = n;
            end
        else
            imageData = seriesMetaData{1};
            if (nargout>0)
                varargout{1} = 1;
            end
        end

        if (nargout>1)
            varargout{2} = fullfile(rootDir,fileName);
        end

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

[imageData.imageDir,~,~] = fileparts(root);
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
            imageDatum.TimeStampDelta = zeros(imageDatum.Dimensions(3),imageDatum.NumberOfChannels,imageDatum.NumberOfFrames);
        end
        plane = textscan(data{1}{k},'TimeStampDelta(%d,%d,%d)%s');
        imageDatum.TimeStampDelta(plane{1},plane{2},plane{3}) = val;
    elseif (~isempty(val))
        imageDatum.(data{1}{k}) = val;
    end
end
imageDatum.imageDir = '.';
end

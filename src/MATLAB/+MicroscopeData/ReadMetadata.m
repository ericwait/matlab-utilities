function [imageData,jsonDir,jsonFile] = ReadMetadata(root,forcePrompt,promptTitle)

imageData = [];
jsonDir = [];
jsonFile = [];

if ( ~exist('promptTitle','var') )
    promptTitle = [];
end

if (~exist('forcePrompt','var'))
    forcePrompt = [];
end

if (~exist('root','var'))
    root = '';
end

if (~isempty(root) && ~any(strcmp(root(end),{'\','/'})) && exist(root,'dir'))
    root = fullfile(root, filesep);
end

% This is to help when the filename might have '.' whithin them
% TODO rework this logic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist([root,'.json'],'file'))
    root = [root,'.json'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bAlwaysPrompt = (~isempty(forcePrompt) && forcePrompt);
if ( ~bAlwaysPrompt )
    [imageData,jsonDir,jsonFile] = MicroscopeData.ReadMetadataFile(root);
end

bNeedData = (isempty(forcePrompt) && isempty(imageData));
if ( bAlwaysPrompt || bNeedData )
    [fileName,rootDir,filterIndex] = uigetfile({'*.json','Metadata files (*.json)';'*.*','All Files (*.*)'},promptTitle,root);
    if (filterIndex==0)
        return
    end

    root = fullfile(rootDir,fileName);
    [imageData,jsonDir,jsonFile] = MicroscopeData.ReadMetadataFile(root);
end

end

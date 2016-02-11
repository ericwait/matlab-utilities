function CreateMetadata(root,imageData,quiet)

if (isempty(root))
    if (isfield(imageData,'imageDir'))
        openDir = imageData.imageDir;
    else
        openDir = [];
    end
    root = uigetdir(openDir,'Directory to Place Metadata');
    if (root==0)
        return
    end
end

if (~exist(root,'dir'))
    mkdir(root);
end

if (~exist('quiet','var') || isempty(quiet))
    quiet = 0;
end

fileName = fullfile(root,[imageData.DatasetName '.json']);

if (~quiet)
    fprintf('Creating Metadata %s...',fileName);
end

if (isfield(imageData,'imageDir'))
    imageData = rmfield(imageData,'imageDir');
end

jsonMetadata = Utils.CreateJSON(imageData);
fileHandle = fopen(fileName,'wt');

fwrite(fileHandle, jsonMetadata, 'char');

fclose(fileHandle);

if (~quiet)
    fprintf('Done\n');
end
end
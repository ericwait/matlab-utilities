function CreateMetadata(root,imageData,ExpName, verbose)

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

if (~exist('verbose','var') || isempty(verbose))
    verbose = 0;
end
%% Write Experiment Name 
if (exist('ExpName','var') && ~isempty(ExpName))
    imageData.ExperimentName = ExpName;
end

fileName = fullfile(root,[imageData.DatasetName '.json']);

if (verbose)
    fprintf('Creating Metadata %s...',imageData.DatasetName);
end

if (isfield(imageData,'imageDir'))
    imageData = rmfield(imageData,'imageDir');
end

%% Write To Json 
jsonMetadata = Utils.CreateJSON(imageData);
fileHandle = fopen(fileName,'wt');

fwrite(fileHandle, jsonMetadata, 'char');

fclose(fileHandle);

if (verbose)
    fprintf('Done\n');
end
end
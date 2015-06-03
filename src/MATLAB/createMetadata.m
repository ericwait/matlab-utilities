function createMetadata(root,imageData,quiet)

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

jsonMetadata = createJSON(imageData);
fileHandle = fopen(fileName,'wt');

fwrite(fileHandle, jsonMetadata, 'char');

fclose(fileHandle);

if (~quiet)
    fprintf('Done\n');
end
end
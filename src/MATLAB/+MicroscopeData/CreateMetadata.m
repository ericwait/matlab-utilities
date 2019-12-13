% CreateMetadata(root,imageData, varargin)
% Create metadata JSON file from imageData structure
% 
% Optional Parameters (Key,Value pairs):
%
% expName - Add 'ExperimentName' field to JSON and populate with expName
% filename - Force name of json file to filename
% verbose - Display verbose output and timing information

function CreateMetadata(root,imageData, varargin)

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

p = inputParser();
p.StructExpand = false;

addParameter(p,'verbose',false, @islogical);
addParameter(p,'expName','',@(x)(validOrEmpty(@ischar,x)));
addParameter(p,'filename','',@(x)(validOrEmpty(@ischar,x)));

parse(p, varargin{:});
args = p.Results; 


%% Write Experiment Name 
if (~isempty(args.expName))
    imageData.ExperimentName = args.ExpName;
end

filename = [imageData.DatasetName '.json'];
if ( ~isempty(args.filename) )
    filename = args.filename;
end

filePath = fullfile(root, filename);

if (args.verbose)
    fprintf('Creating Metadata %s(%s)...',filename, imageData.DatasetName);
end

if (isfield(imageData,'imageDir'))
    imageData = rmfield(imageData,'imageDir');
end

%% Write To Json 
jsonMetadata = Utils.CreateJSON(imageData);
fileHandle = fopen(filePath,'wt');

fwrite(fileHandle, jsonMetadata, 'char');

fclose(fileHandle);

if (args.verbose)
    fprintf('Done\n');
end
end

% Inputs are valid if they are empty or if they satisfy their validity function
function bValid = validOrEmpty(validFunc,x)
    bValid = (isempty(x) || validFunc(x));
end

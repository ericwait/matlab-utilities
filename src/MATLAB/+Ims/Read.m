function [all_metadata, all_images] = Read(ims_file_path, varargin)
    % Read all datasets within an IMS file and return their metadata and images
    % in cell arrays.
    %
    % Parameters:
    %   ims_file_path (string) : The path to the IMS file.
    %   errorcheck (logical)   : Optional. Perform error checking or not.
    %
    % Returns:
    %   all_metadata (cell array) : Metadata for each dataset.
    %   all_images (cell array)    : Images for each dataset.
    
    if nargin > 1
        errorcheck = varargin{1};
    else
        errorcheck = true;
    end
    
    % Get the total number of datasets
    num_datasets = Ims.GetNumberOfDatasets(ims_file_path); 
    
    all_metadata = cell(1, num_datasets);
    all_images = cell(1, num_datasets);
    
    for ds = 1:num_datasets
        % Get metadata for the current dataset
        all_metadata{ds} = Ims.GetMetadata(ims_file_path, 'Dataset', ds);
        
        % Read all images for the current dataset
        all_images{ds} = Ims.ReadAllImages(ims_file_path, [], [], 'Dataset', ds, 'ErrorCheck', errorcheck); % Replace with your function
    end
end

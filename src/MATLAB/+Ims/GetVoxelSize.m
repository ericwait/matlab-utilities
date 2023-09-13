% GETPIXELPITCHFROMIMS Reads the pixel pitch (x, y, z dimensions) from an IMS file.
%
%   pixelPitch = GETPIXELPITCHFROMIMS(filePath, datasetInfoNum)
%   reads the pixel pitch from a specific dataset.
%
% Parameters:
%   filePath       - Full path to the .ims file (string).
%   datasetInfoNum - Optional dataset index (numeric, default='').
%
% Returns:
%   pixelPitch - A vector [xPitch, yPitch, zPitch] of pixel sizes in x, y, and z dimensions.

function pixelPitch = GetVoxelSize(filePath, varargin)
    [~, ~, ~, dataset_num] = Ims.DefaultArgParse_(varargin{:});
    try
        % Retrieve the image extents and dimensions using existing functions
        ext_xyz = Ims.GetImExt(filePath, dataset_num);
        dims_xyz = Ims.GetImDims(filePath, 'Dataset', dataset_num);
        
        % Compute the pixel pitch
        pixelPitch = ext_xyz ./ dims_xyz;
        
    catch ME
        warning('Could not read pixel pitch from IMS file. Returning empty array.');
        fprintf('%s\n', ME.message);
        pixelPitch = [];
    end
end

% GETMETADATA Retrieves metadata information from an IMS file.
%
%   metadata = GETMETADATA(ims_file_path, datasetInfoNum) gathers
%   the metadata from a specific dataset in the IMS file.
%
% Parameters:
%   ims_file_path  - Full path to the IMS file (string).
%   datasetInfoNum - Optional dataset index (numeric, default='').
%
% Returns:
%   metadata - Struct containing various metadata fields.

function metadata = GetMetadata(ims_file_path, varargin)

    metadata = MicroscopeData.GetEmptyMetadata();
    
    metadata.DatasetName = Ims.GetDatasetName(ims_file_path, varargin{:});
    
    metadata.Dimensions = Ims.GetImDims(ims_file_path, varargin{:});
    
    [metadata.NumberOfChannels, metadata.ChannelNames, metadata.ChannelColors] = Ims.GetNumberOfChannels(ims_file_path, varargin{:});
    
    metadata.NumberOfFrames = Ims.GetNumberOfTimePoints(ims_file_path, varargin{:});
    
    metadata.PixelPhysicalSize = Ims.GetVoxelSize(ims_file_path, varargin{:});
    
    metadata.PixelFormat = Ims.GetImValueType(ims_file_path, varargin{:});
    
    metadata.imageDir = fileparts(ims_file_path);
end

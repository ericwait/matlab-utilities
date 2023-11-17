function files = GetFilesRecursively(root_dir, ext)
    % GetFilesRecursively: Recursively gets all files with a specific extension 
    % from a given root directory.
    %
    % Inputs:
    %   root_dir: The root directory from which the search begins.
    %   ext: The file extension to search for (e.g., 'txt').
    %
    % Outputs:
    %   files: An array of structures containing information about the files found.

    % Recursively find files with the given extension in the root directory
    files = dir(fullfile(root_dir, ['**/*.', ext]));
    
    % In some MATLAB versions, dir can return empty structs for non-existing paths,
    % filter these out.
    files = files(~cellfun(@isempty, {files.name}));
    files = Utils.SortDirStruct(files);
end

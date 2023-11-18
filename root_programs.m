function str = root_programs()
    % root_programs - Determines the root directory for programs.
    %
    % This function computes the root directory for storing or accessing
    % programs. The path is determined based on the operating system.
    % For Windows, it derives the path from the user's MATLAB userpath.
    % For non-Windows systems, it defaults to the user's home directory.
    %
    % Output:
    %   str - A string representing the computed root directory path.

    % Check if the operating system is Windows
    if ispc
        % Obtain the user's MATLAB userpath
        usr_path = userpath;

        % Split the userpath to extract components
        path_comp = split(usr_path, filesep);  % Using filesep for OS compatibility

        % Construct the root path from the first three components
        % This assumes the userpath follows a specific structure
        str = fullfile(path_comp{1}, path_comp{2}, path_comp{3});
    else
        % For non-Windows systems, use the user's home directory
        str = '~';
    end
end

function subDirs = GetSubDirectories(rootDir, pattern)
% GetSubDirectories returns a cell array of subdirectories with alternating lexicographic and numeric sorting.
%   subDirs = GetSubDirectories(rootDir, pattern)
%   rootDir: The root directory to search for subdirectories.
%   pattern: A regular expression pattern to match subdirectory names.
%   Returns:
%       subDirs: Cell array of subdirectories sorted in alternating lexicographic and numeric order.

    if ~exist("pattern", "var") || isempty(pattern)
        pattern = '.*';
    end

    dList = dir(rootDir);
    subDirs = {dList([dList.isdir] & ~ismember({dList.name},{'.','..'})).name}';
    
    % Sort subdirectories based on alternating lexicographic and numeric order
    subDirs = sort_subdirectories(subDirs);
    
    % Nested function to sort subdirectories
    function sortedDirs = sort_subdirectories(dirs)
        lexDirs = {};  % Directories to sort lexicographically
        numDirs = {};  % Directories to sort numerically
        
        % Classify directories into lexicographic and numeric
        for i = 1:numel(dirs)
            name = dirs{i};
            if ~isempty(regexp(name, pattern, 'once'))  % Check if name matches pattern
                numDirs = [numDirs; name];
            else
                lexDirs = [lexDirs; name];
            end
        end
        
        % Sort lexicographic directories
        lexDirs = sort(lexDirs);
        
        % Sort numeric directories
        numDirs = sort_numeric(numDirs);
        
        % Merge sorted directories
        sortedDirs = [lexDirs; numDirs];
    end

    % Nested function to sort numeric directories
    function sortedNumDirs = sort_numeric(numDirs)
        if isempty(numDirs)
            sortedNumDirs = {};
            return;
        end
        
        % Extract numeric components from directory names
        numericParts = regexp(numDirs, '\d+', 'match');
        
        % Sort directories based on numeric components
        [~, sortedIndices] = sortrows(cellfun(@str2double, numericParts));
        sortedNumDirs = numDirs(sortedIndices);
    end
end



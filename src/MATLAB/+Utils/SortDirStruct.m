function sortedStruct = SortDirStruct(dirStruct)
    % Extract the 'name' field from the struct array
    names = {dirStruct.name};

    % Convert names to lowercase for case-insensitive sorting
    lowercaseNames = lower(names);

    % Use a natural-order sort to correctly sort strings with numbers
    [~, order] = natsort(lowercaseNames);

    % Apply the sorting order to the original struct array
    sortedStruct = dirStruct(order);
end

function [sortedNames, sortOrder] = natsort(names)
    % Apply natural-order sorting on the array of names
    
    % Use a regular expression to detect numbers and replace them with
    % zero-padded numbers. This ensures natural sorting order.
    replaceNum = @(s) regexprep(s, '(\d+)', '${sprintf(''%010d'', str2double($1))}');

    % Apply the zero-padding to all names
    paddedNames = cellfun(replaceNum, names, 'UniformOutput', false);

    % Sort the padded names and get the sorting order
    [sortedPaddedNames, sortOrder] = sort(paddedNames);

    % Apply the sorting order to the original names
    sortedNames = names(sortOrder);
end

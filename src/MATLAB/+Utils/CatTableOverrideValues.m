function combinedTable = CatTableOverrideValues(baseTable, overrideTable)
    % CatTableOverrideValues - Concatenates two tables and overrides values from the base table with values from the override table.
    %
    % Inputs:
    %   baseTable - The base table with original settings.
    %   overrideTable - The table with settings that should override the base table.
    %
    % Output:
    %   combinedTable - The resulting table after concatenating and overriding values.

    % Copy the base table to start with
    combinedTable = baseTable;

    % Get the variable names (column names) from both tables
    baseVars = baseTable.Properties.VariableNames;
    overrideVars = overrideTable.Properties.VariableNames;

    % Loop through each variable in the override table
    for i = 1:length(overrideVars)
        varName = overrideVars{i};

        % If the variable exists in the base table, override it
        if any(strcmp(baseVars, varName))
            combinedTable.(varName) = overrideTable.(varName);
        else
            % If the variable does not exist in the base, add it
            combinedTable = [combinedTable, overrideTable(:, varName)];
        end
    end
end

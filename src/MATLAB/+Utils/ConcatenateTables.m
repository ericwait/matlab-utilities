function concatenatedTable = ConcatenateTables(table1, table2)
    if isempty(table1)
        concatenatedTable = table2;
        return
    end
    if isempty(table2)
        concatenatedTable = table1;
        return
    end

    % Identify common columns
    commonColumns = intersect(table1.Properties.VariableNames, table2.Properties.VariableNames);
    allColumns = [commonColumns, setdiff(table1.Properties.VariableNames, commonColumns), setdiff(table2.Properties.VariableNames, commonColumns)];
    
    if (length(commonColumns) ~= max(size(table1,2), size(table2,2)))
        % Add missing columns to each table
        table1 = addMissingColumns(table1, table2);
        table2 = addMissingColumns(table2, table1);
    end
    
    % Ensure the same column order
    % allColumns = [commonColumns, setdiff(table1.Properties.VariableNames, commonColumns), setdiff(table2.Properties.VariableNames, commonColumns)];
    table1 = table1(:, allColumns);
    table2 = table2(:, allColumns);
    
    % Vertically concatenate the tables
    concatenatedTable = [table1; table2];
end

function targetTable = addMissingColumns(targetTable, referenceTable)
    % Identify unique columns in the reference table not in the target table
    uniqueColumns = setdiff(referenceTable.Properties.VariableNames, targetTable.Properties.VariableNames);

    % Add each unique column to the target table with appropriate type and size
    for i = 1:length(uniqueColumns)
        currentColName = uniqueColumns{i}; % Use a separate variable for the column name
        cur_vals = referenceTable.(currentColName);
        vals_size = [height(targetTable), size(cur_vals,2)];
        
        % Determine the data type of the column and add an appropriately typed empty column
        if isa(referenceTable.(currentColName), 'numeric')
            emptyVal = NaN(vals_size(1), vals_size(2));
        elseif isa(referenceTable.(currentColName), 'categorical')
            emptyVal = categorical(cell(vals_size(1), vals_size(2)));
        elseif isa(referenceTable.(currentColName), 'string')
            emptyVal = strings(vals_size(1), vals_size(2));
        elseif isa(referenceTable.(currentColName), 'datetime')
            emptyVal = NaT(vals_size(1), vals_size(2));
        elseif iscell(referenceTable.(currentColName))
            % Handle cell arrays, assuming cells contain numeric arrays
            % Adjust this part if the cells contain different types
            emptyVal = repmat({[]}, vals_size(1), vals_size(2));
        else % Fallback for other types like 'logical', etc.
            emptyVal = cell(vals_size(1), vals_size(2));
        end
        targetTable.(currentColName) = emptyVal;
    end
end
function updatedCellArray = UpdateCellArrayNumbers(cellArray, scaler, operator)
    % UpdateCellArrayNumbers Apply an arithmetic operation to a cell array of string numbers
    %
    % Syntax:
    %   updatedCellArray = UpdateCellArrayNumbers(cellArray, scaler, operator)
    %
    % Inputs:
    %   cellArray - Cell array containing strings that can be converted to numbers
    %   scaler - The numerical value to use in the operation
    %   operator - A string specifying the operation to perform. 
    %              It can be one of the following: 'add', 'subtract', 'multiply', 'divide'
    %
    % Outputs:
    %   updatedCellArray - Cell array with updated values after applying the arithmetic operation
    %
    % Example:
    %   updatedArray = UpdateCellArrayNumbers({'1', '2', '3'}, 1, 'add')
    %   updatedArray will be {'2', '3', '4'}
    %
    % Note: 
    %   This function will throw an error for division by zero or invalid operators.

    % Convert strings in cell array to numerical values
    valueArray = cellfun(@str2double, cellArray);

    % Perform the specified operation on the array
    switch operator
        case 'add'
            results = valueArray + scaler;
        case 'subtract'
            results = valueArray - scaler;
        case 'multiply'
            results = valueArray * scaler;
        case 'divide'
            % Check for division by zero
            if scaler == 0
                error('Division by zero.');
            end
            results = valueArray / scaler;
        otherwise
            % Throw an error for invalid operators
            error('Invalid operator.');
    end

    % Convert the numerical results back to a cell array of strings
    updatedCellArray = arrayfun(@num2str, results, 'UniformOutput', false);
end

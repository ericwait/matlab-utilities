function value = ConvertToNativeType(valueStr)
    % ConvertToNativeType - Converts a string to its native type if possible.
    %
    % This function attempts to convert a string value to its native type, such as a double or a datetime.
    % If the conversion is not possible, it returns the original string.
    %
    % Input:
    %   valueStr - The string value to be converted.
    %
    % Output:
    %   value    - The converted value in its native type, or the original string if conversion is not possible.

    % Attempt to convert the string to a numeric value
    numericValue = str2double(valueStr);
    if ~isnan(numericValue)
        value = numericValue;
        return;
    end

    % Attempt to convert the string to a datetime object
    try
        datetimeValue = datetime(valueStr, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a', 'Locale', 'en_US');
        if ~isnat(datetimeValue)
            value = datetimeValue;
            return;
        end
    catch
        % Leave the value as the original string if conversion fails
    end

    % Return the original string if no conversions were successful
    value = valueStr;
end

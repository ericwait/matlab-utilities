function folderNameDateTimeStr = GetNowStr()
    % GetNowStr Creates a string representation of the current datetime.
    %
    % This function generates a string from the current datetime, formatted
    % specifically for use in naming folders or files, to ensure unique names
    % based on the exact time. The format used is 'YYYYMMDD_HHMMSS', which 
    % represents Year, Month, Day, followed by an underscore, then Hour, Minute, 
    % and Second. This format ensures the string is sortable and uniquely identifies
    % the time of creation down to the second.

    % Create a datetime object representing the current moment
    currentDateTime = datetime('now');
    
    % Set the desired format for the datetime string
    % The format 'yyyyMMdd_HHmmss' is chosen for its sortability and readability
    currentDateTime.Format = 'yyyyMMdd_HHmmss';
    
    % Convert the formatted datetime object to a character array (string) for output
    folderNameDateTimeStr = char(currentDateTime);
end

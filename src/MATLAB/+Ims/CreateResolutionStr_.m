% _CREATE_RESOLUTION_STR Create the resolution string based on the resolutionNum.
%
%   resolutionStr = _CREATE_RESOLUTION_STR(resolutionNum) creates the resolution 
%   string, including the '/Resolution ' prefix, to be used in constructing 
%   attribute paths in other functions. The resolutionNum is zero-indexed internally.
%
% Parameters:
%   resolutionNum - Resolution index starting from 1 (numeric).
%
% Returns:
%   resolutionStr - Resolution string including '/Resolution ' prefix. 
%
% Example:
%   resolutionStr = _CREATE_RESOLUTION_STR(1);  % Output: '/Resolution 0'
%   resolutionStr = _CREATE_RESOLUTION_STR(3);  % Output: '/Resolution 2'
%
function resolutionStr = CreateResolutionStr_(resolutionNum)
    if ~isempty(resolutionNum)
        resolutionStr = sprintf('%d', resolutionNum - 1);
    else
        resolutionStr = '0';
    end
    resolutionStr = sprintf('/ResolutionLevel %s', resolutionStr);
end

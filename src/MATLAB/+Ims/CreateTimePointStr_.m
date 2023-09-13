% _CREATE_TIMEPOINT_STR Create the time point string based on the timePointNum.
%
%   timePointStr = _CREATE_TIMEPOINT_STR(timePointNum) creates the time point 
%   string, including the '/TimePoint ' prefix, to be used in constructing 
%   attribute paths in other functions. The timePointNum is zero-indexed internally.
%
% Parameters:
%   timePointNum - Time point index starting from 1 (numeric).
%
% Returns:
%   timePointStr - Time point string including '/TimePoint ' prefix. 
%
% Example:
%   timePointStr = _CREATE_TIMEPOINT_STR(1);  % Output: '/TimePoint 0'
%   timePointStr = _CREATE_TIMEPOINT_STR(3);  % Output: '/TimePoint 2'
%
function timePointStr = CreateTimePointStr_(timePointNum)
    if ~isempty(timePointNum)
        timePointStr = sprintf('%d', timePointNum - 1);
    else
        timePointStr = '0';
    end
    timePointStr = sprintf('/TimePoint %s', timePointStr);
end

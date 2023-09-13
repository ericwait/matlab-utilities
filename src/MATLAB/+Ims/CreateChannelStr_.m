% _CREATE_CHANNEL_STR Create the channel string based on the channelNum.
%
%   channelStr = _CREATE_CHANNEL_STR(channelNum) creates the channel 
%   string, including the '/Channel ' prefix, to be used in constructing 
%   attribute paths in other functions. The channelNum is zero-indexed internally.
%
% Parameters:
%   channelNum - Channel index starting from 1 (numeric).
%
% Returns:
%   channelStr - Channel string including '/Channel ' prefix. 
%
% Example:
%   channelStr = _CREATE_CHANNEL_STR(1);  % Output: '/Channel 0'
%   channelStr = _CREATE_CHANNEL_STR(3);  % Output: '/Channel 2'
%
function channel_str = CreateChannelStr_(channel_num)
    if ~isempty(channel_num)
        channel_str = sprintf('%d', channel_num - 1);
    else
        channel_str = '0';
    end
    channel_str = sprintf('/Channel %s', channel_str);
end

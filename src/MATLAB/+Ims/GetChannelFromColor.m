function channel = GetChannelFromColor(ims_file_path, color)
%GetChannelFromColor - Retrives a channel number based on the color set in Imaris.
% 
% Syntax:  [chan] = Ims.GetChannelFromColor(ims_file_path, color)
%
% Inputs:
%   ims_file_path - this is the file path the the .ims file (realitive or full).
%   color - this is a 1x3 ararry of (R,G,B) values ranging from [0,1].
%
% Outputs:
%   channel - this is the channel in the .ims file with this color.
%       This will be -1 when no channel is found or the default colors are
%       set in the file.
    
    colors = Ims.GetChannelColors(ims_file_path);
    
    if isdiag(colors)
        warning('This looks like the default R,G,B color order to me');
    end
    
    channel = find(ismember(colors,color,'rows'));
    
    if isempty(channel)
        channel = -1;
    end
end

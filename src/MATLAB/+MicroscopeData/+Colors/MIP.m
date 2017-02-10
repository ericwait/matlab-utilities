function [ colorMip ] = MIP(im, imD, channelList, colors)
%MIP Summary of this function goes here
%   Detailed explanation goes here

if (~exist('channelList','var') || isempty(channelList))
    channelList = 1:imD.NumberOfChannels;
end
if (~exist('colors','var') || isempty(colors))
    colors = MicroscopeData.Colors.GetChannelColors(imD);
end

if (isempty(im))
    error('Image must not be empty!');
else
    imChans = im(:,:,:,channelList);
end
colorMip = ImUtils.ThreeD.ColorMIP(imChans,colors(channelList,:));
end

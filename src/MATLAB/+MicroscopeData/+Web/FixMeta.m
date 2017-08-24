function [MetaOut] = MakeRootMeta(imData,Llist)
MetaOut = MetaIn;

defaultmap = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
%% Initalize Colors if they dont exist
if ~isfield(MetaOut,'ChannelColors') || isempty(MetaOut.ChannelColors)
    if MetaOut.NumberOfChannels == 1
        MetaOut.ChannelColors = ones(MetaOut.NumberOfChannels,3);
    else
        MetaOut.ChannelColors = defaultmap(1:MetaOut.NumberOfChannels,:);
    end
end

%% Initalize channel Names if they dont exist
if ~isfield(MetaOut,'ChannelNames') || isempty(MetaOut.ChannelNames)
    MetaOut.ChannelNames = arrayfun(@num2str, 1:MetaOut.NumberOfChannels, 'UniformOutput', false);
end

%% Make sure channel Names are 1x6
if size(MetaOut.ChannelNames,1) > size(MetaOut.ChannelNames,2)
MetaOut.ChannelNames = MetaOut.ChannelNames';
end

%% Initalize Image directory if it doesnt exist
if ~isfield(MetaOut,'imageDir') || isempty(MetaOut.imageDir) || any(strfind(MetaOut.imageDir,'.'))
    [~,newpath] = uigetfile();
    MetaOut.imageDir = newpath(1:end-1);
end

MetaOut.DatasetName = MicroscopeData.Helper.SanitizeString(MetaOut.DatasetName);
end


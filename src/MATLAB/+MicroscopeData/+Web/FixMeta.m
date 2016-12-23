function [MetaOut] = FixMeta(MetaIn)
MetaOut = MetaIn;

%% Initalize Colors if they dont exist
if ~isfield(MetaOut,'ChannelColors') || isempty(MetaOut.ChannelColors)
    if MetaOut.NumberOfChannels == 1
        MetaOut.ChannelColors = ones(MetaOut.NumberOfChannels,3);
    elseif  MetaOut.NumberOfChannels == 3
        MetaOut.ChannelColors = diag(MetaOut.NumberOfChannels,3);
    else
        MetaOut.ChannelColors = prism(MetaOut.NumberOfChannels);
    end
end

%% Initalize channel Names if they dont exist
if ~isfield(MetaOut,'ChannelNames') || isempty(MetaOut.ChannelNames)
    MetaOut.ChannelNames = arrayfun(@num2str, 1:MetaOut.NumberOfChannels, 'UniformOutput', false);
end

%% Initalize Image directory if it doesnt exist
if ~isfield(MetaOut,'imageDir') || isempty(MetaOut.imageDir) || any(strfind(MetaOut.imageDir,'.'))
    [~,newpath] = uigetfile();
    MetaOut.imageDir = newpath(1:end-1);
end

MetaOut.DatasetName = MicroscopeData.Helper.SanitizeString(MetaOut.DatasetName);
MetaOut = MicroscopeData.Web.ConvertMetadata(MetaOut,isfield(MetaOut, 'XDimension'));
end


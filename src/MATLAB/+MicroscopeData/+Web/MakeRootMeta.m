function [MetaOut] = MakeRootMeta(MetaIn,Llist)
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

%% Make Level Infomation List
Levelinfo = [];
for L = 1:length(Llist)
    Levelinfo(L).TDLevel = Llist(L);
    for LL = 1:L
        Levelinfo(LL).BULevel = Llist(L) - Llist(LL);
    end
    %% Number of volume Subdivisions
    nPartitions = max(2^Llist(L),1);
    Levelinfo(L).nPartitions = [nPartitions,nPartitions,1];
    %% Size of each volume Subdivision
    AtlasSize = min(4096*2^(Llist(L)),4096);
    Levelinfo(L).AtlasSize = [AtlasSize,AtlasSize];
    %% Calculate Reductions
    Levelinfo(L).Reductions = MicroscopeData.Web.GetReductions(MetaOut, AtlasSize, Llist(L));
    %% Stop if image is not reduced
    if prod(Levelinfo(L).Reductions) == 1
        break
    end 
end

MetaOut.Levels = [Levelinfo(:).BULevel;];
MetaOut.AtlasSize = vertcat(Levelinfo(:).AtlasSize);
MetaOut.nPartitions = vertcat(Levelinfo(:).nPartitions);
MetaOut.Reductions = vertcat(Levelinfo(:).Reductions);
end


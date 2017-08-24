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

%% Make sure channel Names are 1xN
if size(MetaOut.ChannelNames,1) > size(MetaOut.ChannelNames,2)
MetaOut.ChannelNames = MetaOut.ChannelNames';
end

%% Initalize Image directory if it doesnt exist
if ~isfield(MetaOut,'imageDir') || isempty(MetaOut.imageDir) || any(strfind(MetaOut.imageDir,'.'))
    [~,newpath] = uigetfile();
    MetaOut.imageDir = newpath(1:end-1);
end

OldDatasetName = MetaOut.DatasetName;
MetaOut.DatasetName = MicroscopeData.Helper.SanitizeString(MetaOut.DatasetName);
if ~strcmp(OldDatasetName,MetaOut.DatasetName)
MetaOut.OldDatasetName = OldDatasetName;
end 

%% Make Level Infomation List
Levelinfo = [];
for L = 1:8
    Levelinfo(L).TDLevel = min(Llist)+L-1;
    TDLevel = Levelinfo(L).TDLevel;
    for LL = 1:L
        Levelinfo(LL).BULevel = TDLevel - Levelinfo(LL).TDLevel;
    end
    %% Number of volume Subdivisions
    nPartitions = max(2^TDLevel,1);
    Levelinfo(L).nPartitions = [nPartitions,nPartitions,1];
    %% Size of each volume Subdivision
    AtlasSize = min(4096*2^(TDLevel),4096);
    Levelinfo(L).AtlasSize = [AtlasSize,AtlasSize];
    %% Calculate Reductions
    Levelinfo(L).Reductions = MicroscopeData.Web.GetReductions(MetaOut, AtlasSize, Levelinfo(L).nPartitions);
    %% Stop if image is not reduced
    if prod(Levelinfo(L).Reductions) == 1 && TDLevel>=0
        break
    end 
end

Levelinfo = Levelinfo(ismember([Levelinfo.TDLevel],Llist));

MetaOut.Levels = [Levelinfo(:).BULevel;];
MetaOut.AtlasSize = vertcat(Levelinfo(:).AtlasSize);
MetaOut.nPartitions = vertcat(Levelinfo(:).nPartitions);
MetaOut.Reductions = vertcat(Levelinfo(:).Reductions);

%% Timestamp Export
MetaOut.ExportDate = date();
end


function fixChannelsFromPath(root)

if (~exist('root','var') || isempty(root))
    root = uigetdir();
end

dlist = dir(root);

for i=1:length(dlist)
    if (strcmp(dlist(i).name,'.') || strcmp(dlist(i).name,'..'))
        continue
    end
    
    if (dlist(i).isdir)
        MicroscopeData.Sandbox.fixChannelsFromPath(fullfile(root,dlist(i).name));
        continue
    end
    
    [~,~,ext] = fileparts(dlist(i).name);
    if (strcmpi(ext,'.json'))
        imD = MicroscopeData.ReadMetadata(fullfile(root,dlist(i).name));
        if (isfield(imD,'ChannelName'))
            imD = rmfield(imD,'ChannelName');
        end
        [ colors, stainNames ] = MicroscopeData.Colors.GetChannelColors(imD,true);
        imD.ChannelNames = stainNames;
        imD.ChannelColors = colors;
        MicroscopeData.CreateMetadata(root,imD);
    end
end


function findJSON(folder)

dlist = dir(fullfile(folder,'*.json'));

for i=1:length(dlist)
    curPath = fullfile(folder,dlist(i).name);
    try
        imageData = MicroscopeData.ReadMetadata(curPath);
    catch err
        warning(err.message);
        continue
    end
    
    imageData = MicroscopeData.Sandbox.ConvertData(imageData);
    MicroscopeData.CreateMetadata(folder,imageData);
end

dlist = dir(folder);
dirs = arrayfun(@(x) x.isdir, dlist);
dlist = dlist(dirs);
for i=1:length(dlist)
    if (strcmp(dlist(i).name,'.') || strcmp(dlist(i).name,'..'))
        continue
    end
    
    if (strcmpi(dlist(i).name,'webgl'))
        continue
    end
    
    curPath = fullfile(folder,dlist(i).name);
    if (dlist(i).isdir)
        MicroscopeData.Sandbox.findJSON(curPath);
    end
end
end
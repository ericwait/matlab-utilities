function findJSON(folder)

dlist = dir(folder);

for i=1:length(dlist)
    if (strcmp(dlist(i).name,'.') || strcmp(dlist(i).name,'..'))
        continue
    end
    
    curPath = fullfile(folder,dlist(i).name);
    if (dlist(i).isdir)
        MicroscopeData.Sandbox.findJSON(curPath);
    else
        [~,~,ext] = fileparts(curPath); 
        if (strcmp(ext,'.json'))
            imageData = MicroscopeData.ReadMetadata(curPath);
            imageData = MicroscopeData.Sandbox.ConvertData(imageData);
            MicroscopeData.CreateMetadata(folder,imageData);
        end
    end
end
end
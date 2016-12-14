function SVZConvert(rootDir,direction)

    orgDir = fullfile(rootDir,'Original');    
    filterList = {'.';'..';'old';'controls'};

    if (~exist(orgDir,'dir'))
        rootDlist = dir(rootDir);
        if (exist('direction','var') && ~isempty(direction) && direction<0)
            orderedList = length(rootDlist):-1:1;
        else
            orderedList = 1:length(rootDlist);
        end
        for i=orderedList
            if (rootDlist(i).isdir && ~any(strcmpi(rootDlist(i).name,filterList)))
                MicroscopeData.Sandbox.SVZConvert(fullfile(rootDir,rootDlist(i).name));
            end
        end
    else
        combDir = fullfile(rootDir,'comb');
        if (exist(combDir,'dir'))
            return;
        end
        
        disp(rootDir);
        try
            [imOrg,imDorg] = MicroscopeData.Reader(orgDir,'verbose', true);
        catch err
            disp(err.message)
            imDorg = MicroscopeData.ReadMetadata(orgDir);

            h5Path = fullfile(orgDir,[imDorg.DatasetName,'.h5']);

            fprintf('Reading old format %s...\n',h5Path);
            info = h5info(h5Path);
            if (isempty(info.Groups) && ~isempty(info.Datasets) && any(strcmpi('Data',{info.Datasets.Name})))
                imOrg = h5read(h5Path,'/Data', [1 1 1 1 1], [Utils.SwapXY_RC(imDorg.Dimensions) imDorg.NumberOfChannels imDorg.NumberOfFrames]);
            else
                warning('Weird? check file? %s\n',h5Path);
            end
        end
        try
            [imS,imDs] = MicroscopeData.Reader(rootDir,'verbose', true);
        catch err
            disp(err.message)
            imDs = MicroscopeData.ReadMetadata(rootDir);

            h5Path = fullfile(rootDir,[imDs.DatasetName,'.h5']);

            fprintf('Reading old format %s...\n',h5Path);
            info = h5info(h5Path);
            if (isempty(info.Groups) && ~isempty(info.Datasets) && any(strcmpi('Data',{info.Datasets.Name})))
                imS = h5read(h5Path,'/Data', [1 1 1 1 1], [Utils.SwapXY_RC(imDs.Dimensions) imDs.NumberOfChannels imDs.NumberOfFrames]);
            else
                warning('Weird? check file? %s\n',h5Path);
            end
        end

        mkdir(combDir);
        MicroscopeData.WriterH5(imOrg,'imageData',imDorg,'path',combDir,'verbose',true);
        MicroscopeData.WriterH5(imS,'imageData',imDs,'path',combDir,'imVersion','Processed','verbose',true);

        orgDlist = dir(orgDir);

        for i=1:length(orgDlist)
            if (strcmp(orgDlist(i).name,'.') || strcmp(orgDlist(i).name,'..'))
                continue
            end
            [~,~,ext] = fileparts(orgDlist(i).name);
            if (strcmp(ext,'.h5'))
                continue
            end

            movefile(fullfile(orgDir,orgDlist(i).name),fullfile(orgDir,'..'));
        end
    end
end

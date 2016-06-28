% ConvertSpliceTiffs(rootDir,prefix,outDir)
% 
% Export and automatically splice or interleave images in time based on
% capture deltas from metadata. Prefix is used to match subdirectories with
% valid data and to generate dataset names for splized output.


function ConvertSpliceTiffs(rootDir,prefix,outDir)
    dirList = dir(rootDir);
    
    bInvalidName = arrayfun(@(x)(strncmpi(x.name,'.',1) || strncmpi(x.name,'..',2)), dirList);
    bValidDir = ~bInvalidName & (vertcat(dirList.isdir) > 0);
    dirList = dirList(bValidDir);
    
    bStain = cellfun(@(x)(~isempty(strfind(x,'Staining'))), {dirList.name});
    stainDir = dirList(bStain);
    checkDirs = dirList(~bStain);
    
    matchPrefix = regexptranslate('escape',prefix);
    
    matchNames = {};
    fileSets = {};
    dirSets = {};
    for i=1:length(checkDirs)
        fileList = dir(fullfile(rootDir,checkDirs(i).name));
        
        bInvalidName = arrayfun(@(x)(strncmpi(x.name,'.',1) || strncmpi(x.name,'..',2)), fileList);
        validFileList = fileList(~bInvalidName);
        for j=1:length(validFileList)
            if ( validFileList(j).isdir > 0 )
                continue;
            end
            
            tokMatch = regexp(validFileList(j).name, [matchPrefix '.*?_([ABCD])(\d+)_(\d+)(.*?)\.(\w+)$'], 'once','tokens');
            if ( isempty(tokMatch) )
                continue;
            end
            
            checkName = [prefix '_' tokMatch{1} tokMatch{2} '_' tokMatch{3} tokMatch{4}];
            matchIdx = find(strcmp(checkName, matchNames));
            
            if ( isempty(matchIdx) )
                matchNames = [matchNames; {checkName}];
                fileSets = [fileSets; {{validFileList(j).name}}];
                dirSets = [dirSets; {{fullfile(rootDir,checkDirs(i).name)}}];
            else
                fileSets{matchIdx} = [fileSets{matchIdx} {validFileList(j).name}];
                dirSets{matchIdx} = [dirSets{matchIdx} {fullfile(rootDir,checkDirs(i).name)}];
            end
        end
    end
    
    for i=1:length(matchNames)
        imageCell = {};
        metadata = [];
        for j=1:length(fileSets{i})
            [seriesImages, seriesMetadata] = MicroscopeData.Original.ReadData(dirSets{i}{j},fileSets{i}{j});
            
            imageCell = [imageCell; seriesImages(1)];
            metadata = [metadata; seriesMetadata{1}];
        end
        
        newMetadata = metadata(1);
        
        startTimes = [];
        captureTimes = [];
        imageList = cat(5,imageCell{:});
        for j=1:length(metadata)
            startTimes = [startTimes datetime(metadata(j).StartCaptureDate)];
            newTimes = startTimes(j) + seconds(metadata(j).TimeStampDelta);
            captureTimes = cat(3,captureTimes,newTimes);
        end
        
        [~,srtIdx] = sort(captureTimes(1,1,:),3);
        newStartTime = min(startTimes);
        captureTimes = captureTimes(:,:,srtIdx);
        imageList = imageList(:,:,:,:,srtIdx);
        
        newMetadata.NumberOfFrames = size(imageList,5);
        newMetadata.StartCaptureDate = datestr(newStartTime);
        newMetadata.TimeStampDelta = seconds(captureTimes-newStartTime);
        newMetadata.DatasetName = matchNames{i};
        
        MicroscopeData.Writer(imageList,fullfile(outDir,matchNames{i}),newMetadata);
    end
    
    %% Handle stain files
    stainFiles = dir(fullfile(rootDir,stainDir.name));
    bInvalidName = arrayfun(@(x)(strncmpi(x.name,'.',1) || strncmpi(x.name,'..',2)), stainFiles);
    validFileList = stainFiles(~bInvalidName);
    for i=1:length(validFileList)
        if ( validFileList(i).isdir > 0 )
            continue;
        end
        
        tokMatch = regexp(validFileList(i).name, ['.*?_([ABCD])(\d+)_(\d+)(.*?)\.(\w+)$'], 'once','tokens');
        if ( isempty(tokMatch) )
            continue;
        end

        checkName = [prefix '_' tokMatch{1} tokMatch{2} '_' tokMatch{3} tokMatch{4}];
        matchIdx = find(strcmp(checkName, matchNames));
        if ( isempty(matchIdx) )
            continue;
        end
        
        [seriesImages, seriesMetadata] = MicroscopeData.Original.ReadData(fullfile(rootDir,stainDir.name),validFileList(i).name);
        MicroscopeData.Writer(seriesImages{1},fullfile(outDir,matchNames{i},'stain'),seriesMetadata{1});
    end
end


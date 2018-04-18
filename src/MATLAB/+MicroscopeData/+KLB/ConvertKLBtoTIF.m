function ConvertKLBtoTIF(inputFolder,outputFolder)
    if (~exist('outputFolder','var') || isempty(outputFolder))
        outputFolder = '.';
    end

    dList = dir(inputFolder);
    
    %% recurse through sub directories
    directoryMask = [dList.isdir];
    directories = dList(directoryMask);
    
    for i=1:length(directories)
        if (strcmp(directories(i).name,'.') || strcmp(directories(i).name,'..'))
            continue
        end
        MicroscopeData.KLB.ConvertKLBtoTIF(fullfile(inputFolder,directories(i).name),fullfile(outputFolder,directories(i).name));
    end
        
    %% convert klb
    filesMask = ~directoryMask;
    files = dList(filesMask);
    if (isempty(files))
        return
    end
    
    fName = arrayfun(@(x)(x.name),files,'uniformoutput',false);
    
    klbNames = regexpi(fName,'(.*)\.klb','tokens');
    klbNames = klbNames(cellfun(@(x)(~isempty(x)),klbNames));
    
    if (isempty(klbNames))
        return
    end
    
    klbNames = cellfun(@(x)(x{1,1}),klbNames);
    
    if (~exist(outputFolder,'dir'))
        %make sure we have a directory to write to
        mkdir(outputFolder);
    end
    
    tic
    fprintf('Writing %s...', outputFolder);
    parfor i=1:size(klbNames,1)
        if (isempty(klbNames{i}))
            %this was a different file time
            continue
        end
        
        im = MicroscopeData.KLB.readKLBstack(fullfile(inputFolder,[klbNames{i},'.klb']));
        if (ndims(im)<=3)
            MicroscopeData.KLB.write3Dtiff(im,fullfile(outputFolder,[klbNames{i},'.tif']));
        else
            for t=1:size(im,5)
                for c=1:size(im,4)
                    MicroscopeData.KLB.write3Dtiff(im(:,:,:,c,t),fullfile(outputFolder,sprintf('%s_c%02d_t%04d.tif',klbNames{i},c,t)));
                end
            end
        end
    end
    fprintf('done %dsec\n',toc);
end
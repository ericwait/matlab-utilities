function imD = ConvertData( imDir, imName, outDir, generateJPG, overwrite, quiet, cleanName)
%[ im, imD ] = MicroscopeData.Original.ConvertData( imDir, imName, outDir, generateJPG, overwrite, quiet, cleanName)
imD = [];

if (~exist('generateJPG','var') || isempty(generateJPG))
    generateJPG = false;
end
if (~exist('overwrite','var') || isempty(overwrite))
    overwrite = false;
end
if (~exist('quiet','var') || isempty(quiet))
    quiet = false;
end

if (~exist('imDir','var') || isempty(imDir))
    imDir = '.';
end

if (~exist('imName','var') || isempty(imName))
    [imName,imDir,~] = uigetfile('*.*','Choose a Microscope File to Convert');
    if (imName==0)
        warning('Nothing read');
        return
    end
end

if (~exist('outDir','var') || isempty(outDir))
    outDir = uigetdir('.','Choose a folder to output to');
    if (outDir==0)
        warning('Nowhere to write!');
        return
    end
end

if (~exist('cleanName','var') || isempty(cleanName))
    cleanName = false;
end

if (cleanName)
    outDir = MicroscopeData.Helper.CreateUniqueWordedPath(outDir);
end

[~,name,~] = fileparts(imName);

if (~exist(fullfile(outDir,name),'dir') || overwrite)
    
    imD = MicroscopeData.Original.ReadMetadata(imDir,imName);
    if ( isempty(imD) )
        return;
    end
    
    [~,datasetName,~] = fileparts(imName);
    if (length(imD)>1)
        if (cleanName)
            datasetName = MicroscopeData.Helper.SanitizeString(datasetName);
        end
        outDir = fullfile(outDir,datasetName);
    else
        imD = {imD};
    end
    
    prgs = Utils.CmdlnProgress(length(imD),quiet,['Writing out ',datasetName]);
    for i=1:length(imD)
        if (cleanName)
            imD{i}.DatasetName = MicroscopeData.Helper.SanitizeString(imD{i}.DatasetName);
        end
        
        if (~exist(fullfile(outDir,imD{i}.DatasetName),'dir') || overwrite)
            im = MicroscopeData.Original.ReadImages(imDir,imName,i);
            
            MicroscopeData.WriterH5(im,outDir,'imageData',imD{i},'verbose',~quiet);
            if ( generateJPG )
                im = ImUtils.ConvertType(im,'uint8',true);
                MicroscopeData.WriterJPG(im,fullfile(outDir,imD{i}.DatasetName),'imageData',imD{i},'verbose',~quiet);
            end
        end
        
        prgs.PrintProgress(i);
    end
    prgs.ClearProgress(quiet);
    
    cmd = sprintf('dir "%s" /B /O:N /A:D > "%s"',outDir,fullfile(outDir,'list.txt'));
    system(cmd);
end
end


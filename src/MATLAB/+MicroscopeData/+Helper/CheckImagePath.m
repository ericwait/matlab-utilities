function [fileType,validFiles] = CheckImagePath(imPath, datasetName)
    validExt = {'.klb';
                '.h5';
                '.tif'};

    fileType = '';
    validFiles = {};
    
    flist = dir(fullfile(imPath,[datasetName '*']));
    fnames = {flist.name};
    
    for i=1:length(validExt)
        bValidFiles = cellfun(@(x)(endsWith(x, validExt{i}, 'IgnoreCase',true)), fnames);
        if ( nnz(bValidFiles) > 0 )
            fileType = validExt{i};
            validFiles = fnames(bValidFiles);
        end
    end
    
    %% Specific per-format checks
    if ( strcmpi(fileType,'.h5') && ~strcmpi(validFiles{1},[datasetName '.h5']) )
        %% Dont' match if the HDF5 file is exactly the datasetname
        fileType = '';
        validFiles = {};
    elseif ( strcmpi(fileType,'.tif') )
        %% Don't match if we can't find first ctz format tif
        matchTif = sprintf('%s_c%02d_t%04d_z%04d.tif',datasetName,1,1,1);
        if ( ~any(strcmpi(matchTif, validFiles)) )
            matchTif = sprintf('%s_c%02d_t%04d.tif',datasetName,1,1);
        elseif (~any(strcmpi(matchTif, validFiles)))
            fileType = '';
            validFiles = {};
        end
    end
end

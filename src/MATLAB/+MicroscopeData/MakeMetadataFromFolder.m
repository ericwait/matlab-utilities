function imageData = MakeMetadataFromFolder(rootDir,datasetName)
    imageData = MicroscopeData.GetEmptyMetadata();
    
    tifList = dir(fullfile(rootDir,[datasetName '*.tif']));
    nameList = {tifList.name}.';
    
    prefixStr = regexptranslate('escape',datasetName);
    
    tokMatch = regexp(nameList, [prefixStr '_c(\d+)_t(\d+)_z(\d+)\.tif'], 'tokens','once');
    
    bValidTok = cellfun(@(x)(length(x)==3), tokMatch);
    chkTok = vertcat(tokMatch{bValidTok});
    
    ctzVals = cellfun(@(x)(str2double(x)), chkTok);
    
    ctzMax = max(ctzVals,[],1);
    
    chkFilename = sprintf('%s_c%02d_t%04d_z%04d.tif', datasetName,1,1,1);
    imInfo = imfinfo(fullfile(rootDir,chkFilename));
    
    imageData.DatasetName = datasetName;
    imageData.Dimensions = [imInfo.Width, imInfo.Height, ctzMax(3)];
    imageData.NumberOfChannels = ctzMax(1);
    imageData.NumberOfFrames = ctzMax(2);
    imageData.PixelPhysicalSize = [1,1,1];
    
    colors = [1,0,0;...
          0,1,0;...
          0,0,1;...
          0,1,1;...
          1,0,1;...
          1,1,0];
    
    for c=1:imageData.NumberOfChannels
        imageData.ChannelNames = [imageData.ChannelNames; {sprintf('Channel %d',c)}];
        colidx = mod(c,size(colors,1));
        imageData.ChannelColors = vertcat(imageData.ChannelColors,colors(colidx,:));
    end

    imageData.StartCaptureDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
    imageData.PixelFormat = MicroscopeData.Helper.GetPixelTypeTIF(fullfile(rootDir,chkFilename));
end

function [] = MakeTiles(im,imData,imOutPath,Llist)
%% Tile images
maxTextureSize = 4096;
%[memNeeded, hasEnoughMem] = Cloneview3D.Helper.calcMemory(imDataOrigin, 1);
for c = 1:imData.NumberOfChannels
    % each level
    for l = 1:numel(Llist)
        level = Llist(l);
        %         levelData = GetLevelDims(channelData, level);
        [tileData, reductions] = MicroscopeData.Web.GetReductions(imData, maxTextureSize,level);
        tileData.Level = level;
        %% reduce image size to fit into the texture dimension
        %         [totalImageSize, ~] = Cloneview3D.Helper.calcMemory(levelData);
        %         if(totalImageSize < 4)
        %             useCUDAMex = 1;
        %         else
        %             useCUDAMex = 0;
        %         end
        useCUDAMex = 0;
        [imReduc, imD] = MicroscopeData.Web.ReduceImageTemp(im, imData, reductions, false, useCUDAMex);
        
        tileData.XPixelPhysicalSize = imD.XPixelPhysicalSize;
        tileData.YPixelPhysicalSize = imD.YPixelPhysicalSize;
        tileData.ZPixelPhysicalSize = imD.ZPixelPhysicalSize;
        
        numTilesInXY = 2^level;
        Xlist = 0:numTilesInXY-1;
        Ylist = 0:numTilesInXY-1;
        
        % for each tile...
        for i = 1:numel(Xlist)
            x = Xlist(i);
            for j = 1:numel(Ylist)
                y = Ylist(j);
                tileData.XLocation = x;
                tileData.YLocation = y;
                %                 tileData = AddTileInfo(tileData, level, x, y);
                tileDir = fullfile(imOutPath, num2str(level), sprintf('%02d%02d', x, y));
                if (~exist(tileDir, 'dir'))
                    mkdir(tileDir);
                end
                
                ROI_X = x*tileData.XDimension + 1:(x+1)*tileData.XDimension;
                ROI_Y = y*tileData.YDimension + 1:(y+1)*tileData.YDimension;
                fprintf('Creating atlas for level %d, tile %02d%02d \r\n', level, x,y);
                
                [tileAtlasIm, tileData] = MicroscopeData.Web.makeAtlas(imReduc(ROI_Y, ROI_X, :,c,:), tileData);
                MicroscopeData.Web.ExportAtlasIm(tileAtlasIm, tileData, tileDir, c);
                tileData.isEmpty = 0;
                
                %% Make tile metadata 
                if(c == imData.NumberOfChannels)
                    tileData.NumberOfChannels = imData.NumberOfChannels;
                    tileData.ChannelNames = imData.ChannelNames;
                    tileData.ChannelColors = imData.ChannelColors;
                    tileData.Reduction = reductions(1);
                    %% Export Json for Atlas
                    MicroscopeData.Web.ExportAtlasJSON(tileDir, tileData);
                    %% Create blended atlas
                    MicroscopeData.Web.blendThisTile(tileDir, 'png');
                end
            end
        end
    end
end
end


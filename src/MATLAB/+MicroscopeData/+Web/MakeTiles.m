function [] = MakeTiles(imData,imOutPath,Llist)
%% Tile images
maxTextureSize = 4096;
%[memNeeded, hasEnoughMem] = Cloneview3D.Helper.calcMemory(imDataOrigin, 1);

for l = 1:numel(Llist)
    level = Llist(l);
    %% Calculate Reductions
    [tileData2, reductions] = MicroscopeData.Web.GetReductions(imData, maxTextureSize,level);
    useCUDAMex = 0;
    
    %% Make Tile MetaData
    tileData2.Level = level;
    numTilesInXY = 2^level;
    [TileListX,TileListY] = meshgrid(0:numTilesInXY-1,0:numTilesInXY-1);
    for c = 1:imData.NumberOfChannels
        %% for each tile...
        parfor i = 1:numel(TileListX)
            x = TileListX(i);
            y = TileListY(i);
            
            tileData=tileData2;
            %                 tileData = AddTileInfo(tileData, level, x, y);
            tileDir = fullfile(imOutPath, num2str(level), sprintf('%02d%02d', x, y));
            if ~exist(tileDir, 'dir');  mkdir(tileDir); end
            
            %%Get Region of Interest
            ROI_X = x*imData.XDimension/numTilesInXY + 1:(x+1)*imData.XDimension/numTilesInXY;
            ROI_Y = y*imData.YDimension/numTilesInXY + 1:(y+1)*imData.YDimension/numTilesInXY;
            ROI_Z = 1:imData.ZDimension;
            
            ROIXYZ = [ROI_X(1),ROI_Y(1),ROI_Z(1);ROI_X(end),ROI_Y(end),ROI_Z(end)];
            
            fprintf('Creating atlas for level %d, channel %d, tile %02d%02d \r\n', level, c, x,y);
            [tileData] = MicroscopeData.Web.ReduceMeta(imData,tileData,reductions,x,y);
            
            %% Get Image Chunk'timeRange',[t t]
            [im] = MicroscopeData.Reader('imageData',imData,'roi_xyz',ROIXYZ,'chanList',c,'outType','uint8','verbose',true);
            for t=1:imData.NumberOfFrames
                %% Reduce The Image Section
                [imr] = MicroscopeData.Web.ReduceImage(im(:,:,:,:,t), tileData, reductions, false, useCUDAMex);
                %% Pad Images and Reshape Sections to make Atlas
                [tileAtlasIm] = MicroscopeData.Web.makeAtlas(imr, tileData,maxTextureSize);
                %% Export Atlas Images
                MicroscopeData.Web.ExportAtlasIm(tileAtlasIm, tileData.DatasetName, tileDir, c,t);
            end
            
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
    %% Export Thumbnail
    %     MicroscopeData.Web.makeThumbnail(imOutPath,imData,im);
end


end


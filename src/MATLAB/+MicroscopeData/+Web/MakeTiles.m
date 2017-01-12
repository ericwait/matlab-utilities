function [] = MakeTiles(imData,imOutPath,Llist)
%% Tile images
maxTextureSize = 4096;
[im] = MicroscopeData.Reader('imageData',imData,'outType','uint8','normalize',true,'verbose',true);
for l = 1:numel(Llist)
    level = Llist(l);
    %% Calculate Reductions
    [reductions] = MicroscopeData.Web.GetReductions(imData, maxTextureSize,level);
    %% Make Tile MetaData
    numTilesInXY = 2^level;
    [TileListX,TileListY] = meshgrid(0:numTilesInXY-1,0:numTilesInXY-1);
    for c = 1:imData.NumberOfChannels
        parfor t=1:imData.NumberOfFrames
            %% Get Image Chunk
            %[im] = MicroscopeData.Reader('imageData',imData,'chanList',c,'timeRange',[t t],'outType','uint8','normalize',true,'verbose',true);
            %% For each tile...
            for i = 1:numel(TileListX)
                x = TileListX(i);                       y = TileListY(i);
                %% Make Tree File Structure
                tileDir = fullfile(imOutPath, num2str(level), sprintf('%02d%02d', x, y));
                if ~exist(tileDir, 'dir');  mkdir(tileDir); end
                %% Get Region of Interest
                ROI_X = round(x*imData.XDimension/numTilesInXY + 1:(x+1)*imData.XDimension/numTilesInXY);
                ROI_Y = round(y*imData.YDimension/numTilesInXY + 1:(y+1)*imData.YDimension/numTilesInXY);
                ROI_Z = 1:imData.ZDimension;                
                fprintf('Creating atlas for level %d, channel %d, time %d, tile %02d%02d \r\n', level, c, t,x,y);
                %% Reduce The MetaData
                [tileData] = MicroscopeData.Web.ReduceMeta(imData,reductions,x,y,level,maxTextureSize);
                %% Reduce The Image Section
                [imr] = MicroscopeData.Web.ReduceImage(im(ROI_Y,ROI_X,ROI_Z,c,t), tileData, reductions, false, 0);
                %% Reshape Sections to make Atlas
                tileData.isEmpty = 0;
                MicroscopeData.Web.makeAtlas(imr, tileData ,maxTextureSize,tileDir,c,t);
                %% Export Json for Atlas
                MicroscopeData.Web.ExportAtlasJSON(tileDir, tileData);
            end
            
        end
    end
end

%% Blend The Tiles 
for l = 1:numel(Llist)
    level = Llist(l);
    numTilesInXY = 2^level;
    [TileListX,TileListY] = meshgrid(0:numTilesInXY-1,0:numTilesInXY-1);
    
    for i = 1:numel(TileListX)
        x = TileListX(i);        y = TileListY(i);
        tileDir = fullfile(imOutPath, num2str(level), sprintf('%02d%02d', x, y));
        %% Create blended atlas
        MicroscopeData.Web.blendThisTile(tileDir, 'png');
    end
end
fprintf('Atlas exported to %s\n', imOutPath);
end


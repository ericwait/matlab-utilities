function [] = MakeTiles(imData,imOutPath)
Levels = imData.Levels;
for c = 1:imData.NumberOfChannels
    for t = 1:imData.NumberOfFrames
        %% Get Image Chunk
        [im] = MicroscopeData.Reader('imageData',imData,'chanList',c,'timeRange',[t t],'outType','uint8','verbose',true);
        %% For each tile...
        for L = 1:length(Levels)
            
            nPartX = imData.nPartitions(L,1);
            nPartY = imData.nPartitions(L,2);
            nPartZ = imData.nPartitions(L,3);
            
            [TileListX,TileListY,TileListZ] = meshgrid(0:nPartX-1, 0:nPartY-1, 0:nPartZ-1);
            
            parfor i = 1:numel(TileListX)
                x = TileListX(i);        y = TileListY(i);    z = TileListZ(i);
                %% Make Tree File Structure
                tileDir = fullfile(imOutPath, num2str(Levels(L)), sprintf('%02d%02d%02d', x, y, z));
                if ~exist(tileDir, 'dir');  mkdir(tileDir); end
                
                %% Get Region of Interest
                ROI_X = round(x*imData.Dimensions(1)/nPartX + 1:(x+1)*imData.Dimensions(1)/nPartX);
                ROI_Y = round(y*imData.Dimensions(2)/nPartY + 1:(y+1)*imData.Dimensions(2)/nPartY);
                ROI_Z = round(z*imData.Dimensions(3)/nPartZ + 1:(z+1)*imData.Dimensions(3)/nPartZ);
                
                %% Reduce The MetaData, Check if Empty, Export
                [tileData] = MicroscopeData.Web.ReduceMeta(imData,x,y,z,L);
                tileData.isEmpty = MicroscopeData.Web.checkMask(imData,[ROI_X,ROI_Y,ROI_Z]);
                MicroscopeData.Web.ExportAtlasJSON(tileDir, tileData);
                
                % Reduce The Image Section
                fprintf('Creating atlas for level %d, channel %d, time %d, tile %02d%02d%02d \r\n', Levels(L), c, t,x,y,z);
                [imr] = MicroscopeData.Web.ReduceImage(im(ROI_Y,ROI_X,ROI_Z,1,1), tileData, imData.Reductions(L,:));
                %% Reshape Sections to make Atlas
                MicroscopeData.Web.makeAtlas(imr, tileData,tileDir,c,t);
            end
        end
    end
end

%% Blend The Tiles
for L = 1:numel(Levels)
    nPartX = imData.nPartitions(L,1);
    nPartY = imData.nPartitions(L,2);
    nPartZ = imData.nPartitions(L,3);
    [TileListX,TileListY,TileListZ] = meshgrid(0:nPartX-1, 0:nPartY-1, 0:nPartZ-1);
    for i = 1:numel(TileListX)
        x = TileListX(i);        y = TileListY(i);    z = TileListZ(i);
        tileDir = fullfile(imOutPath, num2str(Levels(L)), sprintf('%02d%02d%02d', x, y, z));
        %% Create blended atlas
        MicroscopeData.Web.blendThisTile(tileDir, 'png');
    end
end
fprintf('Atlas exported to %s\n', imOutPath);
end


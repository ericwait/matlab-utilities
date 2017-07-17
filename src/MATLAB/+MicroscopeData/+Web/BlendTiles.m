function [] = BlendTiles(imData,imOutPath,bOverwrite,bExportText)

MicroscopeData.Web.MakeTiles(imData,imOutPath,bOverwrite,bExportText);

Levels = imData.Levels;
%% Blend The Tiles
for L = 1:numel(Levels)
    fprintf(['Blending atlas for level %d,', imData.DatasetName,'\r\n'],Levels(L));
    
    nPartX = imData.nPartitions(L,1);       nPartY = imData.nPartitions(L,2);           nPartZ = imData.nPartitions(L,3);
    [TileListX,TileListY,TileListZ] = meshgrid(0:nPartX-1, 0:nPartY-1, 0:nPartZ-1);
    
    for i = 1:numel(TileListX)
        x = TileListX(i);
        y = TileListY(i); 
        z = TileListZ(i);
        tileDir = fullfile(imOutPath, num2str(Levels(L)), sprintf('%02d%02d%02d', x, y, z));

        if exist(fullfile(tileDir,sprintf('%s_blend_c%02d_t%04d.png',imData.DatasetName,1,imData.NumberOfFrames)),'file')
            continue;
        end

        %% Create blended atlas
        MicroscopeData.Web.blendThisTile(imData,tileDir, 'png');
    end
end
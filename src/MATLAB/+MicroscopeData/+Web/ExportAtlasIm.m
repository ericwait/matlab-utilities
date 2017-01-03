function ExportAtlasIm(im, DatasetName, outPath, c,t)
%     parfor c=1:imData.NumberOfChannels
%         imwrite(im(:,:,c,t), fullfile(outPath,sprintf('%s_c%02d_t%04d.png',imData.DatasetName,c,t)));
%     end
    imwrite(im(:,:), fullfile(outPath,sprintf('%s_c%02d_t%04d.png',DatasetName,c,t)));
end
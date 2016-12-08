function ExportAtlasIm(im, imData, outPath, c)

for t=1:imData.NumberOfFrames
%     parfor c=1:imData.NumberOfChannels
%         imwrite(im(:,:,c,t), fullfile(outPath,sprintf('%s_c%02d_t%04d.png',imData.DatasetName,c,t)));
%     end
       imwrite(im(:,:,1,t), fullfile(outPath,sprintf('%s_c%02d_t%04d.png',imData.DatasetName,c,t)));
end
end
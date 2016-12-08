function makeThumbnail(Outpath, im, imData)
    nChannels = imData.NumberOfChannels;
%     cList = 1:nChannels;
%     channelString = regexprep(num2str(cList), '\s*', '');
%     dList = dir(fullfile(imData.imageDir, ['*', channelString, '.tif']));
%     if(~isempty(dList))
%         disp('Making thumbnail...');
%         im = imread(fullfile(imData.imageDir, dList(1).name));
%         imThumbnail = imresize(im, [300 500]);
%         imThumbnail = mat2gray(imThumbnail);
%         imwrite(imThumbnail, fullfile(Outpath, 'thumbnail.png'));
%     else
%         error('*chan%d.tif not found\r\n', channelString);
%     end

        disp('Making thumbnail...');
        imThumbnail = imresize(im(:,:,1,1,1),[300 500]);
        imThumbnail = mat2gray(imThumbnail);
        imwrite(imThumbnail, fullfile(Outpath, 'thumbnail.png'));

end
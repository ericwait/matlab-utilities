function makeThumbnail(imd,Outpath)
%    nChannels = imData.NumberOfChannels;
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
        
%ReadBlendedTile(root, channelList, AtlasColorChannels)
%try 
        BlendedPath = fullfile(Outpath,num2str(imd.Levels(2)),'\000000');
        [im,imd] = MicroscopeData.Web.ReadBlendedTile(BlendedPath,[], []);
        
        %[im,imd] = MicroscopeData.Reader('imageData',imd,'getMIP',true,'outType','uint8','timeRange',[1 1]);
        cMIP = ImUtils.ThreeD.ColorMIP(im,imd.ChannelColors);   
        imThumbnail = imresize(cMIP,[300 500]);
        imThumbnail = imadjust(mat2gray(imThumbnail),[.01,.9],[]);
        disp('Making thumbnail...');
        imwrite(imThumbnail, fullfile(Outpath, 'thumbnail.png'));
% catch;  disp([ imd.DatasetName ,' Cant make Thumbnail']);
% end 
end
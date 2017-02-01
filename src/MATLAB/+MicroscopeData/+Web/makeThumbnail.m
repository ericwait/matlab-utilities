function makeThumbnail(imd,Outpath)
        BlendedPath = fullfile(Outpath,num2str(imd.Levels(1)),'\000000');
        [im,imd] = MicroscopeData.Web.ReadBlendedTile(BlendedPath,[], []);
        
        %[im,imd] = MicroscopeData.Reader('imageData',imd,'getMIP',true,'outType','uint8','timeRange',[1 1]);
        cMIP = ImUtils.ThreeD.ColorMIP(im,imd.ChannelColors); 
        
        MIPsize = size(cMIP);
        if MIPsize(1)>MIPsize(2)
           cMIP = permute(cMIP,[2 1 3]);
        end 
        scaleval = 500/size(cMIP,2);
        imThumbnail = imresize(cMIP,scaleval);
        imThumbnail = imadjust(mat2gray(imThumbnail),[.01,.9],[]);
        disp('Making thumbnail...');
        imwrite(imThumbnail, fullfile(Outpath, 'thumbnail.png'));
end
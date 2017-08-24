function makeThumbnail(imd,Outpath)
        if exist(fullfile(Outpath, 'thumbnail.png'),'file')
        delete(fullfile(Outpath, 'thumbnail.png'))    
        end 
        
        BlendedPath = fullfile(Outpath,num2str(imd.Levels(1)),'\000000');
        try 
        [im,~] = MicroscopeData.Web.ReadBlendedTile(imd, BlendedPath,[], []);
        catch
        disp(['Broken at ',imd.DatasetName]);
        return
        end 

        if isempty(im); return; end 
        
        %[im,imd] = MicroscopeData.Reader('imageData',imd,'getMIP',true,'outType','uint8','timeRange',[1 1]);
        cMIP = ImUtils.ThreeD.ColorMIP(im,imd.ChannelColors); 
        
        MIPsize = size(cMIP);
        if MIPsize(1)>MIPsize(2)
           cMIP = permute(cMIP,[2 1 3]);
        end 
        scaleval = 200/size(cMIP,1);
        imThumbnail = imresize(cMIP,scaleval);
        imThumbnail = imadjust(mat2gray(imThumbnail),[.01,.9],[]);
        disp('Making thumbnail...');
        imwrite(imThumbnail, fullfile(Outpath, 'thumbnail.png'));
end
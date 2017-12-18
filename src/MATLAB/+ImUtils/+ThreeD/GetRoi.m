function [imROI,imROID] = GetRoi(im,imD)

    imZproject = ImUtils.ThreeD.GetTemproalMaxProjection(im);

    imNorm = ones(size(imZproject),'uint8');
    for chan=1:size(imZproject,4)
        curChan = mat2gray(imZproject(:,:,:,chan,:));
        curChan = curChan.*2;
        curChan(curChan>1) = 1;
        imNorm = im2uint8(curChan);
    end
    clear curChan

    imZproject = imNorm;
    clear imNorm

    f = figure;
    bw = roipoly(imZproject);
    close(f);
    clear imZproject
    
    [r,c] = find(bw);
    rMin = min(r(:));
    rMax = max(r(:));
    cMin = min(c(:));
    cMax = max(c(:));
    xExt = [cMin,cMax];
    yExt = [rMin,rMax];

    imROI = im(yExt(1):yExt(2),xExt(1):xExt(2),:,:,:);

    imXproject = ImUtils.ThreeD.GetTemproalMaxProjection(imROI,2);

    imNorm = ones(size(imXproject),'uint8');
    for chan=1:size(imXproject,4)
        curChan = mat2gray(imXproject(:,:,:,chan,:));
        curChan = curChan.*2;
        curChan(curChan>1) = 1;
        imNorm = im2uint8(curChan);
    end
    clear curChan

    imXproject = imNorm;
    clear imNorm

    f = figure;
    bw = roipoly(imXproject);
    close(f);
    clear imXproject
    
    [~,c] = find(bw);
    zMin = min(c(:));
    zMax = max(c(:));
    zExt = [zMin,zMax];
    
    imROI = im(yExt(1):yExt(2),xExt(1):xExt(2),zExt(1):zExt(2),:,:);

    imROID = imD;
    sz = size(imROI);
    imROID.Dimensions = sz([2,1,3]);

    imROID.DatasetName = [imROID.DatasetName,'_roi01'];

    D3d.Open(imROI,imROID);
    
    prompt = {'Enter Min Frame:','Enter Max Frame:'};
    dlg_title = 'Pick Time Range';
    num_lines = 1;
    defaultans = {'1',num2str(size(imROI,5))};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    D3d.Close();
    timeRange = [str2double(answer{1}),str2double(answer{2})];
    imROI = im(yExt(1):yExt(2),xExt(1):xExt(2),zExt(1):zExt(2),:,timeRange(1):timeRange(2));
    imROID.NumberOfFrames = size(imROI,5);
end

function [xyz_roi,timeRange] = GetRoi(pathToJson)

    if (~exist('pathToJson','var') || isempty(pathToJson))
        [fileName,pathName,filterIndex] = uigetfile('*.json');
        if (filterIndex==0)
            return
        end
        
        pathToJson = fullfile(pathName,fileName);
    end
    
    imD = MicroscopeData.ReadMetadata(pathToJson);
    
    m = memory;
    [~,tMem] = MicroscopeData.GetImageSetSizeInBytes(imD,imD.PixelFormat);
    numFrames = m.MemAvailableAllArrays /2 /tMem;
    numFrames = min(20,numFrames);
    numFrames = max(1,numFrames);
    timeStride = floor(imD.NumberOfFrames/numFrames);
    getFrames = 1:timeStride:imD.NumberOfFrames;
    
    imDT = imD;
    imDT.NumberOfFrames = length(getFrames);
    im = zeros([Utils.SwapXY_RC(imD.Dimensions),imD.NumberOfChannels,imDT.NumberOfFrames],imD.PixelFormat);
    
    t = 1;
    prgs = Utils.CmdlnProgress(numel(getFrames),true,'Reading images',true);
    for gt=getFrames
        im(:,:,:,:,t) = MicroscopeData.Reader('imageData',imD,'timeRange',[gt,gt]);
        t = t +1;
        prgs.PrintProgress(t);
    end
    prgs.ClearProgress(true);

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

    chanColors = [];
    if (isfield(imD,'ChannelColors'))
        chanColors = imD.ChannelColors;
    end
    
    imC = ImUtils.ThreeD.ColorMIP(permute(imZproject,[1,2,4,3]),chanColors);
    
    msgbox({'Click to put down points for bounding area';'Right click and make mask when done'});
    f = figure;
    bw = roipoly(imC);
    close(f);
    clear imZproject
    
    [r,c] = find(bw);
    rMin = min(r(:));
    rMax = max(r(:));
    cMin = min(c(:));
    cMax = max(c(:));
    xExt = [max(cMin,1),min(cMax,imD.Dimensions(1))];
    yExt = [max(rMin,1),min(rMax,imD.Dimensions(2))];

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

    imC = ImUtils.ThreeD.ColorMIP(permute(imXproject,[1,2,4,3]),chanColors);
    
    msgbox({'Click to put down points for bounding area';'Right click and make mask when done'});
    f = figure;
    bw = roipoly(imC);
    close(f);
    clear imXproject
    
    [~,c] = find(bw);
    zMin = min(c(:));
    zMax = max(c(:));
    zExt = [max(zMin,1),min(zMax,imD.Dimensions(3))];
    if (isempty(zExt))
        zExt = [1,imD.Dimensions(3)];
    end
    
    xyz_roi = [xExt(1),yExt(1),zExt(1);xExt(2),yExt(2),zExt(2)];
    [imMax,imDMax] = MicroscopeData.Reader(pathToJson,'getMIP',true,'roi_xyz',xyz_roi,'verbose',true);

    D3d.Open(imMax,imDMax);
    
    prompt = {'Enter Min Frame:','Enter Max Frame:'};
    dlg_title = 'Pick Time Range';
    num_lines = 1;
    defaultans = {'1',num2str(imDMax.NumberOfFrames)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    D3d.Close();
    timeRange = [str2double(answer{1}),str2double(answer{2})];
end

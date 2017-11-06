function [imROI,imROID] = GetRoi(im,imD)

    imZproject = ImUtils.ThreeD.GetTemproalMaxProjection(im);

    imNorm = mat2gray(imZproject(:,:,1));
    imNorm(:,:,2) = mat2gray(imZproject(:,:,2));
    imNorm = imNorm.*2;
    imNorm(imNorm>1) = 1;
    imNorm(:,:,3) = zeros(size(imNorm,1),size(imNorm,2));

    imZproject = imNorm;

    f = figure;
    bw = roipoly(imZproject);
    close(f);
    [r,c] = find(bw);
    rMin = min(r(:));
    rMax = max(r(:));
    cMin = min(c(:));
    cMax = max(c(:));
    xExt = [cMin,cMax];
    yExt = [rMin,rMax];
%    
% 
%     prompt = {'Enter Min X Coordinate:','Enter Min Y Coordinate:','Enter Max X Coordinate:','Enter Max Y Coordinate:'};
%     dlg_title = 'Z Projection Results';
%     num_lines = 1;
%     defaultans = {'1','1',num2str(size(im,2)),num2str(size(im,1))};
%     answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
%     close(f);
%     
%     xExt = [str2double(answer{1}),str2double(answer{3})];
%     yExt = [str2double(answer{2}),str2double(answer{4})];

    imROI = im(yExt(1):yExt(2),xExt(1):xExt(2),:,:,:);

    imXproject = ImUtils.ThreeD.GetTemproalMaxProjection(imROI,2);

    imNorm = mat2gray(imXproject(:,:,1));
    imNorm(:,:,2) = mat2gray(imXproject(:,:,2));
    imNorm = imNorm.*2;
    imNorm(imNorm>1) = 1;
    imNorm(:,:,3) = zeros(size(imNorm,1),size(imNorm,2));

    imXproject = imNorm;

    f = figure;
    bw = roipoly(imXproject);
    close(f);
    [~,c] = find(bw);
    zMin = min(c(:));
    zMax = max(c(:));
    zExt = [zMin,zMax];
    
%     imshow(imXproject);
%     
%     prompt = {'Enter Min X Coordinate:','Enter Max X Coordinate:'};
%     dlg_title = 'X Projection Results';
%     num_lines = 1;
%     defaultans = {'1',num2str(size(im,3))};
%     answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
%     close(f);

%     zExt = [str2double(answer{1}),str2double(answer{2})];
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

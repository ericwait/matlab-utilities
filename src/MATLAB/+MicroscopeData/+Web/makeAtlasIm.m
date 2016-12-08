function [imData] = makeAtlasIm(maxTextureWidth,maxTextureHeight,outputPath,inputPath,showProgress)

if (~exist('maxTextureWidth','var') || isempty(maxTextureWidth))
    maxTextureWidth = 4096;
end

if (~exist('maxTextureHeight','var') || isempty(maxTextureHeight))
    maxTextureHeight = 4096;
end

if (~exist('outputPath','var') || isempty(outputPath))
    outputPath = uigetdir('.','Choose Output Directory');
    if (~exist('inputPath','var') || isempty(inputPath))
        inputPath = outputPath;
    end
end

if (~exist(outputPath,'dir'))
    mkdir(outputPath);
end
if (~exist('inputPath','var'))
    inputPath = [];
end
if (~exist('showProgress','var') || isempty(showProgress))
    showProgress = false;
end

[im,imData] = MicroscopeData.Reader(inputPath,'verbose',true,'normalize',true);
% imData.DatasetName = sanitizeString(imData.DatasetName);

if (isempty(im))
    return
end

fit = false;
imDims.XDimension = imData.Dimensions(1);
imDims.YDimension = imData.Dimensions(2);
imDims.ZDimension = imData.Dimensions(3);

reductions = [1,1,1];

while (~fit)
    numImInX = min(floor(maxTextureWidth/imDims.XDimension),imDims.ZDimension);
    pwr2 = log2(numImInX*imDims.XDimension);
    
    if (pwr2<1)
        [imDims,reductions] = reduc(reductions,imData);
        continue
    end
    
    if (mod(pwr2,1)>0)
        outImWidth = 2^(floor(pwr2)+1);
    else
        outImWidth = 2^pwr2;
    end
    
    if (numImInX==imDims.ZDimension)
        numImInY = 1;
        pwr2 = log2(imDims.YDimension);
        if (pwr2<1)
            [imDims,reductions] = reduc(reductions,imData);
            continue
        end
        
        if (mod(pwr2,1)>0)
            outImHeight = 2^(floor(pwr2)+1);
        else
            outImHeight = imDims.YDimension;
        end
    else
        numImInY = ceil(imDims.ZDimension/numImInX);
        pwr2 = log2(numImInY*imDims.YDimension);
        if (pwr2<1)
            [imDims,reductions] = reduc(reductions,imData);
            continue
        end
        
        if (mod(pwr2,1)>0)
            outImHeight = 2^(floor(pwr2)+1);
        else
            outImHeight = numImInY*imDims.YDimension;
        end
    end
    
    if (outImHeight>maxTextureHeight)
        [imDims,reductions] = reduc(reductions,imData);
    else
        fit = true;
    end
end

imData.numImInX = numImInX;
imData.numImInY = numImInY;

% for t=1:imData.NumberOfFrames
%     for c=1:imData.NumberOfChannels
%         im(:,:,:,c,t) = CudaMex('ContrastEnhancement',im(:,:,:,c,t),[250,250,175],[3,3,3]);
%     end
% end
imData.ChannelColors = [ 1 1 1];
if (any(reductions>1))
    [im, imData] = ReduceImageTemp( im, imData, reductions, showProgress,0);
end

imD = zeros(imData.YDimension,imData.XDimension,imData.ZDimension,imData.NumberOfChannels,imData.NumberOfFrames);
for c=1:imData.NumberOfChannels
    imC = im(:,:,:,c,:);
    imC = imC - min(imC(:));
    imD(:,:,:,c,:) = double(imC) / double(max(imC(:)));
end

im = im2uint8(imD);
clear imD;

imOut = zeros(outImHeight,outImWidth,imData.NumberOfChannels,imData.NumberOfFrames,'uint8');

z = 1;
for y = 0:numImInY-1
    yStart = y*imData.YDimension +1;
    yEnd = yStart +imData.YDimension -1;
    for x = 0:numImInX-1
        xStart = x*imData.XDimension +1;
        xEnd = xStart +imData.XDimension -1;
        imOut(yStart:yEnd,xStart:xEnd,:,:) = im(:,:,z,:,:);
        z = z +1;
        if (z>imData.ZDimension), break; end
    end
    if (z>imData.ZDimension), break; end
end

for t=1:imData.NumberOfFrames
    for c=1:imData.NumberOfChannels
        imwrite(imOut(:,:,c,t), fullfile(outputPath,sprintf('%s_c%02d_t%04d.jpg',imData.DatasetName,c,t)),'quality',85);
    end
end

colors = GetChannelColors(imData);

fout = fopen(fullfile(outputPath,sprintf('%s_images.json',imData.DatasetName)),'w');

fprintf(fout,'{\n\t');
fprintf(fout,'"DatasetName" : "%s",\n\t',imData.DatasetName);
fprintf(fout,'"NumberOfChannels" : %d,\n\t',imData.NumberOfChannels);
fprintf(fout,'"NumberOfFrames" : %d,\n\t',imData.NumberOfFrames);
fprintf(fout,'"NumberOfPartitions" : 1,\n\t');
if (exist(fullfile(inputPath,'Processed',sprintf('%s_Segmenation.mat',imData.DatasetName)),'file'))
    fprintf(fout, '"BooleanHulls" : true,\n\t');
else
    fprintf(fout, '"BooleanHulls" : false,\n\t');
end
fprintf(fout,'"XDimension" : %d,\n\t',imData.XDimension);
fprintf(fout,'"YDimension" : %d,\n\t',imData.YDimension);
fprintf(fout,'"ZDimension" : %d,\n\t',imData.ZDimension);
fprintf(fout,'"NumberOfImagesWide" : %d,\n\t',numImInX);
fprintf(fout,'"NumberOfImagesHigh" : %d,\n\t',numImInY);
fprintf(fout,'"XPixelPhysicalSize" : %f,\n\t',imData.XPixelPhysicalSize);
fprintf(fout,'"YPixelPhysicalSize" : %f,\n\t',imData.YPixelPhysicalSize);
fprintf(fout,'"ZPixelPhysicalSize" : %f,\n\t',imData.ZPixelPhysicalSize);
fprintf(fout,'"ChannelColors" : [');
for c=1:imData.NumberOfChannels
    fprintf(fout,'"#%02X%02X%02X"',floor(colors(c,1)*255),floor(colors(c,2)*255),floor(colors(c,3)*255));
    if (c~=imData.NumberOfChannels)
        fprintf(fout,',');
    end
end
fprintf(fout,']\n}\n');
fclose(fout);

fout = fopen(fullfile(outputPath,sprintf('index.html')),'w');
fprintf(fout,'<!DOCTYPE html>\n');
fprintf(fout,'<html>\n');
fprintf(fout,'<head lang="en">\n');
fprintf(fout,'\t<meta charset="UTF-8">\n');
fprintf(fout,'\t<title></title>\n');
fprintf(fout,'</head>\n');
fprintf(fout,'<body>\n');
fprintf(fout,'<script type="text/javascript">\n');
fprintf(fout,'\tvar fullpath = window.location.pathname;\n');
fprintf(fout,'\tvar indices = [];\n');
fprintf(fout,'\tfor(var i = 0; i < fullpath.length; i++) {\n');
fprintf(fout,'\t\tif(fullpath[i] == ''/'') {\n');
fprintf(fout,'\t\t\tindices.push(i);\n');
fprintf(fout,'\t\t}\n');
fprintf(fout,'\t}\n');
fprintf(fout,'\tvar path = fullpath.substring(0, indices[indices.length-3]);\n');
fprintf(fout,'\twindow.location.href = "http://" + window.location.host + path + "/?%s";\n', imData.DatasetName);
fprintf(fout,'</script>\n');
fprintf(fout,'</body>\n');
fprintf(fout,'</html>\n');

if (exist(fullfile(inputPath,'Processed',sprintf('%s_Segmenation.mat',imData.DatasetName)),'file'))
    load(fullfile(inputPath,'Processed',sprintf('%s_Segmenation.mat',imData.DatasetName)));
    ExportHullsJSON(imData,Hulls,fullfile(outputPath,sprintf('%s_hulls.json',imData.DatasetName)));
end
end

function [imDims,reduction] = reduc(reduction,imData)
reduction = [reduction(1:2) + 1, reduction(3)+(mod(reduction(1),3)==0)];
imDims.XDimension = ceil(imData.Dimensions(1)/reduction(2));
imDims.YDimension = ceil(imData.Dimensions(2)/reduction(1));
imDims.ZDimension = ceil(imData.Dimensions(3)/reduction(3));
end
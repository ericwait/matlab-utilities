function unmix(DatasetName)

%% read
fprintf('Select Image Dir...');
dirName = uigetdir();

if (isempty(dirName))
    return
end

tic
im = tiffReader(DatasetName,dirName);
chan1 = uint8(im(:,:,:,1,1));
chan2 = uint8(im(:,:,:,1,2));
chan3 = uint8(im(:,:,:,1,3));
chan4 = uint8(im(:,:,:,1,4));
chan5 = uint8(im(:,:,:,1,5));
chan6 = uint8(im(:,:,:,1,6));

%% show
% figure
% imagesc(max(chan1,[],3))
% colormap gray
% figure
% imagesc(max(chan2,[],3))
% colormap gray
% figure
% imagesc(max(chan3,[],3))
% colormap gray
% figure
% imagesc(max(chan4,[],3))
% colormap gray
% figure
% imagesc(max(chan5,[],3))
% colormap gray
% figure
% imagesc(max(chan6,[],3))
% colormap gray

%% bin of 'pure' channels
chan1Bin = CudaMex('OtsuThresholdFilter',chan1,0.8);
chan1Bin = CudaMex('MaxFilterCircle',chan1Bin,[5,5,2]);
chan3Bin = CudaMex('OtsuThresholdFilter',chan3,0.8);
chan3Bin = CudaMex('MaxFilterNeighborHood',chan3Bin,[3,3,1]);
chan5Bin = CudaMex('OtsuThresholdFilter',chan5,0.2);
chan5Bin = keepLargestN(chan5Bin,5);
chan5Bin = CudaMex('MaxFilterNeighborHood',chan5Bin,[3,3,1]);

%% unmix channels
chan2Unmix = chan2;
chan4Unmix = chan4;
chan6Unmix = chan6;

factor2_1 = robustfit(double(chan1(chan1Bin>0)),double(chan2(chan1Bin>0)),[],[],'off');
factor2_3 = robustfit(double(chan3(chan3Bin>0)),double(chan2(chan3Bin>0)),[],[],'off');
factor2_5 = robustfit(double(chan5(chan5Bin>0)),double(chan2(chan5Bin>0)),[],[],'off');

%factor4_1 = robustfit(double(chan1(chan1Bin>0)),double(chan4(chan1Bin>0)),[],[],'off');
factor4_3 = robustfit(double(chan3(chan3Bin>0)),double(chan4(chan3Bin>0)),[],[],'off');
factor4_5 = robustfit(double(chan5(chan5Bin>0)),double(chan4(chan5Bin>0)),[],[],'off');

%factor6_1 = robustfit(double(chan1(chan1Bin>0)),double(chan6(chan1Bin>0)),[],[],'off');
factor6_3 = robustfit(double(chan3(chan3Bin>0)),double(chan6(chan3Bin>0)),[],[],'off');
factor6_5 = robustfit(double(chan5(chan5Bin>0)),double(chan6(chan5Bin>0)),[],[],'off');

chan2Unmix = chan2Unmix-chan1*factor2_1;
chan2Unmix(chan3Bin>0) = chan2Unmix(chan3Bin>0)-chan3(chan3Bin>0)*factor2_3;
chan2Unmix(chan5Bin>0) = chan2Unmix(chan5Bin>0)-chan5(chan5Bin>0)*factor2_5;

%chan4Unmix(chan1Bin>0) = chan4Unmix(chan1Bin>0)-chan1(chan1Bin>0)*factor4_1;
chan4Unmix(chan3Bin>0) = chan4Unmix(chan3Bin>0)-chan3(chan3Bin>0)*factor4_3;
chan4Unmix(chan5Bin>0) = chan4Unmix(chan5Bin>0)-chan5(chan5Bin>0)*factor4_5;

%chan6Unmix(chan1Bin>0) = chan6Unmix(chan1Bin>0)-chan1(chan1Bin>0)*factor6_1;
chan6Unmix(chan3Bin>0) = chan6Unmix(chan3Bin>0)-chan3(chan3Bin>0)*factor6_3;
chan6Unmix(chan5Bin>0) = chan6Unmix(chan5Bin>0)-chan5(chan5Bin>0)*factor6_5;

chan2Unmix = chan2Unmix-min(chan2Unmix(:));
chan2Unmix = uint8(double(chan2Unmix)/double(max(chan2Unmix(:))) * 255);

chan4Unmix = chan4Unmix-min(chan4Unmix(:));
chan4Unmix = uint8(double(chan4Unmix)/double(max(chan4Unmix(:))) * 255);

chan6Unmix = chan6Unmix-min(chan6Unmix(:));
chan6Unmix = uint8(double(chan6Unmix)/double(max(chan6Unmix(:))) * 255);

%% reprocess
% chan2Unmix = CudaMex('ContrastEnhancement',chan2Unmix,[30,30,10],[5,5,2]);
% chan4Unmix = CudaMex('ContrastEnhancement',chan4Unmix,[30,30,10],[5,5,2]);
% chan6Unmix = CudaMex('ContrastEnhancement',chan6Unmix,[30,30,10],[5,5,2]);

%% results
% figure
% imagesc(max(chan2Unmix,[],3))
% colormap gray
% figure
% imagesc(max(chan4Unmix,[],3))
% colormap gray
% figure
% imagesc(max(chan6Unmix,[],3))
% colormap gray

%% done
toc

tiffWriter(chan2Unmix,sprintf('%s\\unmix\\%s_c2',dirName,DatasetName));
imwrite(max(chan2Unmix,[],3),sprintf('%s\\unmix\\%s_c2_MIP',dirName,DatasetName),'tif','compression','lzw');
tiffWriter(chan4Unmix,sprintf('%s\\unmix\\%s_c4',dirName,DatasetName));
imwrite(max(chan4Unmix,[],3),sprintf('%s\\unmix\\%s_c4_MIP',dirName,DatasetName),'tif','compression','lzw');
tiffWriter(chan6Unmix,sprintf('%s\\unmix\\%s_c6',dirName,DatasetName));
imwrite(max(chan6Unmix,[],3),sprintf('%s\\unmix\\%s_c6_MIP',dirName,DatasetName),'tif','compression','lzw');
end


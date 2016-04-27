function WriteMIPcombs( im, imD, outDir )
%WRITEALLCOMBINATIONS Summary of this function goes here
%   Detailed explanation goes here

if (~exist('outDir','var') || isempty(outDir))
    outDir = imD.imageDir;
end

colors = MicroscopeData.Colors.GetChannelColors(imD);
masks = zeros(2^imD.NumberOfChannels,imD.NumberOfChannels);
for i=1:2^imD.NumberOfChannels
    masks(i,:) = bitget(i,imD.NumberOfChannels:-1:1);
end
masks = masks>0;

prgs = Utils.CmdlnProgress(size(masks,1),true,'Making Color Combinations');
chans = 1:imD.NumberOfChannels;
for j=1:size(masks,1)
    curChans = chans(masks(j,:));
    if (isempty(curChans))
        continue
    end
    
    colorMip = MicroscopeData.Colors.MIP(im, imD, curChans, colors);
    
    imageName = sprintf('_%s_chan%s.tif',imD.DatasetName,num2str(curChans,'%d'));
    imagePath = fullfile(outDir,imageName);
    
    imwrite(colorMip,imagePath,'tif','Compression','lzw');

    prgs.PrintProgress(j);
end

prgs.ClearProgress(true);
end


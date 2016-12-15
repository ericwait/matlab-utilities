poolObj = gcp('nocreate');
if (isempty(poolObj))
    parpool(6);
end

load('mixing.mat');
root = 'P:\Images\Temple\3d\SVZ\Montage\Deep\Deep Panel Feb2016 DAPI Mash1-647 Dcx-488 ki67-514 Laminin-Cy3 GFAP-594\';
dList = dir(root);

prgs = Utils.CmdlnProgress(length(dList),false,'Unmixing');

for i=1:length(dList)
    if (~dList(i).isdir || strcmp(dList(i).name,'.') || strcmp(dList(i).name,'..'))
        continue
    end
    
    fprintf('Reading...');
    [im,imD] = MicroscopeData.ReaderParZ(fullfile(root,[dList(i).name,'\']));
    if (isempty(imD))
        continue
    end
    fprintf('Unmixing...');
    im = Unmix.Image(im,imD,false,[],mixingMatrix,unmixingMatrix);
    fprintf('Converting...');
    im(im<0) = 0;
    clss = MicroscopeData.GetImageClass(imD);
    im = ImUtils.ConvertType(im,clss,true);
    fprintf('Writing...\n');
    
    MicroscopeData.Writer(im,fullfile(imD.imageDir,'_unmixed'),imD);
    MicroscopeData.Colors.WriteMIPcombs(im,imD,fullfile(imD.imageDir,'_unmixed'));
    
    prgs2 = Utils.CmdlnProgress(imD.NumberOfChannels,true,'Smoothing');
    for c=1:imD.NumberOfChannels
        im(:,:,:,c) = Cuda.Mex('ContrastEnhancement',im(:,:,:,c),[75,75,25],[3,3,3]);
        prgs2.PrintProgress(c);
    end
    prgs2.ClearProgress(true);
    
    MicroscopeData.Writer(im,fullfile(imD.imageDir,'_unmixed','Smoothed'),imD);
    MicroscopeData.Colors.WriteMIPcombs(im,imD,fullfile(imD.imageDir,'_unmixed','Smoothed'));
    
    for c=1:imD.NumberOfChannels
        im(:,:,:,c) = ImUtils.ConvertType(im(:,:,:,c),class(im));
    end
    
    MicroscopeData.Writer(im,fullfile(imD.imageDir,'_unmixed','Smoothed','normalized'),imD);
    MicroscopeData.Colors.WriteMIPcombs(im,imD,fullfile(imD.imageDir,'_unmixed','Smoothed','normalized'));
    
    prgs.PrintProgress(i);
end
prgs.ClearProgress(true);

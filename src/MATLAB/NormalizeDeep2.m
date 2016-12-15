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

    [im,imD] = MicroscopeData.ReaderParZ(fullfile(root,dList(i).name,'\'));
    
    for c=1:imD.NumberOfChannels
        im(:,:,:,c) = ImUtils.ConvertType(im(:,:,:,c),class(im),true);
    end
    
    MicroscopeData.Writer(im,fullfile(imD.imageDir,'normalized'),imD);
    MicroscopeData.Colors.WriteMIPcombs(im,imD,fullfile(imD.imageDir,'normalized'));
    
    prgs.PrintProgress(i);
end
prgs.ClearProgress(true);

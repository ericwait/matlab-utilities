poolObj = gcp('nocreate');
if (isempty(poolObj))
    parpool(6);
end

root = 'P:\Images\Temple\3d\SVZ\Montage\Deep\Deep Panel Feb2016 DAPI Mash1-647 Dcx-488 ki67-514 Laminin-Cy3 GFAP-594\';
dList = dir(root);
pathSuffix = fullfile('_unmixed','Smoothed\');

prgs = Utils.CmdlnProgress(length(dList),false,'Normalizing');

for i=1:length(dList)
    if (~dList(i).isdir || strcmp(dList(i).name,'.') || strcmp(dList(i).name,'..'))
        continue
    end
    imD = MicroscopeData.ReadMetadata(fullfile(root,dList(i).name,pathSuffix));
    if (isempty(imD))
        continue
    end
    prgs2 = Utils.CmdlnProgress(imD.NumberOfChannels,true,'Norm...');
    for c=1:imD.NumberOfChannels
        im = MicroscopeData.ReaderParZ(imD,[],c);
        im = ImUtils.ConvertType(im,class(im),true);
        MicroscopeData.Writer(im,fullfile(imD.imageDir,'normalized'),imD,[],c);
        prgs2.PrintProgress(c);
    end
    prgs2.ClearProgress(true);
    
    prgs.PrintProgress(i);
end
prgs.ClearProgress(true);

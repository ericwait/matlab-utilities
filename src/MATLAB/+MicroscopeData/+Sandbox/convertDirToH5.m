function convertDirToH5(root,dataDir)
newRoot = fullfile(root,'..','H5');
if (~exist('dataDir','var') || isempty(dataDir))
    dataDir = '.';
end

dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double';
                  'logical'};

dataTypeSize = [1;2;4;8;
                1;2;4;8;
                4;8;
                1];

imD = MicroscopeData.ReadMetadata(fullfile(root,dataDir));

if (~isempty(imD) && isfield(imD,'DatasetName'))
   if (~exist(fullfile(newRoot,dataDir,[imD.DatasetName,'.h5']),'file'))
       m = memory;
       if (isfield(imD,'PixelFormat'))
           typeIdx = find(strcmp(imD.PixelFormat,dataTypeLookup));
       else
           im = MicroscopeData.Reader(imD,1,1,1,[],[],true);
           typeIdx = find(strcmp(class(im),dataTypeLookup));
       end
       
       pixelSize = dataTypeSize(typeIdx);
       
       fullSize = prod(imD.Dimensions)*imD.NumberOfFrames*imD.NumberOfChannels*pixelSize;
       allFrameSize = prod(imD.Dimensions)*imD.NumberOfFrames*pixelSize;
       allChanSize = prod(imD.Dimensions)*imD.NumberOfChannels*pixelSize;
       zStackSize = prod(imD.Dimensions)*pixelSize;

       if (fullSize<m.MemAvailableAllArrays*0.8)
           im = MicroscopeData.Reader(imD);
           MicroscopeData.WriterH5(im,fullfile(newRoot,dataDir),'imageData',imD,'verbose',true);
       elseif (allFrameSize<m.MemAvailableAllArrays*0.8)
           for c=1:imD.NumberOfChannels
               im = MicroscopeData.Reader(imD,[],c);
               MicroscopeData.WriterH5(im,fullfile(newRoot,dataDir),'imageData',imD,'verbose',true,'chanList',c);
           end
       elseif (allChanSize<m.MemAvailableAllArrays*0.8)
           for t=1:imD.NumberOfFrames
               im = MicroscopeData.Reader(imD,t);
               MicroscopeData.WriterH5(im,fullfile(newRoot,dataDir),'imageData',imD,'verbose',true,'timeRange',[t,t]);
           end
       elseif (zStackSize<m.MemAvailableAllArrays*0.8)
           for t=1:imD.NumberOfFrames
               for c=1:imD.NumberOfChannels
                   im = MicroscopeData.Reader(imD,t,c);
                   MicroscopeData.WriterH5(im,fullfile(newRoot,dataDir),'imageData',imD,'verbose',true,'timeRange',[t,t],'chanList',c);
               end
           end
       else
           warning('Cannot write %s because a single frame/channel is too big %f',imD.DatasetName,zStackSize);
       end
   end
end

dList = dir(fullfile(root,dataDir));
for i=1:length(dList)
    if (~strcmp(dList(i).name,'.') && ~strcmp(dList(i).name,'..') && dList(i).isdir)
        MicroscopeData.Sandbox.convertDirToH5(root,fullfile(dataDir,dList(i).name));
    end
end

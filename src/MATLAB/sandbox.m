%% get factors and read in a mixed image
[ factors, unmixFactors ] = linearUnmixSignals(1);
[imMixed, imageData] = tiffReader();%[],[],[],[],'d:\Users\Eric.Bioimage29\Documents\Images\Temple\3mo wmSVZ 6-label 3-17-13\3mo wmSVZ 20x13\');

%% unmix
tic
imUnmixed = zeros(size(imMixed));
for time=1:size(imMixed,5)
    for z=1:size(imMixed,3)
        imtemp = unmixFactors*double(reshape(imMixed(:,:,z,:,time),[size(imMixed,1)*size(imMixed,2), size(imMixed,4)])).';
        imUnmixed(:,:,z,:,time) = reshape(imtemp.',[size(imMixed,1),size(imMixed,2),1,1,size(imMixed,4)]);
    end
end
imUnmixed(imUnmixed<0) = 0;
toc

%% cuda test
tic
cudaOut = CudaMex_d('LinearUnmixing',imMixed,unmixFactors);
toc

%% diplay results
for c=1:size(imUnmixed,4)
    figure
    subplot(1,3,1);
    imagesc(max(imMixed(:,:,:,c),[],3))
    colormap gray
    subplot(1,3,2);
    imagesc(max(imUnmixed(:,:,:,c),[],3))
    colormap gray
    subplot(1,3,3);
    imagesc(max(cudaOut(:,:,:,c),[],3))
    colormap gray
end

%% make dir lists
root = 'd:\Users\Eric.Bioimage29\Documents\Images\Keen\';

rootDirlist = dir(root);
for i=1:length(rootDirlist)
    if strcmp(rootDirlist(i).name,'.') || strcmp(rootDirlist(i).name,'..') || ~rootDirlist(i).isdir, continue, end
    nextDirlist = dir(fullfile(root,rootDirlist(i).name));
    f = fopen(fullfile(root,rootDirlist(i).name,'list.txt'),'w');
    for j=1:length(nextDirlist)
        if strcmp(nextDirlist(j).name,'.') || strcmp(nextDirlist(j).name,'..') || ~nextDirlist(j).isdir || strcmp(nextDirlist(j).name,'list.txt')
            continue
        end
        fprintf(f,'%s\n',nextDirlist(j).name);
    end
    fclose(f);
end

f = fopen('metaOrg.xml','w');
md = data{10,2};
metadataKeys = md.keySet().iterator();
for i=1:md.size()
  key = metadataKeys.nextElement();
  value = md.get(key);
  fprintf(f,'%s = %s\n', key, value);
end
fclose(f);
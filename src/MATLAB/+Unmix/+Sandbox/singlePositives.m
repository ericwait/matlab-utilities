%% read signatures
rootDir = 'D:\Users\Eric\Documents\Images\3mo wmSVZ 6-label 3-17-13\';
datasets = {'DAPI SinglePos 20x1 OptPure', 'Olig2-514 SinglePos 20x1', 'GFAP-all2ary SinglePos 20x1',...
    'Mash1-647 SinglePos 20x1', 'PSA-NCAM-A549 SinglePos 20x1', 'lectin-568 SinglePos 20x1'};
orgImagesRoot = '3mo wmSVZ';
tic

%% create factors

factors = zeros(length(datasets),length(datasets),2);
for stain=1:length(datasets)
    imSinglePos = tiffReader([],[],[],[],fullfile(rootDir,datasets{stain}),sprintf('%s.txt',datasets{stain}));
    imStain = imSinglePos(:,:,:,:,stain);
    imStain = [imStain(:) ones(length(imStain(:)),1)];
    for chan=1:length(datasets)
        if (chan==stain)
            factors(chan,stain,:) = [1 0];
        else
            imChan = imSinglePos(:,:,:,:,chan);
            [factors(chan,stain,:), ~, r] = regress(imChan(:),imStain);
            dif = (max(imChan(:)) - factors(chan,stain,2));
            if (dif<=10)
                factors(chan,stain,1) = 0;
            end
%             fprintf('\tS:%d C:%d dif=%f\n',stain,chan,dif);
%             figure
%             hold on
%             plot(imStain(:,1),imChan(:),'.b');
%             plot([0 255],factors(chan,stain,1)*[0 255]+factors(chan,stain,2),'--g');
%             xlabel(sprintf('(%d) %s',stain,datasets{stain}));
%             ylabel(sprintf('(%d) %s',chan,datasets{chan}));
        end
    end
end

%% adjust factors

factors(factors<0) = 0;

for col=1:size(factors,1)
    factors(col,col,1) = 2-sum(factors(:,col,1)); 
end

unmixFactors = inv(factors(:,:,1));

%% read image to be unmixed

dirList = dir(fullfile(rootDir,sprintf('%s*',orgImagesRoot)));
mkdir(fullfile(rootDir,'Unmixed'));

for i=1:length(dirList)
    orgImages = dirList(i).name;
    
    if (~isempty(strfind(orgImages,'Unmixed')))
        continue;
    end
    
    newDir = fullfile(rootDir,'Unmixed',sprintf('%s Unmixed',orgImages));
    [~,~,id] = mkdir(newDir);
    if (strcmp(id,'MATLAB:MKDIR:DirectoryExists'))
        continue;
    end
    
    try
        imMixed = tiffReader([],[],[],[],fullfile(rootDir,orgImages),sprintf('%s.txt',orgImages));
    catch err
        continue;
    end
    
    %% unmix
    imUnmixed = zeros(size(imMixed));
    for time=1:size(imMixed,4)
        for z=1:size(imMixed,3)
            imtemp = unmixFactors*(reshape(imMixed(:,:,z,time,:),[size(imMixed,1)*size(imMixed,2), size(imMixed,5)])).';
            imUnmixed(:,:,z,time,:) = reshape(imtemp.',[size(imMixed,1),size(imMixed,2),1,1,size(imMixed,5)]);
%             if (mod(z,10)==0)
%                 fprintf('.');
%             end
        end
    end
    
    imUnmixed(imUnmixed<0) = 0;
    
    for c=1:6
        imU = imUnmixed(:,:,:,1,c);
        imU = imU./max(255,max(imU(:)));
        imUnmixed(:,:,:,1,c) = imU;
        %     figure
        %     subplot(2,1,1);
        %     imagesc(max(imMixed(:,:,:,1,c),[],3));
        %     colormap gray
        %     subplot(2,1,2);
        %     imagesc(max(imUnmixed(:,:,:,1,c),[],3))
        %     colormap gray
    end
    
    %% write out Metadata
    oldMetadataFile = fullfile(rootDir,orgImages,sprintf('%s.txt',orgImages));
    newMetadataFile = fullfile(newDir,sprintf('%s Unmixed.txt',orgImages));
    fOld = fopen(oldMetadataFile,'r');
    fNew = fopen(newMetadataFile,'w');
    
    l = fgetl(fOld);
    fprintf(fNew,'%s Unmixed\r\n',l);
    while ischar(l)
        l = fgetl(fOld);
        fprintf(fNew,'%s\r\n',l);
    end
    fclose(fOld);
    fclose(fNew);
    
    %% write out images
    tiffWriter(imUnmixed,fullfile(newDir,sprintf('%s Unmixed',orgImages)));

end

toc
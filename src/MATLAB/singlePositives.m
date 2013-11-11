rootDir = 'D:\Users\Eric\Documents\Programming\Images\22mo wmSVZ 3-23-13\';
datasets = {'DAPI SinglePos 20x4x1', 'Olig2 SinglePos 20x4x1', 'GFAP SinglePos 20x4x1',...
    'Mash1-647 SinglePos 20x4x1', 'PSA-NCAM-514 SinglePos 20x4x1', 'Lectin-568 SinglePos 20x4x1'};

factors = zeros(length(datasets),length(datasets),2);
for stain=1:length(datasets)
    for chan=1:length(datasets)
        imSinglePos(chan,:,:) = imread(fullfile(rootDir,datasets{stain},sprintf('%s_c%d_t0001_z0001.tif',datasets{stain},chan)));
    end
    imStain = imSinglePos(stain,:,:);
    imStain = [imStain(:) ones(length(imStain(:)),1)];
    for chan=1:length(datasets)
        if (chan==stain)
            factors(chan,stain,:) = [1 0];
        end
        
        imChan = imSinglePos(chan,:,:);
        factors(chan,stain,:) = regress(double(imChan(:)),double(imStain));
    end
end

factors(factors<0) = 0;

norms = factors(:,:,1) \ ones(length(datasets),1);

mixFactors = factors(:,:,1)*diag(norms);

unmixFactors = inv(mixFactors);

imMixed = tiffReader('uint8');

imUnmixed = zeros(size(imMixed));
for z=1:size(imMixed,3)
    for x=1:size(imMixed,2)
        for y=1:size(imMixed,1)
            imUnmixed(y,x,z,1,:) = uint8(unmixFactors*squeeze(double(imMixed(y,x,z,1,:))));
        end
    end
end
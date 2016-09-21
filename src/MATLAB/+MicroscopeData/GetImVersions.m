function [ versions ] = GetImVersions( imageDataOrPath )

if (~exist('imageDataOrPath','var') || isempty(imageDataOrPath))
    imD = MicroscopeData.ReadMetadata();
elseif (isstruct(imageDataOrPath) && isfield(imageDataOrPath,'imageDir'))
    imD = imageDataOrPath;
else
    imD = MicroscopeData.ReadMetadata(imageDataOrPath);
end

info = h5info(fullfile(imD.imageDir,[imD.DatasetName '.h5']));
imGrpInfo = info.Groups;

if (isempty(imGrpInfo))
    warning('No image versions found!');
    versions = {''};
    return
end

versions = {imGrpInfo.Datasets.Name};

mask = cellfun(@(x)(isempty(strfind(x,'_MIP'))),versions);
versions = versions(mask);

end

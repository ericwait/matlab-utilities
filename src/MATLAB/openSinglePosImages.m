function imSinglePos = openSinglePosImages()
imSinglePos = [];

uiwait(msgbox({'Choose single positive images and click cancel when done.',...
    '',...
    'A single positive image should have only one stain present in the',...
    'specimen, but each channel should be exposed with the EXACT paramaters',...
    'used in the full experiment. There should be the same number of single',...
    'positive images as there are stains. In other words, there should be NxN',...
    'exposures where N is the number of stains present in the full experiment.'},...
    'Single Positive Definition','help','modal'));

singlePosFiles = struct('name',{},'path',{});
root = '';
while (true)
    [FileName,PathName,~] = uigetfile(fullfile(root,'*.txt'));
    if FileName==0, break, end
    
    root = PathName;
    ind = strfind(FileName,'.');
    name = FileName(1:ind-1);
    singlePosFiles(end+1).name = name;
    singlePosFiles(end).path = fullfile(PathName,FileName);
    fprintf('%d)%s, ',length(singlePosFiles),singlePosFiles(end).name);
end
fprintf('\n');

if isempty(singlePosFiles), disp('No Files...Exiting!')
    return;
end

qstring = sprintf('1) %s\n',singlePosFiles(1).name);
for i=2:length(singlePosFiles)
    qstring = [qstring {sprintf('%d) %s\n',i,singlePosFiles(i).name)}];
end

choice = questdlg(qstring,'Channel Order','Yes','No','Yes');

if (strcmp(choice,'No'))
    return;
end

im = tiffReader(singlePosFiles(1).path,[],[],[],'double',false,true);
imSinglePos = zeros([size(im), length(singlePosFiles)],'like',im);
imSinglePos(:,:,:,:,1) = im;

for i=2:length(singlePosFiles)
    imSinglePos(:,:,:,:,i) = tiffReader(singlePosFiles(i).path,[],[],[],'double',false,true);
end
end

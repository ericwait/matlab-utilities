function [ factors, unmixFactors ] = linearUnmixSignals(showPlots,zeroChannels)
%LINEARUNMIXSIGNALS Summary of this function goes here
%   Detailed explanation goes here

if (~exist('showPlots','var') || isempty(showPlots))
    showPlots = 0;
end

%% open data
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

if isempty(singlePosFiles), disp('No Files...Exiting!')
    factors = [];
    unmixFactors = [];
    return
end

qstring = '';
for i=1:length(singlePosFiles)
    qstring = [qstring sprintf('%d)%s, ',i,singlePosFiles(i).name)];
end
choice = questdlg(qstring,'Channel Order','Yes','No','Yes');
if (strcmp(choice,'No'))
    factors = [];
    unmixFactors = [];
    return;
end

%% create factors
minVal = [];
maxVal = [];

factors = zeros(length(singlePosFiles),length(singlePosFiles),2);
for stain=1:length(singlePosFiles)
    imSinglePos = tiffReader(singlePosFiles(stain).path,[],[],[],'single',0,1);
    if (~isempty(zeroChannels) && ~any(zeroChannels==stain))
        imSinglePos(:,:,:,zeroChannels) = zeros(size(imSinglePos(:,:,:,zeroChannels)),'like',imSinglePos);
    end
    imStain = imSinglePos(:,:,:,stain,:);
    imStain = [imStain(:) ones(length(imStain(:)),1)];
    for chan=1:length(singlePosFiles)
        if (chan==stain)
            factors(chan,stain,:) = [1 0];
        else
            imChan = imSinglePos(:,:,:,chan,:);
            [factors(chan,stain,:), ~] = regress(double(imChan(:)),double(imStain));
            dif = (max(imChan(:)) - factors(chan,stain,2));
%             if (dif<=10)
%                 factors(chan,stain,1) = 0;
%             end
            if (showPlots~=0)
                [minVal, maxVal] = plotRegression(imSinglePos,singlePosFiles,stain,chan,dif,imStain,imChan,factors,minVal,maxVal);
            end
        end
    end
end

%% adjust factors

% factors(factors<0) = 0;
% 
% for col=1:size(factors,1)
%     factors(col,col,1) = 2-sum(factors(:,col,1));
% end

unmixFactors = inv(factors(:,:,1));

end

function [minVal, maxVal] = plotRegression(imSinglePos,singlePosFiles,stain,chan,dif,imStain,imChan,factors,minVal,maxVal)
if (~exist('maxVal','var') || isempty(maxVal))
    switch class(imSinglePos)
        case 'uint8'
            maxVal = 2^8-1;
            minVal = 0;
        case 'uint16'
            maxVal = 2^16-1;
            minVal = 0;
        case 'int16'
            maxVal = 2^16 /2 -1;
            minVal = 0;
        case 'uint32'
            maxVal = 2^32-1;
            minVal = 0;
        case 'int32'
            maxVal = 2^32 /2 -1;
            minVal = -maxVal -1;
        case 'single'
            maxVal = max(imSinglePos(:));
            minVal = min(imSinglePos(:));
            if (maxVal<1), maxVal=1; end
            if (minVal>0), minVal=0; end
        case 'double'
            maxVal = max(imSinglePos(:));
            minVal = min(imSinglePos(:));
            if (maxVal<1), maxVal=1; end
            if (minVal>0), minVal=0; end
    end
end
fprintf('\tS:%d C:%d dif=%f\n',stain,chan,dif);
figure
hold on
plot(imStain(:,1),imChan(:),'.b');
plot([minVal maxVal],factors(chan,stain,1)*[minVal maxVal]+factors(chan,stain,2),'--g');
ylim([minVal maxVal]);
xlim([minVal maxVal]);
xlabel(sprintf('(%d) %s',stain,singlePosFiles(stain).name));
ylabel(sprintf('(%d) %s',chan,singlePosFiles(chan).name));
end


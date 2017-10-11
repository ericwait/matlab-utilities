function imSinglePos = OpenSinglePosImages(imagePaths)
    imSinglePos = [];

    if (~exist('imagePaths','var') || isempty(imagePaths))
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
            [FileName,PathName,~] = uigetfile(fullfile(root,'*.json'));
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
    else
        singlePosFiles.path = imagePaths{1};
        for i=2:length(imagePaths)
            singlePosFiles(i).path = imagePaths{i};
        end
    end

    im = MicroscopeData.Reader(singlePosFiles(1).path);
    imSinglePos = cell(length(singlePosFiles),1);
    imSinglePos{1} = im;

    prgs = Utils.CmdlnProgress(length(singlePosFiles)-1,true,'Opening Single Pos');
    for i=2:length(singlePosFiles)
        curIm = MicroscopeData.Reader(singlePosFiles(i).path);
        imSinglePos{i} = curIm;
        prgs.PrintProgress(i);
    end
    prgs.ClearProgress(true);
end

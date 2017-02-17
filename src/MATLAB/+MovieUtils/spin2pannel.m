%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
imD = MicroscopeData.ReadMetadata();
movieTime = 12;
fps = 30;
spinTimes = 1;
pauseTime = 0.5;
rotTime = 2;
rotAngle = 60;
zoomAmount = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timeFrames = fps*movieTime;
framesPerT = ceil(timeFrames/imD.NumberOfFrames);
timeFrames = framesPerT*imD.NumberOfFrames;
thetaDelta = (spinTimes*360)/(imD.NumberOfFrames*framesPerT);
pauseFrames = fps*pauseTime;
rotFrames = fps*rotTime;
rotDelta = rotAngle/rotFrames;
zoomDelta = zoomAmount/rotFrames;

%% setup 
sigs = 75 * (imD.PixelPhysicalSize./max(imD.PixelPhysicalSize));
movieDir = fullfile(imD.imageDir,'movies',imD.DatasetName);
if (exist(movieDir,'dir'))
    rmdir(movieDir,'s');
end
mkdir(movieDir);

totalFrames = 2*(pauseFrames + rotFrames + pauseFrames + timeFrames*framesPerT + pauseFrames + rotFrames + pauseFrames);
frameCount = 1;

%% capture
prgs = Utils.CmdlnProgress(totalFrames,true);
im = MicroscopeData.Reader('imageData',imD);
for j=1:2
    %% open the viewer
    switch j
        case 1
            titl = 'Original';
        case 2
            titl = 'Smoothed';
    end
    
    D3d.Open(im,imD);
    clear im
    D3d.LoadTransferFunction();
    
    D3d.Viewer.TextureLighting(true);
    
    D3d.Viewer.SetWindowSize(1920/2,1080);    
    D3d.Viewer.ShowFrameNumber(true);
    D3d.Viewer.ShowScaleBar(true);
    D3d.Viewer.ShowWidget(false);
    D3d.Viewer.SetWorldRotation([0,1,0],180);
    D3d.Update();
    frameRH = D3d.Viewer.CaptureWindow();
    
    D3d.Viewer.ShowFrameNumber(false);
    D3d.Viewer.ShowScaleBar(false);
    D3d.Viewer.ShowWidget(true);
    D3d.Update();
    frameLH = D3d.Viewer.CaptureWindow();
    
    %% pause
    movieFrame = cat(2,frameLH,frameRH);
    movieFrame = insertText(movieFrame,[1920/2,40],titl,'AnchorPoint','center','BoxColor',[64,64,64],'TextColor',[220,220,220],'FontSize',52);
    for t=1:pauseFrames
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% rotate
    for t=1:rotFrames
        D3d.Viewer.SetViewRotation([1,0,0],rotDelta);
        D3d.Viewer.MoveCamera([0,0,zoomDelta]);
        D3d.Update();
        frameLH = D3d.Viewer.CaptureWindow();
        
        movieFrame = cat(2,frameLH,frameRH);
        movieFrame = insertText(movieFrame,[1920/2,40],titl,'AnchorPoint','center','BoxColor',[64,64,64],'TextColor',[220,220,220],'FontSize',52);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% pause
    for t=1:pauseFrames
        movieFrame = cat(2,frameLH,frameRH);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% play
    for t=1:imD.NumberOfFrames
        D3d.Viewer.SetFrame(t);
        D3d.Viewer.ResetView();
        D3d.Viewer.SetWorldRotation([0,1,0],180);       
        D3d.Viewer.ShowFrameNumber(true);
        D3d.Viewer.ShowScaleBar(true);
        D3d.Viewer.ShowWidget(false);
        D3d.Update();
        frameRH = D3d.Viewer.CaptureWindow();
        
        D3d.Viewer.ShowFrameNumber(false);
        D3d.Viewer.ShowScaleBar(false);
        D3d.Viewer.ShowWidget(true);
        D3d.Viewer.SetViewRotation([1,0,0],rotAngle);
        D3d.Viewer.SetWorldRotation([0,0,-1],(t-1)*thetaDelta*framesPerT);
        D3d.Viewer.MoveCamera([0,0,zoomAmount]);
        D3d.Update();
        frameLH = D3d.Viewer.CaptureWindow();
        
        movieFrame = cat(2,frameLH,frameRH);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
        
        for i=1:framesPerT-1
            D3d.Viewer.SetWorldRotation([0,0,-1],thetaDelta);
            D3d.Update();
            frameLH = D3d.Viewer.CaptureWindow();
            
            movieFrame = cat(2,frameLH,frameRH);
            imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
            frameCount = frameCount +1;
        end
        
        prgs.PrintProgress(frameCount);
    end
    
    D3d.Viewer.SetWorldRotation([0,0,-1],thetaDelta);
    D3d.Update();
    frameLH = D3d.Viewer.CaptureWindow();
    
    movieFrame = cat(2,frameLH,frameRH);
    imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
    frameCount = frameCount +1;
    
    %% pause
    for t=1:pauseFrames
        movieFrame = cat(2,frameLH,frameRH);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% rotate
    for t=1:rotFrames
        D3d.Viewer.SetViewRotation([1,0,0],-rotDelta);
        D3d.Viewer.MoveCamera([0,0,-zoomDelta]);
        D3d.Update();
        frameLH = D3d.Viewer.CaptureWindow();
        
        movieFrame = cat(2,frameLH,frameRH);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% pause
    for t=1:pauseFrames
        movieFrame = cat(2,frameLH,frameRH);
        imwrite(movieFrame,fullfile(movieDir,sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
    %% close up and read the next
    D3d.Close();
    clear frameLH
    clear frameRH
    clear movieFrame
    
    if (j==1)
        im = MicroscopeData.Reader('imageData',imD,'imVersion','Processed');
    end
end
prgs.ClearProgress(true);

%% make mp4
range = [1,frameCount];
ffmpegimages2video(fullfile(movieDir,'%04d.tif'),...
    fullfile(movieDir,[imD.DatasetName,'.mp4']),...
    'InputFrameRate',fps,...
    'InputStartNumber',range,...
    'x264Tune','stillimage',...
    'OutputFrameRate',fps);

copyfile(fullfile(movieDir,[imD.DatasetName,'.mp4']),fullfile(imD.imageDir,[imD.DatasetName,'.mp4']));

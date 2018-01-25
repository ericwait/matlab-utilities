function CreateTimelapseMovie(movieDurration,startFrame,endFrame,moviePath,movieName)
% CreateTimelapseMovie(movieDurration,startFrame,endFrame,moviePath,movieName)
% Ensure you run the following line to ensure that the resize of the window
% preserves your view!
% D3d.Viewer.SetWindowSize(1920,1080); D3d.Update();

% movieDurration = number of seconds you want the movie to run for
% startFrame = the frame number you want the movie to start from
% endFrame = the frame number you want the movie to end on
% moviePath = the path to the new directory you would like to put you movie
%   IMPORTANT! A new folder will be created for you, if it exists it will
%   be cleaned out first.
% movieName = the file name of the output. The movie will end up being
% movieName.mp4, please leave off the .mp4 when passing in a name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User Settings
movieTime = movieDurration;
showFrames = startFrame:endFrame;
numShowFrames = length(showFrames);
fps = 30;
pauseTime = 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timeFrames = fps*movieTime;
framesPerT = ceil(timeFrames/numShowFrames);
timeFrames = framesPerT*numShowFrames;
pauseFrames = fps*pauseTime;

%% setup 
movieDir = moviePath;
if (exist(movieDir,'dir'))
    rmdir(movieDir,'s');
end
mkdir(movieDir);
mkdir(fullfile(movieDir,'frames'));

totalFrames = 2*(pauseFrames + timeFrames*framesPerT + pauseFrames);
frameCount = 1;

%% setup view
    prgs = Utils.CmdlnProgress(totalFrames,true);   
    D3d.Viewer.SetWindowSize(1920,1080);
    D3d.Viewer.SetCaptureSize(1920,1080);
    D3d.Viewer.ShowFrameNumber(true);
    D3d.Viewer.ShowScaleBar(true);
    D3d.Viewer.ShowWidget(true);
    D3d.Update();
    frame = D3d.Viewer.CaptureWindow();
    
%% pause
    for t=1:pauseFrames
        imwrite(frame,fullfile(movieDir,'frames',sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    
%% play
    for t=showFrames
        D3d.Viewer.SetFrame(t);
        D3d.Update();
        frame = D3d.Viewer.CaptureWindow();
        
        imwrite(frame,fullfile(movieDir,'frames',sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
        
        for i=1:framesPerT-1
            imwrite(frame,fullfile(movieDir,'frames',sprintf('%04d.tif',frameCount)));
            frameCount = frameCount +1;
        end
        
        prgs.PrintProgress(frameCount);
    end
    
%% pause
    D3d.Viewer.SetFrame(showFrames(end));
    D3d.Update();
    for t=1:pauseFrames
        imwrite(frame,fullfile(movieDir,'frames',sprintf('%04d.tif',frameCount)));
        frameCount = frameCount +1;
    end
    prgs.PrintProgress(frameCount);
    clear frame

prgs.ClearProgress(true);

%% make mp4
    range = [1,frameCount];
    ffmpegimages2video(fullfile(movieDir,'frames','%04d.tif'),...
        fullfile(movieDir,[movieName,'.mp4']),...
        'InputFrameRate',fps,...
        'InputStartNumber',range,...
        'x264Tune','stillimage',...
        'OutputFrameRate',fps);
end

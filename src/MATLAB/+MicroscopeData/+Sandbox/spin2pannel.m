[im,imD] = MicroscopeData.Original.ReadData();
im = im{1};
imD = imD{1};
imD.PixelPhysicalSize(3) = imD.PixelPhysicalSize(3)/2;
MicroscopeData.WriterH5(im,'imageData',imD,'path',fullfile('D:\H5\Temple',imD.DatasetName),'verbose',true);

%%
D3d.Open(im,imD);
D3d.Viewer.SetWindowSize(1920/2,1080);
D3d.Viewer.ZoomDecrement(1);

%%
fps = 10;
thetaDelta = 720/imD.NumberOfFrames;

movieDir = fullfile('.','movies',imD.DatasetName);
if (exist(movieDir,'dir'))
    rmdir(movieDir,'s');
end
mkdir(movieDir);

prgs = Utils.CmdlnProgress(imD.NumberOfFrames,true);
for t=1:imD.NumberOfFrames
    D3d.Viewer.SetFrame(t);
    
    D3d.Viewer.ShowFrameNumber(true);
    D3d.Viewer.ShowScaleBar(true);
    D3d.Viewer.ShowWidget(false);
    
    frame2D = D3d.Viewer.CaptureWindow();
    
    D3d.Viewer.ShowFrameNumber(false);
    D3d.Viewer.ShowScaleBar(false);
    D3d.Viewer.ShowWidget(true);
    
    D3d.Viewer.SetViewRotation([1,0,0],60);
    D3d.Viewer.SetWorldRotation([0,0,1],45);
    %D3d.Viewer.SetWorldRotation([0,0,-1],(t-1)*thetaDelta);
    D3d.Viewer.ZoomDecrement(0.8);
    
    frame3D = D3d.Viewer.CaptureWindow();
    
    D3d.Viewer.ZoomIncrement(0.8);
    %D3d.Viewer.SetWorldRotation([0,0,1],(t-1)*thetaDelta);
    D3d.Viewer.SetWorldRotation([0,0,-1],45);
    D3d.Viewer.SetViewRotation([-1,0,0],60);
    
    im = cat(2,frame3D,frame2D);
    imwrite(im,fullfile(movieDir,sprintf('%04d.tif',t)));
    
    prgs.PrintProgress(t);
end
prgs.ClearProgress(true);

%%
range = [1,imD.NumberOfFrames];
ffmpegimages2video(fullfile(movieDir,'%04d.tif'),...
    fullfile(movieDir,[imD.DatasetName,'.mp4']),...
    'InputFrameRate',10,...
    'InputStartNumber',range,...
    'x264Tune','stillimage',...
    'OutputFrameRate',10);

copyfile(fullfile(movieDir,[imD.DatasetName,'.mp4']),fullfile(imD.imageDir,[imD.DatasetName,'.mp4']));
copyfile(fullfile(movieDir,[imD.DatasetName,'.mp4']),fullfile('D:\H5\Temple',imD.DatasetName,[imD.DatasetName,'.mp4']));

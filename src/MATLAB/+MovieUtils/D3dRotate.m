function movieFrames = D3dRotate(numFrames,rotDelta,rotVec,zoomDelta,framePad,padRotOrZoom)
    if (~exist('zoomDelta','var') || isempty(zoomDelta))
        zoomDelta = 0;
    end
    if (~exist('framePad','var') || isempty(framePad))
        framePad = 0;
    end
    if (~exist('padRotOrZoom','var'))
        padRotOrZoom = [];
    end
    
    curFrame = D3d.Viewer.CaptureWindow();
    movieFrames = zeros([size(curFrame),numFrames+numFrames*framePad],'like',curFrame);
    clear curFrame
    
    frameCount = 1;
    for t=1:numFrames
        if (strcmpi(padRotOrZoom,'zoom'))
            for i=1:framePad
                D3d.Viewer.SetViewRotation(rotVec,rotDelta);
                D3d.Update();
                movieFrames(:,:,:,frameCount) = D3d.Viewer.CaptureWindow();
                frameCount = frameCount +1;
            end
            D3d.Viewer.MoveCamera([0,0,zoomDelta]);

        elseif (strcmpi(padRotOrZoom,'rot'))
            for i=1:framePad
                D3d.Viewer.MoveCamera([0,0,zoomDelta]);
                D3d.Update();
                movieFrames(:,:,:,frameCount) = D3d.Viewer.CaptureWindow();
                frameCount = frameCount +1;
            end
            D3d.Viewer.SetViewRotation(rotVec,rotDelta);
        end
        
        D3d.Viewer.SetViewRotation(rotVec,rotDelta);
        D3d.Viewer.MoveCamera([0,0,zoomDelta]);
        D3d.Update();
        movieFrames(:,:,:,frameCount) = D3d.Viewer.CaptureWindow();
        frameCount = frameCount +1;
    end
end

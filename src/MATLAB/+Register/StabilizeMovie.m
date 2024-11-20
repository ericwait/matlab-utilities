function [imOut, imageDataOut,cumulativeDeltas_rc] = StabilizeMovie(imIn,varargin)

    validScalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    %% Input parsing
    p = inputParser;

    % Define the required and optional parameters
    addRequired(p, 'imIn');  % Required input (image data)

    % Optional parameters with default values
    addOptional(p, 'metadata', MicroscopeData.MakeMetadataFromImage(imIn), @isstruct);
    addOptional(p, 'cumulativeDeltas_rc', []);
    addOptional(p, 'toFirstFrame', false);
    addParameter(p, 'minOverlap', 25, validScalar);
    addParameter(p, 'maxSearchSize', 100, validScalar);
    addParameter(p, 'logFile', 1);
    addParameter(p, 'visualize', false, @islogical);
    addParameter(p, 'imMask1', []);
    addParameter(p, 'imMask2', []);
    addParameter(p, 'unitFactor', 1, validScalar);
    addParameter(p, 'prctMemParFor', 0.8, validScalar);

    % Parse the inputs
    parse(p, imIn, varargin{:});

    % Extract parsed values
    imIn = p.Results.imIn;
    metadata = p.Results.metadata;
    cumulativeDeltas_rc = p.Results.cumulativeDeltas_rc;
    toFirstFrame = p.Results.toFirstFrame;
    unitFactor = p.Results.unitFactor;
    minOverlap = p.Results.minOverlap;
    maxSearchSize = p.Results.maxSearchSize;
    logFile = p.Results.logFile;
    visualize = p.Results.visualize;
    imMask1 = p.Results.imMask1;
    imMask2 = p.Results.imMask2;
    prctMemParFor = p.Results.prctMemParFor;
    
    is = tic;
    
%% run the reg
    if (isempty(cumulativeDeltas_rc))
    % calculate the size of the parallel pool needed
    
        numVoxels = prod(metadata.Dimensions);
        w = whos('imIn');
        memNeededBytes = numVoxels*8*8 + 2*w.bytes;
        m = memory;
        pc = parcluster('local');

        numWorkers = floor((m.MemAvailableAllArrays*prctMemParFor)/memNeededBytes);
        numWorkers = min(pc.NumWorkers,numWorkers);

        p = gcp('nocreate');
        oldWorkers = 0;
        if (isvalid(p))
            oldWorkers = p.NumWorkers;
        end
        if (oldWorkers==0)
            parpool(numWorkers);
        elseif (oldWorkers>numWorkers)
            delete(p);
            parpool(numWorkers);
        end    
    
        imMetaT = metadata;
        imMetaT.NumberOfFrames = 1;

        frameDeltas_xyz = zeros(metadata.NumberOfFrames,5);
        parfor t=1:metadata.NumberOfFrames-1
            if (toFirstFrame)
                curFrame = imIn(:,:,:,:,1);
            else
                curFrame = imIn(:,:,:,:,t);
            end
            curMeta = imMetaT;
            curMeta.Position = [0,0,0];
            %curD.Position = squeeze(posT(1,1,t,:))';
            nextFrame = imIn(:,:,:,:,t+1);
            nextMeta = imMetaT;
            nextMeta.Position = [0,0,0];
            %nextD.Position = squeeze(posT(1,1,t+1,:))';

           [deltaX,deltaY,deltaZ,maxNCV,overlapSize] = Register.TwoImages(curFrame, nextFrame,...
               'metadata1', curMeta, 'metadata2', nextMeta,...
               'imMask1', imMask1, 'imMask2', imMask2,...
               'minOverlap', minOverlap, 'maxSearchSize', maxSearchSize, 'logFile', logFile, 'unitFactor', unitFactor, ...
               'visualize', visualize);

            if (isinf(maxNCV))
                [deltaX,deltaY,deltaZ,maxNCV,overlapSize] = Register.TwoImages(curFrame, nextFrame,...
               'metadata1', curMeta, 'metadata2', nextMeta,...
               'imMask1', imMask1, 'imMask2', imMask2,...
               'minOverlap', minOverlap, 'maxSearchSize', maxSearchSize, 'logFile', logFile, 'unitFactor', unitFactor, ...
               'visualize', true);
                title(num2str(t));
            end

            frameDeltas_xyz(t+1,:) = [deltaX,deltaY,deltaZ,maxNCV,overlapSize];
        end

        frameDeltas_rc = Utils.SwapXY_RC(frameDeltas_xyz);
        if (toFirstFrame)
            cumulativeDeltas_rc = frameDeltas_rc(:,1:3);
        else
            cumulativeDeltas_rc = cumsum(frameDeltas_rc(:,1:3),1);
        end       
        
    end

%% apply deltas
    maxDelta_rc = max(cumulativeDeltas_rc,[],1);
    minDelta_rc = min(cumulativeDeltas_rc,[],1);
    
    movementExtent_rc = maxDelta_rc + abs(minDelta_rc);
    
    newSize = Utils.SwapXY_RC(metadata.Dimensions) + movementExtent_rc;
    imOut = zeros([newSize,metadata.NumberOfChannels,metadata.NumberOfFrames],'like',imIn);
    
    for t=1:metadata.NumberOfFrames
        newPosStart = cumulativeDeltas_rc(t,:) - minDelta_rc +1;
        newPosEnd = newPosStart + metadata.Dimensions([2,1,3]) -1;
        imOut(newPosStart(1):newPosEnd(1),newPosStart(2):newPosEnd(2),newPosStart(3):newPosEnd(3),:,t) = imIn(:,:,:,:,t);
    end
    
    if (exist('oldWorkers','var') && oldWorkers~=0 && numWorkers~=oldWorkers)
        p = gcp('nocreate');
        delete(p);
        parpool(oldWorkers);
    end
    
    imageDataOut = metadata;
    imageDataOut.DatasetName = [imageDataOut.DatasetName,'_registered'];
    sz = size(imOut);
    imageDataOut.Dimensions = sz([2,1,3]);
    sec = toc(is);
    fprintf('Image Stabilization Took: %s, avg: %s\n',Utils.PrintTime(sec),Utils.PrintTime(sec/size(imIn,5)));
end

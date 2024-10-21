function [ultimateDeltaX, ultimateDeltaY, ultimateDeltaZ, maxNCV, overlapSize, ncvMatrixROI] = TwoImages(im1, im2, varargin)
%Register.TwoImages - Takes two images and their metadata and returns the
%       offset of image2 compared to image1. If metadata of stage position
%       is present, the offset will be relative to this starting point.
%
% INPUT
%   im1 - image array of the static (non-moving) image.
%
%   im2 - image array of the moving image.
%   
%   args.metadata1 - structure containing the metadata of im1. This should be in
%       the form that MicroscopeData.GetEmptyMetadata() returns.
%
%   args.metadata2 - structure containing the metadata of im2. This should be in
%       the form that MicroscopeData.GetEmptyMetadata() returns.
%
%   args.minOverlap - this is the minimum that the images must overlap. Used to
%       remove optimum of small overlaps and restricts solution to have an
%       overlap.
%
%   args.maxSearchSize - this is the maximum that image2 can move realitive to
%       image1.
%
%   args.logFile - path to a file to dump logging information. Passing a 1 (default) will
%       print log to screen.
%
%   args.visualize - display visualization of decision surfaces if true. False
%       (default).
%
%   args.imMask1 - a binary mask of regions of interest in im1 to use in correlationg
%       images. This way noise does not dominate by correlating with other noise.
%
%   args.imMask2 - a binary mask of regions of interest in im2 to use in correlationg
%       images. This way noise does not dominate by correlating with other noise.
%
%   args.unitFactor - this is a multiplier to change the stage position into the
%       same unit as the voxel physical size.

%% check inputs
    validScalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    
    p = inputParser();
    addParameter(p, 'metadata1', [], @isstruct);
    addParameter(p, 'metadata2', [], @isstruct);
    addParameter(p, 'minOverlap', 25, validScalar);
    addParameter(p, 'maxSearchSize', 100, validScalar);
    addParameter(p, 'logFile', 1);
    addParameter(p, 'visualize', false, @islogical);
    addParameter(p, 'imMask1', []);
    addParameter(p, 'imMask2', []);
    addParameter(p, 'unitFactor', 1, validScalar);
    
    parse(p, varargin{:});
    args = p.Results;
    
    if isempty(args.metadata1)
        args.metadata1 = MicroscopeData.GetEmptyMetadata();
        sz = [size(im1,1),size(im1,2),size(im1,3),size(im1,4),size(im1,5)];
        args.metadata1.Dimensions = sz([2,1,3]);
        args.metadata1.NumberOfChannels = sz(4);
        args.metadata1.NumberOfFrames = sz(5);
        args.metadata1.DatasetName = 'input 1';
        args.metadata1.PixelPhysicalSize = ones(1,3);
    end
    
    if isempty(args.metadata2)
        args.metadata2 = MicroscopeData.GetEmptyMetadata();
        sz = [size(im2,1),size(im2,2),size(im2,3),size(im2,4),size(im2,5)];
        args.metadata2.Dimensions = sz([2,1,3]);
        args.metadata2.NumberOfChannels = sz(4);
        args.metadata2.NumberOfFrames = sz(5);
        args.metadata2.DatasetName = 'input 2';
        args.metadata2.PixelPhysicalSize = ones(1,3);
    end
    
    if isfield(args, 'logFile')
        if (args.logFile~=1)
            fHand = fopen(args.logFile,'at');
        else
            fHand = 1;
        end
        fprintf(fHand,'%s \n\t--> %s\n',args.metadata1.DatasetName,args.metadata2.DatasetName);
        if (fHand~=1)
            fclose(fHand);
        end
    end
    
%% check to see if the image has data and is big enough
    [imageROI1Org_XY,imageROI2Org_XY,~,~] = Register.CalculateOverlapXY(args.metadata1,args.metadata2,args.unitFactor);
    [imageROI1_XY,imageROI2_XY,padding_XY] = Register.AddPaddingToOverlapXY(args.metadata1,imageROI1Org_XY,args.metadata2,imageROI2Org_XY,args.maxSearchSize);
    
    maxNCV = -inf;
    bestChan = 0;
    ultimateDeltaX = 0;
    ultimateDeltaY = 0;
    ultimateDeltaZ = 0;
    ncvMatrixROI = [];
    
    overlapSize = max(min(imageROI1Org_XY(4)-imageROI1Org_XY(1),imageROI2Org_XY(4)-imageROI2Org_XY(1)),1) *...
        max(min(imageROI1Org_XY(5)-imageROI1Org_XY(2),imageROI2Org_XY(5)-imageROI2Org_XY(2)),1);
    
    im1ROI = im1(imageROI1_XY(2):imageROI1_XY(5),imageROI1_XY(1):imageROI1_XY(4),imageROI1_XY(3):imageROI1_XY(6),:,:);
    im2ROI = im2(imageROI2_XY(2):imageROI2_XY(5),imageROI2_XY(1):imageROI2_XY(4),imageROI2_XY(3):imageROI2_XY(6),:,:);
    
    if args.visualize
        figure
        nexttile
        imshow(ImUtils.MakeOrthoSliceProjections(im1, Utils.GetColorByWavelength(1:size(im1, 4)), args.metadata1.PixelPhysicalSize, 50));
        title('Image 1 Full');
        nexttile
        imshow(ImUtils.MakeOrthoSliceProjections(im1ROI, Utils.GetColorByWavelength(1:size(im1ROI, 4)), args.metadata1.PixelPhysicalSize, 50));
        title('Image 1 ROI');
        nexttile
        imshow(ImUtils.MakeOrthoSliceProjections(im2, Utils.GetColorByWavelength(1:size(im2, 4)), args.metadata2.PixelPhysicalSize, 50));
        title('Image 2 Full');
        nexttile
        imshow(ImUtils.MakeOrthoSliceProjections(im2ROI, Utils.GetColorByWavelength(1:size(im2ROI, 4)), args.metadata2.PixelPhysicalSize, 50));
        title('Image 2 ROI');
    end

    if (~isempty(args.imMask1))
        args.imMask1ROI = args.imMask1(imageROI1_XY(2):imageROI1_XY(5),imageROI1_XY(1):imageROI1_XY(4),imageROI1_XY(3):imageROI1_XY(6),:,:);
    else
        args.imMask1ROI = [];
    end
    if (~isempty(args.imMask2))
        args.imMask2ROI = args.imMask2(imageROI2_XY(2):imageROI2_XY(5),imageROI2_XY(1):imageROI2_XY(4),imageROI2_XY(3):imageROI2_XY(6),:,:);
    else
        args.imMask2ROI = [];
    end
    
    [~,~,maxVal] = Utils.GetClassBits(im1ROI);
    % if (max(im1ROI(:))<=0.28*maxVal || max(im2ROI(:))<=0.28*maxVal)
    %     % no real info in the image
    %     return
    % end
    if (overlapSize < args.minOverlap^2)
        % does not have enough overall overlap
        warning('Not enough overlap found');
        return
    end

    numberOfChannels = max(size(im1, 4), size(im2, 4));
    
%% run 2-D case
    newOrgin_RC = Utils.SwapXY_RC(padding_XY);
    totalTm = tic;
    
    im1MaxROI = squeeze(max(im1ROI,[],3));
    im2MaxROI = squeeze(max(im2ROI,[],3));
    for c=1:numberOfChannels   
        [deltas_RC,curNCV,ncvMatrixROI] = Register.GetMaxNCVdeltas(im1MaxROI(:,:,c),im2MaxROI(:,:,c),args.minOverlap^2,args.maxSearchSize,newOrgin_RC([1,2]),args.visualize,c,[],args.imMask1ROI, args.imMask2ROI);
        deltas_XY = Utils.SwapXY_RC(deltas_RC);
        if (curNCV>maxNCV)
            bestChan = c;
            maxNCV = curNCV;
            bestDeltas_XY = deltas_XY;
        end
    end
    
    tm = toc(totalTm);
    if isfield(args, 'logFile')
        if (args.logFile~=1)
            fHand = fopen(args.logFile,'at');
        else
            fHand = 1;
        end
        fprintf(fHand,'\t%s, NVC:%04.3f at (%d,%d) on channel:%d\n',...
            Utils.PrintTime(tm),maxNCV,bestDeltas_XY(1),bestDeltas_XY(2),bestChan);
        if (fHand~=1)
            fclose(fHand);
        end
    end
    
    bestDeltas_XY = [bestDeltas_XY([1,2]),0];
    deltasZ_XY = bestDeltas_XY;
    maxNcovZ = maxNCV;
    
%% run 3-D case
    if (size(im1,3)>1)
        totalTm = tic;
            
        [deltasZ_RC,maxNcovZ,ncvMatrixROI] = Register.GetMaxNCVdeltas(im1ROI(:,:,:,bestChan),im2ROI(:,:,:,bestChan),args.minOverlap^3,args.maxSearchSize,newOrgin_RC,args.visualize,bestChan);
        deltasZ_XY = Utils.SwapXY_RC(deltasZ_RC);
        
        tm = toc(totalTm);
       
        changeDelta_XY = bestDeltas_XY - deltasZ_XY;
        
        if isfield(args, 'logFile')
            if (args.logFile~=1)
                fHand = fopen(args.logFile,'at');
            else
                fHand = 1;
            end
            
            fprintf(fHand,'\t%s, NVC:%04.3f at (%d,%d,%d)\n',...
                Utils.PrintTime(tm),maxNcovZ,deltasZ_XY(1),deltasZ_XY(2),deltasZ_XY(3));
            
            if (changeDelta_XY(1)~=0 || changeDelta_XY(2)~=0)
                fprintf(fHand,'\tA different XY delta was found when looking in Z. Change in deltas from 2D to 3D: (%d,%d,%d). Old NCV:%f, new:%f\n', changeDelta_XY(1),changeDelta_XY(2),changeDelta_XY(3),maxNCV,maxNcovZ);
            end
            if (fHand~=1)
                fclose(fHand);
            end
        end
    end
    
%% fixup results
    % if (maxNcovZ-maxNCV < -0.1)
    %     warning('ROI normalized covariance is worse in 3D (%f) than in 2D (%f)',maxNcovZ,maxNCV);
    % %     maxNcovZ = max(maxNcovZ,maxNCV);
    % end
    
    [xStart1,~,xEnd1] = Register.CalculateROIs(deltasZ_XY(1),imageROI1Org_XY(1),imageROI2Org_XY(1),size(im1,2),size(im2,2));
    [yStart1,~,yEnd1] = Register.CalculateROIs(deltasZ_XY(2),imageROI1Org_XY(2),imageROI2Org_XY(2),size(im1,1),size(im2,1));
    [zStart1,~,zEnd1] = Register.CalculateROIs(deltasZ_XY(3),1,1,size(im1,3),size(im2,3));
    
    overlapSize = max(xEnd1-xStart1,1) * max(yEnd1-yStart1,1) * max(zEnd1-zStart1,1);
    
    % if (maxNcovZ>0.0 && overlapSize >= args.minOverlap^3)
        ultimateDeltaX = deltasZ_XY(1);
        ultimateDeltaY = deltasZ_XY(2);
        ultimateDeltaZ = deltasZ_XY(3);
        
        maxNCV = maxNcovZ;
    % else
    %     maxNCV = -inf;
    %     ultimateDeltaX = 0;
    %     ultimateDeltaY = 0;
    %     ultimateDeltaZ = 0;
    % end
    
end

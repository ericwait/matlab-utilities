function [ imC, imNeg, imPos ] = LoGtoColor( imLoG, localEpsilon)
%LOGTOCOLOR Summary of this function goes here
%   Detailed explanation goes here

    if (~exist('localEpsilon','var') || isempty(localEpsilon))
        localEpsilon = 1e-5;
    end

    imC = zeros([ImUtils.Size(imLoG),3],'uint8');
    for t=1:size(imLoG,5)
        for c=1:size(imLoG,4)
            curIm = imLoG(:,:,:,c,t);
            maskNeg = curIm<0;
            maskPos = curIm>0;

            imNeg = curIm;
            imNeg(~maskNeg) = 0;
            imNeg = ImUtils.BrightenImages(-imNeg,'uint8');

            %     imZero = imLoG;
            %     imZero(~maskZero) = 0;
            % imZero = abs(imZero);
            % imZero = ImUtils.ConvertType(imZero,'uint8',true);

            imPos = curIm;
            imPos(~maskPos) = 0;
            imPos = ImUtils.BrightenImages(imPos,'uint8');

            %negative in magenta
            imC(:,:,:,c,t,1) = imNeg;
            imC(:,:,:,c,t,3) = imNeg;

            %positive in green
            imC(:,:,:,c,t,2) = imPos;
        end
    end
end

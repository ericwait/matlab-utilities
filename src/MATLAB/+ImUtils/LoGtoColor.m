function [ imC, imMin, imMax ] = LoGtoColor(imLoG)
%LOGTOCOLOR Summary of this function goes here
%   Detailed explanation goes here
    
    imMax = imLoG;
    imMax(imMax<0) = 0;
    
    imMin = imLoG;
    imMin(imMin>0) = 0;
    imMin = -imMin;

    imC = zeros([ImUtils.Size(imLoG),3],'uint8');
    for t=1:size(imLoG,5)
        for c=1:size(imLoG,4)
            curMax = imMax(:,:,:,c,t);
            curMin = imMin(:,:,:,c,t);
            
            curMax = ImUtils.BrightenImagesGamma(curMax, 'uint8', 1.0);
            curMin = ImUtils.BrightenImagesGamma(curMin, 'uint8', 1.0);

            %negative in magenta
            imC(:,:,:,c,t,1) = curMin;
            imC(:,:,:,c,t,3) = curMin;

            %positive in green
            imC(:,:,:,c,t,2) = curMax;
        end
    end
end

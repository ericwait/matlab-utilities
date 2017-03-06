function [ isEmpty] = checkMask(mask,ROI)
isEmpty = 0;

if isempty(mask)
   return 
end    
    
bROI = mask(ROI(1,2):ROI(2,2),ROI(1,1):ROI(2,1));
isEmpty = ~any(bROI(:));
end 
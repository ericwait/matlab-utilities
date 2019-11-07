function [pixelType] = GetPixelTypeKLB(klbfileFile)
    pixelType = [];
        
    tempIm = MicroscopeData.KLB.readKLBstack(klbfileFile);
    sz = size(tempIm);
    tempD.Dimensions = sz([2,1,3]);
    w = whos('tempIm');
    pixelType = w.class;
end

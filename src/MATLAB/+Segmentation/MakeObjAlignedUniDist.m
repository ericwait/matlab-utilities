function [ randPix ] = MakeObjAlignedUniDist(V, NUM_PIXELS, MAX_EXTENTS, MIN_EXTENTS)
    randPix = rand(NUM_PIXELS,size(V,1)) .* repmat(MAX_EXTENTS-MIN_EXTENTS,NUM_PIXELS,1) + repmat(MIN_EXTENTS,NUM_PIXELS,1);
    randPix = randPix * V.';
end


function roi_im = MakeBinaryROI(pixel_list_xyz, padding)

    if ~exist('padding','var') || isempty(padding)
        padding = 5;
    end

    start_coords_rcz = Utils.SwapXY_RC(min(round(pixel_list_xyz), [], 1));
    end_coords_rcz = Utils.SwapXY_RC(max(round(pixel_list_xyz), [], 1));

    start_padded = start_coords_rcz - padding;
    end_padded = end_coords_rcz + padding;

    roi_im = false(ceil(end_padded - start_padded+1));

    padded_pixel_list_rcz = Utils.SwapXY_RC(pixel_list_xyz) - start_padded +1;
    indList = Utils.CoordToInd(size(roi_im), padded_pixel_list_rcz);
    roi_im(indList) = true;
end

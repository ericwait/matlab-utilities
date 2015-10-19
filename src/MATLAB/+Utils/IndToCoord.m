function coords_RC = IndToCoord(siz,IND)
    pixCoordCell = cell(1,length(siz));
    [pixCoordCell{:}] = ind2sub(siz,IND);
    coords_RC = cell2mat(pixCoordCell);
end
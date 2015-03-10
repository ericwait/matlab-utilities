function coords = ind2subAllDims(siz,IND)
    pixCoordCell = cell(1,length(siz));
    [pixCoordCell{:}] = ind2sub(siz,IND);
    coords = cell2mat(pixCoordCell);
end
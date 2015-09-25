function X = CalcImCoords(imSize, linIdx)
coordCell = cell(1,length(imSize));
[coordCell{:}] = ind2sub(imSize, linIdx);

X = cell2mat(coordCell);
end
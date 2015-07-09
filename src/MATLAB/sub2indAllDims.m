function inds = sub2indAllDims(siz,coords)
pro = zeros(size(siz));
pro(1) = 1;

for i = 2:numel(siz)
    pro(i) = prod(siz(1:i-1));
end

inds = (coords-1)*pro'+1;
end
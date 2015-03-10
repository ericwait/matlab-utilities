function inds = sub2indAllDims(siz,coords)
switch length(siz)
    case 1
        inds = sub2ind(siz,coords(:,1));
    case 2
        inds = sub2ind(siz,coords(:,1),coords(:,2));
    case 3
        inds = sub2ind(siz,coords(:,1),coords(:,2),coords(:,3));
    case 4
        inds = sub2ind(siz,coords(:,1),coords(:,2),coords(:,3),coords(:,4));
    case 5
        inds = sub2ind(siz,coords(:,1),coords(:,2),coords(:,3),coords(:,4),coords(:,5));
    otherwise
        error('This needs to be implemented more generally for n dimensions!');
end
end
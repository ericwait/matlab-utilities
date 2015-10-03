function swapCoords = SwapXY_RC(coords)
    swapCoords = coords;
    
    if ( isvector(coords) )
        swapCoords([1 2]) = swapCoords([2 1]);
    elseif ( ismatrix(coords) )
        swapCoords(:,[1 2]) = swapCoords(:,[2 1]);
    end
end

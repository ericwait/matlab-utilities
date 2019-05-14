function colorValues = GetColorByWavelength(wavelengths)
    magenta = [1,0,1];
    green = [0,1,0];
    cyan = [0,0.75,1];
    blue = [0.25,0.25,1.0];
    orange = [1.0,0.5,0];
    yellow = [1.0,1.0,0];
    red = [1,0,0];
    white = [1,1,1];
    violet = [0.5,0,1.0];


    [~,I] = sort(wavelengths);
    colorValues = zeros(numel(wavelengths),3);
    switch numel(wavelengths)
        case 1
            colorValues(1,:) = white;
        case 2
            colorValues(I(1),:) = magenta;
            colorValues(I(2),:) = green;
        case 3
            colorValues(I(1),:) = magenta;
            colorValues(I(2),:) = green;
            colorValues(I(3),:) = cyan;
        case 4
            colorValues(I(1),:) = red;
            colorValues(I(2),:) = yellow;
            colorValues(I(3),:) = green;
            colorValues(I(4),:) = cyan;
        case 5
            colorValues(I(1),:) = red;
            colorValues(I(2),:) = orange;
            colorValues(I(3),:) = yellow;
            colorValues(I(4),:) = green;
            colorValues(I(5),:) = cyan;
        case 6
            colorValues(I(1),:) = red;
            colorValues(I(2),:) = orange;
            colorValues(I(3),:) = yellow;
            colorValues(I(4),:) = green;
            colorValues(I(5),:) = cyan;
            colorValues(I(6),:) = blue;
        case 7
            colorValues(I(1),:) = red;
            colorValues(I(2),:) = orange;
            colorValues(I(3),:) = yellow;
            colorValues(I(4),:) = green;
            colorValues(I(5),:) = cyan;
            colorValues(I(6),:) = blue;
            colorValues(I(7),:) = violet;
        otherwise
            error('Cannot handle more than seven colors!');
    end
end

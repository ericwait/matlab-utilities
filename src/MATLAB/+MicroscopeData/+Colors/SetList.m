function stains = SetList()
stains = struct('name','','color',[],'strColor','');

%% blue
stains(1).name = 'DAPI';
stains(end).color = [0.00, 0.00, 0.50];
stains(end).strColor = 'b';

%% red
lclColor = [1.00 0.00 0.00];
lclStr = 'r';
stains = setNextColor(stains, 'Laminin', lclColor, lclStr);
stains = setNextColor(stains, 'laminin', lclColor, lclStr);
stains = setNextColor(stains, 'Tomato', lclColor, lclStr);
stains = setNextColor(stains, 'Bcat', lclColor, lclStr);
stains = setNextColor(stains, 'lectin', lclColor, lclStr);
stains = setNextColor(stains, 'Lectin', lclColor, lclStr);
stains = setNextColor(stains, 'EdU', lclColor, lclStr);
stains = setNextColor(stains, 'EDU', lclColor, lclStr);

%% green
lclColor = [0.00 1.00 0.00];
lclStr = 'g';
stains = setNextColor(stains, 'GFAP', lclColor, lclStr);
stains = setNextColor(stains, 'NCAM', lclColor, lclStr);
stains = setNextColor(stains, 'VCAM', lclColor, lclStr);

%% cyan
lclColor = [0.00 1.00 1.00];
lclStr = 'c';
stains = setNextColor(stains, 'DCX', lclColor, lclStr);
stains = setNextColor(stains, 'Dcx', lclColor, lclStr);
%stains = setNextColor(stains, 'Itga', lclColor, lclStr);
%stains = setNextColor(stains, 'Cy5', lclColor, lclStr);
%stains = setNextColor(stains, 'NCAM', lclColor, lclStr);

%% yellow
lclColor = [1.00 1.00 0.00];
lclStr = 'y';
stains = setNextColor(stains, 'Olig2', lclColor, lclStr);
stains = setNextColor(stains, 'Olg2', lclColor, lclStr);
stains = setNextColor(stains, 'EGFR', lclColor, lclStr);
stains = setNextColor(stains, 'ki67', lclColor, lclStr);
% stains = setNextColor(stains, 'AcTub', lclColor, lclStr);
% stains = setNextColor(stains, 'Bcatenin', lclColor, lclStr);

%% magenta
lclColor = [1.00 0.00 1.00];
lclStr = 'm';
stains = setNextColor(stains, 'AcTub', lclColor, lclStr);
stains = setNextColor(stains, 'Mash', lclColor, lclStr);
stains = setNextColor(stains, 'Msh', lclColor, lclStr);
% stains = setNextColor(stains, 'VCAM', lclColor, lclStr);
% stains = setNextColor(stains, 'Mash', lclColor, lclStr);

%% white
lclColor = [1.00 1.00 1.00];
lclStr = 'w';
stains = setNextColor(stains, 'Phase', lclColor, lclStr);
end

function stains = setNextColor(stains, stainName, val, strC)
stains(end+1).name = stainName;
stains(end).color = val;
stains(end).strColor = strC;
end

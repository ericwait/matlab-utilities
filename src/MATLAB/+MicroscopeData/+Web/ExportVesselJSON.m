%% ExportVesselJSON exports vessel structures' voxel coordinates to JSON for CloneView3D
function g = ExportVesselJSON(imD, outPath,imSkele)
%% decimate skeleton and get verts and indices for WebGL rendering
if exist('imSkele','var') && ~isempty(imSkele)
[g, skeleVerts, skeleIndices] = getVertsAndIndices(imSkele, imD);
else 
g = []; skeleVerts = []; skeleIndices = [];
end 
%% export to json file
skeleFile = fullfile(outPath, [imD.DatasetName, '_vessel.json']);

fout = fopen(skeleFile,'w');

fprintf(fout, '{\n\t');

writeToJSON('skeleton', skeleVerts, skeleIndices, fout);

fprintf(fout, '\n}');
fclose(fout);

fprintf('skeleton json saved to %s\n', skeleFile);
end

function writeToJSON(fieldName, verts, indices, fout)
fieldString = ['"', fieldName,'" : \n\t\t{\n\t\t\t'];
fprintf(fout, fieldString);
fprintf(fout, '"verts" : [\n\t\t\t');

for i = 1:size(verts, 1)
    fprintf(fout,'[%g,%g,%g]',verts(i,1),verts(i,2),verts(i,3));
    if i < size(verts, 1)
        fprintf(fout,',');
    end
end
fprintf(fout,']\n\t\t');

%% export indices
if(~isempty(indices))
    numIdices = numel(indices);
    fprintf(fout, ',\n');
    fprintf(fout, '"indices" : [\n\t\t\t');
    for i = 1:numIdices
        fprintf(fout,'%d',indices(i));
        if i < numIdices
            fprintf(fout,',');
        end
    end
    fprintf(fout,']\n\t\t');
end

fprintf(fout,'}\n\n');
end

%%
function verts = getCoords(im, imD)

[y,x,z,~] = Vessel.find3(im);

% convert verts coord from image space (0 ~ imData.Dimensions) to model space(-0.5 ~ 0.5)
z = z / imD.ZDimension  - 0.5;
x = x / imD.XDimension;
y = y / imD.YDimension;
verts = [x,y,z];

end
%%
function [g,verts,indices] = getVertsAndIndices(im, imD)
% g = binaryImageGraph3(im,26);
g = decimateGraph(im);
indices = reshape([g.Edges.EndNodes]', 1,[]) - 1;

verts = [g.Nodes.x / imD.XDimension, g.Nodes.y / imD.YDimension, g.Nodes.z / imD.ZDimension - 0.5];

end
%%
function g = decimateGraph(im)
g = binaryImageGraph3(im,26);


isDone = false;
iter = 1;
T = 0.2;
if(size(g.Nodes, 1) > 200000)
    T = 0.5;
end

while(~isDone)
    tic;
    
    fprintf(['\nIteration ',' %d,   '], iter);
    if(size(g.Nodes, 1) < 2^16)
        isDone = true;
    end
    
    fprintf('Number of nodes: %d,   ', size(g.Nodes, 1));
    %% vectorized operations
    D = degree(g);
    edgePixIdx = D==2;
    
    
    r = find(edgePixIdx);
    cellNb = arrayfun(@(x) neighbors(g, x), r,'UniformOutput',false);
    vecNb = cell2mat(cellNb')';
    vecNb = [r,vecNb];

 %% iterates through vertices and get removable candidates
    vecRmNb =  vecNb(1,:);
    for i = 2:length(vecNb)
        curRow = vecNb(i,:);
        if(sum(vecRmNb == curRow(:,1)) == 0)
           vecRmNb = [vecRmNb;curRow];
        end
    end

    % e1 and e2 are two edges of current node
    e1 = findedge(g, vecRmNb(:,1), vecRmNb(:,2));
    e2 = findedge(g, vecRmNb(:,1), vecRmNb(:,3));
    

    % l1 and l2 are length of two edges of current node
    l1 = g.Edges(e1,:).Weight;
    l2 = g.Edges(e2,:).Weight;
    
    % n1 and n2 are the two neighbor nodes (with X, Y, Z in each column)
    n1 = table2array(g.Nodes(vecRmNb(:,2),1:3));
    n2 = table2array(g.Nodes(vecRmNb(:,3),1:3));
    
    % distance between n1 and n2
    l3 = sqrt(sum( (n2 - n1).^2, 2) );
    
    difference = abs(l1 + l2 - l3);
    rmVecNbIdx = difference <= T;
    
    rmNodeIdx = vecRmNb(rmVecNbIdx, 1);
    newNode1Idx = vecRmNb(rmVecNbIdx, 2);
    newNode2Idx = vecRmNb(rmVecNbIdx, 3);
    newEdgeWeight = l3(rmVecNbIdx);
    
    % in case the edges already exist, remove them before add edge
    g = rmedge(g, newNode1Idx, newNode2Idx);
    
    % remove misconnected edges between n1 and n2
%     e3 = findedge(g, vecRmNb(:,2), vecRmNb(:,3));
%     g = rmedge(g, e3(e3>0));
% if(iter==2)
%     disp(iter)
% end

    g = rmedge(g, vecRmNb(:,2), vecRmNb(:,3));
    
    tmp = [newNode1Idx, newNode2Idx, newEdgeWeight];
    tmp = unique(tmp,'rows');
    
    g = addedge(g, tmp(:,1), tmp(:,2), tmp(:,3));
    g = rmnode(g, rmNodeIdx);
    
   
    iter = iter + 1;
    fprintf(['Removed ',' %d', ' vertices,  '], numel(rmNodeIdx));
    
    timeUsed = toc; 
    fprintf('Time elapsed %gs \n', timeUsed);
    if(iter > 4 || numel(rmNodeIdx) < 1000)
        T = T + 0.1;
        fprintf(['Threshold = ',' %g\n'], T);
        iter = 1;
    end
end

end

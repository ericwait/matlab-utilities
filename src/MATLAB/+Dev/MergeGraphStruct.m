function [graphStruct,newNodes] = MergeGraphStruct(graphStruct, newStruct)
    oldIdx = cellfun(@(x)(find(strcmp(x,graphStruct.nodes),1,'first')), newStruct.nodes, 'UniformOutput',0);
    bNew = cellfun(@(x)(isempty(x)), oldIdx);

    newNodes = newStruct.nodes(bNew);
    
    p = length(newNodes);
    [m,n] = size(graphStruct.graph);

    idxMap = zeros(1,length(newStruct.nodes));
    idxMap(~bNew) = [oldIdx{~bNew}];
    idxMap(bNew) = (1:p) + n;

    graphStruct.nodes = [graphStruct.nodes; newNodes];
    graphStruct.graph = [graphStruct.graph zeros(n,p); zeros(p,n+p)];
    
    graphStruct.graph(idxMap,idxMap) = (graphStruct.graph(idxMap,idxMap) | newStruct.graph);
end
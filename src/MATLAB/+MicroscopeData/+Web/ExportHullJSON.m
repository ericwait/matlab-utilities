function imDataOut = ExportHullJSON(imData,pathout)
imDataOut = imData;
pathIn = imData.imageDir;
%pathout  = 'D:\Users\Edgar\Documents\MATLAB\Versions of CloneView\clone-view-3d\src\javascript\experiments\Susan_overnight\Susan_overnight\Hulls';
imDataOut.BooleanHulls = 0;
%% Make Hull Dir
pathout = fullfile(pathout,'Hulls');
if(~exist(pathout, 'dir'));    mkdir(pathout);   end

%% Get Hulls or Vessels
HullPath = dir(fullfile(pathIn,[imData.DatasetName,'_LEVer.mat']));
if isempty(HullPath)
    HullPath = dir(fullfile(pathIn,[imData.DatasetName,'.vessels.mat']));
    if isempty(HullPath)
        disp('No Hulls file'); return
    end
end

% if exist(fullfile(pathout,'Hulls_1.json'),'file')
% imDataOut.BooleanHulls = 1;
% disp('Hulls already done'); return
% end

load(fullfile(HullPath.folder,HullPath.name))

%% Initalize Variables
if exist('CONSTANTS','var')
    Dims = CONSTANTS.imageData.Dimensions;
    PhySize = CONSTANTS.imageData.PixelPhysicalSize;
    Time = CONSTANTS.imageData.NumberOfFrames;
else
    Dims = imData.Dimensions;
    PhySize = imData.PixelPhysicalSize;
    Time = 1;
end

if exist('CellHulls','var')
    
    %% Assign Colors from Cell Tracks
    for i = 1:length(CellTracks)
        hullList = CellTracks(i).hulls;
        for j = 1:length(hullList)
            CellHulls(hullList(j)).colors = CellTracks(i).color.background;
        end
    end
    
    %% Get Hull Info from CellHulls
    CellHulls = MicroscopeData.Web.ReduceHullFaces(CellHulls,Dims);
    bValid = arrayfun(@(x)(~isempty(x.verts)), CellHulls);
    CellHulls = CellHulls(bValid);
    
    outStruct = struct('time',{[]}, 'faces',{[]}, 'verts',{[]}, 'colors',{[]},'channel',{[]});
    HullsOut = repmat(outStruct, length(CellHulls),1);
    
    for h = 1:length(CellHulls)

        HullsOut(h).time = CellHulls(h).time;
        HullsOut(h).edges = faces2edges(CellHulls(h).faces);
        HullsOut(h).verts = normVerts(CellHulls(h).verts,Dims,PhySize);
        HullsOut(h).channel = 1;
        HullsOut(h).faces = CellHulls(h).faces;
        HullsOut(h).normals = reshape(transpose(CellHulls(h).norms),numel(CellHulls(h).norms),1);
        HullsOut(h).channel = 1;
    end
    
    %% Assign info from Vessel Output
elseif exist('v','var')

    HullsOut(1).time = 1;
    HullsOut(1).edges = faces2edges(f);
    HullsOut(1).verts = normVerts(v,Dims,PhySize);
    HullsOut(1).colors = ones(size(HullsOut(1).verts));
    HullsOut(1).channel = 1;

elseif exist('vessels','var')
    vessels2 = vessels(cellfun(@(x) length(x)>4 ,vessels));
    [Edges,Verts] = readVessels(vessels2,Dims,PhySize);

    outStruct = struct('time',{[]}, 'faces',{[]}, 'verts',{[]}, 'colors',{[]},'channel',{[]});
    HullsOut = repmat(outStruct, length(Edges),1);
    for e = 1:length(Edges)

        HullsOut(e).time = 1;
        HullsOut(e).edges = Edges{e};
        HullsOut(e).verts = Verts{e};
        HullsOut(e).colors = zeros(size(HullsOut(e).verts));
        HullsOut(e).colors(1:3:end) = 1;
        HullsOut(e).channel = 1;

    end
else
    disp('No Hulls'); return
end

%% Write Out Json
disp(['Writing Hulls for ',imData.DatasetName]);

HullTime = [HullsOut(:).time];
for T = 1:max(HullTime(:))
    jsonMetadata = Utils.CreateJSON(HullsOut(HullTime==T),false);
    fileHandle = fopen(fullfile(pathout,['Hulls_',num2str(T),'.json']),'wt');
    fwrite(fileHandle, jsonMetadata, 'char');
    fclose(fileHandle);
end

imDataOut.BooleanHulls = 1;
end

%% Conversion Functions

%% Convert Faces to Edges
function edges = faces2edges(faces)
edgeList = vertcat(faces(:,[1,2]),faces(:,[2,3]),faces(:,[3,1]));
edgeList = unique(sort(edgeList,2),'rows');
edges = edgeList-1;
edges  = reshape(transpose(edges),numel(edges),1);
end

function nVerts = normVerts(verts,Dims,PhySize)
%% Normalize to Unit Coordinates -0.5 0.5
physSize = Dims .* PhySize;
sizeScale = physSize / max(physSize);
%% Resize Verts
verts = (verts-1) ./ repmat(Dims,[size(verts,1) 1]);
verts = (verts - 0.5) .* repmat(sizeScale,[size(verts,1) 1]);
nVerts = reshape(transpose(verts),numel(verts),1);
end

function[Edges,VertsOut] = readVessels(vessels,Dims,PhySize)
%%Merge Vert Lists
%Verts = cellfun(@(x) [x(1,:)',x(end,:)'],vessels,'UniformOutput',0);
Verts = vertcat(vessels{:});
%% Normalize to Unit Coordinates -0.5 0.5
physSize = Dims .* PhySize;
sizeScale = physSize / max(physSize);
%% Resize Verts
Verts = (Verts-1) ./ repmat(Dims,[size(Verts,1) 1]);
Verts = (Verts - 0.5) .* repmat(sizeScale,[size(Verts,1) 1]);
Verts = reshape(transpose(Verts),numel(Verts),1);
%% Make Edges
Edges = {[]};
lastEdge = 0;
j = 1;
for i = 1:length(vessels)
    if lastEdge + length(vessels{i}) > 2^16
        j = j+1; lastEdge = 0;
        Edges{j} = [];
    end
    edgepts = [1:(length(vessels{i})-1);2:length(vessels{i})]+lastEdge-1;
    edgepts = reshape(edgepts,numel(edgepts),1);
    Edges{j} = [Edges{j}; edgepts];
    lastEdge = lastEdge + length(vessels{i});
end
VertsOut = cell(1,length(Edges));
VertL = 0;
for e = 1:length(Edges)
    MaxL = (max(Edges{e})+1)*3;
    VertH = VertL+MaxL;
    VertL = VertL+1;
    VertsOut{e} = Verts(VertL:VertH);
    VertL = VertH;
end
end


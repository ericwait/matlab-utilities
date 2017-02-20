function imDataOut = ExportHullJSON(imData, pathIn,pathout)
imDataOut = imData;
%pathout  = 'D:\Users\Edgar\Documents\MATLAB\Versions of CloneView\clone-view-3d\src\javascript\experiments\Susan_overnight\Susan_overnight\Hulls';

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
load(fullfile(HullPath.folder,HullPath.name))

%% Initalize Variables
if exist('CONSTANTS','var')
    Dims = CONSTANTS.imageData.Dimensions;
    PhySize = CONSTANTS.imageData.PixelPhysicalSize;
    Time = CONSTANTS.imageData.NumberOfFrames;
else
    Dims = [1 1 1];
    PhySize = [1 1 1];
    Time = 1;
end

if exist('CellHulls','var')
    %% Get Hull Info from CellHulls
    outStruct = struct('time',{[]}, 'faces',{[]}, 'verts',{[]}, 'colors',{[]});
    HullsOut = repmat(outStruct, length(CellHulls),1);
    for h = 1:length(CellHulls)
        HullsOut(h).time = CellHulls(h).time;
        HullsOut(h).edges = faces2edges(CellHulls(h).faces);
        HullsOut(h).verts = normVerts(CellHulls(h).verts,Dims,PhySize);
    end
    
    %% Assign Colors from Cell Tracks
    for i = 1:length(CellTracks)
        hullList = CellTracks(i).hulls;
        for j = 1:length(hullList)
            vertLength = size(CellHulls(hullList(j)).verts,1);
            color = transpose(CellTracks(i).color.background);
            HullsOut(hullList(j)).colors = repmat(color,[vertLength,1]);
        end
    end
    
    %% Assign info from Vessel Output
elseif exist('v','var')
    HullsOut(1).time = 1;
    HullsOut(1).edges = faces2edges(f);
    HullsOut(1).verts = normVerts(v,Dims,PhySize);
    HullsOut(1).colors = ones(size(normVerts(v,Dims,PhySize)));
else
    disp('No Hulls'); return
end

%% Write Out Json
disp(['Writing Hulls for ',imData.DatasetName]);

HullTime = [HullsOut(:).time];
for T = 1:Time
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
%% Convert Verts
verts = verts - 1;
verts = verts ./ repmat(Dims,[size(verts,1) 1]);
verts = (verts - 0.5) .* repmat(sizeScale,[size(verts,1) 1]);
nVerts = reshape(transpose(verts),numel(verts),1);
end

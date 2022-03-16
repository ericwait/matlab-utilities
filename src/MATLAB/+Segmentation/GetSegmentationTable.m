function seg_table = GetSegmentationTable(im_bw, varargin)

    valid_vec = @(x) isnumeric(x) && isvector(x) && all(x>0) && numel(x)==3;
    valid_scaler = @(x) isnumeric(x) && isscalar(x) && (x>=0);
    p = inputParser;
    addOptional(p, 'voxel_size', [1,1,1], valid_vec);
    addOptional(p, 'min_vol', 0, valid_scaler);
    addOptional(p, 'im', []);
    
    parse(p, varargin{:});
    args = p.Results;

    if isempty(args.im)
        im = zeros(size(im_bw), 'uint8');
    else
        im = args.im;
    end
    
    table_vars =  {'Frame',  'Channel', 'Volume', 'Centroid', 'WeightedCentroid', 'MinIntensity', 'MeanIntensity', 'MaxIntensity', 'VoxelIdxList', 'VoxelList', 'Centroid_um', 'WeightedCentroid_um'};
    table_types = {'double', 'double',  'double', 'double',   'double',           'double',       'double',        'double',       'cell',         'cell',      'double',      'double'};
    seg_table = table('Size', [0, length(table_vars)], 'VariableTypes', table_types);
    seg_table.Properties.VariableNames = table_vars;
    
    for t = 1:size(im_bw,5)
        for chan = 1:size(im_bw, 4)
            cur_bw = im_bw(:,:,:,chan,t);
            cur_im = im(:,:,:,chan,t);
            rp = regionprops3(cur_bw, cur_im, 'Volume', 'Centroid', 'WeightedCentroid', 'MinIntensity', 'MeanIntensity', 'MaxIntensity', 'VoxelIdxList', 'VoxelList');
            rp = rp(rp.Volume > args.min_vol, :);
    
            rp.Frame = repmat(t, size(rp,1), 1);
            rp.Channel = repmat(chan, size(rp,1), 1);
            rp.Centroid_um = [rp.Centroid] .* args.voxel_size;
            rp.WeightedCentroid_um = [rp.WeightedCentroid] .* args.voxel_size;
    
            seg_table = [seg_table; rp];
        end
    end
end

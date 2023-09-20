% ORDERBYREFERENCE - Reorder second vector to match the first vector.
%
%   idx = ORDERBYREFERENCE(ref_vec, target_vec) takes two vectors, ref_vec and 
%   target_vec, and reorders target_vec to match the order in ref_vec. The function
%   returns a vector of indices idx such that target_vec(idx) will match the order
%   of ref_vec.
%
% Parameters:
%   ref_vec     - Reference vector (numeric array).
%   target_vec  - Target vector to be reordered (numeric array).
%
% Returns:
%   idx         - Vector of indices that reorder target_vec to match ref_vec.
%
% Example:
%   idx = ORDERBYREFERENCE([3, 1, 2], [1, 2, 3]);
%   % idx will be [3, 1, 2]

function idx = OrderByReference(ref_vec, target_vec)
    [~, ref_sort_idx] = sort(ref_vec);
    [~, target_sort_idx] = sort(target_vec);
    
    idx(ref_sort_idx) = target_sort_idx;
    
    if isempty(idx)
        error('Failed to properly reorder target_vec based on ref_vec.');
    end
end

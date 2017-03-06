% calculate the reduced image dimensions for a given reduction and stepSize
function [reduction] = reduce(reduction,stepSize,dims)

%% Make Default if doesnt exist
if (~exist('stepSize','var') || isempty(stepSize))
    stepSize = 1;
end
%% Make Vector if is Scalar
if length(stepSize)==1
    stepSize = repmat(stepSize,[1,3]);
end
%% Make Default if doesnt exist
if (~exist('dims','var') || isempty(dims))
    dims = 1;
end
%% Make Vector if is Scalar
if length(stepSize)==1
    stepSize = repmat(stepSize,[1,3]);
end

%% Calc anisometric reduction
stepSize = round(stepSize .* (dims)/max(dims));

reduction = reduction + stepSize;
end

function [ flippedVec ] = flipFirstTwoDims( vec )
%FLIPFIRSTTWODIMS just reorders the first two dimensions
%   This is used when sometimes the meaning of the first two values in a
%   vector are [X,Y] or [Y,X]

flippedVec = vec;
flippedVec(2:-1:1) = vec(1:2);
end


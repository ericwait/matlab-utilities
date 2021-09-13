%
%PixelReplicate(im, label)
% im can be a logical image - if so it should contain only one connected
%   component
% im can be a label image - it can contain any number of connected components 
%   and label is used to select the component to replicate
% 

% Modified by Eric Wait 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (c) 2016, Drexel University
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
% 
% * Neither the name of PixelRep nor the names of its
%   contributors may be used to endorse or promote products derived from
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ptsReplicate_xy = PixelReplicate(im, label)
    if nargin>1
        ind = find(im==label);
    else
        ind = find(im);
        % NOTE - this is turned off for speed -- but be sure to 
    %     [L num]=bwlabel(im);
    %     if num>1
    %         fprintf(1,'WARNING: PixelReplicate called on >1 connected component\n');
    %     end
    end    

    bwd = DepthImageFromPoints(ind,im);

    indsReplicate = []; 
    idx = find(bwd);

    % note - you could use a parfor here for speed with large components
    for i=1:length(idx)
        nrep = round(bwd(idx(i)));
        % speed up by using pre-allocated ptsReplicate
        indsReplicate = [indsReplicate;repmat(idx(i),nrep,1)];
    end

    ptsReplicate_xy = Utils.SwapXY_RC(Utils.IndToCoord(size(im),indsReplicate));
end

function [bwd, bw] = DepthImageFromPoints(ind,im)
    bw = false(size(im));
    ind = unique(ind);

    bw(ind) = true;
    bwd = bwdist(~bw);
end


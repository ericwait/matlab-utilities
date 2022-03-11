function segmentation_table = TrackRAB(segmentation_table, max_distance, dimension_scale_xyz)

% SegmentAndTrack.m - This is the main program function for the RAB tools 
% application.

% /******************************************************************************
%   Modified code from rab-tools (license below) by Eric Wait in 2022
%
% This program, part of rab-tools is copyright (C) 2011-2014 Andrew R. 
% Cohen and Mark Winter.  All rights reserved.
% 
% This software may be referenced as:
% 
% Clark, B., M. Winter, A.R. Cohen, and B. Link, Generation of Rab-based transgenic 
% lines for in vivo studies of endosome biology in zebrafish. Developmental Dynamics, 
% 2011. 240(11): p. 2452-65.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
% 
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 
% 2. The origin of this software must not be misrepresented; you must 
%    not claim that you wrote the original software.  If you use this 
%    software in a product, an acknowledgment in the product 
%    documentation would be appreciated but is not required.
% 
% 3. Altered source versions must be plainly marked as such, and must
%    not be misrepresented as being the original software.
% 
% 4. The name of the author may not be used to endorse or promote 
%    products derived from this software without specific prior written 
%    permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
% OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
% GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% Andrew R. Cohen acohen@coe.drexel.edu
% RABTools version 1.0 (release) November 2014
% 
% ******************************************************************************/

    
    % Get length of sequence
    max_frame = max(segmentation_table.Frame);
    % Add track IDs to the table
    segmentation_table.Track_ID = [1:size(segmentation_table, 1)]';
    segmentation_table.Centroid_um = segmentation_table.Centroid .* dimension_scale_xyz;

    % loop over every segmentation in frame t and calculate the distance in t+1
    for f = 1:max_frame -1
        % get segmentations in t
        seg_t_ind = find(segmentation_table.Frame == f);
        seg_t_tab = segmentation_table(seg_t_ind, :);
        % get segmentations in t+1
        seg_t1_ind = find(segmentation_table.Frame == f+1);
        seg_t1_tab = segmentation_table(seg_t1_ind, :);

        % if there are no segmentations in either frame, continue
        if isempty(seg_t_tab) || isempty(seg_t1_tab)
            continue
        end


        % Make a table that shows pairwise similarity (lower number -> more similar)
        similarity_matrix = inf(size(seg_t_tab, 1), size(seg_t1_tab, 1));

        for i = 1:size(seg_t_tab, 1)

            cur_track_id = seg_t_tab.Track_ID(i);
%             cur_track_length = nnz(segmentation_table.Track_ID == cur_track_id);

            for j = 1:size(seg_t1_tab, 1)
                similarity_matrix(i,j) = Inf;

                % Are these segmentations close enough to consider?
                dist = pdist2(seg_t_tab.Centroid_um(i,:), seg_t1_tab.Centroid_um(j, :));
                if dist > max_distance
                    continue
                end

                % How similar are the segmentations? (lower score better)

                % How far away is this segmentation as a ratio of the max?
                % [0,1] where 0 is better
                dist_ratio = dist / max_distance;
                dist_ratio = 0.5 * dist_ratio;

                % 1 - volume ratio
                % [0,1] where 0 is better
                vol_ratio = 1 - (abs(seg_t_tab.Volume(i) - seg_t1_tab.Volume(j)) / max(seg_t_tab.Volume(i), seg_t1_tab.Volume(j)));
                vol_ratio = 1 * vol_ratio;

                % As segmentations move away, they need to have more similar volumes
                vol_dist_bias = dist_ratio * vol_ratio;

                similarity_matrix(i, j) = vol_dist_bias;

%                 length_bias = (f / cur_track_length)^2;
%                 similarity_matrix(i, j) = vol_bias * length_bias;
            end
         end

         assign = Track.AssignmentOptimal(similarity_matrix);
         assign_mask = assign>0;
         assign_ind = assign(assign_mask);

         segmentation_table.Track_ID(seg_t1_ind(assign_ind)) = segmentation_table.Track_ID(seg_t_ind(assign_mask));
    end
end

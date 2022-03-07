function [ax_handles, hist2] = TwoComponentHistogram(independent_var, dependent_var, varargin)
%TwoComponentHistogram - Creates three histograms: one for each varable,
%                           and a bivariate histogram in the center.
%
% Inputs:
%   independent_var     : data to go on the X axis of the bivariate histogram.
%   dependent_var       : data to go on the Y axis of the bivariate histogram.
%
% Optional Inputs:
%   independent_label   : label for the X axis.
%   dependent_label     : label for the Y axis.
%   count_label         : label for the hight of the histograms.
%   title_str           : title for the entire figure.
%   num_bins            : number of bins to use in each of the histograms.
%   figure_handle       : handle to already created figure.
%
% Outputs:
%   None

    p = inputParser;
    valid_string = @(x)(isstring(x) || ischar(x));
    addParameter(p, 'independent_label', '', valid_string);
    addParameter(p, 'dependent_label', '', valid_string);
    addParameter(p, 'count_label', '', valid_string)
    addParameter(p, 'title_str', '', valid_string);
    addParameter(p, 'num_bins', 256, @isscalar);
    addParameter(p, 'figure_handle', []);
    addParameter(p, 'dependent_range', []);
    addParameter(p, 'independent_range', []);
    parse(p,varargin{:})

    args = p.Results;
    
    if isempty(args.figure_handle)
        figure;
    else
        is_vis = args.figure_handle.Visible;
        figure(args.figure_handle);
        args.figure_handle.Visible = is_vis;
    end

    ax_handles.depenent = subplot(5, 5, [1,6,11,16]);
    num_bins = min( length(unique(dependent_var(:))), args.num_bins);
    if ~isempty(args.dependent_range)
        step_size = (args.dependent_range(2) - args.dependent_range(1)) / num_bins;
        num_bins = args.dependent_range(1):step_size:args.dependent_range(2);
    end
    [counts_dep, bins_dep] = histcounts(dependent_var, num_bins);
    barh(bins_dep(1:end-1), counts_dep, LineStyle="none")
    set(gca, 'xscale', 'log', 'XDir', 'reverse')
    ylabel(args.dependent_label)
    xlabel(args.count_label)
    
    ax_handles.independent = subplot(5, 5, 22:25);
    num_bins = min( length(unique(independent_var(:))), args.num_bins);
    if ~isempty(args.independent_range)
        step_size = (args.independent_range(2) - args.independent_range(1)) / num_bins;
        num_bins = args.independent_range(1):step_size:args.independent_range(2);        
    end
    [counts_ind, bins_ind] = histcounts(independent_var, num_bins);
    bar(bins_ind(1:end-1), counts_ind, LineStyle="none")
    set(gca, 'yscale', 'log', 'YDir', 'reverse')
    xlabel(args.independent_label)
    ylabel(args.count_label)
    
    ax_handles.histogram = subplot(5, 5, [2:5,7:10,12:15,17:20]);
    [counts_2, x_edge, y_edge] = histcounts2(independent_var, dependent_var, bins_ind, bins_dep);
    histogram2(XBinEdges=x_edge, YBinEdges=y_edge, BinCounts=counts_2, DisplayStyle="tile",FaceColor='flat');
    set(gca, 'xtick', [])
    set(gca, 'ytick', [])
%     colorbar("east")
    
    title(args.title_str)

    hist2.counts = counts_2;
    hist2.x_edge = x_edge;
    hist2.y_edge = y_edge;
end

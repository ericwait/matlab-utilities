function TwoComponentHistogram(independent_var, dependent_var, varargin)
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
    parse(p,varargin{:})

    args = p.Results;
    
    figure
    
    subplot(5, 5, [1,6,11,16])
    num_bins = min( length(unique(dependent_var(:))), args.num_bins);
    [counts_dep, bins_dep] = histcounts(dependent_var, num_bins);
    barh(bins_dep(1:end-1), counts_dep)
    set(gca, 'xscale', 'log')
    ylabel(args.dependent_label)
    xlabel(args.count_label)
    
    subplot(5, 5, 22:25)
    num_bins = min( length(unique(independent_var(:))), args.num_bins);
    [counts_ind, bins_ind] = histcounts(independent_var, num_bins);
    bar(bins_ind(1:end-1), counts_ind)
    set(gca, 'yscale', 'log')
    xlabel(args.independent_label)
    ylabel(args.count_label)
    
    subplot(5, 5, [2:5,7:10,12:15,17:20])
    [counts_2, x_edge, y_edge] = histcounts2(independent_var, dependent_var, bins_ind, bins_dep);
    histogram2(XBinEdges=x_edge, YBinEdges=y_edge, BinCounts=counts_2, DisplayStyle="tile",FaceColor='flat');
    set(gca, 'xtick', [])
    set(gca, 'ytick', [])
    
    title(args.title_str)
end

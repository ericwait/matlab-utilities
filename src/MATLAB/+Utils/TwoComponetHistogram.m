function TwoComponetHistogram(independent_var, dependent_var, varargin)
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
    [counts,bins] = histcounts(dependent_var, args.num_bins);
    barh(bins(1:end-1), counts)
    ylabel(args.dependent_label)
    xlabel(args.count_label)
    
    subplot(5, 5, 22:25)
    [counts,bins] = histcounts(independent_var, args.num_bins);
    bar(bins(1:end-1), counts)
    xlabel(args.independent_label)
    ylabel(args.count_label)
    
    subplot(5, 5, [2:5,7:10,12:15,17:20])
    histogram2(independent_var, dependent_var, args.num_bins, DisplayStyle="tile")
    
    title(args.title_str)
end

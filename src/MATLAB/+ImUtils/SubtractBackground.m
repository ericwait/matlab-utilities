function im_sub = SubtractBackground(im, varargin)
    p = inputParser;
    is_scalar_or_empty = @(x)(isscalar(x) || isempty(x));
    addParameter(p, 'background_prct', [], is_scalar_or_empty);
    addParameter(p, 'background_val', [], is_scalar_or_empty);
    parse(p,varargin{:})
    args = p.Results;

    bck_prct = args.background_prct;
    if bck_prct > 0.99999999
        bck_prct = bck_prct / 100;
    end
    
    clss = class(im);
    if ~isempty(args.background_prct) && isempty(args.background_val)
        sub_val = (max(im(:))-min(im(:))) * bck_prct;
        if strcmpi('single', clss) || strcmpi('double', clss)
            if max(im(:)) > 1
                sub_val = bck_prct;
            end
        end
    elseif isempty(args.background_prct) && ~isempty(args.background_val)
        sub_val = args.background_val;
    else
        error('Use either background_prct or background_val but not both.');
    end

    im_sub = im - sub_val;
    im_sub(im_sub<0) = 0;
end
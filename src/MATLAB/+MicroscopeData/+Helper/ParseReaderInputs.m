function argStruct = ParseReaderInputs(varargin)
    dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double';
                  'logical'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];

    p = inputParser();
    p.StructExpand = false;

    % This is ridiculous, but we assume that the optional path is specified if
    % length(varargin) is odd
    if ( mod(length(varargin),2) == 1 )
        addOptional(p,'path','', @ischar);
    else
        addParameter(p,'path','', @ischar);
    end

    addParameter(p,'imageData',[], @(x)(validOrEmpty(@isstruct,x)));

    addParameter(p,'chanList',[], @(x)(validOrEmpty(@isvector,x)));
    addParameter(p,'timeRange',[], @(x)(validOrEmpty(@(y)(numel(y)==2),x)));
    addParameter(p,'roi_xyz',[], @(x)(validOrEmpty(@(y)(all(size(y)==[2,3])),x)));
    addParameter(p,'getMIP',false,@islogical);

    addParameter(p,'outType',[], @(x)(validOrEmpty(@(y)(any(strcmp(y,dataTypeLookup))),x)));
    addParameter(p,'normalize',false,@islogical);
    addParameter(p,'imVersion','Original',@ischar);

    addParameter(p,'verbose',false, @islogical);
    addParameter(p,'prompt',[], @(x)(validOrEmpty(@islogical,x)));
    addParameter(p,'promptTitle','', @ischar);

    parse(p,varargin{:});
    argStruct = p.Results;
end

% Inputs are valid if they are empty or if they satisfy their validity function
function bValid = validOrEmpty(validFunc,x)
    bValid = (isempty(x) || validFunc(x));
end

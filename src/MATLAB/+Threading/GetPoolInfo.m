function [ numWorkers ] = GetPoolInfo( createPool, numWorkers )
%GETPOOLINFO Summary of this function goes here
%   Detailed explanation goes here
    if( ~exist('createPool', 'var') || isempty(createPool))
        createPool = false;
    end
    
    if( ~exist('numWorkers', 'var'))
        numWorkers = [];
    end
    
    p = gcp('nocreate');
    
    if(isempty(p) && createPool)
        if(~isempty(numWorkers))
            p = parpool(numWorkers);
        else
            p = parpool();
        end
    end
    
    numWorkers = p.NumWorkers;
end


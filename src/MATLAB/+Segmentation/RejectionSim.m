% X = RejectionSim(numPointsOut,pdfIm)
% 
% Simulate numPointsOut points from the discrete empirical density pdfIm using the
% rejection method.

function X = RejectionSim(numPointsOut,pdfIm)
    d = ndims(pdfIm);
    
    % Generate only near non-zero pixels
    bwIm = ImProc.MaxFilterNeighborhood(pdfIm,[3,3,3]);
    validIdx = find(bwIm);
    
    validCoords = Utils.IndToCoord(size(pdfIm), validIdx);
    
    % Guarantee pdfIm is distribution and find probability of rejection c
    
    % g is the pdf of a uniform distribution over the valid pixels
    g = 1/length(validIdx);
    pdfIm = pdfIm / sum(pdfIm(:));
    
    c = max(pdfIm(:)) / g;
    
    lastIdx = 0;
    X = zeros(numPointsOut,d);
    for i=1:ceil(2*c)
        U = rand(numPointsOut,1);
        coordIdx = randi(length(validIdx),numPointsOut,1);
        C = validCoords(coordIdx,:) + rand(numPointsOut,d) - 0.5;
        
        cellCoord = num2cell(C,1);
        f = interpn(pdfIm, cellCoord{:}, 'linear');
        
        bKeep = (U <= f/(c*g));
        
        numValid = nnz(bKeep);
        writeNum = min(lastIdx+numValid,numPointsOut)-lastIdx;
        
        validC = C(bKeep,:);
        X(lastIdx+(1:writeNum),:) = validC(1:writeNum,:);
        
        lastIdx = lastIdx + writeNum;
        if ( lastIdx >= numPointsOut )
            break;
        end
    end
    
    if ( lastIdx < numPointsOut )
        warning(['Only generated ' num2str(lastIdx) ' valid points!']);
    end
    
    swapCoord = [2 1 3:size(X,2)];
    X = X(:,swapCoord);
end

function timeStampDelta = GetOrderedTimeStamps(secs,numFrames,numChans)
    if (~exist('numFrames','var') || isempty(numFrames))
        numFrames = 1;
    end
    if (~exist('numChans','var') || isempty(numChans))
        numChans = 1;
    end

    secOrdered = sort(secs);
    timeStampDelta = [];
    for t=0:numFrames-1
        startIdx = t*numChans+1;
        deltaT = 0;
        for c=0:numChans-1
            if (length(secOrdered)>=startIdx+c)
                deltaT = deltaT + secOrdered(startIdx+c);
            end
        end
        timeStampDelta(end+1) = (deltaT./numChans)*1e-3;
    end
end

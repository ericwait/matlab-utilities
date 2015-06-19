function PrintProgress(val,init)
%PRINTPROGRESS prints the progress and the estimated time of completion on
%the commandline.
%ENSURE that the code that is being monitored does not have internal
%printing to the commandline.
% INIT - if init is true, then the val passed in will be used as the
% denominator when figuring out the percent completed.
% When init is false, the progress is deleted from the command line and the
% internal valuse reset.
% VAL - when updating the progress enter the number that will be used as
% the numerator for the percent completed and ensure that the second
% paramater is not used or empty.
%
% Usage -- Initalize by using PrintProgress(number of iterations, true);
%          Update by using    PrintProgress(current iteration);
%          Clean up by using  PrintProgress(0,false);

global backspaces firstTime total

cur = now;

if (exist('init','var') && ~isempty(init))
    if (init)
        backspaces = '';
        firstTime = cur;
        total = val;
    else
        fprintf(backspaces);
        backspaces = '';
        firstTime = 0;
        total = inf;
    end
else
    prcntDone = val / total;
    elpsTime = (cur - firstTime) * 86400;
    totalSec = elpsTime / prcntDone;
    finDate = firstTime + (totalSec / 86400);
    timeLeft = (finDate - cur)*86400;
    
    doneStr = sprintf('%5.2f%%%% est. %s @ %s',prcntDone*100,printTime(timeLeft),datestr(finDate,'HH:MM:SS dd-mmm-yy'));
    fprintf([backspaces,doneStr]);
    backspaces = repmat(sprintf('\b'),1,length(doneStr)-1);
end
end

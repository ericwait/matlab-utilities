classdef CmdlnProgress<handle
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
    % Usage -- Initalize by using CmdlnProgress(number of iterations, true);
    %          Update by using    PrintProgress(current iteration);
    %          Clean up by using  PrintProgress(0,false);
    
    properties
        backspaces
        firstTime
        total
        useBs
    end
    
    methods
        function obj = CmdlnProgress(iterations,useBackspace)
            if(~exist('useBackspace', 'var') || isempty(useBackspace))
                obj.useBs = true;
            else
                obj.useBs = useBackspace;
            end
            
            obj.total = iterations;

            obj.backspaces = [];
            obj.firstTime = now;
        end
        
        function PrintProgress(obj,val)
            cur = now;
            
            prcntDone = val / obj.total;
            elpsTime = (cur - obj.firstTime) * 86400;
            totalSec = elpsTime / prcntDone;
            finDate = obj.firstTime + (totalSec / 86400);
            timeLeft = (finDate - cur)*86400;
            
            doneStr = sprintf('%5.2f%%%% est. %s @ %s',prcntDone*100,Utils.PrintTime(timeLeft),datestr(finDate,'HH:MM:SS dd-mmm-yy'));
            fprintf([obj.backspaces,doneStr]);
            
            if(obj.useBs)
                obj.backspaces = repmat(sprintf('\b'),1,length(doneStr)-1);
            else
                fprintf('\n');
            end
        end
        
        function ClearProgress(obj)
            fprintf(obj.backspaces);
            obj.backspaces = [];
            obj.firstTime = 0;
            obj.total = 0;
            obj.useBs = false;
        end
    end
end

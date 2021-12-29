function [ strOut ] = PrintTime( timeIn, n)
%PRINTTIME takes time in sec and outputs a string in the form HH:MM:SS.ss

elapsed_sec = seconds(timeIn);
elapsed_sec.Format = 'hh:mm:ss.SSS';
strOut = string(elapsed_sec);

if (exist('n','var') && ~isempty(n))
    avgTime = timeIn/n;
    strOut = sprintf('%s, average: %s',strOut, Utils.PrintTime(avgTime));
end
end


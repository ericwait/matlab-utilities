function [ strOut ] = PrintTime( timeIn )
%PRINTTIME takes time in sec and outputs a string in the form HH:MM:SS.ss

hr = floor(timeIn/3600);
tmNew = timeIn - hr*3600;
mn = floor(tmNew/60);
tmNew = tmNew - mn*60;
sc = tmNew;

strOut = sprintf('%02dh:%02dm:%05.2fs',hr,mn,sc);
end


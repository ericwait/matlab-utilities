function [ str ] = SanitizeString( str )
%SANITIZESTRING Summary of this function goes here
%   Detailed explanation goes here
str = strrep(str, '!', '');
str = strrep(str, '*', '');
str = strrep(str, '''', '');
str = strrep(str, '(', '');
str = strrep(str, ')', '');
str = strrep(str, ';', '');
str = strrep(str, ':', '');
str = strrep(str, '@', '');
str = strrep(str, '&', '');
str = strrep(str, '=', '');
str = strrep(str, '+', '');
str = strrep(str, '$', '');
str = strrep(str, ',', '');
str = strrep(str, '/', '');
str = strrep(str, '?', '');
str = strrep(str, '#', '');
str = strrep(str, '[', '');
str = strrep(str, ']', '');
end

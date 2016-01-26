function newFilePath = CreateUniqueWordedPath(fPath)
%newFilePath = CreateUniqueWordedPath(fPath)
% Pass in a path with at least two directories with '\' seperating the
% direcories, and a new path will be generated that removes the words that
% are repeated.  This forces the unique words closer to the file name or
% most deep directory.

driveIdx = find(fPath==':',1,'first');
if (~isempty(driveIdx))
    tmpPath = strtrim(MicroscopeData.Helper.SanitizeString(fPath(driveIdx+1:end)));
    fPath = [fPath(1:driveIdx),tmpPath];
else
    fPath = strtrim(MicroscopeData.Helper.SanitizeString(fPath));
end

dirs = strsplit(fPath,'\');

newDirs = {};
for i=1:length(dirs)
    if (strcmp(dirs{i},'.'))
        continue
    end
    if (strcmp(dirs{i},'..'))
        newDirs = newDirs(1:end-1);
        continue
    end
    if (isempty(newDirs))
        newDirs = dirs(i);
    else
        newDirs{end+1} = dirs{i};
    end
end

dirs = newDirs;

wordList = strsplit(dirs{end},' ');

newFilePath = dirs{end};

for i=length(dirs)-1:-1:1
    curDir = dirs{i};
    curWords = strsplit(curDir,' ');
    keepWords = true(1,length(curWords));
    for j=1:length(curWords)
        if (any(strcmpi(curWords{j},wordList)))
            keepWords(j) = false;
        else
            wordList{end+1} = curWords{j};
        end
    end
    
    newDir = '';
    for j=1:length(keepWords)
        if (keepWords(j))
            if (isempty(newDir))
                newDir = strtrim(curWords{j});
            else
                newDir = sprintf('%s %s',newDir,strtrim(curWords{j}));
            end
        end
    end
    newFilePath = fullfile(newDir,newFilePath);
end
end

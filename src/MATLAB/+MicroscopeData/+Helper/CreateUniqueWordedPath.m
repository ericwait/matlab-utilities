function newFilePath = CreateUniqueWordedPath(fPath)
%newFilePath = CreateUniqueWordedPath(fPath)
% Pass in a path with at least two directories with '\' seperating the
% direcories, and a new path will be generated that removes the words that
% are repeated.  This forces the unique words closer to the file name or
% most deep directory.

fPath = MicroscopeData.Helper.SanitizeString(fPath);

dirs = strsplit(fPath,'\');

wordList = strsplit(dirs{end},' ');

newFilePath = dirs{end};

for i=length(dirs)-1:-1:1
    curDir = dirs{i};
    curWords = strsplit(curDir,' ');
    keepWords = true(1,length(curWords));
    for j=1:length(curWords)
        for k=1:length(wordList)
            if (strcmpi(wordList{k},curWords{j}))
                keepWords(j) = false;
                break
            end
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

function imageData = readMetaData(root)

if (~exist('root','var'))
    rootDir = uigetdir('');
    if rootDir==0, return, end
elseif (~isempty(strfind(root,'.txt')))
    fileHandle = fopen(root);
    imageData = readfile(fileHandle);
    return
else
    rootDir = root;
end

imageData = [];
dlist = dir(rootDir);

for i=1:length(dlist)
    if (strcmp('..',dlist(i).name))
        continue;
    end
    
    dSublist = dir(fullfile(rootDir,dlist(i).name,'*.txt'));
    if isempty(dSublist), continue, end
    
    for j=1:length(dSublist)
        fileHandle = fopen(fullfile(rootDir,dlist(i).name,dSublist(j).name));
        imageDatum = readfile(fileHandle);
        
        if (isempty(imageDatum)), continue, end
        
        if (isempty(imageData))
            imageData = imageDatum;
        else
            imageData(length(imageData)+1) = imageDatum;
        end
    end
end
end

function imageDatum = readfile(fileHandle)
imageDatum = {};

if fileHandle<=0, return, end

data = textscan(fileHandle,'%s %s', 'delimiter',':','whitespace','\n');
fclose(fileHandle);

if isempty(data), return, end

for k=1:length(data{1})
    val = str2double(data{2}{k});
    if (isnan(val))
        val = data{2}{k};
    end
    imageDatum.(data{1}{k}) = val;
end
end

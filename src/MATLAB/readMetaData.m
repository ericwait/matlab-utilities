function readMetaData(filePath)
global imageData

if (~exist('filePath','var') || isempty(filePath))
    [fileName,pathName,~] = uigetfile('.txt');
    if (fileName==0)
        return
    end
    filePath = fullfile(pathName,fileName);
end

imageData = [];

fileHandle = fopen(filePath,'r');
if fileHandle<=0
    error('Could not open file!\n');
end

tline = fgetl(fileHandle);

while(tline~=-1)
    data = textscan(tline,'%s', 'delimiter',':','whitespace','\n');
    switch data{1}{1}
        case 'DatasetName'
            imageData.DatasetName = data{1}{2};
        case 'NumberOfChannels'
            imageData.NumberOfChannels = str2double(data{1}{2});
        case 'ChannelColors'
            colors = textscan(data{1}{2},'%s','delimiter',',');
            for i=1:length(colors{1})
                imageData.ChannelColors{i} = colors{1}{i};
            end
        case 'NumberOfFrames'
            imageData.NumberOfFrames = str2double(data{1}{2});
        case 'XDimension'
            imageData.xDim = str2double(data{1}{2});
        case 'YDimension'
            imageData.yDim = str2double(data{1}{2});
        case 'ZDimension'
            imageData.zDim = str2double(data{1}{2});
        case 'XPixelPhysicalSize'
            imageData.XPixelPhysicalSize = str2double(data{1}{2});
        case 'YPixelPhysicalSize'
            imageData.YPixelPhysicalSize = str2double(data{1}{2});
        case 'ZPixelPhysicalSize'
            imageData.ZPixelPhysicalSize = str2double(data{1}{2});
        case 'XPosition'
            imageData.XPosition = str2double(data{1}{2});
        case 'YPosition'
            imageData.YPosition = str2double(data{1}{2});
        case 'ZPosition'
            imageData.XDistanceUnits = data{1}{2};
        case 'XDistanceUnits'
            imageData.YDistanceUnits = data{1}{2};
        case 'YDistanceUnits'
            imageData.ZDistanceUnits = data{1}{2};
        case 'XLength'
            imageData.XLength = str2double(data{1}{2});
        case 'YLength'
            imageData.YLength = str2double(data{1}{2});
        case 'ZLength'
            imageData.ZLength = str2double(data{1}{2});
    end
    
    tline = fgetl(fileHandle);
end
fclose(fileHandle);

end
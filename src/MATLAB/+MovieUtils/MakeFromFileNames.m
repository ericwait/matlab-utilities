function MakeFromFileNames( fileNameList, fps, outputName )
%MAKEFROMFILENAMES Summary of this function goes here
%   Detailed explanation goes here

v = VideoWriter(outputName,'MPEG-4');
v.Quality = 100;
v.FrameRate = fps;
open(v);

for i=1:length(fileNameList)
    im = imread(fileNameList{i});
    writeVideo(v,im);
end

close(v);

end


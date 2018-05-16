function MakeMP4_ffmpeg(frameStart, frameEnd, frameDir, movieFPS, suffix)
    range = [frameStart,frameEnd];
    if (~exist('suffix','var'))
        suffix = [];
    end
    
    [~,name] = fileparts(frameDir);
    if (isempty(name))
        name = 'movie';
    end
    
    ffmpegimages2video(fullfile(frameDir,[suffix,'%04d.tif']),...
        fullfile(frameDir,[name,'.mp4']),...
        'InputFrameRate',movieFPS,...
        'InputStartNumber',range,...
        'x264Tune','stillimage',...
        'OutputFrameRate',movieFPS);
end

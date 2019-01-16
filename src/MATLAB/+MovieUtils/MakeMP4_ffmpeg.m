function MakeMP4_ffmpeg(frameStart, frameEnd, frameDir, movieFPS, suffix)
    range = [frameStart,frameEnd];
    if (~exist('suffix','var'))
        suffix = [];
    end
    
    if (~isempty(suffix))
        name = suffix;
    else
        [~,name] = fileparts(frameDir);
        if (isempty(name))
            name = 'movie';
        end
    end
    
    ffmpegimages2video(fullfile(frameDir,[suffix,'%04d.tif']),...
        fullfile(frameDir,[name,'.mp4']),...
        'InputFrameRate',movieFPS,...
        'InputStartNumber',range,...
        'x264Tune','stillimage',...
        'OutputFrameRate',movieFPS);
end

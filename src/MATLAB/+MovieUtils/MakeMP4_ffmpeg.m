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
    
    try
    ffmpegimages2video(fullfile(frameDir,[suffix,'%04d.tif']),...
        fullfile(frameDir,[name,'.mp4']),...
        'InputFrameRate',movieFPS,...
        'InputStartNumber',range,...
        'x264Tune','stillimage',...
        'OutputFrameRate',movieFPS);
    catch err
        error('If not already...\n\t%s\n\t%s\n\n%s',...
            'Install ffmpeg from: https://ffmpeg.org/',...
            'Install FFmpeg tool box from: https://www.mathworks.com/matlabcentral/fileexchange/42296-ffmpeg-toolbox',...
            err.message);
    end
end

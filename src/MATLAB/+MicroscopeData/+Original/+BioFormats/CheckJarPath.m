function CheckJarPath()
%CHECKJARPATH Summary of this function goes here
%   Detailed explanation goes here

%% ensure that the bioformats jar file is on the path
javaPaths = javaclasspath('-all');
bfIsLoaded = false;
if (~isempty(javaPaths))
    for i=1:length(javaPaths)
        [~,name,~] = fileparts(javaPaths{i});
        if (strcmpi('bioformats_package',name))
            bfIsLoaded = true;
            break
        end
    end
end

if (~bfIsLoaded)
    curPath = mfilename('fullpath');
    [pathstr,~,~] = fileparts(curPath);
    javaaddpath(fullfile(pathstr,'bioformats_package.jar'),'-end');
end
end


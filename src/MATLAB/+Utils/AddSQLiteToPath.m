function AddSQLiteToPath()
    %CHECKJARPATH Summary of this function goes here
    %   Detailed explanation goes here

    %% ensure that the bioformats jar file is on the path
    dynamicPaths = javaclasspath('-dynamic');
    isLoadedJar = false;
    if (~isempty(dynamicPaths))
        for i=1:length(dynamicPaths)
            [~,name,~] = fileparts(dynamicPaths{i});
            if (strcmpi('sqlite',name))
                isLoadedJar = true;
                break
            end
        end
    end

    if (~isLoadedJar)
        curPath = mfilename('fullpath');
        [pathstr,~,~] = fileparts(curPath);
        javaaddpath(fullfile(pathstr,'sqlite.jar'),'-end');
    end
end

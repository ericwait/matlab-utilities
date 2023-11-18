% Check if the script is running in a deployed (compiled) environment
% If so, skip the rest of the script as path additions are not necessary
if isdeployed
    return
end

% Set a breakpoint for all errors - MATLAB will pause execution whenever an error occurs
dbstop if error

% Define the root directory for programming projects
%  
rootProgramming = fullfile(root_programs, 'git', 'programming');

% List of packages to be added to MATLAB's path
% These are assumed to be subdirectories within the rootProgramming directory
pkgList = {...
    'hydra-image-processor';
    'matlab-utilities';
    'direct-5D-viewer';
    'vital-dyes';
    'vhne';
    'hmm-bayes';
    'prototype';
    'eric-sandbox';
    'core'
};

% Call the function to add specified paths to MATLAB's search path
addPaths(rootProgramming, pkgList);

% Function to add paths
function addPaths(rootProgramming, pkgList)
    % Subdirectory names within each package where MATLAB files are located
    matlabDir = fullfile('src','MATLAB');
    matlabDir_l = fullfile('src','matlab');

    % Loop through each package in the list
    for i = 1:length(pkgList)
        % Construct the full path to the MATLAB directory in the package
        pkgPath = fullfile(rootProgramming, pkgList{i}, matlabDir);

        % Add the path if it exists
        if exist(pkgPath, 'dir')
            addpath(pkgPath);
        else
            % Check for an alternate path (lowercase 'matlab')
            pkgPath = fullfile(rootProgramming, pkgList{i}, matlabDir_l);
            if exist(pkgPath, 'dir')
                addpath(pkgPath);
            end
        end
    end
end

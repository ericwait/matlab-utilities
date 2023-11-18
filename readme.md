# MATLAB Utilities

This project started many years ago to standardize the way that I read in microscope data.
This project has expanded to include many helpful functions and scripts when manipulating data from microscopes, namely high dimensional ones.
Many modern microscopes are capable of capturing three-dimensional data with separate channels over time, or what I'll be calling 5-D data.

I hope that you find this repository as useful as I have.
Please let me know if you have additions that you find useful that others will too.

## Getting Started

These tools have been written with MATLAB's [package](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html) paradigm.
This allows for a convenient grouping of similar functions.
This also keeps directories well organized.
There are two ways that you can make these packages available for MATLAB to use regardless of the current workspace directory.
One way (_not recommended_) is to just copy any directory with a + sign to your MATLAB folder in your user space.
For example, on windows this would be `C:\Users\myuser\Documents\MATLAB`.
However, doing so will break the whole point of putting these functions in a git repository.
The **_recommend_** way is to add the packages to your MATLAB path.
This can be done with an addition to your startup.m file located in your user space.

### Setting Up `root_programs.m`

The `root_programs.m` function is used to determine the root directory for MATLAB programs based on the operating system.
This function is crucial for defining a consistent starting point for package paths.

1. **Create the Function**:
   * Create a file named `root_programs.m`.
   * Copy the provided `root_programs` function code into this file.
   * Save the file in a directory that is in your MATLAB path, or add its directory to the MATLAB path.

2. **Function Usage**:
   * This function returns the root directory path for your MATLAB programs.
   * On Windows, it derives the path from the MATLAB `userpath`.
   * On other operating systems, it defaults to the home directory.

### Configuring `startup.m`

The `startup.m` script automatically runs each time MATLAB starts, setting up the environment, including adding necessary paths for your packages.

1. **Create the Script**:
   * Create a file named `startup.m`.
   * Place this file in the directory that MATLAB checks upon startup.
This is usually the MATLAB root directory.

2. **Script Setup**:
   * Copy the provided `startup.m` script code into this file.
   * Modify the `pkgList` array to include the names of your MATLAB packages.

3. **Adding Package Paths**:
   * The script uses the `root_programs` function to find the base directory.
   * It then adds paths for each package listed in `pkgList`.
   * Packages are expected to be in the `src/MATLAB` or `src/matlab` subdirectories.

### Usage

Once you have set up the `root_programs.m` function and the `startup.m` script, MATLAB will automatically configure the paths to your packages each time it starts.
This setup simplifies the management of multiple MATLAB projects and packages, ensuring that all necessary files and directories are easily accessible.

### Tips

* Keep your package directories organized and consistent with the naming conventions used in `pkgList`.
* Regularly update your `startup.m` script as you add or remove packages.
* Use version control (like Git) to track changes in your `startup.m` and `root_programs.m` files, especially if working in a team environment.

By following these instructions, you can streamline your MATLAB environment setup, making it easier to work with multiple projects and packages.

#### `root_programs.m`

```matlab
function str = root_programs()
    % root_programs - Determines the root directory for programs.
    %
    % This function computes the root directory for storing or accessing
    % programs. The path is determined based on the operating system.
    % For Windows, it derives the path from the user's MATLAB userpath.
    % For non-Windows systems, it defaults to the user's home directory.
    %
    % Output:
    %   str - A string representing the computed root directory path.

    % Check if the operating system is Windows
    if ispc
        % Obtain the user's MATLAB userpath
        usr_path = userpath;

        % Split the userpath to extract components
        path_comp = split(usr_path, filesep);  % Using filesep for OS compatibility

        % Construct the root path from the first three components
        % This assumes the userpath follows a specific structure
        str = fullfile(path_comp{1}, path_comp{2}, path_comp{3});
    else
        % For non-Windows systems, use the user's home directory
        str = '~';
    end
end
```

#### `startup.m`

```matlab
% Check if the script is running in a deployed (compiled) environment
% If so, skip the rest of the script as path additions are not necessary
if isdeployed
    return
end

% Set a breakpoint for all errors - MATLAB will pause execution whenever an error occurs
dbstop if error

% Define the root directory for programming projects
rootProgramming = fullfile(root_programs, 'git', 'programming');

% List of packages to be added to MATLAB's path
% These are assumed to be subdirectories within the rootProgramming directory
pkgList = {...
    'hydra-image-processor';
    'matlab-utilities';
    'direct-5D-viewer';
    'hmm-bayes'
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

```

#### Motivation

I put all of my git repositories in a master directory, which is stated in the first line.
I have many different packages that I use, so a list of the repository names goes in the package list.
If you have looked at any of my other repositories, I like to have a standard subdirectory hierarchy.
The folder named `src` indicates where source code goes.
the second folder `MATLAB` indicates that this is MATLAB code.
I then go through all of my packages and add them to my MATLAB path.
This allows me to have access to each of the packages from the MATLAB command line regardless of which directory I'm currently in.

I highly recommend this method.
It also helps when you use some of my other various repositories that depend on this one :smiley:.

### Prerequisites

This package includes the `jar` file for [Bioformats](https://docs.openmicroscopy.org/bio-formats/5.7.2/users/matlab/index.html) that has been tested.
This is only used in the `MicroscopeData.Original` package and is not strictly needed for this repository to be useful.
If you would like to use a newer version of the Bioformats functions or would like to compile your own version, please visit their website.

Also, a version of the [Keller Lab Block Format](https://bitbucket.org/fernandoamat/keller-lab-block-filetype) is included.
If you would like versions for you particular operating system or would just like to compile the most current version, please visit their website.

## Notable Packages

### MicroscopeData

The most heavily used package in this repository is `MicroscopeData.`
This package is how I read and write microscope image data where my other repositories can read them in a predictable way.
`MicroscopeData.Original` wraps the MATLAB version of [Bioformats](https://docs.openmicroscopy.org/bio-formats/5.7.2/users/matlab/index.html) in such a way that the image and meta-data are returned exactly as the ones written by the `MicroscopeData` writers.

The main idea is to read and write 5-D image dataset in multiple file formats with the same MATLAB commands.
For example:

```matlab
[im,imMeta] = MicroscopeData.Reader();
```

Or alternatively:

```matlab
[im,imMeta] = MicroscopeData.Reader('C:\pathToJsonFile');
```

This is the hallmark function of this repository.
Many different file types can be written out by the included code using the particular writers, but reading is as simple as calling the `Reader` command.
This is accomplished by having a set of minimal meta-data stored in a json file that is in the same directory as the image files.
The contents of this json file is enough to know how to read the files and reconstruct the data.
The reader will always return the image data as a 5-D matrix where unused dimensions are singleton.
The ordering of this matrix is always (y,x,z,&#955;,t), where &#955; is the discrete channels.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Eric Wait** -- _Architect and maintainer_ -- [Eric Wait.com](https://ericwait.com)

* **Andrew Cohen** -- _Initial Funder and contributor_ -- [Bioimage](https://bioimage.coe.drexel.edu)

* **Mark Winter** -- _Contributor and consultant_

* **Blair Rossetti** -- _Contributor_

See also the list of [contributors](https://github.com/ericwait/matlab-utilities/graphs/contributors) who participated in this project.

## License

This project is licensed under the BSD License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to Bioformats for doing the impossible task of reading data from multiple microscope manufactures.
* Keller Lab for creating a modern file format that has high compression and parallelized for high throughput.

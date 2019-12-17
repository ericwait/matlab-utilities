# MATLAB Utilities

This project started many years ago to standardize the way that I read in microscope data. This project has expanded to include many helpful functions and scripts when manipulating data from microscopes, namely high dimensional ones. Many modern microscopes are capable of capturing three dimensional data with separate channels over time, or what I'll be calling 5-D data. 

I hope that you find this repository as useful as I have. Please let me know if you have additions that you find useful that others will too.

## Getting Started

These tools have been written with MATLAB's [package](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html) paradigm. This allows for a convenient grouping of similar functions. This also keeps directories well organized. There are two ways that you can make these packages available for MATLAB to use regardless of the current workspace directory. One way (_not recommended_) is to just copy any directory with a + sign to your MATLAB folder in your user space. For example, on windows this would be `C:\Users\myuser\Documents\MATLAB`. However, doing so will break the whole point of putting these functions in a git repository. The **_recommend_** way is to add the packages to your MATLAB path. This can be done with an addition to your startup.m file located in your user space.

For example, here is something similar to what my `startup.m` looks like:

```matlab
rootProgramming = fullfile('C:\git_repos\');

pkgList = {...
    'utilities';
    };

matlabDir = fullfile('src','MATLAB');
for i=1:length(pkgList)
    pkgPath = fullfile(rootProgramming,pkgList{i},matlabDir);
    if (exist(pkgPath,'dir'))
        addpath(pkgPath);
    end
end
```

I put all of my git repositories in a master directory, which is stated in the first line. I have many different packages that I use, so a list of the repository names goes in the package list. If you have looked at any of my other repositories, I like to have a standard subdirectory hierarchy. The folder named `src` indicates where source code goes. the second folder `MATLAB` indicates that this is MATLAB code. I then go through all of my packages and add them to my MATLAB path. This allows me to have access to each of the packages from the MATLAB command line regardless of which directory I'm currently in.

I highly recommend this method. It also helps when you use some of my other various repositories that depend on this one :smiley:. 

### Prerequisites

This package includes the `jar` file for [Bioformats](https://docs.openmicroscopy.org/bio-formats/5.7.2/users/matlab/index.html) that has been tested. This is only used in the `MicroscopeData.Original` package and is not strictly needed for this repository to be useful. If you would like to use a newer version of the Bioformats functions or would like to compile your own version, please visit their website.

Also, a version of the [Keller Lab Block Format](https://bitbucket.org/fernandoamat/keller-lab-block-filetype) is included. If you would like versions for you particular operating system or would just like to compile the most current version, please visit their website.

## Notable Packages

### MicroscopeData

The most heavily used package in this repository is `MicroscopeData.` This package is how I read and write microscope image data where my other repositories can read them in a predictable way. `MicroscopeData.Original` wraps the MATLAB version of [Bioformats](https://docs.openmicroscopy.org/bio-formats/5.7.2/users/matlab/index.html) in such a way that the image and meta-data are returned exactly as the ones written by the `MicroscopeData` writers.

The main idea is to read and write 5-D image dataset in multiple file formats with the same MATLAB commands. For example:

```matlab
[im,imMeta] = MicroscopeData.Reader();
```

Or alternatively:

```matlab
[im,imMeta] = MicroscopeData.Reader('C:\pathToJsonFile');
```

This is the hallmark function of this repository. Many different file types can be written out by the included code using the particular writers, but reading is as simple as calling the `Reader` command. This is accomplished by having a set of minimal meta-data stored in a json file that is in the same directory as the image files. The contents of this json file is enough to know how to read the files and reconstruct the data. The reader will always return the image data as a 5-D matrix where unused dimensions are singleton. The ordering of this matrix is always (y,x,z,&#955;,t), where &#955; is the discrete channels.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Eric Wait** - *Architect and maintainer* - [Eric Wait.com](https://ericwait.com)

* **Andrew Cohen** - *Initial Funder and contributor* - [Bioimage](https://bioimage.coe.drexel.edu)

* **Mark Winter** - *Contributor and consultant*

* **Blair Rossetti** - *Contributor*

See also the list of [contributors](https://github.com/ericwait/matlab-utilities/graphs/contributors) who participated in this project.

## License

This project is licensed under the BSD License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to Bioformats for doing the impossible task of reading data from multiple microscope manufactures.
* Keller Lab for creating a modern file format that has high compression and parallelized for high throughput.

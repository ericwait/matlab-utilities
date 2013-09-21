#include "main.h"
#include <iostream>
#include <fstream>
#include "PreProcessImages.cuh"

std::vector<ImagesTiff*> gImageTiffs;

int main(int argc, char* argv[])
{
	std::string fileListLocation = "";

	HRESULT hr = S_FALSE;

	char q;

	if (argc<2)
	{
		printf("Usage: %s listfile.txt [unmixChan:chan[:chan[:chan]] [numberOfGPUs] \n",argv[0]);
		std::cin >> q;
		return 1;
	}

	printf("Running Param:");
	for (int i=1; i<argc; ++i)
	{
		printf("%s",argv[i]);
	}
	printf("\n");

	fileListLocation = argv[1];	

	if (!fileExists(fileListLocation.c_str()))
	{
		printf("%s does not exist!\n",fileListLocation.c_str());
		std::cin >> q;
		return 1;
	}

	if (argc>2)
	{
		std::string first = argv[2];
		size_t ind = first.find_first_of(':');
		if (ind==std::string::npos)
			numGpus = atoi(first.c_str());
		else
		{
			size_t start = 0;
			while (start<first.size())
			{
				std::string s = first.substr(start,ind-start);
				const char* numC = s.c_str();
				int numI = atoi(numC);
				unmixChannels.push_back(numI -1);
				if (ind==std::string::npos)
					break;

				start = ind+1;
				ind = first.find_first_of(':',start);
			}
		}

	}

	std::vector<std::string> metadataFiles;
	std::ifstream file(fileListLocation.c_str());
	if (file.is_open())
	{
		while(file.good())
		{
			std::string line;
			getline(file,line);
			if (!line.empty())
			{
				metadataFiles.push_back(line);
			}
		}
		file.close();
	}else
	{
		printf("Cannot open %s!\n",fileListLocation.c_str());
		std::cin >> q;
		return 1;
	}

	size_t ind = fileListLocation.find_last_of("\\");
	std::string root = fileListLocation.substr(0,ind);
	//printf("%s\n",root.c_str());
	gImageTiffs.reserve(metadataFiles.size());
	for (int i=0; i<metadataFiles.size(); ++i)
	{
		std::string mf = root;
		mf += "\\";
		mf += metadataFiles[i];
		mf += "\\";
		mf += metadataFiles[i];
		mf += ".txt";
		printf("%s\n",mf.c_str());
		ImagesTiff* im = new ImagesTiff(mf);
		if (im->getDatasetName()!="" && im->getNumberOfChannels()!=0 && im->getNumberOfFrames()!=0)
			gImageTiffs.push_back(im);
		else
			delete im;
	}

	preProcessImages(root);

	for (int i = 0; i < gImageTiffs.size() ; i++)
		delete gImageTiffs[i];

	printf("\nDONE\n");
	std::cin >> q;
	return 0;
}
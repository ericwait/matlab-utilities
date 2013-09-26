#include "PreProcessImages.cuh"
#include "main.h"
#include "CudaImageBuffer.cuh"

int numGpus = 1;
std::vector<std::vector<int>> unmixChannels;

void preProcessImages(std::string root)
{
	//TODO: implement this for multiple frames
	int gpuNumber = 0;
	std::vector<CudaImageBuffer<PixelType>> cudaBuffers;
	cudaBuffers.resize(gImageTiffs[0]->getNumberOfChannels(),CudaImageBuffer<PixelType>(gImageTiffs[0]->getSizes(),gpuNumber));

	for (int curVolume=0; curVolume<gImageTiffs.size(); ++curVolume)
	{
		for (unsigned int frame=0; frame<gImageTiffs[curVolume]->getNumberOfFrames(); ++frame)
		{
			//load all of the channel data onto the card
			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				cudaBuffers[chan].loadImage(gImageTiffs[curVolume]->getConstImageData(chan,frame));
			}

			//loop through all the images that are to be unmixed
			for (int currentChannel=0; currentChannel<unmixChannels.size(); ++currentChannel)
			{
				CudaImageBuffer<PixelType> curChan = cudaBuffers[currentChannel];
				for (int subtractChannel=0; subtractChannel<unmixChannels[currentChannel].size(); ++subtractChannel)
				{
					curChan.unmix(&cudaBuffers[unmixChannels[currentChannel][subtractChannel]]);
				}
				ImageContainer* hostBuffer = gImageTiffs[curVolume]->getImage(currentChannel,frame);
				hostBuffer->loadImage(curChan.retrieveImage());
			}
		}
	}


	//save images back out
	char directry[255];
	char path[255];
	for (int curVolume=0; curVolume<gImageTiffs.size(); ++curVolume)
	{
		sprintf_s(directry,"%s\\processed\\%s",root.c_str(),gImageTiffs[curVolume]->getDatasetName().c_str());
		if (!pathCreate(directry))
		{
			fprintf(stderr,"Could not open %s!\n",directry);
			continue;
		}

		for (unsigned int frame=0; frame<gImageTiffs[curVolume]->getNumberOfFrames(); ++frame)
		{
			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				sprintf_s(path,"%s\\%s_c%d_t%04d_z%s",directry,gImageTiffs[curVolume]->getDatasetName().c_str(),chan+1,frame+1,"%04d");
				writeImage(gImageTiffs[curVolume]->getImage(chan,frame),path);
			}
		}
	}
}
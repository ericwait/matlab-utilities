#include "PreProcessImages.cuh"
#include "main.h"
#include "CudaImageBuffer.cuh"

int numGpus = 1;
std::vector<int> unmixChannels;

void preProcessImages(std::string proccesedPath)
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
				CudaImageBuffer<PixelType>* curChan = &cudaBuffers[unmixChannels[currentChannel]];
				for (int subtractChannel=0; subtractChannel<unmixChannels.size(); ++subtractChannel)
				{
					if (subtractChannel==currentChannel)
						continue;

					curChan->addImageWith(&cudaBuffers[unmixChannels[subtractChannel]],-1.0);
				}
			}

			//get image data from the card back into host memory
			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				ImageContainer* hostBuffer = gImageTiffs[curVolume]->getImage(chan,frame);
				hostBuffer->loadImage(cudaBuffers[chan].retrieveImage());
			}
		}
	}


	//save images back out
	char directry[255];
	char path[255];
	for (int curVolume=0; curVolume<gImageTiffs.size(); ++curVolume)
	{
		sprintf_s(directry,"%s\\processed\\%s",proccesedPath,gImageTiffs[0]->getDatasetName().c_str());
		if (!pathCreate(directry))
		{
			fprintf(stderr,"Could not open %s!\n",directry);
			continue;
		}

		for (unsigned int frame=0; frame<gImageTiffs[curVolume]->getNumberOfFrames(); ++frame)
		{
			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				sprintf_s(path,"%s\\%s_c%d_t%04d_z%s",directry,gImageTiffs[0]->getDatasetName(),chan,frame,"%04d");
				writeImage(gImageTiffs[curVolume]->getImage(chan,frame),path);
			}
		}
	}
}
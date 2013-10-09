#include "PreProcessImages.cuh"
#include "main.h"
#include "CudaImageBuffer.cuh"

int numGpus = 1;
std::vector<std::vector<int>> unmixChannels;

void preProcessImages(std::string root)
{
	//TODO: implement this for multiple frames
	char directry[255];
	char path[255];
	int gpuNumber = 0;
	std::vector<CudaImageBuffer<PixelType>> cudaBuffers;
	cudaBuffers.resize(gImageTiffs[0]->getNumberOfChannels(),CudaImageBuffer<PixelType>(gImageTiffs[0]->getSizes(),gpuNumber));
	float sigma = 50.0f;
	Vec<float>sigmas(sigma,sigma,sigma/3.0);
	time_t start, end;

	for (int curVolume=0; curVolume<gImageTiffs.size(); ++curVolume)
	{
		time(&start);
		printf("(%04.2f%% of %d) Working on %s, ",(float)curVolume/gImageTiffs.size()*100.0f,gImageTiffs.size(),
			gImageTiffs[curVolume]->getDatasetName().c_str());

		for (unsigned int frame=0; frame<gImageTiffs[curVolume]->getNumberOfFrames(); ++frame)
		{
			printf("%d,",frame);
			//load all of the channel data onto the card
			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				cudaBuffers[chan].loadImage(gImageTiffs[curVolume]->getConstImageData(chan,frame));
			}

			for (int chan=0; chan<gImageTiffs[curVolume]->getNumberOfChannels(); ++chan)
			{
				printf("%d...",chan);
				cudaBuffers[chan].contrastEnhancement(sigmas,Vec<unsigned int>(5,5,3));

				if (!unmixChannels.empty())
				{
					for (int subtractChannel=0; subtractChannel<unmixChannels[chan].size(); ++subtractChannel)
						cudaBuffers[chan].unmix(&cudaBuffers[unmixChannels[chan][subtractChannel]],Vec<unsigned int>(5,5,3));
				}

				ImageContainer* hostBuffer = gImageTiffs[curVolume]->getImage(chan,frame);
				hostBuffer->loadImage(cudaBuffers[chan].retrieveImage());
			}
			time(&end);
			double tm = difftime(end,start);
			
			printf(" Done in %5.2f sec\n",tm);
		}
	}


	//save images back out
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
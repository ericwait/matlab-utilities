#pragma once

#include <vector>

extern int numGpus;
extern std::vector<std::vector<int>> unmixChannels;

void preProcessImages(std::string proccesedPath, int device=0);
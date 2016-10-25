function memSize = GetImageSetSizeInBytes(metaData,typeStr)
    dataTypeLookup = {'uint8';'uint16';'uint32';'uint64';
                  'int8';'int16';'int32';'int64';
                  'single';'double';
                  'logical'};

    dataTypeSize = [1;2;4;8;
                    1;2;4;8;
                    4;8;
                    1];

	if (exist('typeStr','var') || ~isempty(typeStr))
		byteIdx = strcmp(typeStr,dataTypeLookup);
	else
		byteIdx = strcmp(metaData.PixelFormat,dataTypeLookup);
	end

	voxelBytes = dataTypeSize(byteIdx);

    imSize = prod([metaData.Dimensions(1),metaData.Dimensions(2),metaData.Dimensions(3),metaData.NumberOfChannels,metaData.NumberOfFrames]);

    memSize = imSize * voxelBytes;
end

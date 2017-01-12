function [] = ExportAtlasJSON(outputPath, imData)

    fout = fopen(fullfile(outputPath,sprintf('%s_images.json',imData.DatasetName)),'w');
    fprintf(fout,'{\n\t');
    fprintf(fout,'"DatasetName" : "%s",\n\t',imData.DatasetName);
    fprintf(fout,'"isEmpty" : %d,\n\t',imData.isEmpty);
    fprintf(fout,'"XLocation" : %d,\n\t',imData.XLocation);
    fprintf(fout,'"YLocation" : %d,\n\t',imData.YLocation);
    fprintf(fout,'"Level" : %d,\n\t',imData.Level);
    fprintf(fout,'"Reduction" : %f,\n\t',imData.Reduction);
    fprintf(fout,'"NumberOfChannels" : %d,\n\t',imData.NumberOfChannels);
    fprintf(fout,'"NumberOfFrames" : %d,\n\t',imData.NumberOfFrames);
    fprintf(fout,'"NumberOfPartitions" : 1,\n\t');
%     if (exist(fullfile(inputPath,'Processed',sprintf('%s_Segmenation.mat',imData.DatasetName)),'file'))
%         fprintf(fout, '"BooleanHulls" : true,\n\t');
%     else
%         fprintf(fout, '"BooleanHulls" : false,\n\t');
%     end
        
    fprintf(fout,'"XDimension" : %d,\n\t',imData.XDimension);
    fprintf(fout,'"YDimension" : %d,\n\t',imData.YDimension);
    fprintf(fout,'"ZDimension" : %d,\n\t',imData.ZDimension);
    fprintf(fout,'"XPixelPhysicalSize" : %f,\n\t',imData.XPixelPhysicalSize);
    fprintf(fout,'"YPixelPhysicalSize" : %f,\n\t',imData.YPixelPhysicalSize);
    fprintf(fout,'"ZPixelPhysicalSize" : %f,\n\t',imData.ZPixelPhysicalSize);
    fprintf(fout,'"PaddingSize" : %d,\n\t',imData.PaddingSize);
    
    
    if(imData.isEmpty ~= 1)
        fprintf(fout,'"NumberOfImagesWide" : %d,\n\t',imData.numImInX);
        fprintf(fout,'"NumberOfImagesHigh" : %d,\n\t',imData.numImInY);       
%         colors = MicroscopeData.Colors.GetChannelColors(imData); 


    end
    
    colors = imData.ChannelColors;

    fprintf(fout,'"ChannelColors" : [');
    for c=1:imData.NumberOfChannels
        fprintf(fout,'"#%02X%02X%02X"',floor(colors(c,1)*255),floor(colors(c,2)*255),floor(colors(c,3)*255));
        if (c~=imData.NumberOfChannels)
            fprintf(fout,',');
        end
    end
    fprintf(fout,']\n}\n');
    fclose(fout);
end
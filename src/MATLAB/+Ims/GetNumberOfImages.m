function num_im = GetNumberOfImages(ims_file_path)
    num_im = Ims.GetAttValue(ims_file_path,'/DataSetInfo/ImarisDataSet','NumberOfImages');
end
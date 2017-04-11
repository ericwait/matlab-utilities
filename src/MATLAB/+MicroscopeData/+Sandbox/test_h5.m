file_id = H5F.open('P:\H5\Conrad\TL0058_Pos21.h5','H5F_ACC_RDONLY','H5P_DEFAULT');

MicroscopeData.Sandbox.traverse_h5(file_id,true);

H5F.close(file_id);

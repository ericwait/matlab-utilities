function [] = createDataList(Path)   

% Json = MicroscopeData.ReadMetadataFile(fullfile(Path, 'List.json'));
% List = Json(1).List;
% Paths = [List{:}];
% 
% for i = 1:length(Paths)
% Path = Paths(i).Path;
% Roots{i} = Paths(i).Path(1:strfind(Path,'/')-1);  
% Sub{i} = Paths(i).Path(strfind(Path,'/')+1:end);    
% end     
% 
% newList = [];
% for i= 1:length(Paths)
% newList = setfield(newList,Roots,Sub);
% end
    % Overwrite old List.json file
    if (exist(fullfile(Path, 'List.json'),'file'))
        fout = fopen(fullfile(Path, 'List.json'),'w'); 
        fprintf(fout,'{\n\t');
        fclose(fout);
    end
    
    folders = dir([Path, '\']);
    FolderIndex = find([folders.isdir]);
    % get rid of '.' and '..'
    if length(FolderIndex) > 1
        FolderIndex(1:2) = [];
    end
    
    fout = fopen(fullfile(Path, 'List.json'),'at');
    fprintf(fout,'"List" : [\n');
    for i = 1:length(FolderIndex)
        subFilesName = folders(FolderIndex(i)).name;
        % skip Montage folders
        if(~strcmp(subFilesName, 'Montage') && ~strcmp(subFilesName, 'foot') && ~strcmp(subFilesName, '150902_DBTH_H2BGFP'))
            subFolders = dir([Path, '\', subFilesName]);
			
			% get rid of '.' and '..'
            subFoldersIndex = find([subFolders.isdir]);
            subFoldersIndex(1:2) = [];

            for j = 1:length(subFoldersIndex)
                datasetName = subFolders(subFoldersIndex(j)).name;
                if(~strcmp( datasetName, 'track')) % skip track folder                   
                    fprintf(fout,'\n\t{\n');
                    fprintf(fout,'\t"Path" : "%s"\n',[subFilesName, '/', datasetName]);
                    fprintf(fout,'\n\t}');
                    if(i < length(FolderIndex))
                        fprintf(fout,',\n');   
                    end
                end
            end
        end
    end
    fprintf(fout,']\n}\n');
    fclose(fout);
end

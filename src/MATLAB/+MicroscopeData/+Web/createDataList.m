function [] = createDataList(Path)
    if (~exist('Path','var') || isempty(Path))
        Path = uigetdir('B:\Users\Bingyao\Documents\git\clone-view-3d\src\javascript\experiments','Choose the Directory');            
    end
    
    
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

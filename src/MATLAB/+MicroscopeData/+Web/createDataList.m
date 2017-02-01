function [] = createDataList(Path)   

List = [];
ProjectList = dir(Path);
n=1;
for i = 1:length(ProjectList)
    if length(ProjectList(i).name)<3 || ~ProjectList(i).isdir; continue;  end
    ExpList = dir(fullfile(ProjectList(i).folder,ProjectList(i).name));
    List(n).Project=ProjectList(i).name;
    nn=1;
    for ii = 1:length(ExpList)
        if length(ExpList(ii).name)<3 || ~ExpList(ii).isdir; continue;  end
        List(n).Experiments{nn} = ExpList(ii).name; 
        nn= nn+1;
    end
    n= n+1;
end
% 
jsonMetadata = Utils.CreateJSON(List);
fileHandle = fopen(fullfile(Path,'List.json'),'wt');
fwrite(fileHandle, jsonMetadata, 'char');
fclose(fileHandle);



%     % Overwrite old List.json file
%     if (exist(fullfile(Path, 'List.json'),'file'))
%         fout = fopen(fullfile(Path, 'List.json'),'w'); 
%         fprintf(fout,'{\n\t');
%         fclose(fout);
%     end   
%     folders = dir([Path, '\']);
%     FolderIndex = find([folders.isdir]);
%     % get rid of '.' and '..'
%     if length(FolderIndex) > 1
%         FolderIndex(1:2) = [];
%     end
%     
%     fout = fopen(fullfile(Path, 'List.json'),'at');
%     fprintf(fout,'"List" : [\n');
%     for i = 1:length(FolderIndex)
%         subFilesName = folders(FolderIndex(i)).name;
%         % skip Montage folders
%         if(~strcmp(subFilesName, 'Montage') && ~strcmp(subFilesName, 'foot') && ~strcmp(subFilesName, '150902_DBTH_H2BGFP'))
%             subFolders = dir([Path, '\', subFilesName]);
% 			
% 			% get rid of '.' and '..'
%             subFoldersIndex = find([subFolders.isdir]);
%             subFoldersIndex(1:2) = [];
% 
%             for j = 1:length(subFoldersIndex)
%                 datasetName = subFolders(subFoldersIndex(j)).name;
%                 if(~strcmp( datasetName, 'track')) % skip track folder                   
%                     fprintf(fout,'\n\t{\n');
%                     fprintf(fout,'\t"Path" : "%s"\n',[subFilesName, '/', datasetName]);
%                     fprintf(fout,'\n\t}');
%                     if(i < length(FolderIndex))
%                         fprintf(fout,',\n');   
%                     end
%                 end
%             end
%         end
%     end
%     fprintf(fout,']\n}\n');
%     fclose(fout);
end

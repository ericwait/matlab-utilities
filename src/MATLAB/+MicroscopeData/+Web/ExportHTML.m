function [] = ExportHTML(outputPath, sanitizedDdataPath, datasetName)
    fout = fopen(fullfile(outputPath,sprintf('index.html')),'w');
    fprintf(fout,'<!DOCTYPE html>\n');
    fprintf(fout,'<html>\n');
    fprintf(fout,'<head lang="en">\n');
    fprintf(fout,'\t<meta charset="UTF-8">\n');
    fprintf(fout,'\t<title></title>\n');
    fprintf(fout,'</head>\n');
    fprintf(fout,'<body>\n');
    fprintf(fout,'<script type="text/javascript">\n');
    fprintf(fout,'\tvar fullpath = window.location.pathname;\n');
    fprintf(fout,'\tvar indices = [];\n');
    fprintf(fout,'\tfor(var i = 0; i < fullpath.length; i++) {\n');
    fprintf(fout,'\t\tif(fullpath[i] == ''/'') {\n');
    fprintf(fout,'\t\t\tindices.push(i);\n');
    fprintf(fout,'\t\t}\n');
    fprintf(fout,'\t}\n');
    fprintf(fout,'\tvar path = fullpath.substring(0, indices[indices.length-3]);\n');
    fprintf(fout,'\twindow.location.href = "http://" + window.location.host + path + "/?%s/%s";\n', sanitizedDdataPath, datasetName);
    fprintf(fout,'</script>\n');
    fprintf(fout,'</body>\n');
    fprintf(fout,'</html>\n');
    fclose(fout);
end

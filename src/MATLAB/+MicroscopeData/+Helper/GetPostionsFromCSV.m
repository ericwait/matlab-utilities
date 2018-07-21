function posData_xyz = GetPostionsFromCSV(fPath)

f = fopen(fPath,'r');

tline = fgetl(f);
posData_xyz = zeros(1,3);
while ischar(tline)
    result = regexpi(tline,'Information\|Image\|V\|View\|Position(\w) #(\d+),(-?[0-9.]+)','tokens');
    if ~isempty(result)
        tileNumber = str2double(result{1,1}{1,2});
        dim = result{1,1}{1,1};
        val = str2double(result{1,1}{1,3});
        switch dim
            case 'X'
                posData_xyz(tileNumber,1) = val;
            case 'Y'
                posData_xyz(tileNumber,2) = val;
            case 'Z'
                posData_xyz(tileNumber,3) = val;
        end
        %fprintf('#%d %s %f\n',tileNumber, dim, val);
    end
    tline = fgetl(f);
end

fclose(f);
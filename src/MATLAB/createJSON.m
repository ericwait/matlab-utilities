function json = createJSON(data)
    if ( isstruct(data) )
        json = writeObject(data,'');
    else
        json = writeArray(data,'');
    end
end

function json = writeObject(data, spacePrefix)
    fields = fieldnames(data);
    
    spacePad = '  ';
    
    fieldSep = ',';
    objJSON = '';
    
    fieldPrefix = [spacePrefix spacePad];
    for i=1:length(fields)
        if ( i == length(fields) )
            fieldSep = '';
        end
        
        elemPad = repmat(' ', 1,5+length(fields{i}));
        elemPrefix = [fieldPrefix elemPad];
        
        valJSON = writeValue(data.(fields{i}), elemPrefix);
        fieldJSON = sprintf('\n%s"%s" : %s%s', fieldPrefix, fields{i}, valJSON,fieldSep);
        
        objJSON = [objJSON fieldJSON];
    end
    
    json = sprintf('{%s\n%s}', objJSON,spacePrefix);
end

function json = writeArray(data, spacePrefix)
    if ( isnumeric(data) && (size(data,1) == numel(data)) )
        json = writeSingleLineArray(data);
        return;
    end

    spacePad = '  ';
    
    valSep = ',';
    arrayJSON = '';
    
    valuePrefix = [spacePrefix spacePad];
    for i=1:size(data,1)
        if ( i == size(data,1) )
            valSep = '';
        end
        
        arrayEntry = squashSelect(data, i);
        if ( numel(arrayEntry) == 1 )
            if ( iscell(arrayEntry) )
                valJSON = writeValue(arrayEntry{1}, valuePrefix);
            else
                valJSON = writeValue(arrayEntry, valuePrefix);
            end
        else
            valJSON = writeArray(arrayEntry, valuePrefix);
        end
        
        arrayJSON = [arrayJSON sprintf('\n%s%s%s', valuePrefix, valJSON, valSep)];
    end
    
    json = sprintf('[%s\n%s]', arrayJSON,spacePrefix);
end

function arrayEntry = squashSelect(arrayData, i)
    if ( ndims(arrayData) == 1 )
        arrayEntry = arrayData(i);
        return;
    end
    
    dimSizes = size(arrayData);
    if ( length(dimSizes) < 3 )
        dimSizes = [dimSizes 1];
    end
    
    arrayEntry = reshape(arrayData(i,:), dimSizes(2:end));
end

function json = writeSingleLineArray(data)
    valSep = ', ';
    arrayJSON = '';
    for i=1:length(data)
        if ( i == length(data) )
            valSep = '';
        end
        
        valJSON = writeValue(data(i),'');
        arrayJSON = [arrayJSON sprintf('%s%s', valJSON,valSep)];
    end
    json = sprintf('[%s]', arrayJSON);
end

function json = writeValue(data, spacePrefix)
    if ( ischar(data) )
        json = sprintf('"%s"',escapeString(data));
    elseif ( iscell(data) || any(size(data) > 1) )
        json = writeArray(data, spacePrefix);
    elseif ( isstruct(data) )
        json = writeObject(data, spacePrefix);
    elseif ( islogical(data) )
        if ( data )
            json = 'true';
        else
            json = 'false';
        end
    elseif ( isempty(data) )
        json = 'null';
    elseif ( isnumeric(data) )
        json = num2str(data);
    else
        ME = MException('json:save','Cannot save unsupported type');
        ME.throw;
    end
end

function quotedStr = escapeString(inStr)
    escChars = {'\' '"' char(8) char(12) char(10) char(13) char(9)};
    escStr = {'\\' '\"','\b','\f','\n','\r','\t'};
    
    escMap = containers.Map(escChars,escStr);
    
    quotedStr = '';
    for i=1:length(inStr)
        nextChar = inStr(i);
        if ( isKey(escMap,nextChar) )
            nextChar = escMap(nextChar);
        end
        
        quotedStr = [quotedStr nextChar];
    end
end

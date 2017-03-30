function json = CreateJSON(data,bWhitespace)
    if ( ~exist('bWhitespace','var') )
        bWhitespace = true;
    end
    
    spaceStruct = struct('line',{''}, 'space',{''}, 'indent',{''});
    if ( bWhitespace )
        spaceStruct = struct('line',{'\n'}, 'space',{' '}, 'indent',{'  '});
    end
    
    if ( isstruct(data) )
        json = writeObject(data,'', spaceStruct);
    else
        json = writeArray(data,'', spaceStruct);
    end
end

function json = writeObject(data, spacePrefix, spaceStruct)
    fields = fieldnames(data);
    
    fieldSep = ',';
    objJSON = '';
    
    fieldPattern = ['%s"%s"' spaceStruct.space ':' spaceStruct.space '%s%s'];
    patternPad = length(sprintf(fieldPattern,'','','',''));
    
    fieldPrefix = [spacePrefix spaceStruct.indent];
    for i=1:length(fields)
        if ( i == length(fields) )
            fieldSep = '';
        end
        
        elemPad = repmat(spaceStruct.space, 1,patternPad+length(fields{i}));
        elemPrefix = [fieldPrefix elemPad];
        
        valJSON = writeValue(data.(fields{i}), elemPrefix, spaceStruct);
        fieldJSON = sprintf([spaceStruct.line fieldPattern], fieldPrefix, fields{i}, valJSON,fieldSep);
        
        objJSON = [objJSON fieldJSON];
    end
    
    objectPattern = ['{%s' spaceStruct.line '%s}'];
    json = sprintf(objectPattern, objJSON,spacePrefix);
end

function [json,bSingleLine] = writeArray(data, spacePrefix, spaceStruct)
    bSingleLine = false;
    if ( isnumeric(data) && (size(data,1) == numel(data)) )
        bSingleLine = true;
        json = writeSingleLineArray(data, spaceStruct);
        return;
    end
    
    valSep = ',';
    arrayJSON = '';
    
    valPattern = '%s%s%s';
    
    valuePrefix = [spacePrefix spaceStruct.indent];
    for i=1:size(data,1)
        if ( i == size(data,1) )
            valSep = '';
        end
        
        arrayEntry = squashSelect(data, i);
        if ( numel(arrayEntry) == 1 )
            if ( iscell(arrayEntry) )
                valJSON = writeValue(arrayEntry{1}, valuePrefix, spaceStruct);
            else
                valJSON = writeValue(arrayEntry, valuePrefix, spaceStruct);
            end
        else
            [valJSON,bSingleLine] = writeArray(arrayEntry, valuePrefix, spaceStruct);
        end
        
        % Combine brackets on one line if all the root array is a single line
        if ( bSingleLine && (size(data,1) == 1) )
            json = sprintf('[%s]',valJSON);
            return
        else
            arrayJSON = [arrayJSON sprintf([spaceStruct.line valPattern], valuePrefix, valJSON, valSep)];
        end
    end
    
    arrayPattern = ['[%s' spaceStruct.line '%s]'];
    json = sprintf(arrayPattern, arrayJSON,spacePrefix);
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

function json = writeSingleLineArray(data, spaceStruct)
    valSep = [',' spaceStruct.space];
    arrayJSON = '';
    for i=1:length(data)
        if ( i == length(data) )
            valSep = '';
        end
        
        valJSON = writeValue(data(i),'', spaceStruct);
        arrayJSON = [arrayJSON sprintf('%s%s', valJSON,valSep)];
    end
    json = sprintf('[%s]', arrayJSON);
end

function json = writeValue(data, spacePrefix, spaceStruct)
    if ( ischar(data) )
        json = sprintf('"%s"',escapeString(data));
    elseif ( iscell(data) || any(size(data) > 1) )
        json = writeArray(data, spacePrefix, spaceStruct);
    elseif ( isstruct(data) )
        json = writeObject(data, spacePrefix, spaceStruct);
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
    escChars = {char(0) '\' '"' char(8) char(12) char(10) char(13) char(9)};
    escStr = {'' '\\' '\"','\b','\f','\n','\r','\t'};
    
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

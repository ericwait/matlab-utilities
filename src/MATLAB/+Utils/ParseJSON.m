% Utils.ParseJson - Parse JSON formatted text into matlab arrays/structures
%   data = Utils.ParseJson(json, varargin)
%
% Inputs:
%   json - Text to be parsed
%
% Optional Parameters:
%   'StructArrays' - Automatically convert cell arrays of structures (with same field layout)
%                    into array of structure elements (default: true)

function data = ParseJSON(json, varargin)
    %% Parse optional parameters
    p = inputParser();
    addParameter(p, 'StructArrays',true, @islogical);
    
    parse(p,varargin{:});
    args = p.Results;

    %% Begin parsing json
    quoteIdx = regexp(json,'\"', 'start');
    escStart = regexp(json,'\\([/\"\\bfnrt]|u[a-fA-F\d]{4})', 'start');
    
    strQuotes = setdiff(quoteIdx,escStart+1);
    quoteMap = containers.Map(strQuotes(1:end-1),strQuotes(2:end));
    
    parsePos = ignoreSpace(json,1);
    assertChar('parse', {'{','['}, json,parsePos);
    
    if ( json(parsePos) == '{' )
        [data,parsePos] = parseObjectJSON(json,parsePos+1, quoteMap);
    elseif ( json(parsePos) == '[' )
        [data,parsePos] = parseArrayJSON(json,parsePos+1, quoteMap);
    end
    
    % TODO: Error handling for parsepos ~= EOF
    
    data = postprocessObjects(data, args);
end

function [objData,parsePos] = parseObjectJSON(json, startPos, quoteMap)
    parsePos = ignoreSpace(json,startPos);
    
    objData = [];
    assertInStr('parseObject', '''STRING'' or ''}''', json, parsePos);
    if ( json(parsePos) == '}' )
        parsePos = ignoreSpace(json,parsePos+1);
        return;
    end
    
    while ( parsePos <= length(json) )
        assertChar('parseObject', '"', json,parsePos);
        [keyStr,parsePos] = parseStringJSON(json,parsePos, quoteMap);
        
        assertChar('parseObject', ':', json,parsePos);
        [value,parsePos] = parseValueJSON(json,parsePos+1, quoteMap);
%         if ( isempty(value) )
%             throwError('parseObject','Expecting ''STRING'', ''NUMBER'', ''NULL'', ''TRUE'', ''FALSE'', ''{'', ''[''', json, parsePos);
%         end
        
        objData.(validFieldName(keyStr)) = value;
        
        assertInStr('parseObject', '''}''', json, parsePos);
        if ( json(parsePos) == '}' )
            parsePos = ignoreSpace(json,parsePos+1);
            return;
        end
        
        assertChar('parseObject', {',','}'}, json,parsePos);
        parsePos = ignoreSpace(json,parsePos+1);
    end
    
    throwError('parseObject','Expecting closing ''}''', json, parsePos);
end

function [arrayData,parsePos] = parseArrayJSON(json, startPos, quoteMap)
    parsePos = ignoreSpace(json,startPos);
    
    arrayData = cell(0,1);
    if ( json(parsePos) == ']' )
        parsePos = ignoreSpace(json,parsePos+1);
        return;
    end
    
    while ( parsePos <= length(json) )
        [value,parsePos] = parseValueJSON(json,parsePos, quoteMap);
%         if ( isempty(value) )
%             throwError('parseArray','Expecting ''STRING'', ''NUMBER'', ''NULL'', ''TRUE'', ''FALSE'', ''{'', ''[''', json, parsePos);
%         end
        
        arrayData{end+1} = value;
        
        assertInStr('parseArray', ''']''', json, parsePos);
        if ( json(parsePos) == ']' )
            parsePos = ignoreSpace(json,parsePos+1);
            return;
        end
        
        assertChar('parseArray', {',',']'}, json,parsePos);
        
        parsePos = ignoreSpace(json,parsePos+1);
    end
    
    throwError('parseArray','Expecting closing '']''', json, parsePos);
end

function [valueData,parsePos] = parseValueJSON(json, startPos, quoteMap)
    parsePos = ignoreSpace(json,startPos);
    
    assertInStr('parseValue', '''STRING'', ''NUMBER'', ''NULL'', ''TRUE'', ''FALSE'', ''{'', ''[''', json, parsePos);
    chkChar = json(parsePos);
    
    keywordMap = {'true',true; 'false',false; 'null',[]};
    
    switch(chkChar)
        case '['
            [valueData,parsePos] = parseArrayJSON(json,parsePos+1, quoteMap);
        case '{'
            [valueData,parsePos] = parseObjectJSON(json,parsePos+1, quoteMap);
        case '"'
            [valueData,parsePos] = parseStringJSON(json,parsePos, quoteMap);
        case {'-','0','1','2','3','4','5','6','7','8','9'}
            [valueData,parsePos] = parseNumberJSON(json,parsePos);
        otherwise
            for i=1:size(keywordMap,1)
                [bMatched,parsePos] = matchKeyword(json,parsePos,keywordMap{i,1});
                if ( bMatched )
                    valueData = keywordMap{i,2};
                    return;
                end
            end
            throwError('parseValue','Expecting ''STRING'', ''NUMBER'', ''NULL'', ''TRUE'', ''FALSE'', ''{'', ''[''', json, parsePos);
    end
end

function [stringData,parsePos] = parseStringJSON(json, startPos, quoteMap)
    if ( ~isKey(quoteMap,startPos) )
        throwError('parseString','Expecting ''STRING''', json, startPos);
    end
    
    startQuote = startPos;
    endQuote = quoteMap(startPos);
    escapedStr = json(startQuote+1:endQuote-1);
    
    stringData = validExpandString(escapedStr, json, startPos);
    parsePos = ignoreSpace(json,endQuote + 1);
end

function [numberData,parsePos] = parseNumberJSON(json, startPos)
    % Recommended float string representation suggests a max of 24 chars (padded to 30)
    numPad = 30;
    chkEnd = min(startPos+numPad,length(json));
    
    matchStr = regexp(json(startPos:chkEnd),'^-?(0|[1-9]\d*)(\.\d+)?([eE][+-]?\d+)?', 'once','match');
    if ( isempty(matchStr) )
        throwError('parseNumber','Expecting ''NUMBER''', json, startPos);
    end
    
    numberData = str2double(matchStr);
    parsePos = ignoreSpace(json,startPos+length(matchStr));
end

function [bMatched,parsePos] = matchKeyword(json,parsePos, keywordStr)
    bMatched = false;
    if ( length(json) < parsePos+length(keywordStr) )
        return;
    end
    
    keywordEnd = parsePos+length(keywordStr)-1;
    if ( ~strcmpi(json(parsePos:keywordEnd), keywordStr) )
        return;
    end
    
    parsePos = ignoreSpace(json,keywordEnd+1);
    bMatched = true;
end

function fieldStr = validFieldName(inStr)
    fieldStr = inStr;
    bAlphaNum = isstrprop(inStr,'alphanum');
    fieldStr(~bAlphaNum) = '_';
    
    if ( ~isletter(fieldStr(1)) )
        fieldStr = ['s_' fieldStr];
    end
end

function expandStr = validExpandString(escapedStr, json,strPos)

    expandSeq = {'\b','\f','\n','\r','\t'};
    unescStart = regexp(escapedStr,['[' [expandSeq{:}] ']'], 'start');
    
    if ( ~isempty(unescStart) )
        throwError('parseString', 'Invalid character in string', json, strPos+unescStart(1));
    end
    
    unescQuoteStart = regexp(escapedStr, '[^\\]\"|^\"', 'start');
    if ( ~isempty(unescQuoteStart) )
        throwError('parseString', 'Invalid character in string', json, strPos+unescQuoteStart(1));
    end

    expandStr = '';
    bEscape = false;
    for i=1:length(escapedStr)
        expandChar = escapedStr(i);
        
        if ( bEscape )
            bEscape = false;
            if ( expandChar == 'u' )
                continue;
            end
            
            if ( ~any(expandChar == '\"bfnrt/') )
                throwError('parseString', 'Invalid escape sequence in string', json, strPos+i);
            end
            
            expandChar = sprintf(['\' expandChar]);
        elseif ( expandChar == '\' )
            bEscape = true;
            continue;
        end
        
        expandStr(end+1) = expandChar;
    end
end

function dataOut = postprocessObjects(dataEntry, args)
    if ( isstruct(dataEntry) )
        fields = fieldnames(dataEntry);
        for i=1:length(fields)
            dataEntry.(fields{i}) = postprocessObjects(dataEntry.(fields{i}), args);
        end
    elseif ( iscell(dataEntry) )
        dataEntry = postprocessArrays(dataEntry, args);
    end
    
    dataOut = dataEntry;
end

function dataEntry = postprocessArrays(dataEntry, args)
    finalDims = length(dataEntry);
    
    [bCanExpand,expandDims] = checkExpandArray(dataEntry);
    %% Force column array if it's not further expandable
    if ( ~bCanExpand )
        finalDims = [finalDims 1];
    end
    
    %% Recursively flatten array keeping track of dimensions
    while ( bCanExpand )
        dataEntry = reshape(dataEntry, numel(dataEntry),1);
        dataEntry = vertcat(dataEntry{:});
        
        finalDims = [finalDims expandDims];
        [bCanExpand,expandDims] = checkExpandArray(dataEntry);
    end
    
    %% Always recursively post-process sub-objects after array expansion
    for i=1:numel(dataEntry)
        dataEntry{i} = postprocessObjects(dataEntry{i}, args);
    end
    
    %% Convert array to final dimensions
    dataEntry = reshape(dataEntry, finalDims);
    
    %% Check if types are trivially mergeable using cell2mat
    bMerge = checkMergeCells(dataEntry, args.StructArrays);
    if ( bMerge )
        dataEntry = cell2mat(dataEntry);
    end
end

function [bCanExpand,expandDims] = checkExpandArray(cellArray)
    chkDims = unique(cellfun(@(x)(length(x)), cellArray(:)));
    
    chkTypes = cellfun(@(x)(class(x)), cellArray(:), 'UniformOutput',0);
    sharedType = getSharedType(chkTypes);
    
    bCanExpand = isscalar(chkDims) && strcmpi(sharedType,'cell');
    expandDims = chkDims;
end

function bMerge = checkMergeCells(cellArray, bStructArrays)
    bMerge = true;
    
    % TODO: Don't dump unit cell arrays?
    chkTypes = cellfun(@(x)(class(x)), cellArray(:), 'UniformOutput',0);
    sharedType = getSharedType(chkTypes);
    
    % Always merge numerical arrays
    if ( strcmpi(sharedType,'double') )
        return;
    end
        
    % Can also trivially merge structure arrays with exact same field layout
    if ( bStructArrays && strcmpi(sharedType,'struct') )
        chkFields = cellfun(@(x)(strjoin(fieldnames(x),',')), cellArray(:), 'UniformOutput',0);
        sharedFields = getSharedType(chkFields);
        if ( ~isempty(sharedFields) )
            return;
        end
    end
    
    bMerge = false;
end

function type = getSharedType(typeList)
    type = '';
    
    chkTypes = unique(typeList);
    if ( isscalar(chkTypes) )
        type = chkTypes{1};
    end
end 


function parsePos = ignoreSpace(json,startPos)
    for parsePos=startPos:length(json)
        if ( ~isspace(json(parsePos)) )
            return;
        end
    end
end

function assertInStr(type, expect, json, parsePos)
    if ( parsePos > length(json) )
        if ( isempty(expect) )
            throwError(type, 'Unexpected end of file', json, parsePos);
        else
            throwError(type, ['Unexpected end of file, expecting ' expect], json, parsePos);
        end
    end
end

function assertChar(type, charValue, json, parsePos)
    if ( ischar(charValue) )
        charValue = {charValue};
    end
    
    if ( parsePos > length(json) )
        throwError(type, makeAssertStr(charValue), json, parsePos)
    end
    
    for i=1:length(charValue)
        if ( json(parsePos) == charValue{i} )
            return;
        end
    end
    
    throwError(type,makeAssertStr(charValue), json, parsePos)
end

function errStr = makeAssertStr(charValues)
    errStr = 'Expecting';
    
    for i=1:length(charValues)-1
        errStr = [errStr ' ''' charValues{i} ''' or'];
    end
    
    errStr = [errStr ' ''' charValues{end} ''''];
end

function throwError(type,message, json, pos)
    contextPad = 5;
    contextStart = max(pos-contextPad,1);
    contextEnd = min(pos+3*contextPad,length(json));
    
    arrowPos = pos-contextStart;
    arrowSpace = repmat(' ',1,arrowPos);
    
    contextStr = json(contextStart:contextEnd);
    contextStr = strtok(contextStr, newline());
    
    ME = MException(['json:' type],'Parse error: %s\n\n%s\n%s^', message,contextStr,arrowSpace);
    ME.throw;
end

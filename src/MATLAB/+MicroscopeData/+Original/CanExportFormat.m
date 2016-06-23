% [bCanExport,guessType] = CanExportFormat(filenames)
% 
% bCanExport - True for all filenames that match a bioformats supported extension
% guessType - Cell arry of strings representing a guess at the associated file type

function [bCanExport,guessType] = CanExportFormat(filenames)
    exportFormats = MicroscopeData.Original.GetSupportedFormats();
    formatIdx = arrayfun(@(x,y)(repmat(y,length(x{1}),1)),exportFormats(:,2),(1:size(exportFormats,1)).', 'UniformOutput',false);
    
    allExt = vertcat(exportFormats{:,2});
    allIdx = vertcat(formatIdx{:});
    
    [chkExt,idxExt] = unique(allExt);
    chkIdx = allIdx(idxExt);
    
    % Can use strncmpi to quickly check extension matches on reversed filenames
    revExt = cellfun(@(x)(x(end:-1:1)),chkExt, 'UniformOutput',false);
    revNames = cellfun(@(x)(x(end:-1:1)),filenames, 'UniformOutput',false);
    
    bCanExport = false(length(filenames),1);
    guessType = cell(length(filenames),1);
    
    matchExt = cellfun(@(x)(find(strncmpi(revNames,x,length(x)))),revExt,'UniformOutput',false);
    matchFormatIdx = arrayfun(@(x,y)(repmat(y,length(x{1}),1)),matchExt,chkIdx,'UniformOutput',false);
    
    matchedIdx = vertcat(matchExt{:});
    matchedFormats = vertcat(matchFormatIdx{:});
    
    bCanExport(matchedIdx) = true;
    guessType(matchedIdx) = exportFormats(matchedFormats,1);
end

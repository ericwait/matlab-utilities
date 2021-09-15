function dirs = GetSubDirsWoWords(root_dir, word_array, opt_ext)

    if ~exist('opt_ext','var') || isempty(opt_ext)
        opt_ext = '*';
    end

    dirs = dir(fullfile(root_dir,'**',['*.', opt_ext]));

    dirs_names = {dirs.folder};

    for i=1:length(word_array)
        mask = cellfun(@(x)(isempty(x)),regexpi(dirs_names,word_array{i},'match'));
        dirs = dirs(mask);
        dirs_names = {dirs.folder};
    end
end

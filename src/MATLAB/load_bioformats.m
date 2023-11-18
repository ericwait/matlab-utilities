try
    reader = javaObject('loci.formats.in.FakeReader');
    return
catch
end

bioformats_dir = fullfile(userpath, "bfmatlab");
jar_path = fullfile(bioformats_dir, 'bioformats_package.jar');

if (~exist(jar_path, "file"))
    bioformat_zip_path = websave(fullfile(userpath, "bfmatlab.zip"), "https://downloads.openmicroscopy.org/bio-formats/latest/artifacts/bfmatlab.zip");
    unzip(bioformat_zip_path, userpath);
    delete(bioformat_zip_path);
end

javaaddpath(jar_path);
addpath(bioformats_dir);
fprintf("Loaded Bioformats from %s\n", jar_path);

function distinctColors = MakeColorblindSafePalette(baseColors, numColors)
    % First color in baseColors is fixed
    % Rest are used as style guides
    % numColors includes the fixed color

    if nargin < 2
        numColors = size(baseColors, 1);
    end

    anchorRGB = baseColors(1,:);
    otherBase = baseColors(2:end,:);
    
    % Generate candidate colors
    hsvBase = rgb2hsv(otherBase);
    nCandidates = 360;
    hueRange = linspace(0, 1, nCandidates);
    candidates = [];

    for i = 1:size(hsvBase,1)
        s = hsvBase(i,2);
        v = hsvBase(i,3);
        for h = hueRange
            rgb = hsv2rgb([h, s, v]);
            candidates = [candidates; rgb];
        end
    end

    % Convert all to LAB
    labAnchor = rgb2lab(anchorRGB);
    labCandidates = rgb2lab(candidates);

    % Initialize output
    selectedLAB = labAnchor;
    selectedRGB = anchorRGB;

    for k = 2:numColors
        % Compute min distance from selected set
        dists = pdist2(selectedLAB, labCandidates);
        minDists = min(dists, [], 1);
        [~, idx] = max(minDists);
        selectedLAB = [selectedLAB; labCandidates(idx,:)];
        selectedRGB = [selectedRGB; candidates(idx,:)];
    end

    distinctColors = selectedRGB;
end
function orgIdx = ShiftIdxBackOrg(orgSize_rc,subSize_rc,indexList,startCoords_rc)
%orgIdx = ImUtils.ROI.ShiftIdxBackOrg(orgSize_rc,subSize_rc,indexList,startCoords_rcz)
%   Detailed explanation goes here

if (islogical(indexList))
    indexList = find(indexList);
end

subCoords_rc = Utils.IndToCoord(subSize_rc,indexList);

subOrgCoords_rc = subCoords_rc + repmat(startCoords_rc-1, size(subCoords_rc,1),1);

orgIdx = Utils.CoordToInd(orgSize_rc,subOrgCoords_rc);
end

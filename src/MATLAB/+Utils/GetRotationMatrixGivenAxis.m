function [rotationRowMatix,rotationColMatrix] = GetRotationMatrixGivenAxis(vector_xyz)

    rotAx_xyz = cross(vector_xyz,[0,0,1]);
    signedAngle = atan2d(norm(rotAx_xyz),dot(vector_xyz,[0,0,1]));
    normRotAx_xyz = rotAx_xyz/norm(rotAx_xyz);
    normRotAxSq_xyz = normRotAx_xyz.^2;

    %% make easier to type var
    ux = normRotAx_xyz(1);
    uy = normRotAx_xyz(2);
    uz = normRotAx_xyz(3);
    u2x = normRotAxSq_xyz(1);
    u2y = normRotAxSq_xyz(2);
    u2z = normRotAxSq_xyz(3);
    cTh = cosd(signedAngle);
    sTh = sind(signedAngle);
    rotationRowMatix = [...
        cTh+u2x*(1-cTh),        uy*ux*(1-cTh)+uz*sTh,   uz*ux*(1-cTh)-uy*sTh,   0;
        ux*uy*(1-cTh)-uz*sTh,   cTh+u2y*(1-cTh),        uz*uy*(1-cTh)+ux*sTh,   0;
        ux*uz*(1-cTh)+uy*sTh,   uy*uz*(1-cTh)-ux*sTh,   cTh+u2z*(1-cTh),        0;
        0,                      0,                      0,                      1];

    rotationColMatrix = [...
        cTh+u2x*(1-cTh),        ux*uy*(1-cTh)-uz*sTh,   ux*uz*(1-cTh)+uy*sTh,   0;
        uy*ux*(1-cTh)+uz*sTh,   cTh+u2y*(1-cTh),        uy*uz*(1-cTh)-ux*sTh,   0;
        uz*ux*(1-cTh)-uy*sTh,   uz*uy*(1-cTh)+ux*sTh,   cTh+u2z*(1-cTh),        0;
        0,                      0,                      0,                      1];
end

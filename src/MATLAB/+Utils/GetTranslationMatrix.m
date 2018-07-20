function [translationRowMatrix,translationColMatrix] = GetTranslationMatrix(newCenter_xyz)
    translationRowMatrix = eye(4,4);
    translationRowMatrix(4,1:3) = newCenter_xyz;
    
    translationColMatrix = permute(translationRowMatrix,[2,1]);
end

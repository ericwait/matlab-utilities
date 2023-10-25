function D = ConcatenateUint8ToUint32(A, B, C)
    % Ensure the input matrices are uint8
    if ~isa(A, 'uint8') || ~isa(B, 'uint8') || ~isa(C, 'uint8')
        error('Input matrices must be of type uint8.');
    end
    
    % Ensure the dimensions match
    if any(size(A) ~= size(B)) || any(size(A) ~= size(C))
        error('All input matrices must have the same dimensions.');
    end
    
    % Convert each uint8 matrix to uint32
    A32 = uint32(A);
    B32 = uint32(B);
    C32 = uint32(C);
    
    % Perform bitwise shift and concatenation
    A32_shifted = bitshift(A32, 16);  % Shift bits 16 positions to the left
    B32_shifted = bitshift(B32, 8);   % Shift bits 8 positions to the left
    
    % Concatenate all three into one uint32 matrix using bitwise OR
    D = bitor(bitor(A32_shifted, B32_shifted), C32);
end

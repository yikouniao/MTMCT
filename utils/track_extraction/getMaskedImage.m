function masked = getMaskedImage(snapshot)

masked = uint8(zeros(size(snapshot)));

for i = 1:3
    
    A = snapshot(:,:,i);
    
    
    c = fix(size(A) / 2);   %# Ellipse center point (y, x)
    r_sq = c([2 1]) .^ 2;  %# Ellipse radii squared (y-axis, x-axis)
    [X, Y] = meshgrid(1:size(A, 2), 1:size(A, 1));
    ellipse_mask = (r_sq(2) * (X - c(2)) .^ 2 + ...
        r_sq(1) * (Y - c(1)) .^ 2 <= prod(r_sq));
    
    %# Apply the mask to the image
    A_cropped = bsxfun(@times, A, uint8(ellipse_mask));
    
    masked(:,:,i) = A_cropped;
    
end
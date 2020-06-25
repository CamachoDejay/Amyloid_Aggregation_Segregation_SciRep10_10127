function [ CM ] = centMass( im )
%CENTMASS Calculates the centre of mass of an image

im = double(im);

row = 1:size(im,1);
col = 1:size(im,2);

[C,R] = meshgrid(col,row);

CM_c = im .* C;
CM_c = sum(CM_c(:))/sum(im(:));

CM_r = im .* R;
CM_r = sum(CM_r(:))/sum(im(:));

CM = [CM_r, CM_c];

end


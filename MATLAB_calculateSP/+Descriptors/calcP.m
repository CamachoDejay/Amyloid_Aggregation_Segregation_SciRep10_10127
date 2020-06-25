function [P, PG, PR ] = calcP( G, R )
%CALCP P is an analog to the electric dipole, is used to distinguish between
%separated states from intermixed ones.
%   G: green channel image
%   R: red channel image

assert(all(G(:)>=0), 'problems with green channel');
assert(all(R(:)>=0), 'problems with green channel');
G = double(G);
R = double(R);

% normalize G
IM = G./sum(G(:));
% get P vals
Pvals = getVals (IM);
% sum all vals for G
PG = sum(Pvals,2);


% normalize and invert R
IM = R./sum(R(:));
IM = IM .* -1;
% get P vals
Pvals = getVals (IM);
% sum all vals for G
PR = sum(Pvals,2);

% calculate total area
agg = or(G>0, R>0);
A = sum(agg(:));

% calculate radius of a circle with same area
R = sqrt(A/pi);

% normalization by size
PG = PG./R;
PR = PR./R;

% calculate total P
P = PG + PR;
% get the norm of the P vector
P = norm(P);


end

function vals = getVals (M)

    M = double(M);
    nRow = size(M,1);
    nCol = size(M,2);
    vals = zeros(2,nRow*nCol);
    n = 0;
    for i = 1:nRow
        for j = 1:nCol
            n = n + 1;
            q = M(i,j);
            r = [i;j];
            Ptmp = q*r;
            vals(:,n) = Ptmp;
        end
    end

end


function [ S, sAmpG, sAmpR ] = calcS( G, R )
%CALCS P is an analog to ratio of scattering amplitudes, is used to distinguish
%between intermixed and evelope states.
%   G: green channel image
%   R: red channel image

% get image data
sAmpG = scattAmp(G);
sAmpR = scattAmp(R);
S = sAmpR / sAmpG;

end

function sAmp = scattAmp(im)

    im = double(im);
    % normalize im data
    im = im./sum(im(:));

    % get rows and col indices
    row = 1:size(im,1);
    col = 1:size(im,2);
    [C,R] = meshgrid(col,row);

    % Calculate center of mass of the image
    [ CM ] = Descriptors.centMass( im );

    % calculate displacement of each pixel from center of mass
    dR = R-CM(1);
    dC = C-CM(2);

    % calculate tensor of intertia
    % Ixx or in my case row row
    IrrM = im.*(dR.^2);
    Irr = sum(IrrM(:));
    % Iyy or in my case col col
    IccM = im.*(dC.^2);
    Icc = sum(IccM(:));
    % Ixy = Iyx or in my case row col
    IrcM = im.*dR.*dC;
    Irc = sum(IrcM(:));
    % calculate principal moment of inertia
    sqFactor = sqrt( (Irr - Icc)^2 + 4*Irc^2 );
    Imax = .5 *( Irr + Icc + sqFactor );
    Imin = .5 *( Irr + Icc - sqFactor );
    % calculate the scattering amplitude
    sAmp = sqrt( (Imin + Imax) /2 );
end

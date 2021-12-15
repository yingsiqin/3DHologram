close all; 
clc; 

% % define physical parameters (in m)
slmpitch = 3.47e-6; % slm pixel pitch
lambda = 520e-9;  % laser wavelength
mode = 'dpe';
numIter = 3;

% % desired hologram size (size of the slm)
numXpix = 3840;  
numYpix = 2160;
Hsize = [numYpix numXpix];

% z1 = 0.070;
% z2 = 0.080;
% fname = '../data/scenes/alphabetsbig.png';
% [HPdisp, IR1disp, IR2disp] = propagate2Depths(fname, z1, z2, ...
%                             slmpitch, lambda, mode, Hsize);

% [HPdisp, IR1disp, IR2disp] = propagate2DepthsIter(fname, z1, z2, ...
%                             slmpitch, lambda, mode, numIter);

Ifname = '../data/scenes/faceI.png';
Zfname = '../data/scenes/faceZ.png';
numdepths = 13;
warning off;
[HPdisp, IRdisp] = propagateMultiDepths(Ifname, Zfname, numdepths, ...
        slmpitch, lambda, mode, Hsize);
function [HPdisp, IRdisp] = propagateMultiDepths(Ifname, Zfname, ...
    numdepths, slmpitch, lambda, mode, Hsize)
% % take the file names of input image (intensity and depth map),  
% % discretized the depth map to numdepths depths, and computes 
% % a multi-depth hologram

    % read the image
    I = im2double(imread(Ifname));
    Z = im2double(imread(Zfname));
    [ylenI, xlenI] = size(I);
    [ylenZ, xlenZ] = size(Z);

    assert (ylenI==ylenZ)
    assert (xlenI==xlenZ)

    % discretize depth values into numbins
    [Zd, ~] = discretize(Z, numdepths);
%     zscale = 1/numdepths/10000;
    zscale = 1/numdepths/400;
    zoffset = 0.02;

    % set the size of the hologram
    ylenH = ylenI * 2; 
    xlenH = xlenI * 2;
    ystart = (ylenH-ylenI)/2;
    yend = (ylenH+ylenI)/2-1; 
    xstart = (xlenH-xlenI)/2;
    xend = (xlenH+xlenI)/2-1;

    % initialize a random phase constant at each pixel
    phi0 = 2*pi*rand(ylenI,xlenI); 
    I = I.*(cos(phi0)+1j*sin(phi0));

    % make an intensity image for each pixel
    % each image contains only content at that pixel

    I1 = zeros(ylenH,xlenH);
    H = zeros(ylenH,xlenH);
    IRdisp = zeros(numdepths, ylenI, xlenI);

    % forward propagation
    for z=1:numdepths
        % layer for this depth
        Itemp = zeros(size(I));
        Itemp(Zd==z) = I(Zd==z);
        I1(ystart:yend,xstart:xend) = Itemp;
        zd = z*zscale + zoffset;
        H1 = genHolo1Depth(I1, zd, slmpitch,lambda);
        H = H + H1;
    end    

    % encode amplitude in phase
    HP = encodeAmplitude(H, mode);
    
    % backward propagation
    % simulate the reconstruction of hologram at multiple depths
    savename = split(Ifname(1:end-4),"/");
    for z=1:numdepths
        zd = z*zscale + zoffset;
        IR1 = reconHoloAt1Depth(HP, zd, slmpitch, lambda);
        IR1 = IR1(ystart:yend, xstart:xend);
        IR1disp = mat2gray(abs(IR1)); 
        IRdisp(z,:,:) = IR1disp;
        imname1 = strcat('../data/reconstructions/sim_', ...
            string(savename(end)), '_', mode, '_d-', int2str(z),'.png');
        imwrite(IR1disp, imname1);
    end   
    
    % save the hologram
    HPdisp = mat2gray(angle(HP));
    Hscale = Hsize(1)/ylenH;
    HPdisp = imresize(HPdisp, Hscale);
    savename = strcat('../data/CGH/3DHologram_', ...
        string(savename(end)),'_',mode, ...
        '_numdepths-',int2str(numdepths),'.png');
    imwrite(HPdisp,savename);

    % display the hologram
    f1 = figure; 
    ax1 = axes(f1);
    imshow(HPdisp, 'Parent', ax1);
    title(ax1, strcat('phase-only CGH using',{' '}, mode,' method')); 

    % display the reconstructions
    f2 = figure;
    subplot 121
    imshow(abs(I));
    title('input intensity')
    subplot 122
    imshow(Zd/numdepths);
    title('input depth')

    f3 = figure;
    f3.Position = [100 100 2000 1600];
    numrows = floor(sqrt(numdepths));
    for i=1:numdepths
        if mod(numdepths,numrows)~=0
            numcols = round(numdepths/numrows)+1;
        else
            numcols = round(numdepths/numrows);
        end
        subplot(numrows,numcols,i)
        imshow(squeeze(IRdisp(i,:,:)));
        axis('off')
        title(strcat('d=',num2str(i*zscale+zoffset),'m'))
    end
    sgtitle("simulated reconstructions")

end

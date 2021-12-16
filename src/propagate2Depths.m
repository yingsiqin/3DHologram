function [HPdisp, IR1disp, IR2disp] = propagate2Depths(fname, z1, z2, ...
                                    slmpitch, lambda, mode, Hsize)
% % takes an intensity image, scale intensity vertically, and 
% % computes a 2-depth hologram

    % read the image
    I = imread(fname);
    I = rgb2gray(I);
    [ylenI, xlenI] = size(I);
    I = im2double(I);

    % scale intensity vertically
    intensityramp = (0:1/(size(I,1)-1):1)';
    Iamp = repmat(intensityramp,1,size(I,2));
    I_scaled = I.*Iamp;
    I = I_scaled;

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

    % make an intensity image for each depth
    % each image contains only content at that depth
    % left half of I is at depth z1, right half of I is at depth z2

    % first depth layer
    I1 = zeros(ylenH,xlenH);
    I1(ystart:yend,xstart:xend) = I(:,:);
    I1(:,xlenH/2+1:xlenH) = 0;

    % second depth layer 
    I2 = zeros(ylenH,xlenH);
    I2(ystart:yend,xstart:xend)=I(:,:);
    I2(:,1:xlenH/2)=0;

    % forward propagation
    H1 = genHolo1Depth(I1,z1,slmpitch,lambda);
    H2 = genHolo1Depth(I2,z2,slmpitch,lambda);
    H = H1 + H2;

    % encode amplitude in phase
    HP = encodeAmplitude(H, mode);
    
    % backward propagation
    % simulate the reconstruction of hologram at two depths
    IR1 = reconHoloAt1Depth(HP, z1, slmpitch, lambda);
    IR2 = reconHoloAt1Depth(HP, z2, slmpitch, lambda);
    IR1 = IR1(ystart:yend, xstart:xend);
    IR2 = IR2(ystart:yend, xstart:xend);
    IR1disp = mat2gray(abs(IR1)); 
    IR2disp = mat2gray(abs(IR2)); 
    savename = split(fname(1:end-4),"/");
    imname1 = strcat('../data/reconstructions/sim_', string(savename(end)), '_d1-',num2str(z1),'m_', mode, '.png');
    imname2 = strcat('../data/reconstructions/sim_', string(savename(end)), '_d2-',num2str(z2),'m_', mode, '.png');
    imwrite(IR1disp, imname1); 
    imwrite(IR2disp, imname2);
    
    % save the hologram
    HPdisp = mat2gray(angle(HP));
    Hscale = Hsize(1)/ylenH;
    HPdisp = imresize(HPdisp, Hscale);
    savename = strcat('../data/CGH/3DHologram_',string(savename(end)),'_2d_',mode,'.png');
    imwrite(HPdisp,savename);

    % display the hologram
    f1 = figure; 
    ax1 = axes(f1);
    imshow(HPdisp, 'Parent', ax1);
    title(ax1, strcat('phase-only CGH using',{' '},mode,' method')); 

    % display the reconstructions
    f2 = figure;
    ax2 = axes(f2);
    imshow(I_scaled, 'Parent', ax2);
    title(ax2, 'input image')
    
    f3 = figure;
    f3.Position = [100 100 1000 600];
    subplot 121
    imshow(IR1disp); 
    title(strcat('d=',num2str(z1),'m'));
    subplot 122
    imshow(IR2disp); 
    title(strcat('d=',num2str(z2),'m')); 
    sgtitle("simulated reconstructions")

end

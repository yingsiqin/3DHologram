function [HPdisp, IR1disp, IR2disp] = propagate2DepthsIter(fname, z1, z2, ...
                                    slmpitch, lambda, mode, numIter, Hsize)
% % takes an intensity image and computes a 2-depth hologram
% % by forward and backward propagating iteravetily for numIter times

    % read the image
    I=imread(fname);
    I = rgb2gray(I);
    [ylenI, xlenI] = size(I);

    % scale intensity vertically
    intensityramp = (0:1/(size(I,1)-1):1)';
    Iamp = repmat(intensityramp,1,size(I,2));
    I_scaled = im2double(I).*Iamp;
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
    H1 = genHolo1Depth(I1,z1,slmpitch,lambda);

    % second depth layer 
    I2 = zeros(ylenH,xlenH);
    I2(ystart:yend,xstart:xend)=I(:,:);
    I2(:,1:xlenH/2)=0;
    H2 = genHolo1Depth(I2,z2,slmpitch,lambda);

    % sum them together
    H = H1 + H2;

    % encode amplitude in phase
    HP = encodeAmplitude(H, mode);

    if numIter>1
        for i=2:numIter
            % back propagate
            IR1 = reconHoloAt1Depth(HP, z1, slmpitch, lambda);
            IR1J = angle(IR1);
            I1P = I1 .* exp(1j*IR1J);
            IR2 = reconHoloAt1Depth(HP, z2, slmpitch, lambda);
            IR2J = angle(IR2);
            I2P = I2 .* exp(1j*IR2J);

            % forward propagate
            H1P = genHolo1Depth(I1P,z1,slmpitch,lambda);
            H1P = exp(1j*angle(H1P));
            H2P = genHolo1Depth(I2P,z2,slmpitch,lambda);
            H2P = exp(1j*angle(H2P));

            % sum
            HP = H1P + H2P;
        end
    end

    
    % simulate the reconstruction of hologram at two depths
    IR1 = reconHoloAt1Depth(HP, z1, slmpitch, lambda);
    IR1 = IR1(ystart:yend, xstart:xend);
    IR1disp = mat2gray(abs(IR1)); 
    savename = split(fname(1:end-4),"/");
    imname1 = strcat('../data/reconstructions/sim_', string(savename(end)), '_d1-',num2str(z1),'m_', mode, '_iter',int2str(numIter), '.png');
    imwrite(IR1disp, imname1); 
    IR2 = reconHoloAt1Depth(HP, z2, slmpitch, lambda);
    IR2 = IR2(ystart:yend, xstart:xend);
    IR2disp = mat2gray(abs(IR2)); 
    imname2 = strcat('../data/reconstructions/sim_', string(savename(end)), '_d2-',num2str(z2),'m_', mode, '_iter',int2str(numIter), '.png');
    imwrite(IR2disp, imname2);
    
    % save the hologram
    HPdisp = mat2gray(angle(HP));
    Hscale = Hsize(1)/ylenH;
    HPdisp = imresize(HPdisp, Hscale);
    savename = strcat('../data/CGH/3DHologram_', string(savename(end)), '_2d_',mode, '_iter',int2str(numIter), '.png');
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

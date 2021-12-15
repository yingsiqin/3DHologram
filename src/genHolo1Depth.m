function H = genHolo1Depth(I, z, slmpitch, lamda)
% % generates a hologram of I at depth z by 
% % implementing the Fresnel holography theory

    [ylenI,xlenI] = size(I);
    
    % define the Fresnel zone plate at physical positions on the SLM
    [kx,ky] = meshgrid(-xlenI/2:xlenI/2-1,-ylenI/2:ylenI/2-1);
    kx = kx*slmpitch;
    ky = ky*slmpitch;

    % generate the lens phase function
    w = 2*pi/lamda;
    mag = sqrt(kx.^2 + ky.^2 + z^2);
    lpf = exp(1j*w*mag); 
    
    % hologram is a convolution of I and lpf in spatial domain
    % thus it equals their product in the frequency domain
    IF = fft2(I); 
    LPF = fft2(lpf); 
    H = fftshift(ifft2(IF.*LPF));

end
function I = reconHoloAt1Depth(H,z,slmpitch,lambda)    
% % reconstruct the propagated view of hologram at depth z by 
% % implementing the Fresnel holography theory

    [ylenI,xlenI] = size(H);

    % define the Fresnel zone plate at physical positions on the SLM
    [kx,ky] = meshgrid(-xlenI/2:xlenI/2-1,-ylenI/2:ylenI/2-1);
    kx = kx*slmpitch;
    ky = ky*slmpitch;

    % generate the lens phase function
    w = 2*pi/lambda;
    mag = sqrt(kx.^2 + ky.^2 + z^2); 
    lpfconj = exp(-1j*w*mag)./mag;
    IF = fft2(H); 
    LPFCONJ = fft2(lpfconj); 
    I = fftshift(ifft2(IF.*LPFCONJ));

end
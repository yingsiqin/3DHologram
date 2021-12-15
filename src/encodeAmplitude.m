function HP = encodeAmplitude(H, mode)
% % remove the amplitude of the hologram
% % when mode is dpe, use double phase encoding
% % when mode is magrm, remove the amplitude directly
    if mode=='dpe'
        HP = 0.5*exp(1j*(angle(H)-acos(abs(H)))) + ...
            0.5*exp(1j*(angle(H)+acos(abs(H))));
    elseif mode=='amprm'
        HP = cos(angle(H)) + 1j*sin(angle(H));
    end
end
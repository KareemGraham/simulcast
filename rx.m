function [ lc_err, mc_err ] = rx( receive )
%RX Summary of this function goes here
%   Detailed explanation goes here

det = crc.detector('Polynomial', '0x8005', 'ReflectInput', ...
true, 'ReflectRemainder', true);

rec = channelDecoding(fft(receive));

lc = (sign(real(rec))+1)/2;
mc = (sign(imag(rec))+1)/2;

[lcpacket lc_err] = detect(det, lc); 
[mcpacket mc_err] = detect(det, mc);

end


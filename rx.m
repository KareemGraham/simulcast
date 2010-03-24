function [ bmpacket, ampacket,lcnerr, mcnerr ] = rx( receive )
%RX Summary of this function goes here
%   Detailed explanation goes here

% det = crc.detector('Polynomial', '0x8005', 'ReflectInput', ...
% false, 'ReflectRemainder', false);

rec = channelDecoding(fft(receive));

bm = reshape((sign(real(rec))+1)/2,length(rec),1);
am = reshape((sign(imag(rec))+1)/2,length(rec),1);
dec = fec.bchdec(length(bm),length(bm)-100);


%[bmpacker lcnerr] = detect(det, bm); 
%[ampacket mcnerr] = detect(det, am);

[bmpacket, lcnerr] = decode(dec,bm);
[ampacket, mcnerr] = decode(dec,am);

end


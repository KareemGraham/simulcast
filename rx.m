function [ bmp, amp,bmerr, amerr ] = rx( receive )
%RX function simulated receiver in PHY to decode the received packet
%
%           Input: receive - the signal received
%
%           Output: bmpacket - the base message
%                   ampacket - the additional message
%                   bmerr - the error in the base message
%                   amerr - the error in the additional message

n_k = 100;%difference between n and k for the FEC

%decode tghe received message
rec = channelDecoding(fft(receive));

%separate the I and Q channel for base message and additional message
bm = reshape((sign(real(rec))+1)/2,length(rec),1);
am = reshape((sign(imag(rec))+1)/2,length(rec),1);

%generate the FEC decoder
dec = fec.bchdec(length(bm),length(bm)-n_k);

%use the FEC to decode two received packets.
[bmpacket, bmerr] = decode(dec,bm);
[ampacket, amerr] = decode(dec,am);

bmp = boolean(bmpacket);
amp = boolean(ampacket);

end


function [ send ] = tx( mcpacket, lcpacket, offsetAngle)
%TX function simulated the PHY transmission using OFDM
%
%        Input: mcpacket - a more capable packet in binary
%               lcpacket - a less capable packet in binary
%               offsetAngle - the simulcast offset angle in degree
%
%        Output: send - a signal mixed with mcpacket and lcpacket using
%                       non-uniform QPSK. The signal is ready to transmit  
%                      

n = 2^10-1;                     %The length of the packet after FEC
a = 1;                          %Signal Magnitude for output power of 0 dBW
offset = offsetAngle*pi()/180;  %Convert degree to radian

%Setup the FEC encoder for packets, the datalength is 923, and total length
%is 1023 
enc = fec.bchenc(n,length(lcpacket));
lcpacket = reshape(lcpacket,length(lcpacket),1);

%Encode the less capable packet
crclcp = encode(enc,lcpacket);
crcmcp = zeros(length(crclcp),1);

%Encode the more capable packet if the offset angle is non-zero
if offset ~= 0     
     crcmcp = encode(enc,reshape(mcpacket,length(mcpacket),1));     
end;

%Apply channel coding for the two messages and convert the messages to BPSK
crclcp = (2*channelCoding(crclcp)-1);
crcmcp = (2*channelCoding(crcmcp)-1);


%Combine the more capable BPSK packet(cosine) and less capable BPSK 
%packet(sine) to make non-uniform QPSK  
encoded_packet = a*(cos(offset)*(2*crclcp-1) + 1i*sin(offset)*(2*crcmcp-1));

%Perform channel coding on the packets and converter the signal to OFDM
%signal
send = ifft(encoded_packet);

end


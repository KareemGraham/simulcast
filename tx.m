function [ send ] = tx( mcpacket, lcpacket, offsetAngle)
%TX Summary of this function goes here
%   Detailed explanation goes here

a = 1; %Signal Magnitude
offset = offsetAngle*pi()/180; %convert degree to radian

%gnereate a CRC objecy for 16-CRC error checking code
%gen = crc.generator('Polynomial', '0x8005', ...
%'ReflectInput', false, 'ReflectRemainder', false);

%Assumme packet length
enc = fec.bchenc(2^10-1,length(lcpacket));

lcpacket = reshape(lcpacket,length(lcpacket),1);

%crclcp = generate(gen,encode(enc,lcpacket));
crclcp = encode(enc,lcpacket);

crcmcp = zeros(length(crclcp),1);

if offset ~= 0
%    crcmcp = generate(gen, encode(enc, mcpacket));
     crcmcp = encode(enc,reshape(mcpacket,length(mcpacket),1));
end;

%combine the more capable(cosine) and less capable packets(sine), 
encoded_packet = a*(cos(offset)*(2*crclcp-1) + 1i*sin(offset)*(2*crcmcp-1));

%Perform channel coding on the packets and converter the signal to OFDM
%signal
send = ifft(channelCoding(encoded_packet));


end


function [ send ] = tx( mcpacket, lcpacket, offsetAngle)
%TX Summary of this function goes here
%   Detailed explanation goes here

a = 1; %Signal Magnitude
offset = offsetAngle*pi()/180; %convert degree to radian
%gnereate a CRC objecy for 16-CRC error checking code
gen = crc.generator('Polynomial', '0x8005', ...
'ReflectInput', true, 'ReflectRemainder', true);

crclcp = generate(gen,lcpacket);

crcmcp = zeros(length(crclcp),1);

if offset ~= 0
    crcmcp = generate(gen, mcpacket);
end;

%combine the more capable(cosine) and less capable packets(sine), 
encoded_packet = a*(cos(offset)*(2*crclcp-1) + 1i*sin(offset)*(2*crcmcp-1));

%Perform channel coding on the packets and converter the signal to OFDM
%signal
send = ifft(channelCoding(encoded_packet));


end


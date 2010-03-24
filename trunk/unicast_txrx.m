function [ err ] = unicast_txrx( packet, dist )
%UNICAST Summary of this function goes here
%   Detailed explanation goes here

send = tx(0,packet,0);
rec = channelAWGN(send,dist);
[lc,mc,err,me] = rx(rec);

%[num, rat]= symerr(packet,reshape(lc,1,length(packet)))

end


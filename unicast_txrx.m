function [ lcpacket, err ] = unicast_txrx( packet, dist )
%UNICAST this function simulated the unicasting tranffic and multicasting 
%        traffic in the wireless network and return the error when reception 
%        fail.
%
%        Inputs : packet - the list of packets for unicast transmission
%                 dist - the list of distants in meter related to each node
%
%        Output : err - return 0 when there is no error
%                       return 1-10 when there is 1-10 bits error but
%                       corrected.
%                       return -1 when error is > 10 bits and fail


err = zeros(1,length(dist));

for i = 1:length(err)
    send = tx(0,packet(i,:),0);
    rec = channelAWGN(send,dist(i));
    [lcpacket(i,:),mc,err(i),mec] = rx(rec);
end

end


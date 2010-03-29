function [ out_packet ] = channelCoding( in_packet)
%CHANNELCODING performs channel coding to match the
%transmission rate in 802.11 stanard
%
%In 802.11, channel BW = 11MHz and Data R = 1Mbps for BPSK;
%therefore, symbol duration to bit ratio is 11

symbolPeriod = 11;

%allocating the memory for the coding after channel coding
out_packet = zeros(symbolPeriod,length(in_packet));

%add channel coding redundancy to the packet
for i=1:length(in_packet)
   out_packet(:,i)=in_packet(i);    
end
    
%re-format the packet to have a single row
out_packet=reshape(out_packet,1,symbolPeriod*length(in_packet));

end


function [ out_packet ] = channelDecoding( in_packet)
%CHANNELDECODING perform channel decoding (averaging symbol)
%
%
%In 802.11, channel BW = 11MHz and Data R = 1Mbps for BPSK;
%therefore, symbol duration is 11

symbolPeriod = 11;

%allocating memory for the decoded packet
out_packet=zeros(1,length(in_packet)/symbolPeriod);
%re-format the incoming packet
in_packet=reshape(in_packet,symbolPeriod,length(out_packet));
%average each symbol
out_packet = sum(in_packet,1)/symbolPeriod; 

end


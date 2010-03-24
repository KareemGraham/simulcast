function [ lcbm_err, lcam_err, mcbm_err, mcam_err] = simulcast_txrx( mcdist, lcdist, angle )
%SIMULCAST_TXRX Summary of this function goes here
%        traffic in the wireless network and return the error when reception 
%        fail.
%
%        Inputs : 
%                mcdist - the list of distants in meter related to more capable node
%
%        Output : err - return 0 when there is no error
%                       return 1-10 when there is 1-10 bits error but
%                       corrected.
%                       return -1 when error is > 10 bits and fail

packetSize = 923;

mcpacket = round(rand(1, packetSize));
lcpacket = round(rand(1, packetSize));

mcbm_err = zeros(1,length(mcdist));
mcam_err = zeros(1,length(mcdist));
lcbm_err = zeros(1,length(mcdist));
lcam_err = zeros(1,length(mcdist));

for i=1:length(mcdist)
    send = tx(mcpacket,lcpacket,angle);

    mc_rec = channelAWGN(send,mcdist);
    lc_rec = channelAWGN(send,lcdist);

    [bm, mc, mcbm_err(i), mcam_err(i)]=rx(mc_rec);
    [lc, mc, lcbm_err(i), lcam_err(i)]=rx(lc_rec);
end

end


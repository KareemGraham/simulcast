function [ lcbm_err, lcam_err, mcbm_err, mcam_err] = simulcast_txrx( mcpacket, mcdist, lcpacket, lcdist, angle )
%SIMULCAST_TXRX Summary of this function goes here
%   Detailed explanation goes here

send = tx(mcpacket,lcpacket,angle);

mc_rec = channelAWGN(send,mcdist);
lc_rec = channelAWGN(send,lcdist);

[bm, mc, mcbm_err, mcam_err]=rx(mc_rec);
[lc, mc, lcbm_err, lcam_err]=rx(lc_rec);


end


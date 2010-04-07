function [ lcbm, lcam, mcbm, mcam, lcbm_err, lcam_err, mcbm_err, mcam_err] = simulcast_txrx( mcpacket, lcpacket, mcdist, lcdist, angle )
%SIMULCAST_TXRX the function simulated simulcast traffic flow for uni- and
%        multi-cast in the wireless network and return the error when  
%        message recovery is fail.
%
%        Inputs : mcpaket - the packets list for more capable links
%                 lcpacket - the packets list for less capable links
%                 mcdist* - the list of distants in meter related to more
%                          capable nodes.
%                 lcdist* - the of distants in meter related to less capable
%                          nodes.
%                 angle - simulcasting angle in degree                 
%
%        Output : err - return 0 when there is no error
%                       return 1-10 when there is 1-10 bits error but
%                       corrected.
%                       return -1 when error is > 10 bits and fail to
%                       recover the message
%
%                 lcbm_err - error to recover base message for less-capable
%                            node.
%                 lcam_err - error to recover additional message for
%                            less-capable node.
%                 mcbm_err - error to recover base message for more-capable
%                            node.
%                 mcam_err - error to recover additional message for
%                            more-capable node.
%
%                   lcbm: base message recovered by a less capable node.
%                   lcam: additional message recovered by a less capable
%                         node.
%                   mcbm: base message recovered by a more capable node.
%                   mcam: additional message recovered by a more capable
%                         node.
%
%         *Note: the list size in mcdist must be equal to lcdist and mcdist
%                must be less than lcdist
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This code includes multicast; in case of unicast only, not need to use
%this one.
%
%mcbm_err = zeros(1,length(mcdist));
%mcam_err = zeros(1,length(mcdist));
%lcbm_err = zeros(1,length(mcdist));
%lcam_err = zeros(1,length(mcdist));
% 
% for i=1:length(mcdist)
%     send = tx(mcpacket(i,:),lcpacket(i,:),angle);
% 
%     mc_rec = channelAWGN(send,mcdist(i));
%     lc_rec = channelAWGN(send,lcdist(i));
% 
%     [mcbm(i,:), mcam(i,:), mcbm_err(i), mcam_err(i)]=rx(mc_rec);
%     [lcbm(i,:), lcam(i,:), lcbm_err(i), lcam_err(i)]=rx(lc_rec);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

send = tx(mcpacket,lcpacket,angle);

mc_rec = channelAWGN(send,mcdist);
lc_rec = channelAWGN(send,lcdist);

[mcbm, mcam]=rx(mc_rec);
[lcbm, lcam]=rx(lc_rec);

lcbm_err=0;lcam_err=0; mcbm_err=0; mcam_err=0;

[MCNum, MRate]=symerr(double(mcpacket),mcam);
[LCNum, LRate]=symerr(double(lcpacket),lcbm);

if MCNum > 10
   mcam_err = -1; 
end

if LCNum > 10
    lcbm_err = -1;
end

end


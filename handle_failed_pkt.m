function [node,txBuff] = handle_failed_pkt(node,txBuff)
% Check the number of retries, if = Rmax, drop packet. Else, increment
% the number of retries, change the state of the packet
global Rmax Pkt Ready
Retries = txBuff.Rtr;
if(Retries == Rmax)
    % Number of retries reached, drop the packet
    txBuff = Pkt;
elseif(Retries < Rmax)
    % Packet state is either TxF or Colli. Change it to Ready for next
    % attempt
    txBuff.State = Ready; 
    txBuff.Rtr = Retries + 1;
else
    disp('Error: Retries must not exceed Rmax!');
%     dbgstop;
end
end
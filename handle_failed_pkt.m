function [node,txBuff] = handle_failed_pkt(node,txBuff)
% Check the number of retries, if = Rmax, drop packet. Else, increment
% the number of retries, change the state of the node
global Rmax Pkt
Retries = txBuff.Rtr;
if(Retries == Rmax)
    % Number of retries reached, drop the packet
    txBuff = Pkt;
    % TODO: Change the state of the node here
elseif(Retries < Rmax)
    txBuff.Rtr = Retries + 1;
    % TODO: Change the state of the node here to next CW
else
    disp('Error: Retries must not exceed Rmax!');
%     dbgstop;
end
end
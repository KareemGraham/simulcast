function [SrcNode,DesNode,SrcBuff] = handle_next_des_pkt(SrcNode,DesNode,SrcBuff,links)
% Process the received packet's Tsrc, Tdes and Rtr fields for next hop
global Pkt Fwd Ready
SrcBuff.Tsrc = SrcBuff.Tdes;
SrcBuff.Tdes = DesNode.ID;
SrcBuff.Type = Fwd;
SrcBuff.State = Ready;
SrcBuff.Rtr = 0;
% Schedule the packet in one of the Fwd queues of next hop node
if (links(SrcBuff.Tsrc, SrcBuff.Tdes) > 0)
    % Can be put on the More Capable Link Fwd Queue
    len = DesNode.McFQ.len;
    Des.McFQ.Pkts(len+1) = SrcBuff;
    DesNode.McFQ.len = len + 1;
elseif(links(SrcBuff.Tsrc, SrcBuff.Tdes) < 0)
    % Can be put on the Less Capable Link Fwd Queue
    len = DesNode.LcFQ.len;
    Des.LcFQ.Pkts(len+1) = SrcBuff;
    DesNode.LcFQ.len = len + 1;
else
    % if this field of link is 0, there is no link between these two nodes
    disp('Error: No link between the nodes');
%     dbstop;
end
% Return the cleared packet to Source Node Buffer
SrcBuff = Pkt;
% Increment the node link counter
SrcNode.LinkCount = SrcNode.LinkCount + 1;
end
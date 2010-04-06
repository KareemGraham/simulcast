function [node,clear_pkt] = handle_final_des_pkt(node)
% Just increments both the counters and clears the packet
global Pkt
node.LinkCount = node.LinkCount + 1;
node.E2ECount = node.E2ECount + 1;
clear_pkt = Pkt;
end
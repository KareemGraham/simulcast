function [d] = topo_dist(i, j, node);
% return distance between two nodes i and j
n=length(node);
d = 0;
if i<=0 | i>n, return; end
if j<=0 | j>n, return; end
d = sqrt((node(i, 1) - node(j, 1))^2 + (node(i, 2) - node(j, 2))^2);

return;

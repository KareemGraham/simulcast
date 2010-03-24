function [ nodes ] = nodes_with_n_hops(links, x, n)
% finds nodes with n hops from x
%   Detailed explanation goes here
[d,~,~] = bfs(links,x,0);
nodes = find(d == n);
end


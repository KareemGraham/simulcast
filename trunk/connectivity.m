function [ links ] = connectivity( node, Dmax )
%connectivity - returns matrix of connectivity of nodes
%   Detailed explanation goes here
global node;
d = zeros(length(node));
for x = 1:length(node)    
    for y = 1:length(node)
        links(x,y) = topo_dist(x,y);
        links(x,y) = links(x,y)*(links(x,y) < Dmax);
    end
end


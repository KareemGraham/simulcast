function [ mhop ] = max_hops( links )
%finds maximum hops from a node
%   Detailed explanation goes here
for x=1:length(links)
[d,~,~] = bfs(links,x,0);
mhop(x) = max(d);
end
end


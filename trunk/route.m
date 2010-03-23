function [ route ] = route( src, dst, links )
%route - finds route from src to dst from links
%   Detailed explanation goes here
[d,~,pred] = bfs(links,dst,src);
route = zeros(d(src),1);
route(1) = src;
for x=2:d(src)+1
    route(x) = pred(route(x-1));
end
end

